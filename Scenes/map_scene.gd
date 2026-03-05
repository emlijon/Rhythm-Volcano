extends Control

func _on_unity_level_1_pressed() -> void:
	# Let's drop into the volcano!
	get_tree().change_scene_to_file("res://Scenes/Level1.tscn")
