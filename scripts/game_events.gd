extends Node

# ////////////////////
# Signals
# ////////////////////
signal player_moved(direction: Vector2)
signal player_turned(direction: Vector2)
signal player_interacted(data: InteractableData)
signal player_picked_up_object()
