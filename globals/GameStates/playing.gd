extends GameState
class_name Playing

@onready var camera : Camera3D = get_tree().get_first_node_in_group("camera")


func enter( from_state_name : String, parameters : Dictionary ) -> void:
	pprint("enter()")

	camera.set_process(true)
	camera.set_physics_process(true)
	camera.set_process_input(true)
	#camera.set_process_unhandled_input(true)
	#if parameters.has("new_level_instance"):
		#parameters["new_level_instance"].start_action()


func exit() -> void:
	pprint("exit()")


func update( delta ) -> void:
	pass


func physics_update( delta ) -> void:
		camera.position = fsm.current_level.action.get_camera_target().global_position
		camera.transform.basis = fsm.current_level.action.get_camera_target().global_transform.basis


func handle_input(event: InputEvent) -> void:
	#if Input.is_action_just_pressed("ui_pause"):
	#if Input.is_action_pressed("ui_pause"):
	if Input.is_action_just_pressed_by_event("ui_pause", event):
		pprint("PAUSE")
		transitioned.emit(self, "Pause", {})


func pprint(thing) -> void:
	print('[game state] ["Playing"] %s'%thing)
