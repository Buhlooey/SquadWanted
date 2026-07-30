extends VSlider

@export var busName: String
@onready var bus: FmodBus = FmodServer.get_bus("bus:/" + busName)

func _ready():
	# FmodServer.wait_for_all_loads()
	value = bus.get_volume()

func _on_value_changed(newValue: float) -> void:
	bus.set_volume(newValue)
