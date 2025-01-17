extends CharacterBody3D

@export var mouse_sensitivity := 0.05 

var held_object: RigidBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _camera:Camera3D = $Camera3D
@onready var _raycast:RayCast3D = _camera.get_node("./RayCast3D")
@onready var _holdPoint:Node3D = _camera.get_node("./HoldPoint")

@onready var _audio = $AudioStreamPlayer3DWalk
@onready var _audioPlayer = $AudioStreamPlayer3DStartUp
@onready var _audioReact = $AudioStreamPlayer3DReact
@onready var _timer = $Timer

var jumpArray = [
					preload("res://resources/sound_music/player_sound/script_24_huah1.ogg"),
					preload("res://resources/sound_music/player_sound/script_25_huah2.ogg"),
					preload("res://resources/sound_music/player_sound/script_26_huah3.ogg")
				]

var array = [
				preload("res://resources/sound_music/player_sound/script_36_luka_minecraft.ogg"),
				preload("res://resources/sound_music/player_sound/script_29_vroom.ogg"),
				preload("res://resources/sound_music/player_sound/script_36_luka_minecraft.ogg"),
				preload("res://resources/sound_music/player_sound/script_16_fish_5_laugh1.ogg"),
				preload("res://resources/sound_music/player_sound/script_39_luka_on_it.ogg"),
				preload("res://resources/sound_music/player_sound/Ring_bell_first.ogg"),
				preload("res://resources/sound_music/player_sound/script_13_fish_2.ogg"),
				preload("res://resources/sound_music/player_sound/script_37_luka_yeah_boi.ogg"),
				preload("res://resources/sound_music/player_sound/script_38_luka_love_the_tunes.ogg"),
				preload("res://resources/sound_music/player_sound/script_20_drop_the_ball.ogg")
			]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		_audio.stop()
		_audioReact.stream = jumpArray[randi_range(0,2)]
		_audioReact.playing = true
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if !_audio.playing and is_on_floor() and velocity.y == 0:
			_audio.play()

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		_audio.stop()

	move_and_slide()
	
	if Input.is_action_just_pressed("right_click"):
		if held_object:
			held_object.freeze = false
			var forceDir = to_global(_raycast.target_position) - _raycast.global_position
			#print(forceDir + Vector3(0,2,0))
			held_object.apply_central_impulse((forceDir + Vector3(0,2,0)) * 5)
			held_object = null
	#
	if Input.is_action_just_pressed("left_click"):
		if held_object:
			held_object.freeze = false
			held_object = null
		else:
			if _raycast.get_collider():
				if(_raycast.get_collider().get_class() == "RigidBody3D"):
					held_object = _raycast.get_collider()
					held_object.freeze = true
					#print(held_object)
				elif(_raycast.get_collider().is_in_group("Interactable")):
					_raycast.get_collider().clicked()
	
	if held_object:
		held_object.position = _holdPoint.global_transform.origin
	
func _process(_delta):
	_camera.position = Vector3(position.x, position.y + 0.6, position.z)

	if _raycast.get_collider():
		#print(_raycast.get_collider().name)
		if _audioReact.playing == false:
			if _raycast.get_collider().name.contains("panties"):
				if _audioPlayer.playing == false:
					_audioPlayer.stream = array[3]
					_audioPlayer.play()
			if _raycast.get_collider().name == "Mirror":
				if _audioPlayer.playing == false:
					_audioPlayer.stream = array[7]
					_audioPlayer.play()

			if _raycast.get_collider().name == "fish" and Logger.CanFish and !Logger.SeenFish:
				Logger.SeenFish = true
				get_tree().call_group("EventListeners", "_on_event", "SeeFish")
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		
		_camera.rotation_degrees.x -= event.relative.y * mouse_sensitivity
		_camera.rotation_degrees.x = clampf(_camera.rotation_degrees.x, -90.0, 90.0)
		#print_debug(_camera.rotation_degrees.x)
		
		_camera.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		_camera.rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
		
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
	pass

func _on_event(eventName):
	match eventName:
		"Car React":
			#play_with_delay(array[1], 0)
			_audioPlayer.stream = array[1]
			_audioPlayer.playing = true
		"Tree React":
			play_with_delay(array[2], 1)
		"Player intro react":
			play_with_delay(array[4], 1)
			#_audioPlayer.stream = array[4]
			#_audioPlayer.playing = true
		"Ring Bell Dialogue":
			play_with_delay(array[5], 1)
		"SeeFish":
			get_tree().call_group("EventListeners", "_on_event", "NarratorFishReact")
		#"SeePanties":
			#print("panties")
			#_audioPlayer.stream = array[3]
			#_audioPlayer.playing = true
		"Player intro fish react":
			play_with_delay(array[6], 0)
		"Radio love listening":
			play_with_delay(array[8], 4)
		"End":
			queue_free()

# delay func and var
var path = null

func play_with_delay(audioPath, time):
	path = audioPath
	_timer.start(time)

func _on_timer_timeout():
	#_audioPlayer.volume_db = 20
	#_audioPlayer.max_db = 10
	_audioPlayer.stream = path
	_audioPlayer.play()
