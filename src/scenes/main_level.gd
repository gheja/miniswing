extends Node3D

const SLOW_DOWN_AMOUNT_PER_SEC = 0.2
const SLOW_DOWN_AMOUNT_PER_SWING = 0.3
const HEIGHT_INCREASE_PER_SEC = 50.0
const SWING_MULTIPLIER = 1.5
const MIN_HEIGHT = 0.5
const MAX_HEIGHT = 160.0

var t = 0.0

# this is not really height but... rather the maximum angle which the swing will swing
var height = 0.0

func _ready() -> void:
	height = 100.0
	next_height = height
	target_height = height

var a = 0.0
var last_a = 0.0

var next_height = 0.0
var target_height = 0.0

func _process(delta: float) -> void:
	
	t += delta
	
	var a = cos(t * SWING_MULTIPLIER) * height
	# var a = 
	
	# if just swung by the middle point
	if last_a < 0 and a > 0:
		next_height = clamp(next_height, MIN_HEIGHT, MAX_HEIGHT)
		
		target_height = next_height
		
		next_height = next_height * (1.0 - SLOW_DOWN_AMOUNT_PER_SWING)
	
	# height = height + (target_height)
	height = lerp(height, target_height, 0.1)
	
	$LevelObjects/SwingThing.rotation_degrees.x = a
	
	var change_speed = a - last_a
	
	if change_speed > 0:
		$LevelObjects/PlayerCharacter/AnimationPlayer.play("sit_forward")
	else:
		$LevelObjects/PlayerCharacter/AnimationPlayer.play("sit_backward")
	
	if Input.get_action_strength("action_go") > 0.5:
		next_height += HEIGHT_INCREASE_PER_SEC * delta * sign(change_speed)
	
	$LevelObjects/PlayerCharacter.global_position = $LevelObjects/SwingThing/PivotStart/Construct/Marker3D.global_position
	$LevelObjects/PlayerCharacter.rotation_degrees.x = $LevelObjects/SwingThing.rotation_degrees.x
	
	$Camera3D.look_at($LevelObjects/PlayerCharacter/CameraMarker.global_position)
	
	print([ height, change_speed, a ])
	
	last_a = a
