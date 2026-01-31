#@tool
extends Control

var total_time := 3.0
var fade_time := 0.15
#var timer_has_started := false

@onready var text : TextureRect = find_child("text_texture")
@onready var video : VideoStreamPlayer = find_child("VideoStreamPlayer")


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	video.play()
	video.loop = true
	video.modulate = Color.BLACK
	text.modulate = Color.BLACK
	$Timer.wait_time = total_time
	await get_tree().create_timer(0.5).timeout
	
	$Timer.start()
	#timer_has_started = true


func _process(_delta: float) -> void:
	var v : float = clamp( remap($Timer.time_left, total_time, total_time-fade_time, 0.0, 1.0), 0.0, 1.0 )
	v = v * clamp( remap($Timer.time_left, fade_time, 0.0, 1.0, 0.0), 0.0, 1.0 )
	var c = Color(v,v,v,1.0)
	video.modulate = c
	text.modulate = c


func _on_timer_timeout() -> void:
	$Timer.stop()
	await get_tree().create_timer(0.5).timeout
	if not Engine.is_editor_hint():
		_end_splash()
	else:
		$Timer.start()


func _end_splash() -> void:
	get_tree().change_scene_to_file( "res://globals/title_splash.tscn" )


func _input(event: InputEvent) -> void:
	var skip = false
	# eneter to skip, unless +Alt to change ot fullscreen
	if event is InputEventKey:
		if Input.is_action_just_pressed("ui_accept") and not event.alt_pressed:
			skip = true
	else:
		if Input.is_action_just_pressed("ui_accept"):
			skip = true
			
	if skip:
		_end_splash()
		
