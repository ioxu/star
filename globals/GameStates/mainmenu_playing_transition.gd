extends GameState
class_name MainMenu_Playing_transition

@export var main_menu : Node
@onready var menu_logos : Control = main_menu.find_child( "logos" )
@onready var menu_bg : Control = main_menu.find_child( "crosses_whole" )
@onready var menu_buttons : MarginContainer = main_menu.find_child( "buttons" )

var transitioning : bool
var prepping : bool
@export var prepping_time := 1.0
@export var transition_time := 1.0
@export var reverse_transition_time := 0.5

var norm_prepping_time : float
var norm_transition_time : float

var player : CharacterBody3D
var initial_transform : Transform3D
var final_transform : Transform3D

var camera : Camera3D
var prepause_camera_transform : Transform3D
var initial_camera_transform : Transform3D
var initial_camera_fov : float

var reverse := false

@onready var player_relative_pose = main_menu.find_child("player_relative_pose")


# ------------------------------------------------------------------------------

@onready var loading_progressbar_container : Control = main_menu.find_child("progressbar_container")
@onready var loading_progressbar : ProgressBar = main_menu.find_child("loading_progressbar")

# ------------------------------------------------------------------------------



func enter( from_state_name : String, parameters : Dictionary ) -> void:
	pprint("enter()")
	player = get_tree().get_first_node_in_group("player")
	initial_transform = player.global_transform
	camera = get_tree().get_first_node_in_group("camera")

	transitioning = false

	# ------------------------------------------------------------------------------
	# switch level and get into position
	loading_progressbar_container.visible = true
	$prep_timer.wait_time = prepping_time
	$prep_timer.start()

	fsm.request_change_level( "res://assets/levels/test_level_two.tscn" )
	# ------------------------------------------------------------------------------

	if from_state_name == "Pause":
		pprint('entering from "Pause"')
		pprint("running transition in REVERSE")
		reverse = true
		prepause_camera_transform = parameters["pre_pause_camera_transform"]
		initial_camera_transform = camera.global_transform
		$transition_timer.wait_time = reverse_transition_time
		initial_camera_fov = camera.fov
	else:
		prepping = true
		reverse = false
		#final_transform = Transform3D()
		final_transform = fsm.current_level.action.get_player_start_position()
		initial_camera_transform = Transform3D( camera.global_transform )
		$transition_timer.wait_time = transition_time
		initial_camera_fov = camera.fov

	#$transition_timer.start()



func exit() -> void:
	pprint("exit()")


func update( delta ) -> void:
	if prepping:
		
		norm_prepping_time = clampf((prepping_time - $prep_timer.time_left) / prepping_time, 0.0, 1.0)
		loading_progressbar.value = norm_prepping_time * 100.0
		camera.position = lerp( initial_camera_transform.origin, fsm.current_level.action.get_camera_target().global_position, norm_prepping_time )
		camera.transform.basis = initial_camera_transform.basis.slerp( fsm.current_level.action.get_camera_target().global_transform.basis, norm_prepping_time )
		#camera.fov = lerp(initial_camera_fov, fsm.current_level.action.get_camera_target().fov, norm_prepping_time)


		# stick player to camera
		var camera_basis = camera.global_transform.basis
		var player_basis = camera_basis.rotated( camera_basis.x, PI/2.0 )
		player_basis = player_basis.rotated( camera_basis.z, PI/4.0 )
		#player_basis = player_basis.rotated( player_basis.z, sin(object_time*2.0) * (PI*0.1) )
		player_basis = player_basis.rotated( player_basis.z, sin(Clocks.global_time*2.0) * (PI*0.1) )
		var player_relative_origin := Vector3( 0.0, -2.5, -20.0 )
		var player_relative_basis = Basis().rotated( Vector3.UP, PI/4.0 )
		player_relative_basis = player_relative_basis.rotated( Vector3.RIGHT, PI/2.0)
		player_relative_basis = player_relative_basis.rotated( player_relative_basis.z, sin(Clocks.global_time*2.0) * (PI*0.1) )
		player_relative_pose.transform = Transform3D(Basis( player_relative_basis ), player_relative_origin )
		player.global_transform = camera.transform * player_relative_pose.transform

		initial_transform = player.global_transform


	if transitioning:
		norm_transition_time = clamp((transition_time - $transition_timer.time_left) / transition_time , 0.0, 1.0)
		norm_transition_time = ease(norm_transition_time, -2.0)
		
		camera.fov = lerp(initial_camera_fov, fsm.current_level.action.get_camera_target().fov, norm_transition_time)

		if reverse:
			final_transform = camera.global_transform * player_relative_pose.transform

			var intermediate_transform : Transform3D = lerp( initial_transform, final_transform, norm_transition_time )
			player.global_transform = intermediate_transform

			camera.global_transform = lerp( initial_camera_transform, prepause_camera_transform, norm_transition_time )

			#menu_logos.visible = true
			#menu_buttons.visible = true
			main_menu.visible = true
			
			var tc = Color(1.0, 1.0, 1.0, norm_transition_time)
			menu_logos.modulate = tc
			menu_buttons.modulate = tc
			menu_bg.modulate = tc

			menu_buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE

			if norm_transition_time == 1.0:
				transitioning = false
				transitioned.emit(self, "MainMenu", {})

		else:
			var intermediate_transform : Transform3D = lerp( initial_transform, final_transform, norm_transition_time )
			intermediate_transform = intermediate_transform.rotated_local( Vector3.FORWARD, norm_transition_time * PI * 2 )
			player.global_transform = intermediate_transform
		
			var tc = Color(1.0, 1.0, 1.0, 1.0 - norm_transition_time)
			menu_logos.modulate = tc
			menu_buttons.modulate = tc
			menu_bg.modulate = tc

			menu_buttons.mouse_filter = Control.MOUSE_FILTER_PASS

			if norm_transition_time == 1.0:
				transitioning = false
				
				#menu_logos.visible = false
				#menu_buttons.visible = false
				main_menu.visible = false
				
				player.set_process(true)
				player.set_physics_process(true)
				player.set_process_input(true)
				#player.set_process_unhandled_input(true)
				
				pprint("transition timer finished")
				pprint("transition done.")
				
				fsm.current_level.start_action()
				
				transitioned.emit(self, "Playing", {})


func physics_update( delta ) -> void:
	pass


func handle_input(event: InputEvent) -> void:
	pass


func pprint(thing) -> void:
	print('[game state] ["MainMenu_Playing_transition"] %s'%thing)


func _on_prep_timer_timeout() -> void:
	pprint("prepping timer finished")
	loading_progressbar_container.visible = false
	prepping = false
	transitioning = true
	$transition_timer.start()
	
