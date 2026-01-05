extends GameState
class_name MainMenu

var player : CharacterBody3D
var camera : Camera3D

var object_time := 0.0

func enter() -> void:
	pprint("enter()")
	player = get_tree().get_first_node_in_group("player")
	camera = get_tree().get_first_node_in_group("camera")
	pprint("player %s"%player)
	pprint("%s"%player.get_path())
	player.set_process(false)
	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)


func exit() -> void:
	pprint("exit()")


func update( delta ) -> void:
	object_time += delta
	var camera_basis = camera.global_transform.basis
	
	var player_basis = camera_basis.rotated( camera_basis.x, PI/2.0 )
	player_basis = player_basis.rotated( camera_basis.z, PI/4.0 )
	player_basis = player_basis.rotated( player_basis.z, sin(object_time*2.0) * (PI*0.1) )
	
	player.global_transform = Transform3D(Basis( player_basis ), camera.global_transform.translated_local( Vector3( 0.0, -2.5, -20.0 ) ).origin )


func physics_update( delta ) -> void:
	pass


func pprint(thing) -> void:
	print('[game state] "MainMenu" %s'%thing)
