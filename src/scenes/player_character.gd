extends CharacterBody3D

const GRAVITY = Vector3(0, -9.9, 0)

@onready var animation_tree = $AnimationTree

var speed: Vector3 = Vector3.ZERO

var is_free = false

const ANIM_SIT_BACKWARD = 0
const ANIM_SIT_FORWARD = 1
const ANIM_FALLING = 2
const ANIM_FACEPLANT = 3

var anim_weights = [ 0.0, 0.0, 0.0, 0.0 ]
var anim_weight_targets = [ 0.0, 0.0, 0.0, 0.0 ]

func set_target_anim(weight_index):
	for i in range(0, anim_weight_targets.size()):
		anim_weight_targets[i] = 0.0
	
	anim_weight_targets[weight_index] = 1.0

func start_falling():
	is_free = true
	$CollisionShape3DNormal.disabled = false
	$CollisionShape3DHurt.disabled = false
	
	# cheating: a bit of a boost because why not :)
	speed = last_speed * 1.2

var last_position: Vector3 = Vector3.ZERO
var last_speed: Vector3 = Vector3.ZERO

func _process(delta: float) -> void:
	for i in range(0, anim_weight_targets.size()):
		anim_weights[i] = lerp(anim_weights[i], anim_weight_targets[i], 0.1)
	
	animation_tree.set("parameters/Blend2/blend_amount", anim_weights[1])
	animation_tree.set("parameters/Blend2 2/blend_amount", anim_weights[2])
	animation_tree.set("parameters/Blend2 3/blend_amount", anim_weights[3])
	
	speed += GRAVITY * delta * 0.6
	
	if self.is_on_floor():
		speed = Vector3.ZERO
	
	if is_free:
		var a = self.move_and_collide(speed * delta)
		if a:
			print(a.get_local_shape())
	else:
		last_speed = (global_position - last_position) * (1/delta)
		last_position = global_position
