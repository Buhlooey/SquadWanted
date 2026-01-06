extends Node2D

const INVALID_ANGLE: float = 50

# ~~~~~~~~~~~~~~~ VARIABLES ~~~~~~~~~~~~~~~

# ~~~~~ Game Rules ~~~~~
## The number of incorrect faces generated alongside the correct face.
@export var faces: int

enum PlaceMode {SCATTERED, GRID, BORDER, CLUSTERS, BOUNCE}
@export var placementMode: PlaceMode

@export var moveVelocity: int
@export var sameMoveDir: bool
var moveAngle: float = INVALID_ANGLE

@export var doWaveMovementX: bool
@export var doWaveMovementY: bool

@export var doGravity: bool
@export var doBounceOnEdges: bool

@export var sizeScale: float

@export var correctFaceScene: PackedScene
@export var incorrectFaceScene: PackedScene

@onready var gameAreaCollider: CollisionShape2D = $GameArea/CollisionShape2D
var gameArea: Rect2

var score: int = 0

# @onready var edges: Node2D = $Edges
@onready var staticBorder: StaticBody2D = $StaticBorder

@onready var scoreTextLabel: RichTextLabel = $TimeAndScore/ScoreText


# ~~~~~~~~~~~~~~~ FUNCTIONALITY ~~~~~~~~~~~~~~~

# Called when the node enters the scene tree for the first time.
func _ready():
	initializeGame()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	pass


func initializeGame():
	gameArea = gameAreaCollider.get_shape().get_rect()

	# Enable/disable bouncing
	if doBounceOnEdges:
		staticBorder.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		staticBorder.process_mode = Node.PROCESS_MODE_DISABLED

	# Place faces
	if placementMode == PlaceMode.GRID:
		pass # place faces on a grid

	elif placementMode == PlaceMode.BORDER:
		pass # choose one edge, place faces on it

	elif placementMode == PlaceMode.CLUSTERS:
		pass # create a set number of clusters, then add faces as children of those clusters

	elif placementMode == PlaceMode.BOUNCE:
		initializeFace(correctFaceScene,
						Vector2(randf_range(gameArea.position.x, gameArea.end.x),
								randf_range(gameArea.position.y, gameArea.end.y)))
		for i in range(faces):
			initializeFace(incorrectFaceScene,
							Vector2(randf_range(gameArea.position.x, gameArea.end.x), -80))

	else: # SCATTERED is default
		# create faces scattered randomly about the board
		initializeFace(correctFaceScene,
						Vector2(randf_range(gameArea.position.x, gameArea.end.x), -80),
						moveVelocity,
						randomizeAngleIfApplicable())
		for i in range(faces):
			initializeFace(incorrectFaceScene,
							Vector2(randf_range(gameArea.position.x, gameArea.end.x),
									randf_range(gameArea.position.y, gameArea.end.y)),
							moveVelocity,
							randomizeAngleIfApplicable())


func initializeFace(scene: PackedScene, facePosition: Vector2, faceVelocity: int = 0, faceMoveAngle: float = 0) -> void:
	var faceNode: CharacterBody2D = scene.instantiate()
	faceNode.gameNode = self
	faceNode.set_global_position(facePosition)
	faceNode.set_velocity(Vector2(faceVelocity*cos(faceMoveAngle), faceVelocity*sin(faceMoveAngle)))
	add_child(faceNode)


func reinitializeGame() -> void:
	clearFaces()
	initializeGame()


# ~~~~~ Helpers ~~~~~

func randomizeAngleIfApplicable() -> float:
	if !sameMoveDir or moveAngle == INVALID_ANGLE:
		moveAngle = randf_range(0.0, PI*2.0)
	return moveAngle


func updateScoreTextLabel() -> void:
	scoreTextLabel.text = str("Score: ", score)

func incrementScore() -> void:
	score += 1
	updateScoreTextLabel()

func resetScore() -> void:
	score = 0
	updateScoreTextLabel()


func clearFaces():
	for child in get_children():
		if child.is_in_group("Face"):
			child.queue_free()


# ~~~~~ Signals ~~~~~

func _on_game_area_input_event(viewport:Node, event:InputEvent, shape_idx:int) -> void:
	if event.is_action_pressed("click"):
		var query = PhysicsPointQueryParameters2D.new()
		query.set_position(viewport.get_mouse_position())
		query.set_collide_with_areas(false)
		var bodies = get_world_2d().get_direct_space_state().intersect_point(query)
		if !bodies.is_empty():
			print(query.position, " - ", bodies)
			for body in bodies:
				print(instance_from_id(body["collider_id"]))
				if instance_from_id(body["collider_id"]).is_in_group("CorrectFace"):
					incrementScore()
					moveVelocity += 20
					faces += 2
					reinitializeGame()

		# print(get_world_2d().direct_space_state.intersect_point(PhysicsPointQueryParameters2D.new()))
		viewport.set_input_as_handled()
