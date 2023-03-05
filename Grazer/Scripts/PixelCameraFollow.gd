extends Camera3D

# Declare member variables here.
@export (float) var screenWidth = 640.0
@export (float) var unitWidth = 42.0
@export (float) var lerpSpeed = 3.0
@export (bool) var incrementalCamera = true
@export (NodePath) var targetNodePath = NodePath("/root/Level/Ball")
var followTarget
var camOffset
var pos

# Called when the node enters the scene tree for the first time.
func _ready():
	followTarget = get_node(targetNodePath)
	if(followTarget == null):
		followTarget = get_parent()
	camOffset = self.position
	pos = self.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pos = lerp(pos, followTarget.global_translation, lerpSpeed * delta)
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
