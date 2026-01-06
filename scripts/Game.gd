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

@onready var correctGuessPauseTimer: Timer = $CorrectGuessPauseTimer


# ~~~~~~~~~~~~~~~ FUNCTIONALITY ~~~~~~~~~~~~~~~

# Called when the node enters the scene tree for the first time.
func _ready():
	set_visible(false)

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
						Vector2(randf_range(gameArea.position.x, gameArea.end.x), -80),
						true,
						moveVelocity,
						randomizeAngleIfApplicable())
		for i in range(faces):
			initializeFace(incorrectFaceScene,
							Vector2(randf_range(gameArea.position.x, gameArea.end.x), -80),
							false,
							moveVelocity,
							randomizeAngleIfApplicable())

	else: # SCATTERED is default
		# create faces scattered randomly about the board
		initializeFace(correctFaceScene,
						Vector2(randf_range(gameArea.position.x, gameArea.end.x),
								randf_range(gameArea.position.y, gameArea.end.y)),
						true,
						moveVelocity,
						randomizeAngleIfApplicable())
		for i in range(faces):
			initializeFace(incorrectFaceScene,
							Vector2(randf_range(gameArea.position.x, gameArea.end.x),
									randf_range(gameArea.position.y, gameArea.end.y)),
							false,
							moveVelocity,
							randomizeAngleIfApplicable())
	set_visible(true)

func initializeFace(scene: PackedScene, facePosition: Vector2, isWanted = false, faceVelocity: int = 0, faceMoveAngle: float = 0) -> void:
	var faceNode: CharacterBody2D = scene.instantiate()
	faceNode.gameNode = self
	faceNode.set_global_position(facePosition)
	faceNode.set_velocity(Vector2(faceVelocity*cos(faceMoveAngle), faceVelocity*sin(faceMoveAngle)))
	faceNode.doGravity = doGravity
	faceNode.isWanted = isWanted
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


func clearFaces(onlyIncorrect: bool = false):
	for child in get_children():
		if child.is_in_group("Face"):
			if !child.is_in_group("CorrectFace") or !onlyIncorrect:
				child.queue_free()


# ~~~~~ Signals ~~~~~

func _on_game_area_input_event(viewport:Node, event:InputEvent, _shape_idx:int) -> void:
	if event.is_action_pressed("click"):
		if correctGuessPauseTimer.is_stopped():
			var query = PhysicsPointQueryParameters2D.new()
			query.set_position(viewport.get_mouse_position())
			query.set_collide_with_areas(false)
			var bodies = get_world_2d().get_direct_space_state().intersect_point(query)

			if !bodies.is_empty():
				var correctFaceFound: bool = false
				for body in bodies:
					var thisFace: Node2D = instance_from_id(body["collider_id"])
					if thisFace.is_in_group("CorrectFace"):
						thisFace.clickFace()
						correctFaceFound = true
						incrementScore()
						clearFaces(true)

						moveVelocity += 20
						faces += 2
						correctGuessPauseTimer.start()
						await correctGuessPauseTimer.timeout
						reinitializeGame()

				if !correctFaceFound:
					print("Incorrect face clicked")
					var firstIncorrectFace: Node2D = instance_from_id(bodies[0]["collider_id"])
					firstIncorrectFace.clickFace()

		viewport.set_input_as_handled()
