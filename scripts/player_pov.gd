extends Node2D

# ////////////////////
# Exports
# ////////////////////
@export var current_tile_position: Vector2 = Vector2.ZERO
@export var current_player_face_direction: Vector2 = Vector2.UP

# ////////////////////
# Virtual Functions
# ////////////////////
func _ready():
	GameEvents.player_moved.connect(_on_player_moved)
	GameEvents.player_turned.connect(_on_player_turned)
	

func _process(delta):
	var format_string = "%s, %s"
	var actual_string = format_string % [current_tile_position.x, current_tile_position.y]
	
	%Label.text = actual_string
	
	var direction_text = ""
	if current_player_face_direction == Vector2.UP:
		direction_text = "UP"
	elif current_player_face_direction == Vector2.LEFT:
		direction_text = "LEFT"
	elif current_player_face_direction == Vector2.DOWN:
		direction_text = "DOWN"
	else:
		direction_text = "RIGHT"
	
	%Label2.text = direction_text
	

# ////////////////////
# Private Functions
# ////////////////////
func _on_player_moved(direction: Vector2) -> void:
	current_tile_position += direction
	

func _on_player_turned(face_direction: Vector2) -> void:
	current_player_face_direction = face_direction
	
