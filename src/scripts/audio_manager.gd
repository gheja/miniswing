extends Node

var main_music_player: AudioStreamPlayer = null
var music_pitch = 1.0
var music_pitch_target = 1.0

var sounds = [
	preload("res://assets/sounds/265583__aglinder__wooden-door-01_trim1.ogg"),
	preload("res://assets/sounds/265583__aglinder__wooden-door-01_trim2.ogg"),
	preload("res://assets/sounds/683101__florianreichelt__quick-woosh_trim1.ogg"),
	preload("res://assets/sounds/556322__garuda1982__wine-glass-toast-pling-sound-effect_trim1.ogg"),
	preload("res://assets/sounds/678541__mglennsound__af-crowd-cheer-natural-ending_trim1.ogg"),
	preload("res://assets/sounds/734629__vrymaa__body-fall-heavy-dangerous_trim1.ogg"),
	preload("res://assets/music/incompetech_beauty_flow_edit1.ogg"),
]

var volume_overrides = [
	1.0, 1.0, 1.0, 1.25
]

func play_sound(index, pitch_shift_min: float = 1.0, pitch_shift_max: float = 1.0, volume_multiplier: float = 1.0):
	var tmp = AudioStreamPlayer.new()
	tmp.stream = sounds[index]
	tmp.bus = "SFX"
	
	if volume_overrides.size() > index and volume_overrides[index] != null:
		tmp.volume_db = linear_to_db(volume_overrides[index] * volume_multiplier)
	else:
		tmp.volume_db = linear_to_db(1.0 * volume_multiplier)
	
	if pitch_shift_min != 1.0 or pitch_shift_max != 1.0:
		tmp.pitch_scale = randf_range(pitch_shift_min, pitch_shift_max)
	
	get_tree().root.call_deferred("add_child", tmp)
	
	tmp.play.call_deferred()

func _ready():
	main_music_player = AudioStreamPlayer.new()
	main_music_player.stream = sounds[6]
	main_music_player.volume_db = linear_to_db(volume_overrides[0])
	main_music_player.bus = "Music"
	
	get_tree().root.call_deferred("add_child", main_music_player)
	main_music_player.play.call_deferred()

func set_music_pitch_target(n: float):
	music_pitch_target = n

func _process(_delta):
	music_pitch = lerp(music_pitch, music_pitch_target, 0.075)
	main_music_player.pitch_scale = music_pitch
