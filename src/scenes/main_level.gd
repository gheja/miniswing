extends Node3D

const STATE_SWINGING = 0
const STATE_FALLING = 1
const STATE_FAIL = 2
const STATE_SUCCESS = 3

@onready var player_character = $LevelObjects/PlayerCharacter

const SLOW_DOWN_AMOUNT_PER_SEC = 0.2
const HEIGHT_INCREASE_PER_SEC = 50.0
const SWING_MULTIPLIER = 1.5
const MIN_MAX_ANGLE = 0.5
const MAX_MAX_ANGLE = 160.0

var t = -10.0
var max_angle = 100.0
var next_max_angle
var target_max_angle

var state = STATE_SWINGING

func _ready() -> void:
	max_angle = 50.0
	next_max_angle = max_angle
	target_max_angle = max_angle

var a = 0.0
var last_a = 0

func _process(delta: float) -> void:
	var sign_a
	
	t += delta
	
	a = cos(t) * max_angle
	sign_a = sign(a - last_a)
	
	max_angle = lerp(max_angle, target_max_angle, 0.0035)
	
	next_max_angle = next_max_angle * (1 - SLOW_DOWN_AMOUNT_PER_SEC * delta)
	next_max_angle = clamp(next_max_angle, MIN_MAX_ANGLE, MAX_MAX_ANGLE)
	
	if (last_a < 0 and a > 0) or (last_a > 0 and a < 0):
		target_max_angle = next_max_angle
	
	$LevelObjects/SwingThing.rotation_degrees.x = a
	
	if Input.get_action_strength("action_go") > 0.5:
		next_max_angle += HEIGHT_INCREASE_PER_SEC * delta * sign_a
		player_character.set_target_anim(player_character.ANIM_SIT_FORWARD)
		# $LevelObjects/PlayerCharacter/AnimationPlayer.play("sit_forward")
	else:
		player_character.set_target_anim(player_character.ANIM_SIT_BACKWARD)
		# $LevelObjects/PlayerCharacter/AnimationPlayer.play("sit_backward")
	
	# player_character.set_target_anim(player_character.ANIM_FALLING)
	
	player_character.global_position = $LevelObjects/SwingThing/PivotStart/Construct/Marker3D.global_position
	player_character.rotation_degrees.x = $LevelObjects/SwingThing.rotation_degrees.x
	
	$Camera3D.look_at($LevelObjects/PlayerCharacter/CameraMarker.global_position)
	
	# print([a, last_a, max_angle, target_max_angle, next_max_angle, sign_a ])
	
	last_a = a
