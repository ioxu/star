extends GameState
class_name MainMenu_Playing_transition

@export var main_menu : Node
var menu_logos : Control
var menu_buttons : MarginContainer

var transitioning : bool
@export var transition_time := 2.0

var norm_transition_time : float

var player : CharacterBody3D
var initial_transform : Transform3D
var final_transform = Transform3D()


func enter() -> void:
	pprint("enter()")
	player = get_tree().get_first_node_in_group("player")
	initial_transform = player.global_transform

	transitioning = true
	$transition_timer.wait_time = transition_time
	$transition_timer.start()

	menu_logos = main_menu.find_child( "logos" )
	menu_buttons = main_menu.find_child( "buttons" )


func exit() -> void:
	pprint("exit()")


func update( delta ) -> void:
	if transitioning:
		norm_transition_time = clamp((transition_time - $transition_timer.time_left) / transition_time , 0.0, 1.0)
		norm_transition_time = ease(norm_transition_time, -3.0)
		#pprint("norm_tranition_time: %s"%norm_transition_time)
		var intermediate_transform : Transform3D = lerp( initial_transform, final_transform, norm_transition_time )
		intermediate_transform = intermediate_transform.rotated_local( Vector3.FORWARD, norm_transition_time * PI * 4 )
		player.global_transform = intermediate_transform
	
		menu_logos.modulate = Color(1.0, 1.0, 1.0, 1.0 - norm_transition_time)
		menu_buttons.modulate = Color(1.0, 1.0, 1.0, 1.0 - norm_transition_time)

		if norm_transition_time == 1.0:
			transitioning = false
			
			menu_logos.visible = false
			menu_buttons.visible = false
			
			player.set_process(true)
			player.set_physics_process(true)
			player.set_process_input(true)
			player.set_process_unhandled_input(true)
			
			pprint("transition done.")
			transitioned.emit(self, "Playing")


func physics_update( delta ) -> void:
	pass


func handle_input(event: InputEvent) -> void:
	pass


func pprint(thing) -> void:
	print('[game state] ["MainMenu_Playing_transition"] %s'%thing)
