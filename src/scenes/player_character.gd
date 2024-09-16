extends CharacterBody3D

const GRAVITY = Vector3(0, -9.9, 0)

@onready var animation_tree = $AnimationTree

var speed: Vector3 = Vector3.ZERO

var is_free = false

const ANIM_SIT_BACKWARD = 0
const ANIM_SIT_FORWARD = 1
const ANIM_FALLING = 2
const ANIM_FACEPLANT = 3
const ANIM_SUCCESS = 4
const ANIM_HAPPY = 5

var anim_weights = [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
var anim_weight_targets = [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]

var last_position: Vector3 = Vector3.ZERO
var last_speed: Vector3 = Vector3.ZERO
var target_rotation: Vector3 = Vector3.ZERO

func set_target_anim(weight_index):
	for i in range(0, anim_weight_targets.size()):
		anim_weight_targets[i] = 0.0
	
	anim_weight_targets[weight_index] = 1.0

func start_falling():
	is_free = true
	$CollisionShape3DNormal.disabled = false
	
	target_rotation = self.rotation_degrees
	
	# cheating: a bit of a boost because why not :)
	speed = last_speed * 1.2


func correct_course():
	# we only have rotation on the x axis
	
	if abs(target_rotation.x) < 10:
		target_rotation.x = 0
	elif target_rotation.x < 0:
		target_rotation.x += 10
	elif target_rotation.x > 0:
		target_rotation.x -= 10

func _process(delta: float) -> void:
	for i in range(0, anim_weight_targets.size()):
		anim_weights[i] = lerp(anim_weights[i], anim_weight_targets[i], 0.1)
	
	rotation_degrees = lerp(rotation_degrees, target_rotation, 0.2)
	
	animation_tree.set("parameters/Blend2/blend_amount", anim_weights[1])
	animation_tree.set("parameters/Blend2 2/blend_amount", anim_weights[2])
	animation_tree.set("parameters/Blend2 3/blend_amount", anim_weights[3])
	animation_tree.set("parameters/Blend2 4/blend_amount", anim_weights[4])
	animation_tree.set("parameters/Blend2 5/blend_amount", anim_weights[5])
	
	speed += GRAVITY * delta * 0.6
	
	if self.is_on_floor():
		speed = Vector3.ZERO
	
	if is_free:
		var a = self.move_and_collide(speed * delta)
		
		if a:
			is_free = false
			
			if abs(rotation_degrees.x) < 10:
				Signals.emit_signal("player_success")
				set_target_anim(ANIM_HAPPY)
			else:
				Signals.emit_signal("player_fail")
				set_target_anim(ANIM_FACEPLANT)
		else:
			if abs(rotation_degrees.x) < 10:
				set_target_anim(ANIM_SUCCESS)
	else:
		last_speed = (global_position - last_position) * (1/delta)
		last_position = global_position
	
	print(rotation_degrees)
