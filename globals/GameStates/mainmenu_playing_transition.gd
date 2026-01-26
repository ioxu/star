extends GameState
class_name MainMenu_Playing_transition

@export var main_menu : Node
@onready var menu_logos : Control = main_menu.find_child( "logos" )
@onready var menu_buttons : MarginContainer = main_menu.find_child( "buttons" )

var transitioning : bool
@export var transition_time := 1.0
@export var reverse_transition_time := 0.5



var norm_transition_time : float

var player : CharacterBody3D
var initial_transform : Transform3D
var final_transform : Transform3D

var camera : Camera3D
var prepause_camera_transform : Transform3D
var initial_camera_transform : Transform3D

var reverse := false

@onready var player_relative_pose = main_menu.find_child("player_relative_pose")

@export var level_container : Node3D

var new_level = preload("res://assets/levels/test_level_two.tscn")



func enter( from_state_name : String, parameters : Dictionary ) -> void:
	pprint("enter()")
	player = get_tree().get_first_node_in_group("player")
	initial_transform = player.global_transform
	camera = get_tree().get_first_node_in_group("camera")

	transitioning = true

	if from_state_name == "Pause":
		pprint('entering from "Pause"')
		pprint("running transition in REVERSE")
		reverse = true
		prepause_camera_transform = parameters["pre_pause_camera_transform"]
		initial_camera_transform = camera.global_transform
		$transition_timer.wait_time = reverse_transition_time
	else:
		reverse = false
		final_transform = Transform3D()
		$transition_timer.wait_time = transition_time

	$transition_timer.start()

	level_container.get_child(0).queue_free()
	var new_level_inst = new_level.instantiate()
	level_container.add_child( new_level_inst )


func exit() -> void:
	pprint("exit()")


func update( delta ) -> void:
	if transitioning:
		norm_transition_time = clamp((transition_time - $transition_timer.time_left) / transition_time , 0.0, 1.0)
		norm_transition_time = ease(norm_transition_time, -2.0)

		if reverse:
			final_transform = camera.global_transform * player_relative_pose.transform

			var intermediate_transform : Transform3D = lerp( initial_transform, final_transform, norm_transition_time )
			player.global_transform = intermediate_transform

			camera.global_transform = lerp( initial_camera_transform, prepause_camera_transform, norm_transition_time )

			menu_logos.visible = true
			menu_buttons.visible = true
			
			menu_logos.modulate = Color(1.0, 1.0, 1.0, norm_transition_time)
			menu_buttons.modulate = Color(1.0, 1.0, 1.0, norm_transition_time)

			menu_buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE

			if norm_transition_time == 1.0:
				transitioning = false
				transitioned.emit(self, "MainMenu", {})

		else:
			var intermediate_transform : Transform3D = lerp( initial_transform, final_transform, norm_transition_time )
			intermediate_transform = intermediate_transform.rotated_local( Vector3.FORWARD, norm_transition_time * PI * 2 )
			player.global_transform = intermediate_transform
		
			menu_logos.modulate = Color(1.0, 1.0, 1.0, 1.0 - norm_transition_time)
			menu_buttons.modulate = Color(1.0, 1.0, 1.0, 1.0 - norm_transition_time)

			menu_buttons.mouse_filter = Control.MOUSE_FILTER_PASS

			if norm_transition_time == 1.0:
				transitioning = false
				
				menu_logos.visible = false
				menu_buttons.visible = false
				
				player.set_process(true)
				player.set_physics_process(true)
				player.set_process_input(true)
				player.set_process_unhandled_input(true)
				
				pprint("transition done.")
				transitioned.emit(self, "Playing", {})


func physics_update( delta ) -> void:
	pass


func handle_input(event: InputEvent) -> void:
	pass


func pprint(thing) -> void:
	print('[game state] ["MainMenu_Playing_transition"] %s'%thing)
