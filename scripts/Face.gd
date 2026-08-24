extends CharacterBody2D

@export var faceName: String

var textures: Array

var gameNode: Node2D

var isWanted: bool

var doGravity: bool = false
var currGravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var storedVelocity: Vector2
var storedGravity: float = currGravity

@onready var eventEmitter: FmodEventEmitter2D = $FmodEventEmitter2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var eyesSprite: Sprite2D = $Eyes
var gameAreaToWrapEdgeDistance: int = 64

func _ready():
	eyesSprite.set_visible(false)
	sprite.set_visible(false)
	eventEmitter.set_parameter("Face", faceName)
	sprite.set_texture(textures[0])
	eyesSprite.set_texture(textures[1])
	await gameNode.showFaces
	sprite.set_visible(true)


func _physics_process(delta) -> void:
	if !is_on_floor():
		if doGravity:
			velocity.y += currGravity * delta

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
		position.y -= gameNode.gameArea.size.y + gameAreaToWrapEdgeDistance
	elif edgeName == "TopEdge" and velocity.y < 0:
		position.y += gameNode.gameArea.size.y + gameAreaToWrapEdgeDistance
	elif edgeName == "RightEdge" and velocity.x > 0:
		position.x -= gameNode.gameArea.size.x + gameAreaToWrapEdgeDistance
	elif edgeName == "LeftEdge" and velocity.x < 0:
		position.x += gameNode.gameArea.size.x + gameAreaToWrapEdgeDistance

# Called by Game.gd
func clickFace():
	if isWanted:
		doGravity = false
		velocity = Vector2.ZERO
		eventEmitter.set_parameter("Event", "Found")
		eyesSprite.set_visible(true)
	else:
		eventEmitter.set_parameter("Event", "Misclick")
	
	eventEmitter.play()


# Called by Game.gd
func onNotFound():
	eventEmitter.set_parameter("Event", "NotFound")
	eventEmitter.play()
	# set_velocity(Vector2(0,0))


func onParryStart():
	storedVelocity = velocity
	velocity = Vector2.ZERO
	storedGravity = currGravity
	currGravity = 0.0


func onParryEnd():
	velocity = storedVelocity
	currGravity = storedGravity

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
