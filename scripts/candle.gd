extends Node2D

# ////////////////////
# Exports
# ////////////////////
@export var is_lit: bool = false
@export var type: CandleType = CandleType.TEA_LIGHT
@export var flicker_time_seconds: float = 1
@export var flicker_energy_drain: float = 0.2

# ////////////////////
# Preloads (Resources)
# ////////////////////
var _candle_light_sound = preload("res://assets/match_strike.wav")
var _candle_extinguish_sound = preload("res://assets/blow_out_candle.wav")
var _default_sprite = preload("res://assets/candle.png")
var _lit_sprite = preload("res://assets/candle_lit.png")

# ////////////////////
# Private Variables
# ////////////////////
var _should_light_on_interact: bool = false
var _initial_light_energy: float = 1
var _is_flickering: bool = false

# ////////////////////
# Virtual Functions
# ////////////////////
func _ready():
	_setup_for_candle_type()
	_update_candle_light_enabled_state()
	
	%InteractionArea.area_entered.connect(_on_interaction_area_entered)
	%InteractionArea.area_exited.connect(_on_interaction_area_exited)
	
	%LightArea.area_entered.connect(_on_light_area_entered)
	%LightArea.area_exited.connect(_on_light_area_exited)
	

func _process(_delta):
	_handle_character_interaction()
	_handle_candle_flicker()

# ////////////////////
# Private Functions
# ////////////////////
func _setup_for_candle_type() -> void:
	var light_energy: float
	var light_texture_scale: float
	var light_area_shape_size: Vector2
	
	match type:
		CandleType.TEA_LIGHT:
			light_energy = 0.5
			light_texture_scale = 0.25
			light_area_shape_size = Vector2(32, 32)
		CandleType.VOTIVE:
			light_energy = 0.6
			light_texture_scale = 0.5
			light_area_shape_size = Vector2(96, 96)
		CandleType.TAPER:
			light_energy = 0.7
			light_texture_scale = 0.6
			light_area_shape_size = Vector2(96, 96)
		CandleType.PILLAR:
			light_energy = 0.8
			light_texture_scale = 0.9
			light_area_shape_size = Vector2(128, 128)
	
	%CandleLight.energy = light_energy
	%CandleLight.texture_scale = light_texture_scale
	
	var new_light_area_shape = RectangleShape2D.new()
	new_light_area_shape.size = light_area_shape_size
	
	%LightArea/LightAreaShape.shape = new_light_area_shape
	_initial_light_energy = light_energy
	

func _update_candle_light_enabled_state() -> void:
	%CandleLight.enabled = is_lit
	if is_lit:
		%CandleSprite.texture = _lit_sprite
	else:
		%CandleSprite.texture = _default_sprite
	
	if is_lit:
		GameEvents.player_entered_light.emit()
	
	

func _on_interaction_area_entered(_area: Area2D) -> void:
	_should_light_on_interact = true
	

func _on_interaction_area_exited(_area: Area2D) -> void:
	_should_light_on_interact = false
	

func _on_light_area_entered(_area: Area2D) -> void:
	if is_lit:
		GameEvents.player_entered_light.emit()
	

func _on_light_area_exited(_area: Area2D) -> void:
	GameEvents.player_entered_dark.emit()
	

func _handle_character_interaction() -> void:
	if _should_light_on_interact and Input.is_action_just_pressed("interact"):
		is_lit = not is_lit
		
		if is_lit:
			%AudioPlayer.stream = _candle_light_sound
		else:
			%AudioPlayer.stream = _candle_extinguish_sound
		%AudioPlayer.play()
		
		_update_candle_light_enabled_state()
	

func _handle_candle_flicker() -> void:
	if is_lit and not _is_flickering:
		var new_light_energy: float
		if %CandleLight.energy == _initial_light_energy:
			new_light_energy = _initial_light_energy - flicker_energy_drain
		else:
			new_light_energy = _initial_light_energy
		
		var tween: Tween = create_tween()
		tween.tween_property(%CandleLight, "energy", new_light_energy, flicker_time_seconds)
		tween.finished.connect(_handle_candle_stop_flicker)
		
		_is_flickering = true
	

func _handle_candle_stop_flicker() -> void:
	_is_flickering = false
	

# ////////////////////
# Nested Types
# ////////////////////
enum CandleType {
	TEA_LIGHT, VOTIVE, TAPER, PILLAR
}
