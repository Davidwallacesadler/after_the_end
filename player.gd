extends Area2D

# ////////////////////
# Exports
# ////////////////////
@export var step_length: int = 64
@export var tween_time_seconds: float = 0.1

# ////////////////////
# Private Variables
# ////////////////////
var _player_face_direction: Vector2 = Vector2.UP
var _is_moving: bool = false
var _is_rotating: bool = false

# ////////////////////
# Virtual Functions
# ////////////////////
func _process(delta):
	pass
	

func _unhandled_input(event):
	if not _is_moving and (event.is_action_pressed("move_up") or event.is_action_pressed("move_down")):
		_handle_forward_backward_movement(event)
	if not _is_rotating and (event.is_action_pressed("move_left") or event.is_action_pressed("move_right")):
		_handle_left_right_turning(event)
	

# ////////////////////
# Private Functions
# ////////////////////
func _handle_forward_backward_movement(event: InputEvent) -> void:
	var movement_direction = Vector2.ZERO
	
	if event.is_action_pressed("move_up"):
		movement_direction = _player_face_direction
	else:
		movement_direction = -_player_face_direction
		
	
	var new_position = self.position + movement_direction * step_length
	var tween = self.create_tween()
	
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "position", new_position, tween_time_seconds)
	tween.finished.connect(_on_forward_backward_movement_finished)
	
	_is_moving = true
	

func _on_forward_backward_movement_finished() -> void:
	_is_moving = false
	

func _handle_left_right_turning(event: InputEvent) -> void:
	var player_rotation_degrees: float = 0.0
	
	if event.is_action_pressed("move_left"):
		player_rotation_degrees = -90.0
		if _player_face_direction == Vector2.UP:
			_player_face_direction = Vector2.LEFT
		elif _player_face_direction == Vector2.LEFT:
			_player_face_direction = Vector2.DOWN
		elif _player_face_direction == Vector2.DOWN:
			_player_face_direction = Vector2.RIGHT
		else:
			_player_face_direction = Vector2.UP
	else:
		player_rotation_degrees = 90.0
		if _player_face_direction == Vector2.UP:
			_player_face_direction = Vector2.RIGHT
		elif _player_face_direction == Vector2.RIGHT:
			_player_face_direction = Vector2.DOWN
		elif _player_face_direction == Vector2.DOWN:
			_player_face_direction = Vector2.LEFT
		else:
			_player_face_direction = Vector2.UP
	
	var new_player_rotation: float = self.rotation + deg_to_rad(player_rotation_degrees)
	var tween = self.create_tween()
	
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "rotation", new_player_rotation, tween_time_seconds)
	tween.finished.connect(_on_rotation_finished)
	
	_is_rotating = true
	

func _on_rotation_finished() -> void:
	_is_rotating = false
	
