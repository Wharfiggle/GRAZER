extends CharacterBody3D


@onready var player = get_node("/root/Level/Player")
#@onready var nav = get_node("/root/Level/Navigation")
@onready var level = get_tree().root.get_child(0)
var bullet = preload("res://Prefabs/Bullet.tscn")
var smoke = preload("res://Prefabs/Smoke.tscn")
@onready var revolver = get_node(NodePath("./Revolver"))
var shootingPoint

#audioStream
@onready var Steps = $EFootsteps
@onready var Vocal = $EVoice
@onready var SoundFX = $ESoundFX
#soundFile Preload
var reloadSound = preload("res://sounds/gunsounds/Reload.wav")
var revolverShootSound = preload("res://sounds/gunsounds/Copy of revolverfire.wav")

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
var baseSpeed = 5.5
var speed = 1.0
var followDistance = 7.0 + randf_range(-1,1)
var fleeDirection = -1 #1 to flee towards position z (backwards), -1 towards negative (forwards)
var herdRadius = 10 + randf_range(-2,2)
var currentCircle = 1
var tVelocity = Vector3.ZERO
var GRAVITY = 30 #hibernate() sets this to 30, so both need to be changed when modified

#Distance from player when the enemy will stop hibernating
var wakeUpDistance = 20.0
var canFire = true
var fireDirection
@export var knockbackMod = 2.0
#@export var knockbackIFrames = 0.3
#var knockbackIFramesTimer = 0.0
@export var knockbackTime = 0.6
var knockbackTimer = 0.0
var knockbackVel = Vector3(0,0,0)
var knockbackStrength = 0
@onready var knockbox = $knockbox
@export var stunTime = 1.0
var stunTimer = 0

enum behaviors {idle, pursuit, flee, retreat, circle, attack, cowPursuit, hibernate}
var currentMode = behaviors.hibernate
enum enemyTypes {thief, gunman}
@export var marauderType:enemyTypes

var rng = RandomNumberGenerator.new()
@onready var herd = get_node(NodePath("/root/Level/Herd"))
var draggedCow = null
var dragRange = 3.0
var escapeRange = 18

func _ready():
	if(revolver != null):
		shootingPoint = revolver.find_child("ShootingPoint")
#	#Setting enemy type
#	if(marauderType == null):
#		if(randi_range(0,1) == 0):
#			marauderType = enemyTypes.thief
#		else:
#			marauderType = enemyTypes.gunman
#	if(marauderType == enemyTypes.gunman):
#		$Mesh.scale = Vector3(1,0.7,1)

#Called at set time intervals, delta is time elapsed since last call
func _physics_process(delta):
	if(dynamicCooldown > 0):
		dynamicCooldown -= delta
	lerp(dynamicMov.x,0.0,0.1)
	lerp(dynamicMov.z,0.0,0.1)
	
	if(herd == null):
		herd = get_node(NodePath("/root/Level/Herd"))
	
	#TODO ADD RAYCAST TO CHECK IF CHUNK IS UNLOADED
	if(position.distance_to(player.position) > 50):
		currentMode = behaviors.hibernate
	
	rotation.y = lerp_angle(
		rotation.y,
		atan2(position.x - targetPos.x, position.z - targetPos.z) + PI,
		0.1)
	
	if(marauderType == enemyTypes.thief && currentMode == behaviors.circle):
		var rn = randi_range(1, 600)
		if(rn == 1):
			currentMode = behaviors.cowPursuit
		var cows = herd.getCows()
		for i in cows.size():
			if(position.distance_to(cows[i].position) < dragRange):
				currentMode = behaviors.cowPursuit
	
	
	if(reloadCooldown > 0):
		reloadCooldown -= delta
	if(attackCooldown > 0):
		attackCooldown -= delta
	
	if(knockbackTimer == 0 && stunTimer == 0):
		match[currentMode]: #Essentially a switch statement
			[behaviors.idle]:
				idle()
			[behaviors.circle]:
				circle()
			[behaviors.pursuit]:
				pursuit()
			[behaviors.cowPursuit]:
				cowPursuit()
			[behaviors.flee]:
				flee()
			[behaviors.retreat]:
				retreat()
			[behaviors.hibernate]:
				hibernate()
	
	#gravity
	tVelocity.y -= GRAVITY * delta
	if(is_on_floor()):
		tVelocity.y = -0.1
	
	if(pathNode < path.size()):
		var direction = (path[pathNode] - global_transform.origin)
		if(direction.length() < 1):
			pathNode += 1
		else:
			#set velocity to account for changes in direction but leave gravity alone
			var tempVel = direction.normalized() * baseSpeed * speed + dynamicMov
			tVelocity.x = tempVel.x
			tVelocity.z = tempVel.z
	
	set_velocity(tVelocity)
	if(knockbackTimer > 0 || stunTimer > 0):
		set_velocity(Vector3(knockbackVel.x, tVelocity.y, knockbackVel.z))
	set_up_direction(Vector3.UP)
	move_and_slide()
	
	if(position.y < -20):
		if(draggedCow != null):
			herd.removeCow(draggedCow)
			draggedCow.queue_free()
		queue_free()
	
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
		if(currentMode != behaviors.flee):
			var m = position.z - player.position.z
			fleeDirection = m / abs(m)
		
		currentMode = behaviors.flee
	
	#knockback timer
	if(knockbackTimer > 0):
		knockbackTimer -= delta
		if(knockbackTimer < 0):
			knockbackTimer = 0
			knockbackStrength = 0
			stunTimer = stunTime
		#lerp speed towards 0 on a square root curve
		var t = knockbackTimer / knockbackTime
		t = pow(t, 2)
		knockbackVel = knockbackVel.normalized() * t * knockbackStrength
		knock()
	elif(stunTimer > 0):
		stunTimer -= delta
		if(stunTimer < 0):
			stunTimer = 0
	#knockback iframes timer
#	elif(knockbackIFramesTimer > 0):
#		knockbackIFramesTimer -= delta
#		if(knockbackIFramesTimer < 0):
#			knockbackIFramesTimer = 0

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
	var circleSpeed = 2.0
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
	if(rVec.z == 0):
		baseB = 0
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
		lerp(speed, 1.0, lerpSpeed) # got an error here. "cannot convert argument 2 from float to Nil"
	
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
	
#	if(marauderType == enemyTypes.thief and randi_range(1,1000) <= 1):
#		currentMode = behaviors.cowPursuit

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
				pass
			if(attackCooldown <= 0):
				attack(direction)
				attackCooldown = 3
				clip -= 1
				#print("Bullets left: " + str(clip))
				if(clip <= 0):
					#setting sound to reload
					SoundFX.stream = reloadSound
					#SoundFX.play()
					#print("Reloading")
					clip = clipSize
					reloadCooldown = reloadTime 
					currentMode = behaviors.circle
					speed = 1.0
	
	elif(spacing < followDistance and spacing > followDistance / 2.0):
		#Backing up
		if(speed < 1):
			speed *= followDistance / spacing
			if(spacing == 0):
				speed = 0.0
		if(speed > 1):
			speed = 1.0
		
		var fleeVector = Vector3(0,0,0)
		fleeVector = global_transform.origin - player.global_transform.origin
		fleeVector.y = 0
		fleeVector = fleeVector.normalized()
		targetPos = global_transform.origin + fleeVector * 5
	#If thief gets too close
	elif(marauderType == enemyTypes.thief and spacing < followDistance / 2.0):
		#print("Panic!")
		currentMode = behaviors.flee
	#If gunman is too close, back up
	elif(marauderType == enemyTypes.gunman and spacing < followDistance / 2.0):
		var fleeVector = Vector3(0,0,0)
		fleeVector = global_transform.origin - player.global_transform.origin
		fleeVector.y = 0
		fleeVector = fleeVector.normalized()
		targetPos = global_transform.origin + fleeVector * 5

	elif(speed < 1):
		speed = 1.0

func cowPursuit():
	#Marauder runs towards closest cow and attempts to lasso when in range
	#If successful, or cowboy gets too close, the marauder switches to flee mode.
	speed = 1.0
	if(herd == null):
			herd = get_node(NodePath("/root/Level/Herd"))
			if(herd == null):
				return
	
	#if(targetCow == null):
	targetCow = herd.getClosestCow(position)
	if(targetCow == null):
		currentMode = behaviors.circle
	
	if(herd.numCows <= 0):
		return
	
	if(targetCow != null && position.distance_to(targetCow.position) > dragRange):
		targetPos = targetCow.position
	elif(targetCow != null && draggedCow == null):
		draggedCow = targetCow
		draggedCow.startDragging(self)
		#print("toFlee")
		currentMode = behaviors.flee
		var m = position.z - player.position.z
		fleeDirection = m / abs(m)

#Running away to despawn
func flee():
	#Marauder runs away from cowboy towards offscreen until it despawns.
	#If is currently lassoed to a cow, move speed is slowed.
	#If health gets too low, sever lasso and attempt to escape.
	var spacing = global_transform.origin.distance_to(player.global_transform.origin)
	speed = 1.5
	var fleeVector = position - player.position + Vector3(0,0, fleeDirection * abs(position.x / 8.0))
	#TODO Add check to see if enemy is at edge chunk and if so causes it to move only along z axis
	if(abs(terrainController.getPlayerChunk(position).x) >= terrainController.mapWidth):
		fleeVector.x = 0
	fleeVector = fleeVector.normalized()
	targetPos = global_transform.origin + fleeVector * 5
	
	#Despawn self and cow when successfully stealing cow, free other draggers
	if(draggedCow != null):
		#print(draggedCow)
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
					#print("toCircle")
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
		#print("toFlee")
		currentMode = behaviors.flee
		return
	
	var spacing = global_transform.origin.distance_to(player.global_transform.origin)
	speed = 1.5
	var fleeVector = position - player.position
	fleeVector = fleeVector.normalized()
	targetPos = global_transform.origin + fleeVector * 5
	if(spacing > 3 * followDistance && health > 0.3 * maxHealth):
			currentMode = behaviors.circle

func hibernate():
	GRAVITY = 0
	baseSpeed = 0
	#Despawn distance
	if(position.distance_to(player.position) > 200):
		queue_free()
	#Wake up distance
	if(position.distance_to(player.position) < wakeUpDistance):
		currentMode = behaviors.circle
		baseSpeed = 5.5
		GRAVITY = 30


#Function for setting a random direction to add variety to marauder movement
func genDynamicMov():
	return
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
	#print(dynamicMov)
	dynamicCooldown = randf_range(1.0,3.0)

#navigation function
func moveTo(_targetPos):
	path = NavigationServer3D.map_get_path(get_world_3d().get_navigation_map(),
global_transform.origin, _targetPos, true)
	pathNode = 0

func _on_Timer_timeout():
	moveTo(targetPos)

func attack(direction:Vector3):
	if(shootingPoint != null):
		#spawns bullet in the direction the muzzle is facing 
		var b = bullet.instantiate()
		var bulletRotation = Vector3(0, atan2(direction.x, direction.z) + PI, 0)
		b.shoot(self, "enemy", shootingPoint.global_position, bulletRotation, 15.0, 2.0)
		var smokeInstance = smoke.instantiate()
		var boomSound = b.find_child("Boom")
		boomSound.stream = revolverShootSound
		boomSound.play(.55)
		shootingPoint.add_child(smokeInstance)
		smokeInstance.position = Vector3.ZERO
		smokeInstance.get_child(0).emitting = true
		smokeInstance.get_child(1).emitting = true
	else:
		shootingPoint = revolver.find_child("ShootingPoint")

func knock():
	var enemies = knockbox.get_overlapping_bodies()
	for enemy in enemies:
		if(enemy != self && enemy.has_method("knockback")):
			enemy.knockback(position, knockbackVel.length(), false)

func knockback(damageSourcePos:Vector3, kSpeed:float, useModifier:bool):
	#prevents knockback until knockbackIFramesTimer is zero
#	if(knockbackIFramesTimer > 0):
#		return
#	#activate knockback and IFrames timers
#	knockbackIFramesTimer = knockbackIFrames
	if(knockbackTimer > 0 || kSpeed < 0.1):
		return
	knockbackTimer = knockbackTime
	#set knockbackVel to the direction vector * speed
	knockbackVel = damageSourcePos.direction_to(self.position)
	knockbackVel.y = 0
	knockbackStrength = kSpeed
	if(useModifier):
		knockbackStrength *= knockbackMod
	knockbackVel *= knockbackStrength
	if(draggedCow != null):
		draggedCow.stopDragging(self)
		draggedCow = null
		currentMode = behaviors.cowPursuit

func damage_taken(damage, from) -> bool:
	if(from != "enemy"):
		health -= damage
		if health <= 0:
			if(draggedCow != null):
				draggedCow.stopDragging(self)
			queue_free()
			#print("dead")
		return true
	else:
		return false
