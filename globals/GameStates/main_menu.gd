extends GameState
class_name MainMenu

var player : CharacterBody3D
var camera : Camera3D

var player_relative_pose : Node3D

var object_time := 0.0

@export var main_menu : Control #Node # reference to main menu ui tree

@onready var loading_progressbar_container : Control = main_menu.find_child("progressbar_container")
@onready var loading_progressbar : ProgressBar = main_menu.find_child("loading_progressbar")

var camera_initial_position : Vector3
var camera_initial_rotation : Vector3


func _ready() -> void:
	main_menu.new_game_button_pressed.connect(_on_new_game)
	loading_progressbar_container.visible = false


func enter( from_state_name : String, parameters : Dictionary ) -> void:
	pprint("enter()")
	player = get_tree().get_first_node_in_group("player")
	camera = get_tree().get_first_node_in_group("camera")
	
	camera_initial_position = camera.global_position
	camera_initial_rotation - camera.rotation
	
	pprint("player %s"%player)
	pprint("%s"%player.get_path())
	player.set_process(false)
	player.set_physics_process(false)
	player.set_process_input(false)
	#player.set_process_unhandled_input(false)

	player_relative_pose = main_menu.find_child("player_relative_pose")

	main_menu.find_child("new_game_button").grab_focus()

	camera.set_process(true)
	camera.set_physics_process(true)
	camera.set_process_input(true)
	#camera.set_process_unhandled_input(true)

	


func exit() -> void:
	pprint("exit()")


func update( delta ) -> void:
	object_time += delta
	
	#-- movement
	camera.position.x = camera_initial_position.x + sin(Clocks.global_time*0.3)* 30
	camera.position.y = camera_initial_position.y + sin(Clocks.global_time*0.5)* 30
	camera.position.z = camera_initial_position.z + cos(Clocks.global_time*0.4)* 30
	camera.rotation.y = camera_initial_rotation.y + sin((Clocks.global_time+0.375)*1.5) *0.15

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




func physics_update( delta ) -> void:
	pass


func handle_input(event: InputEvent) -> void:
	pass


func _on_quit_button_pressed() -> void:
	get_tree().quit()
	

func _on_new_game() -> void:
	pprint("_on_new_game received")
	transitioned.emit( self, "MainMenu_Playing_transition", {} )


func pprint(thing) -> void:
	print('[game state] ["MainMenu"] %s'%thing)
