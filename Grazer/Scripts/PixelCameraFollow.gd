extends Camera

# Declare member variables here.
export (float) var screenWidth = 640.0
export (float) var unitWidth = 42.0
export (float) var lerpSpeed = 3.0
export (bool) var incrementalCamera = true
export (NodePath) var targetNodePath = NodePath("/root/Level/Ball")
var followTarget
var camOffset
var pos

# Called when the node enters the scene tree for the first time.
func _ready():
	followTarget = get_node(targetNodePath)
	if(followTarget == null):
		followTarget = get_parent()
	camOffset = self.translation
	pos = self.translation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pos = lerp(pos, followTarget.global_translation, lerpSpeed * delta)
	self.translation = pos + camOffset
	if(incrementalCamera):
		self.translation -= Vector3(
		#42 units accross the screen horizontally with camera size 30
			fmod(self.translation.x * screenWidth / unitWidth, 1) * unitWidth / screenWidth,
			fmod(self.translation.y * screenWidth / unitWidth, 1) * unitWidth / screenWidth,
			fmod(self.translation.z * screenWidth / unitWidth, 1) * unitWidth / screenWidth)
	#print(self.translation)
	#self.translation = followTarget.global_translation + camOffset
