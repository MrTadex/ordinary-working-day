extends Node3D

@onready var _audio = $AudioStreamPlayer3D
@onready var _animation = $AnimatedSprite3D

var alarm = false

func _process(delta):
	if alarm:
		if !_audio.playing:
			_audio.play()
		_animation.play("Alarm")
	else:
		_audio.stop()
		_animation.play("Idle")


func _on_event(eventName):
	if eventName == "Start" or eventName == "Start Alarm":
		alarm = true
		
	if eventName == "Stop Alarm":
		alarm = false
