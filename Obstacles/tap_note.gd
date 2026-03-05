extends Area2D

@export var perfect_threshold: float = 0.1
var target_time: float = 0.0 
var can_be_hit: bool = false
var has_been_hit: bool = false

@onready var hit_sound: AudioStreamPlayer = $HitSound

func initialize(time: float) -> void:
	target_time = time

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		can_be_hit = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" and not has_been_hit:
		can_be_hit = false
		print("Tap Note: MISSED! (Fell past it)")
		queue_free()

func _process(delta: float) -> void:
	# Check if they are in the zone AND pressed the button this exact frame
	if can_be_hit and not has_been_hit and Input.is_action_just_pressed("jump"):
		hit_note()

func hit_note() -> void:
	has_been_hit = true
	var time_diff = abs(Conductor.song_position - target_time)
	
	if time_diff <= perfect_threshold:
		print("Tap Note: PERFECT!")
	else:
		print("Tap Note: GOOD/EARLY/LATE")
		
	hit_sound.play()
	$Sprite2D.hide()
	
	await hit_sound.finished
	queue_free()
