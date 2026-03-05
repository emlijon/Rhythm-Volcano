extends Node2D

@export var json_file_path: String = "res://level_1.json"
@export var scroll_speed: float = 2000.0
@export var camera: Camera2D
@export var strike_zone_offset: float = 950.0 

@export var obstacle_scenes: Dictionary = {
	"pass": preload("res://Obstacles/PassNote.tscn"),
	"tap": preload("res://Obstacles/TapNote.tscn"),
	"barrier": preload("res://Obstacles/HoldBarrier.tscn")
}

# Updated to include "D" so D3/D4/D5 actually spawn in lane 0
var pitch_to_lane: Dictionary = {
	"D": 0, "D#": 0, "E": 1, "F": 2, "F#": 3, "G": 4
}

var level_data: Array = []

func _ready() -> void:
	load_json_data()

func load_json_data() -> void:
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	var parsed_dict = JSON.parse_string(json_string)
	
	if parsed_dict.has("tracks"):
		level_data.clear()
		# --- THE FIX: Loop through all tracks ---
		for track in parsed_dict["tracks"]:
			if track.has("notes"):
				level_data.append_array(track["notes"])
		print("--- JSON LOADED: Total of ", level_data.size(), " notes collected across all tracks ---")

func start_spawning_notes() -> void:
	if camera == null:
		print("!!! ERROR: Camera not assigned!")
		return
		
	var base_y = camera.global_position.y + strike_zone_offset
	var counts = {"pass": 0, "tap": 0, "barrier": 0, "skipped": 0}
	
	for note_data in level_data:
		var full_note_name: String = note_data["name"]
		var target_time: float = note_data["time"]
		
		# Octave 3 = Barrier, 4 = Pass, 5 = Tap
		var type: String = ""
		if full_note_name.ends_with("3"):
			type = "barrier"
		elif full_note_name.ends_with("4"):
			type = "pass"
		elif full_note_name.ends_with("5"):
			type = "tap"
			
		var pitch = full_note_name.left(full_note_name.length() - 1) 
		
		if type != "" and pitch_to_lane.has(pitch):
			var lane_index = pitch_to_lane[pitch]
			var x_pos = -1000.0 + (lane_index * (2000 / 5))
			var spawn_y = base_y + (target_time * scroll_speed)
			
			create_obstacle(type, target_time, Vector2(x_pos, spawn_y))
			counts[type] += 1
		else:
			counts["skipped"] += 1

	print("--- SPAWN COMPLETE ---")
	print("Barriers (Oct 3): ", counts["barrier"], " | Pass (Oct 4): ", counts["pass"], " | Taps (Oct 5): ", counts["tap"])
	print("Skipped (Other Octaves/Pitches): ", counts["skipped"])

func create_obstacle(type: String, target_time: float, spawn_pos: Vector2) -> void:
	if obstacle_scenes.has(type):
		var obstacle = obstacle_scenes[type].instantiate()
		add_child(obstacle)
		obstacle.global_position = spawn_pos
		if obstacle.has_method("initialize"):
			obstacle.initialize(target_time)
