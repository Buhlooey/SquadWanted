extends Node


enum PlaceMode {SCATTERED, GRID, BORDER, CLUSTERS, BOUNCE}
@export var placementMode: PlaceMode

@export var faces: int

@export var gridWidth: int
@export var gridHeight: int

@export var borderToUse: int = -1

@export var moveVelocity: int
@export var sameMoveDir: bool
var moveAngle: float
@export var doWaveMovementX: bool
@export var doWaveMovementY: bool

@export var doGravity: bool
@export var doBounceOnEdges: bool

func _ready() -> void:
	pass

func getLevelParams() -> Array:
	placementMode = randi_range(0, 5)

	if placementMode == 0:
		pass

	return [placementMode, faces, gridWidth, gridHeight, borderToUse]
