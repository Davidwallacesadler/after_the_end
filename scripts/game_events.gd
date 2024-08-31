extends Node

# ////////////////////
# Signals
# ////////////////////
signal player_moved(direction: Vector2)
signal player_turned(direction: Vector2)
signal player_interacted(data: InteractableData)
signal player_picked_up_object()
signal player_entered_light()
signal player_entered_dark()
signal player_health_changed(value: float)
signal player_fuel_time_changed(value: int)
