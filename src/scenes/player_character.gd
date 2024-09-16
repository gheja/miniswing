extends Node3D

@onready var animation_tree = $AnimationTree

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

func _process(delta: float) -> void:
	for i in range(0, anim_weight_targets.size()):
		anim_weights[i] = lerp(anim_weights[i], anim_weight_targets[i], 0.1)
	
	animation_tree.set("parameters/Blend2/blend_amount", anim_weights[1])
	animation_tree.set("parameters/Blend2 2/blend_amount", anim_weights[2])
	animation_tree.set("parameters/Blend2 3/blend_amount", anim_weights[3])
