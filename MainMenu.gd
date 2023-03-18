extends Node2D

#Check if connection exists, if not, connnect to testnet
var config = {
	"network_id": "testnet",
	"node_url": "https://rpc.testnet.near.org",
	"wallet_url": "https://wallet.testnet.near.org",
}

func _ready():
	if Near.near_connection == null:
		Near.start_connection(config)

func _on_StartButton_pressed():
	get_tree().change_scene("res://Gameplay.tscn")

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_HighScoresButton_pressed():
	get_tree().change_scene("res://HighScoresMenu.tscn")
