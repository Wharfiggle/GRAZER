extends KinematicBody

onready var player = get_node("../Ball")
onready var nav = get_node("/root/Level/Navigation")

var Bullet = preload("res://Prefabs/BulletE.tscn")

var Smoke = preload("res://Prefabs/Smoke.tscn")

var maxHealth = 10.0
var health = maxHealth

var targetPos = Vector3(0,0,0)
var targetCow = null
var path = []
var pathNode = 0
var baseSpeed = 4
var speed = 1.0
var followDistance = 7.0

var canFire=true

var fireDirection

#var playerPosition

var currentMode = "pursuit"
var marauderType = "gunman" #thief or gunman

var rng = RandomNumberGenerator.new()
onready var herd = null#get_node(NodePath("/root/Level/Herd"))
var draggedCow = null
export (float) var dragRange = 4.0

# Called when the node enters the scene tree for the first time.
#func _ready():

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):

#Called at set time intervals, delta is time elapsed since last call
func _physics_process(_delta):
	
	if(herd != null):
		var blah = null
	else:
		herd = get_node(NodePath("/root/Level/Herd"))
	
	if(Input.is_action_just_pressed("debug4")):
		if(currentMode == "idle"):
			currentMode = "pursuit"
		elif(currentMode == "pursuit"):
			currentMode = "flee"
		elif(currentMode == "flee"):
			currentMode = "idle"
	
	if(Input.is_action_just_pressed("debug3")):
		print("debug3")
		#currentMode = "cowPursuit"
	
	match[currentMode]: #Essentially a switch statement
		["idle"]:
			[idle()]
		["circle"]:
			[circle()]
		["pursuit"]:
			[pursuit()]
#		["cowPursuit"]:
#			[cowPursuit()]
		["flee"]:
			[flee()]
		["attack"]:
			[attack()]
	
	if(pathNode < path.size()):
		var direction = (path[pathNode] - global_transform.origin)
		if(direction.length() < 1):
			pathNode += 1
		else:
			move_and_slide(direction.normalized() * baseSpeed * speed, Vector3.UP)
	

	#TODO figure out how to call getClosestCow
#	if(herd != null and targetCow == null):
#		targetCow = herd.getClosestCow(translation)

	
	#Basic cow dragging test
	#drag a random cow
	if(Input.is_action_just_pressed("debug3")):
		if(herd == null):
			herd = get_node(NodePath("/root/Level/Herd"))
		if(herd.getNumCows() > 0):
			if(draggedCow == null):
				rng.randomize()
				var rn = rng.randi_range(0, herd.getNumCows() - 1)
				draggedCow = herd.getCow(rn)
				draggedCow.startDragging(self)
			else:
				draggedCow.stopDragging()
				draggedCow = null
	
	#stay within dragRange of dragged cow
	if(draggedCow != null):
		var cowVector = Vector2(
			draggedCow.translation.x - translation.x, 
			draggedCow.translation.z - translation.z)
		var dist = sqrt( pow(cowVector.x, 2) + pow(cowVector.y, 2) )
		if(dist > dragRange):
			cowVector = cowVector.normalized() * dragRange
			translation = Vector3(
				draggedCow.translation.x - cowVector.x,
				translation.y,
				draggedCow.translation.z - cowVector.y)


func idle():
	#Marauder sits still, maybe makes occasional random movements
	targetPos = translation

func circle():
	#Marauder circles around the herd. If marauderType is theif, it should 
	#try to avoid the cowboy. If marauderType is gunman, it should(?) switch to pursuit
	#when the cowboy gets close.
	print("Circle mode")
	

func pursuit():
	#Marauder runs directly at cowboy.
	#Once close enough,
	#If marauderType is gunman, they attempt to shoot the cowboy. 
	targetPos = player.global_transform.origin
	
	#Slows down when getting close to follow distance
	#If closer than follow distance, back up
	#If closer than half of follow distance, panic and flee
	var spacing = global_transform.origin.distance_to(player.global_transform.origin)
	if(spacing < followDistance + 3 and spacing > followDistance):
		#Slowing down when getting close
		if(speed > 0):
			speed = (spacing - followDistance) / 3.0
			#attack()
	elif(spacing < followDistance and spacing > followDistance / 2.0):
		#Backing up
		#print("Too close")
		if(speed < 1):
			speed *= followDistance / spacing
		if(speed > 1):
			speed = 1
		
		var fleeVector = Vector3(0,0,0)
		fleeVector = global_transform.origin - player.global_transform.origin
		fleeVector.y = 0
		fleeVector = fleeVector.normalized()
		targetPos = global_transform.origin + fleeVector * 5
		
	elif(spacing < followDistance / 2.0):
		print("Panic!")
		currentMode = "flee"
		
	elif(speed < 1):
		speed = 1
		#attack()

func cowPursuit():
	#Marauder runs towards closest cow and attempts to lasso when in range
	#If successful, or cowboy gets too close, the marauder switches to flee mode.
	if(herd == null):
			herd = get_node(NodePath("/root/Level/Herd"))
			if(herd == null):
				return
	
	#TODO figure out how to call getClosestCow
	if(targetCow == null):
		print(herd.findHerdCenter())
		herd.getClosestCow(translation)
		#targetCow = herd.getClosestCow(translation)
	
	targetPos = targetCow.translation
	print("CWWOP")

func flee():
	#Marauder runs away from cowboy towards offscreen until it despawns.
	#If is currently lassoed to a cow, move speed is slowed.
	#If health gets too low, sever lasso and attempt to escape.
	var spacing = global_transform.origin.distance_to(player.global_transform.origin)
	
	#TODO change both to currentMode == "circle"
	if(spacing > 3 * followDistance && health > 0.3 * maxHealth):
		if(marauderType == "gunman"):
			currentMode = "pursuit"
			#currentMode = "circle"
		elif(marauderType == "thief"):
			currentMode = "idle"
			#currentMode = "circle"
	
	speed = 1.5
	var fleeVector = Vector3(0,0,0)
	fleeVector = global_transform.origin - player.global_transform.origin
	fleeVector.y = 0
	fleeVector = fleeVector.normalized()
	targetPos = global_transform.origin + fleeVector * 5
	

#navigation function
func moveTo(targetPos):
	path = nav.get_simple_path(global_transform.origin, targetPos)
	pathNode = 0

func _on_Timer_timeout():
	moveTo(targetPos)

func attack():
		for x in 6:
			var b = Bullet.instance()
			owner.add_child(b)
			b.transform = $Position3D.global_transform
			b.velocity = b.transform.basis.z * b.muzzle_velocity
			print("enemy fire")
			_emit_smoke(b)
	

func _emit_smoke(bullet):
	var newSmoke = Smoke.instance()
	bullet.add_child(newSmoke)


func damage_taken(damage):
	health -= damage
	
	if health <= 0:
		print("Wasted")

