extends Control

@onready var mainMenu: VBoxContainer = $MainMenu
@onready var creditsPanel: Panel = $CreditsPanel

@onready var startButton: Button = $MainMenu/StartButton
@onready var creditsButton: Button = $MainMenu/CreditsButton
@onready var optionsButton: Button = $MainMenu/OptionsButton

@onready var mainNode: Node2D = get_tree().root.find_child("Main", true, false)
@onready var fmodMusic: FmodEventEmitter2D = get_tree().root.find_child("FmodMusic", true, false)

func _ready() -> void:
	creditsPanel.hide()
	mainMenu.show()


func _on_credits_button_pressed() -> void:
	mainMenu.hide()
	creditsPanel.show()

func _on_credits_close_button_pressed() -> void:
	creditsPanel.hide()
	mainMenu.show()

func disableButtons() -> void:
	startButton.set_disabled(true)
	creditsButton.set_disabled(true)
	optionsButton.set_disabled(true)

func enableButtons() -> void:
	startButton.set_disabled(false)
	creditsButton.set_disabled(false)
	optionsButton.set_disabled(false)