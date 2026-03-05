extends Camera2D

@export var scroll_speed: float = 2000.0
@export var camera_smooth: float = 0.15  # SMALL smoothing to kill jitter

var start_y: float
var active_music: AudioStreamPlayer = null
var is_scrolling: bool = false

func _ready() -> void:
	# Just remember where we started, do play any music here
	start_y = global_position.y

func start_scrolling(main_track: AudioStreamPlayer) -> void:
	# The Level1 Director calls this when the Spacebar transition finishes
	start_y = global_position.y
	active_music = main_track
	is_scrolling = true

func _physics_process(delta: float) -> void:
	# The camera is locked in place UNTIL is_scrolling becomes true
	if is_scrolling and active_music and active_music.playing:
		var current_time = active_music.get_playback_position()
		var target_y = start_y + (current_time * scroll_speed)
		
		# Tiny smoothing to avoid jitter feedback loop
		global_position.y = lerp(global_position.y, target_y, camera_smooth)
