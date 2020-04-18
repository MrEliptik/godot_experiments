extends Spatial

func _on_VideoPlayer_finished():
		$tv/Viewport/VideoPlayer.play()
