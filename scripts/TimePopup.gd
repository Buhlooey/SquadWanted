extends Node2D

@onready var richTextLabel: RichTextLabel = $RichTextLabel

var timeChange: float = 1
var velocity: float = 150
var deacceleration: float = 300

const BONUS_COLOR: String = "#8df"
const PENALTY_COLOR: String = "#f66"

func setTimeChange(change: float) -> void:
	timeChange = change

func _ready() -> void:
	if timeChange > 0:
		richTextLabel.text = "[center][b][color=" + BONUS_COLOR + "]+" + str(timeChange)
	elif timeChange < 0:
		richTextLabel.text = "[center][b][color=" + PENALTY_COLOR + "]" + str(timeChange)
	else:
		richTextLabel.text = ""

func _physics_process(delta: float) -> void:
	velocity = move_toward(velocity, 0, deacceleration * delta)
	position.y -= velocity * delta
	if global_position.y < 16:
		global_position.y = 16
		velocity = 0

func _on_timer_timeout() -> void:
	queue_free()
