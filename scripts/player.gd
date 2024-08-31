class_name Player extends Area2D

# ////////////////////
# Exports
# ////////////////////
@export var step_length: int = 32
@export var tween_time_seconds: float = 0.1

# ////////////////////
# Private Variables
# ////////////////////
var _player_face_direction: Vector2 = Vector2.DOWN
var _is_moving: bool = false
var _is_rotating: bool = false
var _can_move_forwards: bool = true
var _can_move_backwards: bool = true
var _can_rotate: bool = true

# ////////////////////
# Virtual Functions
# ////////////////////
func _ready():
	GameEvents.player_interacted.connect(_on_player_interacted)
	GameEvents.player_picked_up_object.connect(_on_player_picked_up_object)
	

func _unhandled_input(event):
	if not _is_moving and (event.is_action_pressed("move_up") or event.is_action_pressed("move_down")):
		_handle_forward_backward_movement(event)
	if not _is_rotating and (event.is_action_pressed("move_left") or event.is_action_pressed("move_right")):
		_handle_left_right_turning(event)
	

# ////////////////////
# Private Functions
# ////////////////////
func _handle_forward_backward_movement(event: InputEvent) -> void:
	var movement_direction: Vector2 = Vector2.ZERO
	
	if event.is_action_pressed("move_up") and _can_move_forwards:
		movement_direction = _player_face_direction
	elif event.is_action_pressed("move_down") and _can_move_backwards:
		movement_direction = -_player_face_direction
	
	if movement_direction == Vector2.ZERO:
		return # Exit Early -- no movement will happen
	
	var new_position: Vector2 = self.position + movement_direction * step_length
	var tween: Tween = self.create_tween()
	
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "position", new_position, tween_time_seconds)
	tween.finished.connect(_on_forward_backward_movement_finished)
	
	_is_moving = true
	
	GameEvents.player_moved.emit(movement_direction)
	

func _on_forward_backward_movement_finished() -> void:
	_is_moving = false
	_check_collision_ray_casts()
	

func _handle_left_right_turning(event: InputEvent) -> void:
	var player_rotation_degrees: float = 0.0
	
	if event.is_action_pressed("move_left") and _can_rotate:
		player_rotation_degrees = -90.0
		if _player_face_direction == Vector2.UP:
			_player_face_direction = Vector2.LEFT
		elif _player_face_direction == Vector2.LEFT:
			_player_face_direction = Vector2.DOWN
		elif _player_face_direction == Vector2.DOWN:
			_player_face_direction = Vector2.RIGHT
		else:
			_player_face_direction = Vector2.UP
	elif event.is_action_pressed("move_right") and _can_rotate:
		player_rotation_degrees = 90.0
		if _player_face_direction == Vector2.UP:
			_player_face_direction = Vector2.RIGHT
		elif _player_face_direction == Vector2.RIGHT:
			_player_face_direction = Vector2.DOWN
		elif _player_face_direction == Vector2.DOWN:
			_player_face_direction = Vector2.LEFT
		else:
			_player_face_direction = Vector2.UP
	
	if player_rotation_degrees == 0:
		return # Exit Early -- no rotation will happen
	
	var new_player_rotation: float = self.rotation + deg_to_rad(player_rotation_degrees)
	var tween: Tween = self.create_tween()
	
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "rotation", new_player_rotation, tween_time_seconds)
	tween.finished.connect(_on_rotation_finished)
	
	_is_rotating = true
	
	GameEvents.player_turned.emit(_player_face_direction)
	

func _on_rotation_finished() -> void:
	_is_rotating = false
	_check_collision_ray_casts()
	

func _check_collision_ray_casts() -> void:
	_can_move_forwards = not %ForwardsCollisionRayCast.is_colliding()
	_can_move_backwards = not %BackwardsCollisionRayCast.is_colliding()
	

func _on_player_interacted(_data: InteractableData) -> void:
	_can_move_backwards = false
	_can_move_forwards = false
	_can_rotate = false
	

func _on_player_picked_up_object() -> void:
	_check_collision_ray_casts()
	_can_rotate = true
