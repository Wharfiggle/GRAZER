extends CharacterBody3D


@onready var player = get_node("/root/Level/Player")
@onready var terrain = get_node("/root/Level/AllTerrain")
#@onready var nav = get_node("/root/Level/Navigation")
var bullet = preload("res://Prefabs/Bullet.tscn")
var smoke = preload("res://Prefabs/Smoke.tscn")
var revolver
var shootingPoint
var aimDirection = 0
var movementBlend = 0.0
@export var baseAimSpeed = 0.75
var aimLerpSpeed = baseAimSpeed
var itemDropPrefab = preload("res://Prefabs/ItemDrop.tscn")
var itemDrop = null

#audioStream
@onready var Steps = $EFootsteps
@onready var Vocal = $EVoice
@onready var SoundFX = $ESoundFX
#soundFile Preload
var reloadSound = preload("res://sounds/gunsounds/Reload.wav")
var revolverShootSound = preload("res://sounds/gunsounds/Copy of revolverfire.wav")
var damagesound= preload("res://sounds/New Sound FEX/Marauder/Copy of maraudervox5.wav")
var deathSound = preload("res://sounds/New Sound FEX/Marauder/Copy of maraudervox6.wav")
var voice1 = preload("res://sounds/New Sound FEX/Marauder/Copy of maraudervox4.wav")
var voice2 = preload("res://sounds/New Sound FEX/Marauder/Copy of maraudervox2.wav")
var voice3 = preload("res://sounds/New Sound FEX/Marauder/Copy of maraudervox1.wav")
var audioArray = [voice1,voice2,voice3]


var maxHealth = 15.0
var health = maxHealth
var clipSize = 3
var clip = 3
var aimTime = 1
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
var aiming = false
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
var critHit = false
@export var hitColor = Color(1, 1, 0)
@export var critHitColor = Color(1, 0, 0)
@onready var hitFlash = get_node(NodePath("./Model/Armature/Skeleton3D/pants")).get_material_override()
var hitFlashAmount = 0.0
@onready var silhouette = hitFlash.get_next_pass()
@onready var silhouetteColor = silhouette.albedo_color
@onready var animation = get_node(NodePath("./Model/AnimationPlayer/AnimationTree"))

enum behaviors {idle, pursuit, flee, retreat, circle, attack, cowPursuit, hibernate}
var currentMode = behaviors.hibernate
enum enemyTypes {thief, gunman}
@export var marauderType:enemyTypes

var rng = RandomNumberGenerator.new()
@onready var herd = get_node(NodePath("/root/Level/Herd"))
var draggedCow = null
var dragRange = 2.0
var escapeRange = 18
var waited = false

func _ready():
	self.add_to_group('DespawnAtCheckpoint')
	self.add_to_group('Enemy')
	
	position.y = 0
	if(marauderType == enemyTypes.gunman):
		revolver = get_node(NodePath("./Model/Armature/Skeleton3D/GunRight/RevolverOffset/Revolver"))
	if(revolver != null):
		shootingPoint = revolver.find_child("ShootingPoint")
	
	rng.randomize()
	var rn = rng.randf()
	if(rn <= 0.1):
		itemDrop = itemDropPrefab.instantiate()
		
	hitFlash.set_shader_parameter("color", hitColor)

#Called at set time intervals, delta is time elapsed since last call
func _physics_process(delta):
	if(waited == false):
		waited = true
		var origPos = position
		var displaceDir = origPos - player.position
		var tries = 0
		var validLoc = false
		while(validLoc == false && tries < 10):
			validLoc = true
			var ray_query = PhysicsRayQueryParameters3D.new()
			ray_query.from = Vector3(global_position.x + 0.25, 2.5, global_position.z + 0.25)
			ray_query.to = ray_query.from + Vector3(-0.5, -2, -0.5)
			ray_query.hit_from_inside = true
			ray_query.set_collision_mask(0b1111)
			var collision = get_world_3d().direct_space_state.intersect_ray(ray_query)
			if(!collision.is_empty() && collision.collider != self):
				print("try " + str(tries) + ": something in the way")
				validLoc = false
			else: #looking good, check for ground
				position.y = 0
				set_velocity(Vector3(0, -1, 0))
				set_up_direction(Vector3.UP)
				move_and_slide()
				if(!is_on_floor()):
					print("try " + str(tries) + ": no ground")
					validLoc = false
			if(validLoc):
				position.y = 0.1
				print("enemy spawn tries: " + str(tries))
			else:
				position.y = 30
				tries += 1
				var displace = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1))
				if(displaceDir.x < 0 && displace.x < 0 && displaceDir.z < 0 && displace.y < 0):
					var rn = rng.randf()
					if(rn > 0.5):
						displace.x *= -1
					else:
						displace.y *= -1
				position = Vector3(
					origPos.x + 1 * tries * displace.x, origPos.y,
					origPos.z + 1 * tries * displace.y)
				if(tries == 10):
					print("couldn't find valid location for enemy to spawn in, deleting")
					queue_free()
					SceneCounter.marauders -= 1
	
	movementBlend = lerpf(movementBlend, speed, 0.1)
	var temp = 1.0 -  movementBlend
	animation.set("parameters/idleWalk/blend_amount", temp)
	
	if(hitFlashAmount > 0.1):
		hitFlash.set_shader_parameter("amount", hitFlashAmount)
		hitFlashAmount = lerpf(hitFlashAmount, 0, 0.3)
		if(hitFlashAmount < 0.1):

			critHit = false
			hitFlash.set_shader_parameter("amount", 0.0)
	
	if(herd == null):
		herd = get_node(NodePath("/root/Level/Herd"))
	
	#TODO, ENEMY AIMING IS SEPERATE FROM ENEMY ROTATION DIRECTION, FIX
	var rotateTo
	if(!aiming):
		rotateTo = targetPos
	else:
		rotateTo = player.position
	rotation.y = lerp_angle(
		rotation.y,
		atan2(position.x - rotateTo.x, position.z - rotateTo.z) + PI,
		0.1)
	
	if(marauderType == enemyTypes.thief && currentMode == behaviors.circle):
		var rn = randi_range(1, 100)
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
	
	if(currentMode == behaviors.hibernate):
		#print("im hibernating")
		return
		
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
			var tempVel = direction.normalized() * baseSpeed * speed
			tVelocity.x = tempVel.x
			tVelocity.z = tempVel.z
	
	set_velocity(tVelocity)
	if(knockbackTimer > 0 || stunTimer > 0):
		set_velocity(Vector3(knockbackVel.x, tVelocity.y, knockbackVel.z))
	set_up_direction(Vector3.UP)
	move_and_slide()
	
	if(!is_on_floor()):
		var chunk = terrainController.getPlayerChunk(position)
		if(!terrain.activeCoord.has(chunk)):
			#print("gonna hibernate, my chunk: " + str(chunk) + " activeCoords: " + str(terrain.activeCoord))
			position.y = 0
			currentMode = behaviors.hibernate
			if(draggedCow != null):
				herd.removeCow(draggedCow)
				draggedCow.queue_free()
				SceneCounter.cows -= 1
				queue_free()
				SceneCounter.marauders -= 1
	
	if(position.y < -0.5):
		#print("no silhouette for me: " + str(position.y))
		silhouette.set_albedo(Color(0, 0, 0, 0))
#		if(revolver != null):
#			revolver.get_node("./RootNode/Revolver_FULL/Revolver").get_material_override().get_next_pass().albdeo_color = Color(0, 0, 0, 0)
		if(position.y < -20):
			if(draggedCow != null):
				herd.removeCow(draggedCow)
				draggedCow.queue_free()
				SceneCounter.cows -= 1
			queue_free()
			SceneCounter.marauders -= 1
	else:
		silhouette.set_albedo(silhouetteColor)
	
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
				
	if(health <= 3.0):
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

func circle():
	#Marauder circles around the herd. If marauderType is thief, it should 
	#try to avoid the cowboy. If marauderType is gunman, it switches to pursuit
	#when the cowboy gets close.
	if(herd == null or herd.numCows <= 0):
		targetPos = player.position
		return
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
	elif(marauderType == enemyTypes.gunman and relate.length() < followDistance + 6 and 
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
	
	#Slows down when getting close to follow distance
	#If closer than follow distance, back up
	#If closer than half of follow distance, panic and flee
	var spacing = global_transform.origin.distance_to(player.global_transform.origin)
	if((spacing < followDistance + 3 and spacing > followDistance) or aiming):
		#Slowing down in desired range
		if(speed > 0):
			speed = (spacing - followDistance) / 3.0
		if (canFire):
			var direction = transform.origin - player.transform.origin
			direction = direction.normalized()
			aimDirection = lerp_angle(aimDirection, 
				atan2(direction.x, direction.z) + PI, aimLerpSpeed)
			var angle_to = direction.dot(transform.basis.z)
			if angle_to > 0:
				pass
			if(attackCooldown <= 0):
				readyAim()
				attackCooldown = 1.0
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
	var clip_to_play = audioArray[randi() % audioArray.size()] 
	Vocal.stream=clip_to_play
	Vocal.play()
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
			SceneCounter.cows -= 1
			SceneCounter.marauders -= 1

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
#	if(position.distance_to(player.position) > 200):
#		queue_free()
#		SceneCounter.marauders -= 1
	#Wake up distance
	var chunk = terrainController.getPlayerChunk(position)
	if(terrain.activeCoord.has(chunk)):
		currentMode = behaviors.circle
		baseSpeed = 5.5
		GRAVITY = 30
#	if(position.distance_to(player.position) < wakeUpDistance):
#		currentMode = behaviors.circle
#		baseSpeed = 5.5
#		GRAVITY = 30

#navigation function
func moveTo(_targetPos):
	path = NavigationServer3D.map_get_path(get_world_3d().get_navigation_map(),
global_transform.origin, _targetPos, true)
	pathNode = 0

func _on_Timer_timeout():
	moveTo(targetPos)

func readyAim():
	if(aiming):
		return
	aiming = true
	for i in 6:
		speed = 1 - i / 7.0
		aimLerpSpeed = baseAimSpeed * (1 - i / 5.0)
		if(aimLerpSpeed < 0):
			aimLerpSpeed = 0
		if(speed > 1):
			speed = 1
#		movementBlend = lerpf(movementBlend, 1, 0.1)
#		movementBlend = speed
#		animation.set("parameters/idleWalk/blend_amount", movementBlend)
		
		await get_tree().create_timer(aimTime / 5.0).timeout
	attack()
	aiming = false
	speed = 1.0
	aimLerpSpeed = baseAimSpeed

func attack():
	var clip_to_play = audioArray[randi() % audioArray.size()] 
	targetPos = player.global_transform.origin
	Vocal.stream=clip_to_play
	
	
	if(shootingPoint != null):
		Vocal.play()
		#spawns bullet in the direction the muzzle is facing 
		var b = bullet.instantiate()
		
		var direction = transform.origin - player.transform.origin
		direction = direction.normalized()
		var looking = atan2(direction.x, direction.z)
		
		
		
		
		#var bulletRotation = Vector3(0, atan2(direction.x, direction.z) + PI, 0)
		b.shoot(self, "enemy", shootingPoint.global_position, Vector3(0, rotation.y, 0), 15.0, 2.0, false)
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

func knockback(damageSourcePos:Vector3, kSpeed:float, useModifier:bool) -> bool:
	#print("enemy knockback: " + str(damageSourcePos))
	#prevents knockback until knockbackIFramesTimer is zero
#	if(knockbackIFramesTimer > 0):
#		return
#	#activate knockback and IFrames timers
#	knockbackIFramesTimer = knockbackIFrames
	var result = (knockbackTimer == 0)
	if(knockbackTimer > 0 && kSpeed <= knockbackStrength):
		return result
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
	return result

func die():
	#Changing the health to -100000 is to prevent the counter being
	#changed multiple times because of the shotgun bullets.
	Vocal.stream = deathSound
	Vocal.play()
	if(health > -100000):
		SceneCounter.marauders -= 1
		if(draggedCow != null):
			draggedCow.stopDragging(self)
		if(itemDrop != null):
			get_node("/root/Level").add_child(itemDrop)
			itemDrop.position = position
			itemDrop = null
		queue_free()
	health = -100000

func updateHealth(newHP:float):
	health = newHP
	if(health <= 0):
		die()

func damage_taken(damage:float, from:String, inCritHit:bool = false, inBullet:Node = null) -> bool:
	if(from != "enemy"):
		Vocal.stream = damagesound
		if(!Vocal.playing):
			Vocal.play(0.13)
		updateHealth(health - damage)
		hitFlashAmount = 1
		critHit = inCritHit
		if(!critHit):
			hitFlash.set_shader_parameter("color", hitColor)
		else:
			hitFlash.set_shader_parameter("color", critHitColor)
		if(inBullet != null):
			inBullet.bulletStopExtend = 1
		return true
	else:
		return false
