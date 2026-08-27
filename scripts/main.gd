extends Node2D

@onready var transition: AnimationPlayer = $TransitionAnimator

@onready var gameNode: Node2D = $Game
@onready var titleScreenNode: Control = $TitleScreen
@onready var fmodMusic: FmodEventEmitter2D = get_tree().root.find_child("FmodMusic", true, false)

func _on_start_button_pressed() -> void:
	titleScreenNode.disableButtons()
	transition.play("transition1start")
	await transition.animation_finished

	titleScreenNode.set_visible(false)
	gameNode.startGame()
	fmodMusic.set_parameter("LeaveIntroLoop", 1)
	await gameNode.startDrumroll

	transition.play("transition1end")
	await gameNode.gameCompleted
	
	titleScreenNode.enableButtons()
	titleScreenNode.set_visible(true)
