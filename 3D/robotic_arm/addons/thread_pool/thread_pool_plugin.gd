tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("ThreadPool", "Node", preload("thread_pool.gd"), preload("thread.png"))
	add_custom_type("FutureThreadPool", "Node", preload("future_thread_pool.gd"), preload("thread.png"))

func _exit_tree():
	remove_custom_type("ThreadPool")
	remove_custom_type("FutureThreadPool")
