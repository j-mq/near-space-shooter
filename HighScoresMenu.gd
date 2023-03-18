extends Node2D

const CONTRACT_NAME = "dev-1679115038294-40250639006395"

onready var scores_grid = $ScoresGrid
onready var player_name_label = $ScoresGrid/PlayerName
onready var player_score_label = $ScoresGrid/PlayerScore

func _ready():
	# First, hide the placeholder labels
	player_name_label.hide()
	player_score_label.hide()
	
	# Next, fetch the high scores and create new labels for each score
	var result = Near.call_view_method(CONTRACT_NAME, "getScores")
	if result is GDScriptFunctionState:
		result = yield(result, "completed")
	if result.has("error"):
		$MessageLabel.show()
	else:
		var data = result.data
		var json_data = JSON.parse(data)
		var high_scores: Array = json_data.result

		# Selection sort
		for i in high_scores.size() - 1:
			var indexOfLargest = i
			for j in range(i+1, high_scores.size()):
				if high_scores[j].value > high_scores[indexOfLargest].value:
					indexOfLargest = j
			if indexOfLargest != i:
				# Swap
				var temp = high_scores[i]
				high_scores[i] = high_scores[indexOfLargest]
				high_scores[indexOfLargest] = temp
		
		for score in high_scores:
			var name_label = player_name_label.duplicate()
			name_label.set_text(score.username)
			scores_grid.add_child(name_label)
			name_label.show()
			
			var score_label = player_score_label.duplicate()
			score_label.set_text(str(score.value))
			scores_grid.add_child(score_label)
			score_label.show()

func _on_BackButton_pressed():
	get_tree().change_scene("res://MainMenu.tscn")
