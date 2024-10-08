extends Node2D

# ////////////////////
# Export Variables
# ////////////////////
@export var player_start_position_in_tiles: Vector2 = Vector2(2, 2)
@export var player_start_direction: Vector2 = Vector2.DOWN
@export var tile_size: int = 32

# ////////////////////
# Private Variables
# ////////////////////
var _is_showing_player_pov: bool = false
var _darkness_color: Color = Color(0.004, 0.145, 0.204)

# ////////////////////
# Virtual Functions
# ////////////////////
func _ready():
	var player_start_position = Vector2(tile_size / 2, tile_size / 2)
	
	if player_start_position_in_tiles.x > 1:
		player_start_position.x += tile_size * (player_start_position_in_tiles.x - 1)
	if player_start_position_in_tiles.y > 1:
		player_start_position.y += tile_size * (player_start_position_in_tiles.y - 1)
	
	%Player.position = player_start_position
	%PlayerPov.current_tile_position = player_start_position_in_tiles
	%WorldDarkness.color = _darkness_color
	
	GameEvents.player_interacted.connect(_on_player_interacted)
	GameEvents.player_picked_up_object.connect(_on_player_picked_up_object)
	GameEvents.player_health_changed.connect(_on_player_health_changed)
	GameEvents.player_fuel_time_changed.connect(_on_player_fuel_time_changed)
	

func _process(delta):
	_check_and_handle_pov_button_pressed()
	_check_and_handle_open_inventory_pressed()
	

# ////////////////////
# Private Functions
# ////////////////////
func _check_and_handle_pov_button_pressed() -> void:
	if Input.is_action_just_pressed("toggle_player_pov"):
		_is_showing_player_pov = not _is_showing_player_pov
		_update_scene_visiblities()
	

func _check_and_handle_open_inventory_pressed() -> void:
	if Input.is_action_just_pressed("open_inventory"):
		%Inventory.visible = not %Inventory.visible
	

func _update_scene_visiblities() -> void:
	%World.visible = not _is_showing_player_pov
	%PlayerPov.visible = _is_showing_player_pov
	

func _on_player_interacted(data: InteractableData) -> void:
	_is_showing_player_pov = true
	_update_scene_visiblities()
	
	%MainAudioPlayer.stream = data.interaction_sound
	%MainAudioPlayer.play()
	

func _on_player_picked_up_object() -> void:
	_is_showing_player_pov = false
	_update_scene_visiblities()
	

func _on_player_health_changed(value: float) -> void:
	var string = "%s"
	var real_string = string % value
	%EverythingButWorld/MainUI/HealthValueLabel.text = real_string

func _on_player_fuel_time_changed(value: int) -> void:
	var string = "%s"
	var real_string = string % value
	%EverythingButWorld/MainUI/FuelValueLabel.text = real_string
