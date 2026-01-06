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
var faceSet1: Array[PackedScene] = [
	preload('res://scenes/faces/FaceAlex.tscn'),
	preload('res://scenes/faces/FaceSoda.tscn'),
	preload('res://scenes/faces/FaceDyl.tscn'),
	preload('res://scenes/faces/FaceTyflo.tscn'),
]
var currFaceSet: Array[PackedScene]
var currWantedFace: PackedScene

@onready var gameAreaCollider: CollisionShape2D = $GameArea/CollisionShape2D
var gameArea: Rect2

var score: int = 0

@onready var staticBorder: StaticBody2D = $StaticBorder

@onready var scoreTextLabel: RichTextLabel = $TimeAndScore/ScoreText

@onready var correctGuessPauseTimer: Timer = $CorrectGuessPauseTimer

@onready var wantedIcon: Sprite2D = $WantedIcon


# ~~~~~~~~~~~~~~~ FUNCTIONALITY ~~~~~~~~~~~~~~~

# Called when the node enters the scene tree for the first time.
func _ready():
	set_visible(false)

	for face in faceSet1:
		currFaceSet.append(face)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	pass


func initializeRound():
	gameArea = gameAreaCollider.get_shape().get_rect()

	# Enable/disable bouncing
	if doBounceOnEdges:
		staticBorder.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		staticBorder.process_mode = Node.PROCESS_MODE_DISABLED

	# Choose wanted face
	currWantedFace = currFaceSet.pop_at(randi_range(0, faceSet1.size()-1))
	
	# Place faces
	if placementMode == PlaceMode.GRID:
		pass # place faces on a grid

	elif placementMode == PlaceMode.BORDER:
		pass # choose one edge, place faces on it

	elif placementMode == PlaceMode.CLUSTERS:
		pass # create a set number of clusters, then add faces as children of those clusters

	elif placementMode == PlaceMode.BOUNCE:
		# scatter faces in a row near the top of the game area so they can fall and bounce
		for i in range(faces):
			var face: PackedScene
			var wanted: bool = false
			if i == floor(faces/2): # The (i/2)th face spawned will be the wanted face
				face = currWantedFace
				wanted = true
			else:
				face = currFaceSet[randi_range(0, currFaceSet.size()-1)]

			initializeFace(face,
							Vector2(randf_range(gameArea.position.x, gameArea.end.x), -80),
							wanted,
							moveVelocity,
							randomizeAngleIfApplicable())

	else: # SCATTERED is default
		# scatter faces randomly about the board
		for i in range(faces):
			var face: PackedScene
			var wanted: bool = false
			if i == floor(faces/2): # The (i/2)th face spawned will be the wanted face
				face = currWantedFace
				wanted = true
				print("spawning wanted face")
			else:
				face = currFaceSet[randi_range(0, currFaceSet.size()-1)]
				print("spawning non-wanted face")

			initializeFace(face,
							Vector2(randf_range(gameArea.position.x, gameArea.end.x),
									randf_range(gameArea.position.y, gameArea.end.y)),
							wanted,
							moveVelocity,
							randomizeAngleIfApplicable())

	set_visible(true)

	currFaceSet.append(currWantedFace)


func initializeFace(scene: PackedScene, facePosition: Vector2, isWanted = false, faceVelocity: int = 0, faceMoveAngle: float = 0) -> void:
	var faceNode: CharacterBody2D = scene.instantiate()
	faceNode.gameNode = self
	faceNode.set_global_position(facePosition)
	faceNode.set_velocity(Vector2(faceVelocity*cos(faceMoveAngle), faceVelocity*sin(faceMoveAngle)))
	faceNode.doGravity = doGravity
	faceNode.isWanted = isWanted
	if isWanted:
		faceNode.add_to_group("CorrectFace")
		wantedIcon.set_texture(faceNode.get_child(0).texture)
	add_child(faceNode)


func reinitializeRound() -> void:
	clearFaces()
	initializeRound()


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
					if thisFace and thisFace.is_in_group("CorrectFace"):
						thisFace.clickFace()
						correctFaceFound = true
						incrementScore()
						clearFaces(true)

						moveVelocity += 20
						faces += 2
						correctGuessPauseTimer.start()
						await correctGuessPauseTimer.timeout
						reinitializeRound()

				if !correctFaceFound:
					print("Incorrect face clicked")
					var firstIncorrectFace: Node2D = instance_from_id(bodies[0]["collider_id"])
					firstIncorrectFace.clickFace()

		viewport.set_input_as_handled()
