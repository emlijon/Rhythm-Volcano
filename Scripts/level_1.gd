extends Node2D

@onready var track1_start: AudioStreamPlayer = $Start
@onready var track2_loop: AudioStreamPlayer = $Loop
@onready var track3_main: AudioStreamPlayer = $Main
@onready var camera: Camera2D = $Camera2D
@onready var note_spawner: Node2D = $NoteSpawner

var is_started: bool = false
var is_transitioning: bool = false

func _ready() -> void:
	# 1. Play the first track
	track1_start.play()
	
	# 2. Get the EXACT mathematical length of the audio file in seconds
	var exact_intro_length = track1_start.stream.get_length()
	
	# 3. Wait for that exact time (bypassing the 1-frame signal delay)
	await get_tree().create_timer(exact_intro_length).timeout
	
	# 4. If the player hasn't pressed spacebar yet, start the loop perfectly on beat!
	if not is_started and not is_transitioning:
		track2_loop.play()

func _process(_delta: float) -> void:
	# Listen for the spacebar to start the actual game
	if Input.is_action_just_pressed("jump") and not is_started and not is_transitioning:
		start_main_game()

func start_main_game() -> void:
	is_transitioning = true
	
	# Handle what happens depending on WHEN they pressed space
	if track1_start.playing:
		# If they are impatient and press space during the very first intro track,
		# wait for the intro track to finish, then skip the loop entirely.
		var time_remaining = track1_start.stream.get_length() - track1_start.get_playback_position()
		await get_tree().create_timer(time_remaining).timeout
		track1_start.stop()
		
	elif track2_loop.playing:
		# If they press space during the idle loop, wait for the loop to hit its exact end
		var current_time = track2_loop.get_playback_position()
		var total_length = track2_loop.stream.get_length()
		var time_remaining = total_length - current_time
		
		await get_tree().create_timer(time_remaining).timeout
		track2_loop.stop()
	
	# Swap to the main level music!
	track3_main.play()
	
	Conductor.active_track = track3_main
	
	# Tell the camera it is time to drop, passing the new main track as the timekeeper
	camera.start_scrolling(track3_main)
	
	note_spawner.start_spawning_notes()
	
	is_started = true
