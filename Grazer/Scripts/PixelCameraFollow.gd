extends Camera3D

# Declare member variables here.
@export var screenWidth = 640.0
@export var unitWidth = 42.0
@export var lerpSpeed = 5.0
@export var incrementalCamera = false
var targetNodePath = NodePath("/root/Level/Player")
var followTarget
var camOffset
var pos

@export var trauamaReducRate = 1.0
var trauma = 0.0
var time = 0.0

@export var trauma_amount = 0.1

@export var maxX = 10.0
@export var maxY = 10.0
@export var maxZ = 5.0

@export var noise : FastNoiseLite
@export var noiseSpeed = 50.0

@onready var camera = self
@onready var initialRotation = camera.rotation as Vector3

func _process(delta):
	time += delta
	trauma = max(trauma - delta * trauamaReducRate, 0.0)

	var cameraRotDelta = Vector3.ZERO
	cameraRotDelta.x = maxX * get_shake_intensity() * get_noise_from_seed(0)
	cameraRotDelta.y = maxY * get_shake_intensity() * get_noise_from_seed(1)
	cameraRotDelta.z = maxZ * get_shake_intensity() * get_noise_from_seed(2)
	cameraRotDelta *= PI / 180.0
	camera.rotation = initialRotation + cameraRotDelta

func add_trauma(trauma_amount : float):
	trauma = clamp(trauma + trauma_amount, 0.0, 0.4)

func get_shake_intensity() -> float:
	return trauma * trauma

func get_noise_from_seed(_seed : int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noiseSpeed)


# Called when the node enters the scene tree for the first time.
func _ready():
	followTarget = get_node(targetNodePath)
	if(followTarget == null):
		followTarget = get_parent()
	camOffset = self.position
	pos = self.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pos = lerp(pos, followTarget.global_transform.origin, lerpSpeed * delta)
	#pos = followTarget.global_translation
	self.position = pos + camOffset
	if(incrementalCamera):
		self.position -= Vector3(
		#42 units accross the screen horizontally with camera size 30
			fmod(self.position.x * screenWidth / unitWidth, 1) * unitWidth / screenWidth,
			fmod(self.position.y * screenWidth / unitWidth, 1) * unitWidth / screenWidth,
			fmod(self.position.z * screenWidth / unitWidth, 1) * unitWidth / screenWidth)
	#print(self.position)
	#self.position = followTarget.global_translation + camOffset
