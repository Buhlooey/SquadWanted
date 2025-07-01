extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var ruleGravity: bool = false

var gameNode: Node2D

var spriteSize: int = 64

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	velocity = gameNode.ruleMoveVelocity


func _physics_process(delta) -> void:
	# Add the gravity.
	if gameNode.ruleDoGravity:
		if not is_on_floor():
			velocity.y += gravity * delta

	move_and_slide()


func screenWrap() -> void:
	if position.x >= gameNode.gameArea.end.x:
		position.x -= gameNode.gameArea.size.x + spriteSize - 4
	elif position.x <= gameNode.gameArea.position.x:
		position.x += gameNode.gameArea.size.x + spriteSize - 4
	
	if position.y >= gameNode.gameArea.end.y:
		position.y -= gameNode.gameArea.size.y + spriteSize - 4
	elif position.y <= gameNode.gameArea.position.y:
		position.y += gameNode.gameArea.size.y + spriteSize - 4


func _on_input_event(_viewport:Node, event:InputEvent, _shape_idx:int) -> void:
	if event.is_action_pressed("click"):
		#respond to incorrect click
		print("teehee i got yoU!!!!!!")
		get_viewport().set_input_as_handled()