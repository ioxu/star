extends Node

@export var state : GameState
@export var subviewport_container : SubViewportContainer

var new_game_button : Button
var settings_button : Button

@onready var player_test_scene_button : Button = find_child("player_test_scene_button")
@onready var test_level_2_button : Button = find_child("test_level_2_button")

var graphics_fadeup_time := 0.5
var viewport_fadeup_time := 0.3
var viewport_fadeup_start := 0.5
var finished_fadeups := false

var total_time := 4.0

signal new_game_button_pressed
signal settings_button_pressed


func _ready() -> void:
	if subviewport_container is not SubViewportContainer:
		push_error('[main menu] needs "Subviewport Container" to be set')
	if state is not GameState or state.name != "MainMenu":
		push_error('[main menu] needs "State" to be set to the GameState object called "MainNenu"')

	new_game_button = find_child("new_game_button")
	pprint("new_game_button: %s"%new_game_button)
	new_game_button.grab_focus()
	
	settings_button = find_child("settings_button")
	pprint("settings_button %s"%settings_button)
	
	$fade_up_timer.wait_time = total_time
	$fade_up_timer.start()
	
	$logos.modulate = Color.BLACK
	$blackout_panel.visible = true
	$blackout_panel.modulate = Color.WHITE

	#-- window
	if WindowManager.fullscreen:
		subviewport_container.size = DisplayServer.screen_get_size()

	WindowManager.change_fullscreen.connect(_on_change_fullscreen)



func _process(delta: float) -> void:
	#fadeups
	if not finished_fadeups:
		var v_logos = remap( total_time-$fade_up_timer.time_left, 0.0, graphics_fadeup_time, 0.0, 1.0 )
		v_logos = clamp(v_logos, 0.0, 1.0)
		$logos.modulate = Color(v_logos, v_logos, v_logos, 1.0)
		
		var v_viewport = remap( total_time-$fade_up_timer.time_left, viewport_fadeup_start, viewport_fadeup_start+viewport_fadeup_time, 1.0, 0.0 )
		v_viewport = clamp(v_viewport, 0.0, 1.0)
		$blackout_panel.modulate = Color(1.0, 1.0, 1.0, v_viewport)


func _on_fade_up_timer_timeout() -> void:
	finished_fadeups = true
	# get rid of the blackout panel
	#$blackout_panel.queue_free()
	$blackout_panel.visible = false


func _on_new_game_button_pressed() -> void:
	pprint("_on_new_game_button_pressed()")
	new_game_button_pressed.emit()


func _on_change_fullscreen( fullscreen : bool ) -> void:
	if fullscreen:
		subviewport_container.size = DisplayServer.screen_get_size()


func pprint(thing) -> void:
	print("[main menu] %s"%thing)


func _on_player_test_scene_button_pressed() -> void:
	get_tree().change_scene_to_file( "res://assets/player/player_testing_scene.tscn" )


func _on_test_level_2_button_pressed() -> void:
	get_tree().change_scene_to_file( "res://assets/levels/test_level_two.tscn" )
