extends Node3D

const STATE_SWINGING = 0
const STATE_FALLING = 1
const STATE_FAIL = 2
const STATE_SUCCESS = 3

@onready var player_character = $LevelObjects/PlayerCharacter

# to prevent accidental jumps
var input_enabled = false

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
	
	AudioManager.set_music_pitch_target(1.0)
	
	Signals.connect("player_success", on_player_success)
	Signals.connect("player_fail", on_player_fail)

var a = 0.0
var last_a = 0
var press_length = 0

func _process(delta: float) -> void:
	t += delta * 2
	
	a = cos(t) * max_angle
	
	max_angle = lerp(max_angle, target_max_angle, 0.0035)
	
	next_max_angle = next_max_angle * (1 - SLOW_DOWN_AMOUNT_PER_SEC * delta)
	next_max_angle = clamp(next_max_angle, MIN_MAX_ANGLE, MAX_MAX_ANGLE)
	
	if (last_a < 0 and a > 0) or (last_a > 0 and a < 0):
		target_max_angle = next_max_angle
	
	$LevelObjects/SwingThing.rotation_degrees.x = a
	
	if state == STATE_SWINGING:
		process_swinging(delta)
	elif state == STATE_FALLING:
		process_falling(delta)
	
	$CameraContainer/Camera3D.look_at($LevelObjects/PlayerCharacter/CameraMarker.global_position)
	
	last_a = a

func process_swinging(delta: float):
	var sign_a = sign(a - last_a)
	
	player_character.rotation_degrees.x = $LevelObjects/SwingThing.rotation_degrees.x
	
	if input_enabled and Input.get_action_strength("action_go") > 0.5:
		next_max_angle += HEIGHT_INCREASE_PER_SEC * delta * sign_a
		player_character.set_target_anim(player_character.ANIM_SIT_FORWARD)
		press_length += delta
	else:
		player_character.set_target_anim(player_character.ANIM_SIT_BACKWARD)
	
	if input_enabled and Input.is_action_just_released("action_go"):
		if press_length < 0.15:
			player_character.set_target_anim(player_character.ANIM_FALLING)
			player_character.start_falling()
			state = STATE_FALLING
			
			# cheating: the next time the swing will not go that high
			next_max_angle *= 0.75
			
			# some bullett time to give a bit more time to react
			Engine.time_scale = 0.33
			
			$DirectionalLight3D2.light_energy = 1.0
			
			$AnimationPlayer.play("finish")
			
			Signals.emit_signal("player_jumped")
			AudioManager.set_music_pitch_target(0.75)
		
		press_length = 0.0
	
	player_character.global_position = $LevelObjects/SwingThing/PivotStart/Construct/Marker3D.global_position
	
	# print([a, last_a, max_angle, target_max_angle, next_max_angle, sign_a ])
	
	process_audio()

func process_audio():
	if max_angle < 10.0:
		return
	
	var pitch = (max_angle - 10.0) / (MAX_MAX_ANGLE - 10.0)
	
	pitch = 0.6 + pitch * 0.6
	
	# swinging forward
	if last_a + 10 < 0 and a + 10 > 0:
		AudioManager.play_sound(1, pitch, pitch)
		print(pitch)
	
	# swinging backward
	if last_a - 10 > 0 and a - 10 < 0:
		AudioManager.play_sound(0, pitch * 0.8, pitch * 0.8)

func process_falling(delta: float):
	if Input.get_action_strength("action_go") > 0.5:
		press_length += delta
	
	if Input.is_action_just_released("action_go"):
		if press_length < 0.15:
			if player_character.target_rotation.x != 0.0:
				player_character.correct_course()
				
				if player_character.target_rotation.x == 0.0:
					AudioManager.play_sound(3)
				else:
					var pitch = clamp(abs(player_character.target_rotation.x), 0, 90) / 90
					pitch = 0.4 + pitch * 0.6
					AudioManager.play_sound(2, pitch, pitch)
			
		press_length = 0.0

func on_player_success():
	state = STATE_SUCCESS
	
	Engine.time_scale = 1.0
	$DirectionalLight3D2.light_color = Color(0, 1.0, 0)
	player_character.set_target_anim(player_character.ANIM_HAPPY)
	
	AudioManager.set_music_pitch_target(1.0)
	AudioManager.play_sound(4)

func on_player_fail():
	state = STATE_FAIL
	
	Engine.time_scale = 1.0
	$DirectionalLight3D2.light_color = Color(1.0, 0, 0)
	player_character.set_target_anim(player_character.ANIM_FACEPLANT)
	
	AudioManager.set_music_pitch_target(1.0)
	AudioManager.play_sound(5)

func _on_timer_timeout() -> void:
	input_enabled = true
