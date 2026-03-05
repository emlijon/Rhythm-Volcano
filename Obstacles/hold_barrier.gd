extends StaticBody2D

@export var required_hold_time: float = 0.1 # Must hold for half a second to break it
var current_hold_time: float = 0.0
var player_is_on_barrier: bool = false

@onready var charge_sound: AudioStreamPlayer = $AudioStreamPlayer
@onready var sprite: Sprite2D = $Sprite2D

func _on_hold_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_is_on_barrier = true

func _on_hold_trigger_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_is_on_barrier = false
		current_hold_time = 0.0 # Reset if they fall off
		charge_sound.stop()

func _process(delta: float) -> void:
	if player_is_on_barrier:
		# is_action_pressed checks if the button is currently being HELD DOWN
		if Input.is_action_pressed("jump"):
			current_hold_time += delta
			
			# Visual feedback: Make it shake or change color as it charges
			sprite.modulate = Color(1, 1 - (current_hold_time/required_hold_time), 1)
			
			if not charge_sound.playing:
				charge_sound.play()
				
			# Did they hold it long enough?
			if current_hold_time >= required_hold_time:
				break_barrier()
		else:
			# If they let go early, lose progress!
			current_hold_time = 0.0
			sprite.modulate = Color(1, 1, 1)
			charge_sound.stop()

func break_barrier() -> void:
	print("BARRIER BROKEN!")
	# Play a shatter sound here if you want!
	
	# The moment we queue_free, the physical floor vanishes.
	# The player's vertical_spring_strength will instantly yank them 
	# back down the screen to catch up to the camera!
	queue_free()
