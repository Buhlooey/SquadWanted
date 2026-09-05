extends Control

@onready var faceSoundEmitter: FmodEventEmitter2D = $OptionsPanel/VBoxContainer/HBoxContainer/VolumeContianer/FaceSoundEmitter

func openMenu() -> void:
	set_process_mode(Node.PROCESS_MODE_INHERIT)
	show()

func closeMenu() -> void:
	hide()
	faceSoundEmitter.stop()
	set_process_mode(Node.PROCESS_MODE_DISABLED)