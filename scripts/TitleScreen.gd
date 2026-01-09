extends Control

@onready var gameNode: Node2D = get_tree().get_first_node_in_group("Game")
@onready var fmodMusic: FmodEventEmitter2D = get_tree().get_first_node_in_group("FmodAudioPlayer")

func _on_start_button_pressed() -> void:
	set_visible(false)
	gameNode.startGame()
	fmodMusic.set_parameter("LeaveIntroLoop", 1)

	await gameNode.gameCompleted
	set_visible(true)
