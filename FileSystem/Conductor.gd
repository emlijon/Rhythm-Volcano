extends Node

# This is the single source of truth for the entire game
var song_position: float = 0.0
var active_track: AudioStreamPlayer = null

func _process(_delta: float) -> void:
	if active_track and active_track.playing:
		# High-precision time calculation to account for hardware audio latency
		var time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
		song_position = active_track.get_playback_position() + time_delay
