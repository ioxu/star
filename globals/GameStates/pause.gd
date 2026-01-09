extends GameState
class_name Pause

@export var ui_pause : Control

var player : CharacterBody3D
var camera : Camera3D

var transition_time := 0.25
var norm_transition_time : float
var transitioning_in = true
var transitioning_out = false

var last_camera_transform : Transform3D
var pre_pause_camera_transform : Transform3D

# target transform to lerp the camera to, relative to the player transform:
var relative_target_transform : Transform3D 

#-- buttons
var resume_button : Button
var quit_to_main_menu_button : Button
var quit_to_desktop_button : Button


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	camera = get_tree().get_first_node_in_group("camera")
	$transition_timer.wait_time = transition_time

	ui_pause.visible = false
	ui_pause.modulate = Color(1.0, 1.0, 1.0, .0)

	resume_button = ui_pause.find_child("resume_button")
	quit_to_main_menu_button = ui_pause.find_child("quit_to_main_menu_button")
	quit_to_desktop_button = ui_pause.find_child("quit_to_desktop_button")


func enter( from_state_name : String, parameters : Dictionary ) -> void:
	#var rel_origin : Vector3 = Vector3(2.0, 1.0, -2.0)
	#var rel_basis : Basis = Basis().rotated( Vector3.RIGHT, -PI*0.2 ).rotated(Vector3.UP, -PI *0.1)
	#relative_target_transform = Transform3D( rel_basis, rel_origin )
	
	pprint("enter()")
	transitioning_in = true
	$transition_timer.start()
	player.set_process(false)
	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)

	camera.set_process(false)
	camera.set_physics_process(false)
	camera.set_process_input(false)
	camera.set_process_unhandled_input(false)

	last_camera_transform = camera.global_transform
	pre_pause_camera_transform = camera.global_transform

	ui_pause.visible = false
	
	resume_button.grab_focus.call_deferred()


func exit() -> void:
	pprint("exit()")
	$transition_timer.stop()
	player.set_process(true)
	player.set_physics_process(true)
	player.set_process_input(true)
	player.set_process_unhandled_input(true)

	#camera.set_process(true)
	#camera.set_physics_process(true)
	#camera.set_process_input(true)
	#camera.set_process_unhandled_input(true)
	#camera.transform = last_camera_transform


func update( delta ) -> void:
	var rel_origin : Vector3 = Vector3(5.0, 11.0, 7.0)
	var rel_basis : Basis = Basis().rotated( Vector3.RIGHT, -PI*0.3 ).rotated(Vector3.UP, PI *0.1)
	relative_target_transform = Transform3D( rel_basis, rel_origin )

	if transitioning_in:
		ui_pause.visible = true
		norm_transition_time = clamp((transition_time - $transition_timer.time_left) / transition_time , 0.0, 1.0)
		norm_transition_time = ease(norm_transition_time, -3.0)

		camera.transform = lerp(last_camera_transform, player.global_transform * relative_target_transform, norm_transition_time)
		
		ui_pause.modulate = Color( 1.0, 1.0, 1.0, norm_transition_time )

		if norm_transition_time == 1.0:
			#transitioning_in = false
			pass
	else:
		pass
	if transitioning_out:
		norm_transition_time = 1.0 - clamp((transition_time - $transition_timer.time_left) / transition_time , 0.0, 1.0)
		norm_transition_time = ease(norm_transition_time, -3.0)

		camera.transform = lerp(last_camera_transform, player.global_transform * relative_target_transform, norm_transition_time)

		ui_pause.modulate = Color( 1.0, 1.0, 1.0, norm_transition_time )

		if norm_transition_time == 0.0:
			transitioning_out = false
			ui_pause.visible = false
			transitioned.emit(self, "Playing", {})
			


func physics_update( delta ) -> void:
	pass


func handle_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed_by_event("ui_pause", event):
		unpause()


func unpause() -> void:
	pprint("UN-PAUSE")
	transitioning_out = true
	$transition_timer.start()


func _on_resume_button() -> void:
	unpause()


func _on_quit_to_main_menu_button() -> void:
	ui_pause.visible = false
	#camera.set_process(false)
	#camera.set_physics_process(false)
	#camera.set_process_input(false)
	#camera.set_process_unhandled_input(false)
	transitioned.emit(self, "MainMenu_Playing_transition", {"pre_pause_camera_transform" = pre_pause_camera_transform})


func _on_quit_to_desktop_button() -> void:
	get_tree().quit()


func _on_settings_button() -> void:
	pass # Replace with function body.


func pprint(thing) -> void:
	print('[game state] ["Pause"] %s'%thing)
