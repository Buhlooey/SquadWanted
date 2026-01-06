extends CharacterBody2D

var gameNode: Node2D

var isWanted: bool

var doGravity: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var correctAudios: Array = $CorrectAudio.get_children()
@onready var incorrectAudios: Array = $IncorrectAudio.get_children()
@onready var eyesSprite: Sprite2D = $Eyes
var spriteSize: int = 48

func _ready():
	eyesSprite.set_visible(false)


func _physics_process(delta) -> void:
	if !is_on_floor():
		if doGravity:
			velocity.y += gravity * delta

	var collision: KinematicCollision2D = move_and_collide(velocity*delta)
	if collision:
		# If it hit something, calculate the bounce
		var normal = collision.get_normal()
		# Bounce the velocity
		velocity = velocity.bounce(normal)
		
		# Apply an extra push (force) for a stronger bounce
		velocity += normal * 100 * delta

# Called by GameAreaEdge.gd
func screenWrap(edgeName:String) -> void:
	if edgeName == "BottomEdge" and velocity.y > 0:
		position.y -= gameNode.gameArea.size.y + spriteSize-4
	elif edgeName == "TopEdge" and velocity.y < 0:
		position.y += gameNode.gameArea.size.y + spriteSize-4
	elif edgeName == "RightEdge" and velocity.x > 0:
		position.x -= gameNode.gameArea.size.x + spriteSize-4
	elif edgeName == "LeftEdge" and velocity.x < 0:
		position.x += gameNode.gameArea.size.x + spriteSize-4

# Called by Game.gd
func clickFace():
	if isWanted and !correctAudios.is_empty():
		doGravity = false
		velocity = Vector2(0,0)
		correctAudios[randi_range(0, correctAudios.size()-1)].play()
		eyesSprite.set_visible(true)
	elif !incorrectAudios.is_empty():
		incorrectAudios[randi_range(0, incorrectAudios.size()-1)].play()

## OLD SCREENWRAP
# func screenWrap() -> void:
# 	if position.x >= gameNode.gameArea.end.x + spriteSize/2:
# 		position.x -= gameNode.gameArea.size.x + spriteSize - 4
# 	elif position.x <= gameNode.gameArea.position.x - spriteSize/2:
# 		position.x += gameNode.gameArea.size.x + spriteSize - 4
	
# 	if position.y >= gameNode.gameArea.end.y + spriteSize/2:
# 		position.y -= gameNode.gameArea.size.y + spriteSize - 4
# 	elif position.y <= gameNode.gameArea.position.y - spriteSize/2:
# 		position.y += gameNode.gameArea.size.y + spriteSize - 4

## OLD EDGEBOUNCE - now handled by 
# func edgeBounce(edgeName:String) -> void:
# 	if edgeName == "BottomEdge" and velocity.y > 0:
# 		velocity.y *= -1
# 	elif edgeName == "TopEdge" and velocity.y < 0:
# 		velocity.y *= -1
# 	elif edgeName == "RightEdge" and velocity.x > 0:
# 		velocity.x *= -1
# 	elif edgeName == "LeftEdge" and velocity.x < 0:
# 		velocity.x *= -1
