extends Control

@onready var mainMenu: VBoxContainer = $MainMenu
@onready var optionsMenu: Panel = $OptionsMenu
@onready var creditsPanel: Panel = $CreditsPanel

@onready var startButton: Button = $MainMenu/StartButton
@onready var creditsButton: Button = $MainMenu/CreditsButton
@onready var optionsButton: Button = $MainMenu/OptionsButton

@onready var fmodMusic: FmodEventEmitter2D = get_tree().root.find_child("FmodMusic", true, false)

func _ready() -> void:
	optionsMenu.hide()
	creditsPanel.hide()
	mainMenu.show()


func _on_options_button_pressed() -> void:
	mainMenu.hide()
	optionsMenu.show()

func _on_options_close_button_pressed() -> void:
	optionsMenu.hide()
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