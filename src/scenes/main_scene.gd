extends Node

var color = "#888"
var best_height = 0.0
var press_restart = false
var player_already_won = false

func saveConfig():
	var config = ConfigFile.new()
	
	config.set_value("scores", "best_height", best_height)
	
	config.save("user://config.cfg")

func loadConfig():
	var config = ConfigFile.new()
	var err = config.load("user://config.cfg")
	
	if err != OK:
		return
	
	best_height = config.get_value("scores", "best_height", 0.0)

func prepareConfig():
	var config = ConfigFile.new()
	var err = config.load("user://config.cfg")
	
	if err != OK:
		saveConfig()
		return



func format_height(x: float) -> String:
	return "%.2f" % x

func _ready():
	Signals.connect("player_jumped", on_player_jumped)
	Signals.connect("player_success", on_player_success)
	Signals.connect("player_fail", on_player_fail)
	Signals.connect("player_hit_by_swing", on_player_hit_by_swing)
	
	prepareConfig()
	loadConfig()

func _process(delta: float) -> void:
	var player_character = $MainLevel/LevelObjects/PlayerCharacter
	$MainOverlay/RichTextLabel.text = "[right][color=" + color + "]Height: " + format_height(player_character.max_height) + " meters[/color]\nBest: " + format_height(best_height) + " meters[/right]"
	
	if press_restart:
		if Input.get_action_strength("action_go") > 0.5:
			get_tree().reload_current_scene()

func on_player_jumped():
	color = "#fff"
	
	$MainOverlay/Hint1Label.hide()
	$MainOverlay/Hint2Label.show()

func on_player_success():
	player_already_won = true
	
	$MainOverlay/Hint2Label.hide()
	
	var player_character = $MainLevel/LevelObjects/PlayerCharacter
	
	if player_character.max_height > best_height:
		best_height = player_character.max_height
		saveConfig()
	
	color = "#0f0"
	$Timer.start()
	$Timer2.start()

func on_player_fail():
	if player_already_won:
		return
	
	$MainOverlay/Hint2Label.hide()
	
	color = "#f00"
	$Timer.start()
	$Timer2.start()

func _on_timer_timeout() -> void:
	$MainOverlay/RestartLabel.visible = true

func _on_timer_2_timeout() -> void:
	press_restart = true
	
	$MainOverlay/CreditsContainer.visible = true

func on_player_hit_by_swing():
	$MainOverlay/StillCountsContainer.visible = true
