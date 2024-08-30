extends Node2D

# ////////////////////
# Exports
# ////////////////////
@export var is_lit: bool = false
@export var type: CandleType = CandleType.TEA_LIGHT

# ////////////////////
# Private Variables
# ////////////////////
var _should_light_on_interact: bool = false

# ////////////////////
# Virtual Functions
# ////////////////////
func _ready():
	_setup_for_candle_type()
	_update_candle_light_enabled_state()
	
	%InteractionArea.area_entered.connect(_on_interaction_area_entered)
	%InteractionArea.area_exited.connect(_on_interaction_area_exited)


func _process(_delta):
	if _should_light_on_interact and Input.is_action_just_pressed("interact"):
		_on_player_interacted()

# ////////////////////
# Private Functions
# ////////////////////
func _setup_for_candle_type() -> void:
	var light_energy: float
	var light_texture_scale: float
	
	match type:
		CandleType.TEA_LIGHT:
			light_energy = 0.5
			light_texture_scale = 0.25
		CandleType.VOTIVE:
			light_energy = 0.6
			light_texture_scale = 0.5
		CandleType.TAPER:
			light_energy = 0.7
			light_texture_scale = 0.6
		CandleType.PILLAR:
			light_energy = 0.8
			light_texture_scale = 0.9
	
	%CandleLight.energy = light_energy
	%CandleLight.texture_scale = light_texture_scale
	

func _update_candle_light_enabled_state() -> void:
	%CandleLight.enabled = is_lit

func _on_interaction_area_entered(_area: Area2D) -> void:
	_should_light_on_interact = true
	

func _on_interaction_area_exited(_area: Area2D) -> void:
	_should_light_on_interact = false
	

func _on_player_interacted() -> void:
	if _should_light_on_interact:
		is_lit = not is_lit
		_update_candle_light_enabled_state()
	

# ////////////////////
# Nested Types
# ////////////////////
enum CandleType {
	TEA_LIGHT, VOTIVE, TAPER, PILLAR
}
