extends Node2D

# ~~~~~~~~~~~~~~~ VARIABLES/INITIALIZATION ~~~~~~~~~~~~~~~

const SPRITE_SIZE: int = 48
const BORDER_SPAWN_WIDTH: int = 10
const BORDER_SPAWN_HEIGHT: int = 8
const GRID_WIDTH_LIMIT: int = 11
const GRID_HEIGHT_LIMIT: int = 9
const INVALID_ANGLE: float = 50

# ~~~~~ Game Rules ~~~~~

enum PlaceMode {SCATTERED, GRID, BORDER, CLUSTERS, BOUNCE}
@export var placementMode: PlaceMode

## The number of incorrect faces generated alongside the correct face. Used in: Scattered, Clusters, Bounce.
@export var faces: int
## The number of clusters that faces will be grouped in. Faces will be mostly uniformly distributed between clusters. Used in: Clusters.
@export var clusters: int

## The horizontal size of the grid where faces spawn. Used in: Grid.
@export var gridWidth: int
## The vertical size of the grid where faces spawn. Used in: Grid.
@export var gridHeight: int

## The border of the screen to use; 0=top, 1=bottom, 2=left, 3=right. Used in: Border.
@export var borderToUse: int = -1

## The velocity faces will move in. Used in: Scattered, Clusters, Bounce.
@export var moveVelocity: int
## Whether the same random moveAngle will be given to every face, or each face/cluster will get a random moveAngle. Used in: Scattered, Clusters, Bounce.
@export var sameMoveDir: bool
var moveAngle: float = INVALID_ANGLE

# TODO: Implement wave movement
## Whether or not faces will move horizontally in a sine wave. Used in: Scattered, Clusters.
@export var doWaveMovementX: bool
## Whether or not faces will move vertically in a sine wave. Used in: Scattered, Clusters.
@export var doWaveMovementY: bool

## Whether or not faces will bounce off of the edge of the screen or loop to the other side of it. Used in: Scattered, Bounce.
@export var doBounceOnEdges: bool



@export var initialWaitTime: int = 30

var canClick: bool = true

# ~~~~~ Faces ~~~~~

var faceScene: PackedScene = preload('res://scenes/Face.tscn')

var faceSetImages: Dictionary[String, Array] = {
	"Alex":		[preload('res://assets/images/faces/FaceAlex.png'),
			 	 preload('res://assets/images/faces/EyesAlex.png')],
	"Dyl":		[preload('res://assets/images/faces/FaceDyl.png'),
				 preload('res://assets/images/faces/EyesDyl.png')],
	"Soda": 	[preload('res://assets/images/faces/FaceSoda.png'),
				 preload('res://assets/images/faces/EyesSoda.png')],
	"Tyflo":	[preload('res://assets/images/faces/FaceTyflo.png'),
				 preload('res://assets/images/faces/EyesTyflo.png')],
}

var currFaceSet: Array
var currWantedFace: String

# ~~~~~ Level Loading ~~~~~
var levelsFilePath: String = "res://assets/json/levels.json"
@onready var levelsJson: Dictionary = loadJson(levelsFilePath)

# ~~~~~ Child Node References ~~~~~
@onready var gameAreaCollider: CollisionShape2D = $GameArea/CollisionShape2D
var gameArea: Rect2
@onready var staticBorder: StaticBody2D = $StaticBorder

@onready var wantedIcon: Sprite2D = $WantedIcon
@onready var timeTextLabel: RichTextLabel = $TimeAndScore/TimeText
@onready var scoreTextLabel: RichTextLabel = $TimeAndScore/ScoreText
@onready var correctGuessPauseTimer: Timer = $CorrectGuessPauseTimer
@onready var gameTimer: Timer = $GameTimer

@onready var musicPlayer: FmodEventEmitter2D = $FmodAndAudio/FmodMusic

# ~~~~~ Other Variables ~~~~~
var score: int = 0


# ~~~~~ Signals ~~~~~
signal gameCompleted()


# ~~~~~~~~~~~~~~~ FUNCTIONALITY ~~~~~~~~~~~~~~~

# Called when the node enters the scene tree for the first time.
func _ready():
	print(levelsJson)
	set_visible(false)
	musicPlayer.play()

	currFaceSet = faceSetImages.keys()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	updateTimeTextLabel()


func initializeRound():
	loadLevelPreset("section1")
	gameArea = gameAreaCollider.get_shape().get_rect()

	# Enable/disable bouncing
	if doBounceOnEdges:
		staticBorder.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		staticBorder.process_mode = Node.PROCESS_MODE_DISABLED

	# Choose wanted face
	currWantedFace = currFaceSet.pop_at(randi_range(0, currFaceSet.size()-1))
	
	# Place faces
	if placementMode == PlaceMode.GRID:
		gridWidth = min(gridWidth, GRID_WIDTH_LIMIT)
		gridHeight = min(gridHeight, GRID_HEIGHT_LIMIT)

		var xMidpointIndex: float = float(gridWidth-1)/2.0
		var yMidpointIndex: float = float(gridHeight-1)/2.0
		var wantedFaceX: int = randi_range(0, gridWidth-1)
		var wantedFaceY: int = randi_range(0, gridHeight-1)

		for x in range(gridWidth):
			var xPos: int = int(SPRITE_SIZE * float(x - xMidpointIndex))
			for y in range(gridHeight):
				var yPos: int = int(SPRITE_SIZE * float(y - yMidpointIndex))

				var faceName: String
				var wanted: bool = false
				if x == wantedFaceX and y == wantedFaceY:
					faceName = currWantedFace
					wanted = true
				else:
					faceName = currFaceSet[randi_range(0, currFaceSet.size()-1)]

				initializeFace(faceName, Vector2(xPos, yPos), wanted)

	elif placementMode == PlaceMode.BORDER:
		if borderToUse < 0 or borderToUse > 3:
			borderToUse = randi_range(0,3) # 0=top, 1=bottom, 2=left, 3=right

		if borderToUse <= 1: # top or bottom
			var yPos: float
			if borderToUse == 0:
				yPos = gameArea.position.y
			else:
				yPos = gameArea.end.y
			var midpointIndex: float = float(BORDER_SPAWN_WIDTH-1)/2.0
			var wantedFaceIndex: int = randi_range(0, BORDER_SPAWN_WIDTH-1)
			for x in range(BORDER_SPAWN_WIDTH):
				var xPos: int = int(SPRITE_SIZE * float(x - midpointIndex))
				var faceName: String
				var wanted: bool = false
				if x == wantedFaceIndex:
					faceName = currWantedFace
					wanted = true
				else:
					faceName = currFaceSet[randi_range(0, currFaceSet.size()-1)]

				initializeFace(faceName, Vector2(xPos, yPos), wanted)
		
		else: # left or right
			var xPos: float
			if borderToUse == 2:
				xPos = gameArea.position.x
			else:
				xPos = gameArea.end.x
			var midpointIndex: float = float(BORDER_SPAWN_HEIGHT-1)/2.0
			var wantedFaceIndex: int = randi_range(0, BORDER_SPAWN_HEIGHT-1)
			for y in range(BORDER_SPAWN_WIDTH):
				var yPos: int = int(SPRITE_SIZE * float(y - midpointIndex))
				var faceName: String
				var wanted: bool = false
				if y == wantedFaceIndex:
					faceName = currWantedFace
					wanted = true
				else:
					faceName = currFaceSet[randi_range(0, currFaceSet.size()-1)]

				initializeFace(faceName, Vector2(xPos, yPos), wanted)
		
	elif placementMode == PlaceMode.CLUSTERS: #TODO
		pass # create a set number of clusters, then add faces as children of those clusters

	elif placementMode == PlaceMode.BOUNCE:
		# scatter faces in a row near the top of the game area so they can fall and bounce
		for i in range(faces):
			var faceName: String
			var wanted: bool = false
			if i == floor(float(faces)/2): # The (i/2)th face spawned will be the wanted face
				faceName = currWantedFace
				wanted = true
			else:
				faceName = currFaceSet[randi_range(0, currFaceSet.size()-1)]

			initializeFace(faceName,
							Vector2(randf_range(gameArea.position.x, gameArea.end.x), -80),
							wanted,
							moveVelocity,
							randomizeAngleIfApplicable(),
							true)

	else: # SCATTERED is default
		# scatter faces randomly about the board
		for i in range(faces):
			var faceName: String
			var wanted: bool = false
			if i == floor(float(faces)/2): # The (i/2)th face spawned will be the wanted face
				faceName = currWantedFace
				wanted = true
			else:
				faceName = currFaceSet[randi_range(0, currFaceSet.size()-1)]

			initializeFace(faceName,
							Vector2(randf_range(gameArea.position.x, gameArea.end.x),
									randf_range(gameArea.position.y, gameArea.end.y)),
							wanted,
							moveVelocity,
							randomizeAngleIfApplicable())

	gameTimer.set_paused(false)
	gameTimer.start()

	currFaceSet.append(currWantedFace)

	canClick = true


func initializeFace(faceName: String, facePosition: Vector2, isWanted, faceVelocity: int = 0, faceMoveAngle: float = 0, doGravity: bool = false) -> void:
	var faceNode: CharacterBody2D = faceScene.instantiate()
	faceNode.faceName = faceName
	faceNode.textures = faceSetImages[faceName]
	faceNode.gameNode = self
	faceNode.set_global_position(facePosition)
	faceNode.set_velocity(Vector2(faceVelocity*cos(faceMoveAngle), faceVelocity*sin(faceMoveAngle)))
	faceNode.doGravity = doGravity
	faceNode.isWanted = isWanted
	if isWanted:
		faceNode.add_to_group("CorrectFace")
		wantedIcon.set_texture(faceSetImages[faceName][0])
	add_child(faceNode)


func reinitializeRound() -> void:
	clearFaces()
	initializeRound()

func startGame() -> void:
	gameTimer.set_wait_time(initialWaitTime)
	initializeRound()
	set_visible(true)


func closeGame() -> void:
	clearFaces()
	set_visible(false)
	resetScore()


# ~~~~~ Helpers ~~~~~

func randomizeAngleIfApplicable() -> float:
	if !sameMoveDir or moveAngle == INVALID_ANGLE:
		moveAngle = randf_range(0.0, PI*2.0)
	return moveAngle


func updateScoreTextLabel() -> void:
	scoreTextLabel.text = str("[center][b]", score)

func incrementScore() -> void:
	score += 1
	updateScoreTextLabel()

func resetScore() -> void:
	score = 0
	updateScoreTextLabel()

func updateTimeTextLabel() -> void:
	var time: float = gameTimer.time_left
	var intPart: int = int(time)
	var decPart: float = snapped(time - intPart, 0.1)
	timeTextLabel.text = str("[center][b]", intPart, "[font_size=32]", str(decPart).lstrip("0").lstrip("1")) 
	# timeTextLabel.text = str("[right][b]", str(floor(gameTimer.time_left)).rstrip("."))
	# var snappedDecimal: float = snapped(gameTimer.time_left - floorf(gameTimer.time_left), 0.1)
	# timeDecimalTextLabel.text = str("[left][b]", str(snappedDecimal).lstrip("0"))

func clearFaces(onlyIncorrect: bool = false):
	for child in get_children():
		if child.is_in_group("Face"):
			if !child.is_in_group("CorrectFace") or !onlyIncorrect:
				child.queue_free()


# ~~~~~ Level Loading ~~~~~

func loadJson(path: String) -> Dictionary:
	if !FileAccess.file_exists(path):
		push_error("File ", path, " doesn't exist")
		return {}
	
	var json: JSON = JSON.new()
	
	var dataFile: FileAccess = FileAccess.open(path, FileAccess.READ)
	var jsonString: String = dataFile.get_as_text()
	var error: int = json.parse(jsonString)

	if error:
		push_error("JSON Parse Error: ", json.get_error_message(), " in ", jsonString, " at line ", json.get_error_line())
		return {}
		
	var parsedData: Dictionary = JSON.parse_string(jsonString)
	return parsedData

func loadLevelPreset(presetName: String, index: int = -1) -> void:
	var levelSet: Array = levelsJson[presetName]
	if index < 0 or index > levelSet.size():
		# If index to pick a level is outside the range of the level set, pick a random level
		if index != -1:
			push_warning("Index {index} out of range for this level set (size {levelSet.size()}). Choosing a random level.".format([index, levelSet.size()]))
		index = randi_range(0, levelSet.size()-1)

	var level: Dictionary = levelSet[index]
	placementMode = int(level["placeMode"]) as PlaceMode

	print("placementMode: ", placementMode)

	if placementMode == PlaceMode.SCATTERED:
		faces = level["faces"]
		moveVelocity = level["moveVelocity"]
		sameMoveDir = level["sameMoveDir"]
		doWaveMovementX = level["doWaveMovementX"]
		doWaveMovementY = level["doWaveMovementY"]
		doBounceOnEdges = level["doBounceOnEdges"]
	elif placementMode == PlaceMode.GRID:
		gridWidth = level["gridWidth"]
		gridHeight = level["gridHeight"]
		doBounceOnEdges = false
	elif placementMode == PlaceMode.BORDER:
		borderToUse = level["borderToUse"]
		doBounceOnEdges = false
	elif placementMode == PlaceMode.CLUSTERS:
		faces = level["faces"]
		clusters = level["clusters"]
		moveVelocity = level["moveVelocity"]
		sameMoveDir = level["sameMoveDir"]
		doWaveMovementX = level["doWaveMovementX"]
		doWaveMovementY = level["doWaveMovementY"]
		doBounceOnEdges = false
	elif placementMode == PlaceMode.BOUNCE:
		faces = level["faces"]
		moveVelocity = level["moveVelocity"]
		sameMoveDir = level["sameMoveDir"]
		doWaveMovementX = level["doWaveMovementX"]
		doWaveMovementY = level["doWaveMovementY"]
		doBounceOnEdges = level["doBounceOnEdges"]

# ~~~~~ Signals ~~~~~

func _on_game_area_input_event(viewport:Node, event:InputEvent, _shape_idx:int) -> void:
	if event.is_action_pressed("click"):
		if canClick:
			var query = PhysicsPointQueryParameters2D.new()
			query.set_position(viewport.get_mouse_position())
			query.set_collide_with_areas(false)
			var bodies = get_world_2d().get_direct_space_state().intersect_point(query)

			if !bodies.is_empty():
				var correctFaceFound: bool = false
				for body in bodies:
					var thisFace: Node2D = instance_from_id(body["collider_id"])
					if thisFace and thisFace.is_in_group("CorrectFace"):
						canClick = false
						gameTimer.set_wait_time(gameTimer.get_time_left() + 3)
						gameTimer.set_paused(true)
						thisFace.clickFace()
						correctFaceFound = true
						incrementScore()
						clearFaces(true)

						correctGuessPauseTimer.start()
						await correctGuessPauseTimer.timeout
						reinitializeRound()
						break

				if !correctFaceFound:
					print("Incorrect face clicked")
					var timeLeft: float = gameTimer.get_time_left() - 5.0
					if timeLeft < 0:
						gameTimer.stop()
						gameTimer.timeout.emit()
					else:
						gameTimer.start(timeLeft)
					var firstIncorrectFace: Node2D = instance_from_id(bodies[0]["collider_id"])
					firstIncorrectFace.clickFace()

		viewport.set_input_as_handled()


func _on_game_timer_timeout() -> void:
	canClick = false
	clearFaces(true)
	musicPlayer.set_parameter("PlayGameOver", 1)
	musicPlayer.set_parameter("LeaveIntroLoop", 0)
	musicPlayer.stop()
	for child in get_children():
		if child.is_in_group("CorrectFace"):
			child.onNotFound()
			await child.eventEmitter.stopped
			break

	musicPlayer.play()
	correctGuessPauseTimer.start()
	await correctGuessPauseTimer.timeout
	closeGame()
	gameCompleted.emit()
