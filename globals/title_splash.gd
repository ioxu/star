extends Control

var total_time := 2.5
var fade_time := 0.3


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	$TextureRect.modulate = Color.BLACK
	$Timer.wait_time = total_time
	#await get_tree().create_timer(1.0).timeout
	$Timer.start()


func _process(_delta: float) -> void:
	var v : float = clamp( remap($Timer.time_left, total_time, total_time-fade_time, 0.0, 1.0), 0.0, 1.0 )
	v = v * clamp( remap($Timer.time_left, fade_time, 0.0, 1.0, 0.0), 0.0, 1.0 )
	$TextureRect.modulate = Color(v,v,v,1.0)


func _on_timer_timeout() -> void:
	$Timer.stop()
	await get_tree().create_timer(0.5).timeout
	_end_splash()


func _end_splash() -> void:
	get_tree().change_scene_to_file( "res://globals/game.tscn" )


func _input(event: InputEvent) -> void:
	# eneter to skip, unless +Alt to change ot fullscreen
	var skip = false
	if event is InputEventKey:
		if Input.is_action_just_pressed("ui_accept") and not event.alt_pressed:
			skip = true
	else:
		if Input.is_action_just_pressed("ui_accept"):
			skip = true
	if skip:
		_end_splash()
