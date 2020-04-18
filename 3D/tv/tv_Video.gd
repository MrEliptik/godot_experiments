extends Spatial


func _on_VideoPlayer_finished():
	$MeshInstance/Viewport/VideoPlayer.play()
