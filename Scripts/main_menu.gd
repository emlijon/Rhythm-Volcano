extends Control

func _on_start_button_pressed() -> void:
	# This instantly destroys the Main Menu and loads the Map Screen!
	get_tree().change_scene_to_file("res://Scenes/MapScreen.tscn")
