extends Node2D

func _on_StartButton_pressed():
	get_tree().change_scene("res://Gameplay.tscn")

func _on_ExitButton_pressed():
	get_tree().quit()


func _on_HighScoresButton_pressed():
	get_tree().change_scene("res://HighScoresMenu.tscn")
