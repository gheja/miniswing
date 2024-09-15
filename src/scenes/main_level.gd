extends Node3D

const SLOW_DOWN_AMOUNT_PER_SEC = 0.2
const HEIGHT_INCREASE_PER_SEC = 100.0
const SWING_MULTIPLIER = 1.5
const MIN_HEIGHT = 0.5
const MAX_HEIGHT = 160.0

var t = 0.0

# this is not really height but... rather the maximum angle which the swing will swing
var height = 0.0

func _ready() -> void:
	height = 100.0

func _process(delta: float) -> void:
	t += delta
	
	if Input.get_action_strength("action_go") > 0.5:
		height += HEIGHT_INCREASE_PER_SEC * delta
	
	height = height * (1.0 - SLOW_DOWN_AMOUNT_PER_SEC * delta)
	
	height = clamp(height, MIN_HEIGHT, MAX_HEIGHT)
	
	$LevelObjects/SwingThing.rotation_degrees.x = cos(t * SWING_MULTIPLIER) * height
	if $LevelObjects/SwingThing.rotation_degrees.x > 0:
		$LevelObjects/PlayerCharacter/AnimationPlayer.play("sit_forward")
	else:
		$LevelObjects/PlayerCharacter/AnimationPlayer.play("sit_backward")
	$LevelObjects/PlayerCharacter.global_position = $LevelObjects/SwingThing/PivotStart/Construct/Marker3D.global_position
	$LevelObjects/PlayerCharacter.rotation_degrees.x = $LevelObjects/SwingThing.rotation_degrees.x
	
	$Camera3D.look_at($LevelObjects/PlayerCharacter/CameraMarker.global_position)
	
	print(height)
