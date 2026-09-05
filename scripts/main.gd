extends Node2D

@onready var transition: AnimationPlayer = $Transition/TransitionAnimator

@onready var gameNode: Node2D = $Game
@onready var titleScreenNode: Control = $TitleScreen
@onready var optionsMenuNode: Control = $OptionsMenu
@onready var fmodMusic: FmodEventEmitter2D = get_tree().root.find_child("FmodMusic", true, false)

func _ready() -> void:
	optionsMenuNode.closeMenu()
	gameNode.hide()
	titleScreenNode.show()


func openOptionsMenu() -> void:
	optionsMenuNode.set_process_mode(Node.PROCESS_MODE_INHERIT)
	optionsMenuNode.show()

func closeOptionsMenu() -> void:
	optionsMenuNode.hide()
	optionsMenuNode.set_process_mode(Node.PROCESS_MODE_DISABLED)


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


func _on_options_button_pressed() -> void:
	titleScreenNode.disableButtons()
	optionsMenuNode.openMenu()

func _on_options_close_button_pressed() -> void:
	titleScreenNode.enableButtons()
	optionsMenuNode.closeMenu()
