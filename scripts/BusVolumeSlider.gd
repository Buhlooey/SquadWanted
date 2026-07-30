extends VSlider

@export var busName: String
@onready var bus: FmodBus = FmodServer.get_bus("bus:/" + busName)

@onready var nameText: RichTextLabel = $SliderName
@onready var valueText: RichTextLabel = $SliderValue

func _ready():
	# FmodServer.wait_for_all_loads()
	nameText.text = busName
	value = bus.get_volume()

func _on_value_changed(newValue: float) -> void:
	bus.set_volume(newValue)
	valueText.text = str(int(newValue * 100), "%")
