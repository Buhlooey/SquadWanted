extends CharacterBody2D

var doGravity: bool = false

var gameNode: Node2D

var spriteSize: int = 64

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	pass


func _physics_process(delta) -> void:
	if gameNode.doGravity:
		if not is_on_floor():
			velocity.y += gravity * delta

	var collision: KinematicCollision2D = move_and_collide(velocity*delta)
	if collision:
		# If it hit something, calculate the bounce
		var normal = collision.get_normal()
		# Bounce the velocity
		velocity = velocity.bounce(normal)
		
		# Apply an extra push (force) for a stronger bounce
		# velocity += normal * 1000 * delta

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

## OLD EDGEBOUNCE
# func edgeBounce(edgeName:String) -> void:
# 	if edgeName == "BottomEdge" and velocity.y > 0:
# 		velocity.y *= -1
# 	elif edgeName == "TopEdge" and velocity.y < 0:
# 		velocity.y *= -1
# 	elif edgeName == "RightEdge" and velocity.x > 0:
# 		velocity.x *= -1
# 	elif edgeName == "LeftEdge" and velocity.x < 0:
# 		velocity.x *= -1

func screenWrap(edgeName:String) -> void:
	if edgeName == "BottomEdge" and velocity.y > 0:
		position.y -= gameNode.gameArea.size.y + spriteSize-4
	elif edgeName == "TopEdge" and velocity.y < 0:
		position.y += gameNode.gameArea.size.y + spriteSize-4
	elif edgeName == "RightEdge" and velocity.x > 0:
		position.x -= gameNode.gameArea.size.x + spriteSize-4
	elif edgeName == "LeftEdge" and velocity.x < 0:
		position.x += gameNode.gameArea.size.x + spriteSize-4
