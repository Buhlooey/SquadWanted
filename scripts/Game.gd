extends Node2D

# ~~~~~~~~~~~~~~~ VARIABLES ~~~~~~~~~~~~~~~

# ~~~~~ Game Rules ~~~~~
@export var ruleFaces: int


@export var ruleMoveVelocity: Vector2
@export var ruleSameMovement: float

@export var ruleDoWaveMovementX: bool
@export var ruleDoWaveMovementY: bool

@export var ruleDoGravity: bool
@export var ruleDoBounceOnEdges: bool

@export var ruleClusters: int

@export var ruleSizeScale: float

@export var correctFaceScene: PackedScene
@export var incorrectFaceScene: PackedScene

@onready var gameAreaCollider: CollisionShape2D = $GameArea/CollisionShape2D
var gameArea: Rect2

# Called when the node enters the scene tree for the first time.
func _ready():
	gameArea = gameAreaCollider.get_shape().get_rect()
	initializeFace(correctFaceScene)
	for i in range(ruleFaces - 1):
		initializeFace(incorrectFaceScene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func initializeFace(scene: PackedScene) -> void:
	var faceNode: CharacterBody2D = scene.instantiate()
	faceNode.gameNode = self
	faceNode.position = Vector2(randf_range(gameArea.position.x, gameArea.end.x),
								randf_range(gameArea.position.y, gameArea.end.y))
	add_child(faceNode)

func _on_game_area_body_exited(body: Node2D) -> void:
	body.screenWrap()
