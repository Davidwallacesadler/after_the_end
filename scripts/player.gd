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

var _health: float = 100
var _is_in_light: bool = false
var _is_taking_damage: bool = false

var _lantern_seconds_left: int = 15
var _is_lantern_on: bool = true

var _damage_amount: float:
	get:
		if _is_in_light or (_is_lantern_on and _lantern_seconds_left > 0):
			return -2.5
		else:
			return 2.5

# ////////////////////
# Virtual Functions
# ////////////////////
func _ready():
	GameEvents.player_interacted.connect(_on_player_interacted)
	GameEvents.player_picked_up_object.connect(_on_player_picked_up_object)
	GameEvents.player_entered_light.connect(_on_player_entered_light)
	GameEvents.player_entered_dark.connect(_on_player_entered_dark)
	
	%HealthChangeTimer.timeout.connect(_handle_player_damage)
	%LanternUsageTimer.timeout.connect(_handle_lantern_usage_update)

func _unhandled_input(event):
	if not _is_moving and (event.is_action_pressed("move_up") or event.is_action_pressed("move_down")):
		_handle_forward_backward_movement(event)
	if not _is_rotating and (event.is_action_pressed("move_left") or event.is_action_pressed("move_right")):
		_handle_left_right_turning(event)
	if event.is_action_pressed("toggle_lantern"):
		_handle_lantern_toggle()
	

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

func _on_player_entered_light() -> void:
	_is_in_light = true
	

func _on_player_entered_dark() -> void:
	_is_in_light = false
	

func _handle_player_damage() -> void:
	var new_player_health: float = _health - _damage_amount
	
	if new_player_health < 0 or new_player_health > 100:
		return
	
	_health = new_player_health
	GameEvents.player_health_changed.emit(_health)
	

func _handle_lantern_usage_update() -> void:
	if not _is_lantern_on:
		return
	
	
	var new_time_left = _lantern_seconds_left - 1
	
	if new_time_left < 0:
		return
	
	_lantern_seconds_left = new_time_left
	GameEvents.player_fuel_time_changed.emit(_lantern_seconds_left)
	if _lantern_seconds_left == 0:
		%LanternLight.energy = 0.25
		%LanternLight.texture_scale = 0.5
		_is_lantern_on = false
		# %LanternLight.energy = 0 # Makes cool black blob
	

func _handle_lantern_toggle() -> void:
	if not _is_lantern_on and _lantern_seconds_left == 0:
		return
	
	_is_lantern_on = not _is_lantern_on
	
	if _is_lantern_on and _lantern_seconds_left > 0:
		%LanternLight.energy = 1
		%LanternLight.texture_scale = 1
	else:
		%LanternLight.energy = 0.25
		%LanternLight.texture_scale = 0.5
