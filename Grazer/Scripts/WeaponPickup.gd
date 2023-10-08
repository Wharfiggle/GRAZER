#Elijah Southman
extends Area3D

@onready var origPos = position
var time = 0.0
@export var bobSpeed = 3.0
@export var bobStrength = 0.15
@export var spinSpeed = 2.0
var waited = false
var levelScript
var player
@export var revolverPickup = true

func _physics_process(delta):
	if(!waited):
		levelScript = get_node("/root/Level")
		player = levelScript.find_child("Player")
		waited = true
	
	time += delta
	position.y = sin(time * bobSpeed) * bobStrength
	rotation.y += spinSpeed * delta

func _on_body_entered(body):
	if(waited):
		if(body.is_in_group('Player')):
			if(revolverPickup):
				player.noRevolver = false
				player.setWeapon(true)
				player.rightHand = null
			else:
				player.noShotgun = false
				player.setWeapon(false)
				player.rightHand = null
			queue_free()
