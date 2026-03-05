extends CharacterBody2D

# --- Mutable Lane Math ---
@export var max_lanes: int = 6
@export var min_x: float = -1000.0
@export var max_x: float = 1000.0
@export var dodge_speed: float = 0.4 

var target_x: float = 0.0
var lane_positions: Array[float] = []

# --- Vertical Variables ---
@export var camera: Camera2D
@export var strike_zone_offset: float = 150.0

func _ready() -> void:
	# 1. Calculate the array automatically on startup
	var total_width = max_x - min_x
	var lane_spacing = total_width / float(max_lanes - 1)
	
	for i in range(max_lanes):
		lane_positions.append(min_x + (i * lane_spacing))
		
	# 2. Start her in a middle lane (e.g., Lane 2)
	target_x = lane_positions[2]
	global_position.x = target_x

func _physics_process(delta: float) -> void:
	# 1. Dynamically loop through inputs!
	# This automatically checks "lane_0" through "lane_5"
	for i in range(max_lanes):
		if Input.is_action_just_pressed("lane_" + str(i)):
			target_x = lane_positions[i]
			
	# 2. Smoothly dash her to the target X position
	global_position.x = lerp(global_position.x, target_x, dodge_speed)

	# 3. Vertical spring logic
	if camera:
		var target_y = camera.global_position.y + strike_zone_offset + 800
		global_position.y = lerp(global_position.y, target_y, 0.03)

	move_and_slide()
