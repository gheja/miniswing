extends StaticBody3D

func _ready() -> void:
	Signals.connect("player_success", on_player_success)
	Signals.connect("player_hit_by_swing", on_player_hit_by_swing)
	
	$CollisionShape3D.disabled = true

func on_player_success():
	$CollisionShape3D.disabled = false

func on_player_hit_by_swing():
	$CollisionShape3D.disabled = true
