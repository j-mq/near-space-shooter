extends Node2D

const CONTRACT_NAME = "dev-1679115038294-40250639006395"

onready var game_ui = $UILayer/GameUI
onready var animation_player = $AnimationPlayer
onready var spawn_system = $SpawnSystem
onready var player = $Player

var wallet_connection

func _ready():
	wallet_connection = WalletConnection.new(Near.near_connection)
	game_ui.set_lives(3)
	game_ui.set_score(0)
	animation_player.play("intro")

func _on_Player_life_lost(remaining_lives: int):
	if remaining_lives < 0:
		animation_player.play("game_over")
		spawn_system.stop_spawning()
		if wallet_connection.is_signed_in():
			var args = {"newScore": game_ui.score}
			wallet_connection.call_change_method(CONTRACT_NAME, "submitScore", args)
	else:
		game_ui.remove_life()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "intro":
		spawn_system.start_spawning()
		player.state = player.States.ALIVE
