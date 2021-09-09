extends Node2D

const ScoreItem = preload("SmallScoreItem.tscn")
const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd")

var ld_names = ["Weekly", "Monthly", "main"]

func _ready():
	SilentWolf.Scores.connect("sw_scores_received", self, "_on_scores_received")
	#var scores = SilentWolf.Scores.scores
	add_loading_scores_message()
	SilentWolf.Scores.get_high_scores(10, "main")
	# the other leaderboard scores will be called once the main call in finished 
	# (see signal connected above and _on_scores_received function below)
	# when all the scores are loaded the leaderboard scene can be opened


func render_boards(leaderboards):
	#print("leaderboards: " + str(leaderboards))
	var board_number = 0
	for board in leaderboards:
		var list_index = 1
		#print("ld name: " + str(ld_names[board_number]))
		#print("ld scores: " + str(board))
		for score in board:
			add_item(ld_names[board_number], score.player_name, str(int(score.score)), list_index)
			list_index += 1
		board_number += 1


func add_item(ld_name, player_name, score, list_index):
	var item = ScoreItem.instance()
	item.get_node("PlayerName").text = str(list_index) + str(". ") + player_name
	item.get_node("Score").text = score
	item.margin_top = list_index * 100
	get_node("MainContainer/Boards/" + ld_name + "/HighScores/ScoreItemContainer").add_child(item)


func add_no_scores_message():
	var item = $"MainContainer/MessageContainer/TextMessage"
	item.text = "No scores yet!"
	$"MainContainer/MessageContainer".show()
	item.margin_top = 135


func add_loading_scores_message():
	var item = $"MainContainer/MessageContainer/TextMessage"
	item.text = "Loading scores..."
	$"MainContainer/MessageContainer".show()
	item.margin_top = 135


func hide_message():
	$"MainContainer/MessageContainer".hide()


func _on_CloseButton_pressed():
	var scene_name = SilentWolf.scores_config.open_scene_on_close
	SWLogger.info("Closing SilentWolf leaderboard, switching to scene: " + str(scene_name))
	#global.reset()
	get_tree().change_scene(scene_name)


func _on_scores_received(ld_name, scores):
	if ld_name == "main":
		SilentWolf.Scores.get_high_scores(10, "Weekly")
		#SilentWolf.Scores.get_high_scores(10, "Weekly", -1)
	elif ld_name == "Weekly":
		SilentWolf.Scores.get_high_scores(10, "Monthly")
	else:
		#print("SilentWolf.Scores.leaderboards: " + str(SilentWolf.Scores.leaderboards))
		var ld_scores = []
		for i in [0, 1, 2]:
			if ld_names[i] in SilentWolf.Scores.leaderboards:
				ld_scores.append(SilentWolf.Scores.leaderboards[ld_names[i]])
			#elif (ld_names[i] + ";-1") in SilentWolf.Scores.leaderboards_past_periods:
			#	ld_scores.append(SilentWolf.Scores.leaderboards_past_periods[(ld_names[i] + ";-1")])
			else:
				ld_scores.append([])
		hide_message()
		render_boards(ld_scores)
