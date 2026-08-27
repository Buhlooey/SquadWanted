extends VBoxContainer

@export var busName: String
@onready var bus: FmodBus = FmodServer.get_bus("bus:/" + busName)

@onready var slider: VSlider = $Slider
@onready var nameText: RichTextLabel = $SliderName
@onready var valueText: RichTextLabel = $SliderValue

signal drag_ended(value_changed: bool)

func _ready():
	# FmodServer.wait_for_all_loads()
	nameText.text = busName
	print("busName: ", busName)
	slider.value = bus.get_volume()


func _on_slider_value_changed(value: float) -> void:
	bus = FmodServer.get_bus("bus:/" + busName)
	bus.set_volume(value)
	valueText.text = str(int(value * 100), "%")

func _on_slider_drag_ended(value_changed: bool) -> void:
	drag_ended.emit(value_changed)
