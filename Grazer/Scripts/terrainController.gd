extends Spatial
onready var player = preload("res://Assets/Ball.tscn")
onready var basicTile = preload("res://Assets/FloorTiles/basicFloorTile.tscn")
var tileWidth = 15
var currentTile
var tilePointer

func _ready():
	#load origin tile
	var newTile = basicTile.instance()
	newTile.transform.origin = (Vector3(0,0,0))
	get_tree().get_root().add_child(newTile)
	tilePointer = newTile
	currentTile = newTile

func _process(delta):
	if(Input.is_action_just_pressed("debug2")):
		#placing the new tile
		var newTile = basicTile.instance()
		var newTransform = Vector3(tilePointer.transform.origin.x + tileWidth,0, tilePointer.transform.origin.z + tileWidth)
		newTile.transform.origin = (newTransform)
		get_tree().get_root().add_child(newTile)
		#move the tilePointer
		tilePointer.botRight = newTile
		tilePointer = newTile

	if(Input.is_action_just_pressed("debug1")):
		var newPlayer = player.instance()
		newPlayer.transform.origin = (Vector3(0,5,0))
		get_tree().get_root().add_child(newPlayer)
	
	_checkCurrentTile()

func _checkCurrentTile() -> void:
	var thePlayer = get_parent().get_node("Ball")
	var pX = thePlayer.transform.origin.x
	var pZ = thePlayer.transform.origin.z
	var cX = currentTile.transform.origin.x
	var cZ = currentTile.transform.origin.z
	#could possibly change this code if there is a way for the player to tell
	#what chunk it is in
	
	if((pX - cX) + (pZ - cZ) > 15): #Checking if player left the current chunk
		if( pX > cX and pZ > cZ ): #player moved to BotRight
			print("BotRight")
			currentTile = currentTile.botRight
		if( pX > cX and pZ < cZ ): #player moved to TopRight
			print("TopRight")
		if( pX < cX and pZ > cZ ): #player moved to BotLeft
			print("BotLeft")
		if( pX < cX and pZ < cZ ): #player moved to TopLeft
			print("TopLeft")
