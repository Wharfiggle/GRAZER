extends Camera

# Declare member variables here.
export (int) var screenWidth = 640
export (int) var screenHeight = 360
export (float) var lerpSpeed = 3
export (bool) var incrementalCamera = true
export (NodePath) var targetNodePath
var followTarget
var camOffset
var pos

# Called when the node enters the scene tree for the first time.
func _ready():
	followTarget = get_node(targetNodePath)
	camOffset = self.translation
	pos = self.translation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pos = lerp(pos, followTarget.global_translation, lerpSpeed * delta)
	self.translation = pos + camOffset
	if(incrementalCamera):
		self.translation -= Vector3(
		#42 units accross the screen horizontally with camera size 30
			fmod(self.translation.x * screenWidth / 42.0, 1) * 42.0 / screenWidth,
			fmod(self.translation.y * screenWidth / 42.0, 1) * 42.0 / screenWidth,
			fmod(self.translation.z * screenWidth / 42.0, 1) * 42.0 / screenWidth)
	#print(self.translation)
	#self.translation = followTarget.global_translation + camOffset
