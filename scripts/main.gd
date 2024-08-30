extends Node2D


# ////////////////////
# Export Variables
# ////////////////////
@export var player_start_position_in_tiles: Vector2 = Vector2(3, 2)
@export var tile_size: int = 32

# ////////////////////
# Private Variables
# ////////////////////
var _is_showing_player_pov: bool = false

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
	

func _process(delta):
	_check_and_handle_pov_button_pressed()
	

# ////////////////////
# Private Functions
# ////////////////////
func _check_and_handle_pov_button_pressed() -> void:
	if Input.is_action_just_pressed("toggle_player_pov"):
		_is_showing_player_pov = not _is_showing_player_pov
		_update_scene_visiblities()
	

func _update_scene_visiblities() -> void:
	%WorldTileMap.visible = not _is_showing_player_pov
	%Player.visible = not _is_showing_player_pov
	
	%PlayerPov.visible = _is_showing_player_pov
	
