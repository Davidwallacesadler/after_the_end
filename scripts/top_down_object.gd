extends Node2D

# ////////////////////
# Exports
# ////////////////////
@export var interactable_data: InteractableData

# ////////////////////
# Private Variables
# ////////////////////
var _has_area_entered_interaction_area: bool = false

# ////////////////////
# Virtual Functions
# ////////////////////
func _ready():
	%MainSprite.texture = interactable_data.image
	%InteractionArea.area_entered.connect(_on_area_entered_interaction_area)
	%InteractionArea.area_exited.connect(_on_area_exited_interaction_area)
	GameEvents.player_picked_up_object.connect(_on_player_picked_up_object)
	

func _process(delta):
	if Input.is_action_just_pressed("interact") and _has_area_entered_interaction_area:
		GameEvents.player_interacted.emit(interactable_data)

# ////////////////////
# Private Functions
# ////////////////////
func _on_area_entered_interaction_area(body: Node2D) -> void:
	_has_area_entered_interaction_area = true
	

func _on_area_exited_interaction_area(body: Node2D) -> void:
	_has_area_entered_interaction_area = false
	

func _on_player_picked_up_object() -> void:
	if _has_area_entered_interaction_area:
		queue_free()
