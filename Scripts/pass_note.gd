extends Area2D

@export var perfect_threshold: float = 0.1
@export var good_threshold: float = 0.25

var target_time: float = 0.0 
@onready var hit_sound: AudioStreamPlayer = $HitSound

# Called by your Spawner when it creates the note
func initialize(time: float) -> void:
	target_time = time

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player": # Or body is Player, depending on your setup
		score_note()

func score_note() -> void:
	# Calculate how close they were to the perfect mathematical beat
	var time_diff = abs(Conductor.song_position - target_time)
	
	if time_diff <= perfect_threshold:
		print("Pass Note: PERFECT!")
	elif time_diff <= good_threshold:
		print("Pass Note: GOOD!")
	else:
		print("Pass Note: MISS!") # They touched it, but way off beat
		
	# Play sound, hide the visual, and destroy after sound finishes
	hit_sound.play()
	$Sprite2D.hide()
	$CollisionShape2D.set_deferred("disabled", true) # Stop multiple triggers
	
	await hit_sound.finished
	queue_free()
