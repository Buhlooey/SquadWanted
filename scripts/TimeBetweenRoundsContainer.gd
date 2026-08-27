extends HBoxContainer

@onready var slider: HSlider = $TimeBetweenRoundsSlider
@onready var textLabel: RichTextLabel = $TimeBetweenRoundsTextLabel
@onready var correctGuessPauseTimer: Timer = get_tree().root.find_child("CorrectGuessPauseTimer", true, false)

func _on_time_between_rounds_slider_value_changed(value: float) -> void:
	textLabel.text = str(value)
	correctGuessPauseTimer.wait_time = value
