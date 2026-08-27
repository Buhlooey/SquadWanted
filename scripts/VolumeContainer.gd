extends VBoxContainer

@onready var faceSoundEmitter: FmodEventEmitter2D = $FaceSoundEmitter

func _on_volume_slider_sfx_drag_ended(_value_changed: bool) -> void:
	faceSoundEmitter.set_parameter("Event", ["Found", "NotFound", "Misclick"].pick_random())
	faceSoundEmitter.set_parameter("Face", ["Dyl", "Alex", "Soda", "Tyflo"].pick_random())
	faceSoundEmitter.play()
