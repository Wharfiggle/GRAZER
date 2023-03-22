extends CharacterBody3D


@onready var player = get_node("/root/Level/Player")
@onready var nav = get_node("/root/Level/Navigation")
@onready var level = get_tree().root.get_child(0)
var Bullet = preload("res://Prefabs/BulletE.tscn")
var Smoke = preload("res://Prefabs/Smoke.tscn")


var maxHealth = 10.0
var health = maxHealth
var clipSize = 3
var clip = 3
var attackTime = 3
var attackCooldown = 0
var reloadTime = 3
var reloadCooldown = 0


var targetPos = Vector3(0,0,0)
var dynamicMov = Vector3(0,0,0)
var dynamicCooldown = 0.0;
var targetCow = null
@onready var navAgent = get_node("NavigationAgent3D")
var path = []
var pathNode = 0
var baseSpeed = 4
var speed = 1.0
var followDistance = 7.0 + randf_range(-1,1)
var herdRadius = 10 + randf_range(-2,2)
var currentCircle = 1

var canFire = true
var fireDirection
@export var knockable = true
@export var knockbackMod = 5
var kIFrames = 0
var knockbackDirection = Vector3(0,0,0)

enum behaviors {idle, pursuit, flee, retreat, circle, attack, cowPursuit}
var currentMode = behaviors.circle
enum enemyTypes {thief, gunman}
var marauderType = enemyTypes.thief #thief or gunman

var rng = RandomNumberGenerator.new()
@onready var herd = get_node(NodePath("/root/Level/Herd"))
var draggedCow = null
var dragRange = 4.0
var escapeRange = 16

func _ready():
	#Setting enemy type
	if(randi_range(0,1) == 0):
		marauderType = enemyTypes.thief
	else:
		marauderType = enemyTypes.gunman
		$Mesh.scale = Vector3(1,0.7,1)


#Called at set time intervals, delta is time elapsed since last call
func _physics_process(_delta):
	if(dynamicCooldown > 0):
		dynamicCooldown -= _delta
	lerp(dynamicMov.x,0.0,0.1)
	lerp(dynamicMov.z,0.0,0.1)
	
	if(herd == null):
		herd = get_node(NodePath("/root/Level/Herd"))
	
	rotation.y = lerp_angle(
		rotation.y,
		atan2(position.x - targetPos.x, position.z - targetPos.z) + PI,
		0.1
	)
	
	if(Input.is_action_just_pressed("debug4")):
		if(currentMode == behaviors.idle):
			currentMode = behaviors.pursuit
		elif(currentMode == behaviors.pursuit):
			currentMode = behaviors.flee
		elif(currentMode == behaviors.flee):
			currentMode = behaviors.idle
	
	if(Input.is_action_just_pressed("debug3")):
		if(marauderType == enemyTypes.thief):
			currentMode = behaviors.cowPursuit
	
	if(reloadCooldown > 0):
		reloadCooldown -= _delta
	if(attackCooldown > 0):
		attackCooldown -= _delta
	
	match[currentMode]: #Essentially a switch statement
		[behaviors.idle]:
			[idle()]
		[behaviors.circle]:
			[circle()]
		[behaviors.pursuit]:
			[pursuit()]
		[behaviors.cowPursuit]:
			[cowPursuit()]
		[behaviors.flee]:
			[flee()]
		[behaviors.retreat]:
			[retreat()]
		[behaviors.attack]:
			[attack()]
	
	if(pathNode < path.size()):
		var direction = (path[pathNode] - global_transform.origin)
		if(direction.length() < 1):
			pathNode += 1
		else:
			if(kIFrames > 0):
				set_velocity(knockbackDirection * 30)
			else:
				set_velocity(direction.normalized() * baseSpeed * speed + dynamicMov)
			set_up_direction(Vector3.UP)
			move_and_slide()
	
	#stay within dragRange of dragged cow
	if(draggedCow != null):
		var cowVector = Vector2(
			draggedCow.position.x - position.x, 
			draggedCow.position.z - position.z)
		var dist = sqrt( pow(cowVector.x, 2) + pow(cowVector.y, 2) )
		if(dist > dragRange):
			cowVector = cowVector.normalized() * dragRange
			position = Vector3(
				draggedCow.position.x - cowVector.x,
				position.y,
				draggedCow.position.z - cowVector.y)
				
	if(health <= 4.0):
		currentMode = behaviors.flee
	if(kIFrames > 0):
		kIFrames -= _delta
		if(kIFrames < 0):
			kIFrames = 0
	

func idle():
	#Marauder sits still, maybe makes occasional random movements
	targetPos = position
	genDynamicMov()

func circle():
	#Marauder circles around the herd. If marauderType is thief, it should 
	#try to avoid the cowboy. If marauderType is gunman, it switches to pursuit
	#when the cowboy gets close.
	if(herd == null or herd.numCows <= 0):
		targetPos = player.position
		return
	genDynamicMov()
	#variable for determining how far away to place next naviagation point from current position
	var circleSpeed = 2
	var lerpSpeed = 0.1
	var herdCenter = herd.findHerdCenter()
	#Desired position vector based on desired radius
	var rVec = herdRadius * ((position - herdCenter).normalized())
	
	#Dot product math and scaler projection math
	var baseA
	if((rVec.x > 0 and rVec.z > 0) or (rVec.x < 0 and rVec.z > 0)):
		baseA = -1
	else:
		baseA = 1
	var baseB = (-rVec.x * baseA) / rVec.z
	var baseV = Vector3(baseA, 0, baseB)
	
	var relate = position - player.position
	var scaler = ((relate.x * baseV.x) + (relate.z * baseV.z))
	
	#if player is far too close to thief (Break Circle)
	if(marauderType == enemyTypes.thief and relate.length() < followDistance - 2):
		lerp(speed, 1.2, lerpSpeed)
		var fleeVector = Vector3(0,0,0)
		fleeVector = position - player.position
		fleeVector.y = 0
		fleeVector = fleeVector.normalized()
		targetPos = position + fleeVector * 5
		return
	
	#If player is close enough to gunman, (Pursuit)
	elif(marauderType == enemyTypes.gunman and relate.length() < followDistance + 4 and 
	reloadCooldown <= 0):
		currentMode = behaviors.pursuit
		return
	
	#If enemy is too far away from the herd (Enter Circle)
	elif((herdCenter - position).length() > (2 * followDistance)):
		lerp(speed, 1.0, lerpSpeed)
	
	#If enemy feels too close (Flee in circle)
	else:
		lerp(speed, 1.0, lerpSpeed)
	if(scaler > 0):
		scaler = 1
	else:
		scaler = -1
		
	if(relate.length() < (herdCenter - position).length()):
		currentCircle = scaler
	targetPos = rVec + herdCenter + (baseV.normalized() * circleSpeed * currentCircle)

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
		#Slowing down in desired range
		if(speed > 0):
			speed = (spacing - followDistance) / 3.0
		
		genDynamicMov()
		
		if (canFire):
			var direction = transform.origin - player.transform.origin
			direction = direction.normalized()
			var angle_to = direction.dot(transform.basis.z)
			if angle_to > 0:
				#print("facing player")
				pass
			if(attackCooldown <= 0):
				attack()
				attackCooldown = 3
				clip -= 1
				print("Bullets left: " + str(clip))
				if(clip <= 0):
					print("Reloading")
					clip = clipSize
					reloadCooldown = reloadTime 
					currentMode = behaviors.circle
					speed = 1.0
	
	elif(spacing < followDistance and spacing > followDistance / 2.0):
		#Backing up
		if(speed < 1):
			speed *= followDistance / spacing
		if(speed > 1):
			speed = 1
		
		var fleeVector = Vector3(0,0,0)
		fleeVector = global_transform.origin - player.global_transform.origin
		fleeVector.y = 0
		fleeVector = fleeVector.normalized()
		targetPos = global_transform.origin + fleeVector * 5
	#If thief gets too close
	elif(marauderType == enemyTypes.thief and spacing < followDistance / 2.0):
		print("Panic!")
		currentMode = behaviors.flee
	#If gunman is too close, back up
	elif(marauderType == enemyTypes.gunman and spacing < followDistance / 2.0):
		var fleeVector = Vector3(0,0,0)
		fleeVector = global_transform.origin - player.global_transform.origin
		fleeVector.y = 0
		fleeVector = fleeVector.normalized()
		targetPos = global_transform.origin + fleeVector * 5

	elif(speed < 1):
		speed = 1

func cowPursuit():
	#Marauder runs towards closest cow and attempts to lasso when in range
	#If successful, or cowboy gets too close, the marauder switches to flee mode.
	speed = 1
	if(herd == null):
			herd = get_node(NodePath("/root/Level/Herd"))
			if(herd == null):
				return
	
	if(targetCow == null):
		herd.getClosestCow(position)
		targetCow = herd.getClosestCow(position)
	
	if(herd.numCows <= 0):
		return
	
	if(position.distance_to(targetCow.position) > dragRange):
		targetPos = targetCow.position
	elif(draggedCow == null):
		draggedCow = targetCow
		draggedCow.startDragging(self)
		currentMode = behaviors.flee

#Running away to despawn
func flee():
	#Marauder runs away from cowboy towards offscreen until it despawns.
	#If is currently lassoed to a cow, move speed is slowed.
	#If health gets too low, sever lasso and attempt to escape.
	var spacing = global_transform.origin.distance_to(player.global_transform.origin)
	speed = 1.5
	var fleeVector = position - player.position
	fleeVector = fleeVector.normalized()
	targetPos = global_transform.origin + fleeVector * 5
	
	#Despawn self and cow when successfully stealing cow, free other draggers
	if(draggedCow != null):
		print(draggedCow)
		var distPlayer = spacing #sqrt(pow(player.position.x - position.x, 2) + pow(player.position.y - position.y, 2))
		var centerHerd = herd.findHerdCenter()
		var distCenterHerd = centerHerd.distance_to(player.position) #sqrt(pow(player.position.x - centerHerd.x, 2) + pow(player.position.y - centerHerd.y, 2))
		if(distPlayer > escapeRange && distCenterHerd > escapeRange):
			var leadDragger = null
			var cowTemp = draggedCow
			for i in draggedCow.draggers:
				if(leadDragger == null):
					leadDragger = i
				else:
					i.currentMode = behaviors.circle
				i.targetCow = null
				i.draggedCow = null
			herd.removeCow(cowTemp)
			cowTemp.queue_free()
			leadDragger.queue_free()

#Temporarily retreat
func retreat():
	#Switching to fleeing
	if(draggedCow != null or health < 0.3 * maxHealth):
		currentMode = behaviors.flee
		return
	
	var spacing = global_transform.origin.distance_to(player.global_transform.origin)
	speed = 1.5
	var fleeVector = position - player.position
	fleeVector = fleeVector.normalized()
	targetPos = global_transform.origin + fleeVector * 5
	if(spacing > 3 * followDistance && health > 0.3 * maxHealth):
			currentMode = behaviors.circle

#Function for setting a random direction to add variety to marauder movement
func genDynamicMov():
	if(dynamicCooldown <= 0):
		dynamicMov = Vector3(dynamicMov.x + randf_range(-1.0, 1.0), 0, 
dynamicMov.z + randf_range(-1.0, 1.0))
	else:
		return
	var maxOff = 1.5
	if(dynamicMov.x > maxOff):
		dynamicMov.x = maxOff
	if(dynamicMov.z > maxOff):
		dynamicMov.z = maxOff
	print(dynamicMov)
	dynamicCooldown = randf_range(1.0,3.0)

#navigation function
func moveTo(_targetPos):
	path = NavigationServer3D.map_get_path(get_world_3d().get_navigation_map(),
global_transform.origin, _targetPos, true)
	pathNode = 0

func _on_Timer_timeout():
	moveTo(targetPos)

func attack():
	for x in 1:
		var b = Bullet.instantiate()
		level.add_child(b)
		b.from = "enemy"
		b.global_position = $Marker3D.global_position
		b.rotation = rotation
		_emit_smoke(b)

func _emit_smoke(bullet):
	var newSmoke = Smoke.instantiate()
	bullet.add_child(newSmoke)
	
func knockback(damageSourcePos:Vector3, kSpeed:int):
	if(kIFrames > 0):
		return
	kIFrames = 0.3
	if knockable:
		knockbackDirection = damageSourcePos.direction_to(self.position)
		print(knockbackDirection)
		knockbackDirection.y = 0
		var knockbackStrength = kSpeed * knockbackMod 
		var knockB = knockbackDirection * knockbackStrength
		#print(knockB)
		#position += knockB

func damage_taken(damage, from) -> bool:
	if(from != "enemy"):
		health -= damage
		if health <= 0:
			queue_free()
		return true
	else:
		return false
