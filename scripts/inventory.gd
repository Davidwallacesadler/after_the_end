extends Node2D

# ////////////////////
# Private Variables
# ////////////////////
var _match_count: int = 0
var _fuel_count: int = 0

var _item_list: Array = []
var _inventory_items: Array:
	get:
		return _item_list
	set(value):
		_item_list = value
		_update_item_list_ui()
		
var _current_item_to_add: InteractableData

# ////////////////////
# Virtual Functions
# ////////////////////
func _ready():
	GameEvents.player_interacted.connect(_on_player_interacted)
	GameEvents.player_picked_up_object.connect(_on_player_picked_up_object)

# ////////////////////
# Private Functions
# ////////////////////
func _on_player_interacted(data: InteractableData) -> void:
	_current_item_to_add = data

func _on_player_picked_up_object() -> void:
	# TODO: Check inventory type and add to the appropriate list -- just update count of items
	_inventory_items = _inventory_items + [_current_item_to_add]
	_current_item_to_add = null

func _update_item_list_ui() -> void:
	%ItemList.clear()
	for item in _inventory_items:
		%ItemList.add_item(item.name)
