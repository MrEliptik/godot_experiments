extends Node

const CommonErrors = preload("../common/CommonErrors.gd")
const SWLogger = preload("../utils/SWLogger.gd")
const UUID = preload("../utils/UUID.gd")

# legacy signals
signal scores_received
signal position_received
signal score_posted

# new signals
signal sw_scores_received
signal sw_position_received
signal sw_scores_around_received
signal sw_score_posted
signal sw_leaderboard_wiped
signal sw_score_deleted

# leaderboard scores by leaderboard name
var leaderboards = {}
# leaderboard scores from past periods by leaderboard name and period_offset (negative integers)
var leaderboards_past_periods = {}
# leaderboard configurations by leaderboard name
var ldboard_config = {}

# contains only the scores from one leaderboard at a time
var scores = []
var local_scores = []
#var custom_local_scores = []
var score_id = ""
var position = 0
var scores_above = []
var scores_below  = []

#var request_timeout = 3
#var request_timer = null

# latest number of scores to be fetched from the backend
var latest_max = 10

var ScorePosition = null
var ScoresAround = null
var HighScores = null
var PostScore = null
var WipeLeaderboard = null
var DeleteScore = null

# wekrefs
var wrScorePosition = null
var wrScoresAround = null
var wrHighScores = null
var wrPostScore = null
var wrWipeLeaderboard = null
var wrDeleteScore = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#connect("request_completed", self, "_on_Scores_request_completed")
	#setup_request_timer()
	
func get_score_position(score, ldboard_name="main"):
	var score_id = null
	var score_value = null
	print("score: " + str(score))
	if UUID.is_uuid(str(score)):
		score_id = score 
	else:
		score_value = score
	ScorePosition = HTTPRequest.new()
	wrScorePosition = weakref(ScorePosition)
	if OS.get_name() != "HTML5":
		ScorePosition.set_use_threads(true)
	get_tree().get_root().call_deferred("add_child", ScorePosition)
	ScorePosition.connect("request_completed", self, "_on_GetScorePosition_request_completed")
	SWLogger.info("Calling SilentWolf to get score position")
	var game_id = SilentWolf.config.game_id
	var game_version = SilentWolf.config.game_version
	var payload = { "game_id": game_id, "game_version": game_version, "ldboard_name": ldboard_name }
	if score_id:
		payload["score_id"] = score_id
	if score_value:
		payload["score_value"] = score_value
	var query = JSON.print(payload)
	var request_url = "https://api.silentwolf.com/get_score_position"
	send_post_request(ScorePosition, request_url, query)
	return self


func get_scores_around(score, scores_to_fetch=3, ldboard_name="main"):
	var score_id = null
	var score_value = null
	print("score: " + str(score))
	if UUID.is_uuid(str(score)):
		score_id = score 
	else:
		score_value = score
	ScoresAround = HTTPRequest.new()
	wrScoresAround = weakref(ScoresAround)
	if OS.get_name() != "HTML5":
		ScoresAround.set_use_threads(true)
	get_tree().get_root().call_deferred("add_child",ScoresAround)
	ScoresAround.connect("request_completed", self, "_on_ScoresAround_request_completed")
	SWLogger.info("Calling SilentWolf backend to scores above and below a certain score...")
	# resetting the latest_number value in case the first requests times out, we need to request the same amount of top scores in the retry
	#latest_max = maximum
	var game_id = SilentWolf.config.game_id
	var game_version = SilentWolf.config.game_version
	var request_url = "https://api.silentwolf.com/get_scores_around/" + str(game_id) + "?version=" + str(game_version) + "&scores_to_fetch=" + str(scores_to_fetch)  + "&ldboard_name=" + str(ldboard_name) + "&score_id=" + str(score_id) + "&score_value=" + str(score_value)
	send_get_request(ScoresAround, request_url)
	return self

func get_high_scores(maximum=10, ldboard_name="main", period_offset=0):
	HighScores = HTTPRequest.new()
	wrHighScores = weakref(HighScores)
	if OS.get_name() != "HTML5":
		HighScores.set_use_threads(true)
	get_tree().get_root().call_deferred("add_child",HighScores)
	HighScores.connect("request_completed", self, "_on_GetHighScores_request_completed")
	SWLogger.info("Calling SilentWolf backend to get scores...")
	# resetting the latest_number value in case the first requests times out, we need to request the same amount of top scores in the retry
	latest_max = maximum
	var game_id = SilentWolf.config.game_id
	var game_version = SilentWolf.config.game_version
	var request_url = "https://api.silentwolf.com/get_top_scores/" + str(game_id) + "?version=" + str(game_version) + "&max=" + str(maximum)  + "&ldboard_name=" + str(ldboard_name) + "&period_offset=" + str(period_offset)
	send_get_request(HighScores, request_url)
	return self
	
func add_to_local_scores(game_result, ld_name="main"):
	var local_score = { "score_id": game_result.score_id, "game_id_version" : game_result.game_id + ";"  + game_result.game_version, "player_name": game_result.player_name, "score": game_result.score }
	local_scores.append(local_score)
	#if ld_name == "main":
		# TODO: even here, since the main leader board can be customized, we can't just blindly write to the local_scores variable and pull up the scores later
		# we need to know what type of leader board it is, or local caching is useless
		#local_scores.append(local_score)
	#else:
		#if ld_name in custom_local_scores:
			# TODO: problem: can't just append here - what if it's a highest/latest/accumulator/time-based leaderboard?
			# maybe don't use local scores for these special cases? performance?
			#custom_local_scores[ld_name].append(local_score)
		#else:
			#custom_local_scores[ld_name] = [local_score]
	SWLogger.debug("local scores: " + str(local_scores))


# metadata, if included should be a dictionary
func persist_score(player_name, score, ldboard_name="main", metadata={}):
	# player_name must be present
	if player_name == null or player_name == "":
		SWLogger.error("ERROR in SilentWolf.Scores.persist_score - please enter a valid player name")
	elif typeof(ldboard_name) != TYPE_STRING:
		# check that ldboard_name, if present is a String
		SWLogger.error("ERROR in ilentWolf.Scores.persist_score - leaderboard name must be a String")
	elif typeof(metadata) != TYPE_DICTIONARY:
		# check that metadata, if present, is a dictionary
		SWLogger.error("ERROR in SilentWolf.Scores.persist_score - metadata must be a dictionary")
	else:
		PostScore = HTTPRequest.new()
		wrPostScore = weakref(PostScore)
		if OS.get_name() != "HTML5":
			PostScore.set_use_threads(true)
		get_tree().get_root().call_deferred("add_child", PostScore)
		PostScore.connect("request_completed", self, "_on_PostNewScore_request_completed")
		SWLogger.info("Calling SilentWolf backend to post new score...")
		var game_id = SilentWolf.config.game_id
		var game_version = SilentWolf.config.game_version
		
		var score_uuid = UUID.generate_uuid_v4()
		score_id = score_uuid
		var payload = { 
			"score_id" : score_id, 
			"player_name" : player_name, 
			"game_id": game_id, 
			"game_version": game_version, 
			"score": score, 
			"ldboard_name": ldboard_name 
		}
		print("!metadata.empty(): " + str(!metadata.empty()))
		if !metadata.empty():
			print("metadata: " + str(metadata))
			payload["metadata"] = metadata
		SWLogger.debug("payload: " + str(payload))
		# also add to local scores
		add_to_local_scores(payload)
		var query = JSON.print(payload)
		var request_url = "https://api.silentwolf.com/post_new_score"
		send_post_request(PostScore, request_url, query)
	return self
		
# Deletes all your scores for your game and version
# Scores are permanently deleted, no going back!
func wipe_leaderboard(ldboard_name='main'):
	WipeLeaderboard = HTTPRequest.new()
	wrWipeLeaderboard = weakref(WipeLeaderboard)
	if OS.get_name() != "HTML5":
		WipeLeaderboard.set_use_threads(true)
	get_tree().get_root().call_deferred("add_child", WipeLeaderboard)
	WipeLeaderboard.connect("request_completed", self, "_on_WipeLeaderboard_request_completed")
	SWLogger.info("Calling SilentWolf backend to wipe leaderboard...")
	var game_id = SilentWolf.config.game_id
	var game_version = SilentWolf.config.game_version
	var payload = { "game_id": game_id, "game_version": game_version, "ldboard_name": ldboard_name }
	var query = JSON.print(payload)
	var request_url = "https://api.silentwolf.com/wipe_leaderboard"
	send_post_request(WipeLeaderboard, request_url, query)
	return self


func delete_score(score_id):
	DeleteScore = HTTPRequest.new()
	wrDeleteScore = weakref(DeleteScore)
	if OS.get_name() != "HTML5":
		DeleteScore.set_use_threads(true)
	get_tree().get_root().call_deferred("add_child", DeleteScore)
	DeleteScore.connect("request_completed", self, "_on_DeleteScore_request_completed")
	SWLogger.info("Calling SilentWolf to delete a score")
	var game_id = SilentWolf.config.game_id
	var game_version = SilentWolf.config.game_version
	var request_url = "https://api.silentwolf.com/delete_score?game_id=" + str(game_id) + "&game_version=" + str(game_version) + "&score_id=" + str(score_id)
	send_get_request(DeleteScore, request_url)
	return self

		
func _on_GetHighScores_request_completed(result, response_code, headers, body):
	SWLogger.info("GetHighScores request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	#print("client status: " + str(HighScores.get_http_client_status()))
	#HighScores.queue_free()
	SilentWolf.free_request(wrHighScores, HighScores)
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/leaderboard")
		else:
			SWLogger.info("SilentWolf get high score success")
			if "top_scores" in response:
				scores = response.top_scores
				SWLogger.debug("scores: " + str(scores))
				var ld_name = response.ld_name
				#print("ld_name: " + str(ld_name))
				var ld_config = response.ld_config
				#print("ld_config: " + str(ld_config))
				if "period_offset" in response:
					var period_offset = str(response["period_offset"])
					leaderboards_past_periods[ld_name + ";" + period_offset] = scores
				else:
					leaderboards[ld_name] = scores
				ldboard_config[ld_name] = ld_config
				#print("latest_scores: " + str(leaderboards))
				emit_signal("sw_scores_received", ld_name, scores)
				emit_signal("scores_received", scores)
	#var retries = 0
	#request_timer.stop()
	
func _on_DeleteScore_request_completed(result, response_code, headers, body):
	SWLogger.info("DeleteScore request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	SilentWolf.free_request(wrDeleteScore, DeleteScore)
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/leaderboard")
		else:
			SWLogger.info("SilentWolf delete score success")
			emit_signal("sw_score_deleted")

		
func _on_PostNewScore_request_completed(result, response_code, headers, body):
	SWLogger.info("PostNewScore request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	#PostScore.queue_free()
	SilentWolf.free_request(wrPostScore, PostScore)
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/leaderboard")
		else:
			SWLogger.info("SilentWolf post score success: " + str(response_code))
			if "score_id" in response:
				emit_signal("sw_score_posted", response["score_id"])
			else:
				emit_signal("sw_score_posted")
				emit_signal("score_posted")


func _on_GetScorePosition_request_completed(result, response_code, headers, body):
	SWLogger.info("GetScorePosition request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	#ScorePosition.queue_free()
	SilentWolf.free_request(wrScorePosition, ScorePosition)
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/leaderboard")
		else:
			SWLogger.info("SilentWolf find score position success.")
			position = response.position
			emit_signal("sw_position_received", position)
			emit_signal("position_received", position)
			
			
func _on_ScoresAround_request_completed(result, response_code, headers, body):
	SWLogger.info("ScoresAround request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	
	SilentWolf.free_request(wrScoresAround, ScoresAround)
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/leaderboard")
		else:
			SWLogger.info("SilentWolf get scores around success")
			if "scores_above" in response:
				scores_above = response.scores_above
				scores_below = response.scores_below
				var ld_name = response.ld_name
				#print("ld_name: " + str(ld_name))
				var ld_config = response.ld_config
				#print("ld_config: " + str(ld_config))
				ldboard_config[ld_name] = ld_config
				if "score_position" in response:
					position = response.score_position
				
				emit_signal("sw_scores_around_received", scores_above, scores_below, position)
			
			
func _on_WipeLeaderboard_request_completed(result, response_code, headers, body):
	SWLogger.info("WipeLeaderboard request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	#WipeLeaderboard.queue_free()
	SilentWolf.free_request(wrWipeLeaderboard, WipeLeaderboard)
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/leaderboard")
		else:
			SWLogger.info("SilentWolf wipe leaderboard success.")
			emit_signal("sw_leaderboard_wiped")


func send_get_request(http_node, request_url):
	var headers = ["x-api-key: " + SilentWolf.config.api_key]
	if !http_node.is_inside_tree():
		yield(get_tree().create_timer(0.01), "timeout")
	http_node.request(request_url, headers) 
	

func send_post_request(http_node, request_url, query):
	var use_ssl = true
	var headers = ["Content-Type: application/json, x-api-key: " + SilentWolf.config.api_key]
	if !http_node.is_inside_tree():
		yield(get_tree().create_timer(0.01), "timeout")
	http_node.request(request_url, headers, use_ssl, HTTPClient.METHOD_POST, query)
