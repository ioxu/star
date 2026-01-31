extends Node
class_name StateMachine

#-------------------------------------------------------------------------------
# https://www.youtube.com/watch?v=ow_Lum-Agbs
# Bitlytic
#-------------------------------------------------------------------------------

# state machine
@export var initial_state : GameState

var current_state : GameState
var states: Dictionary[String, GameState] = {}

#-------------------------------------------------------------------------------
# context
@export var level_container : Node3D

var current_level



func _ready() -> void:
	# @fsm
	for child in get_children():
		if child is GameState:
			states[child.name] = child
			child.transitioned.connect( on_state_transitioned )
			child.fsm = self

	if initial_state:
		initial_state.enter( "", {} )
		current_state = initial_state

	# @context
	current_level = level_container.get_child(0)
	pprint("current level: %s"%current_level.get_path())


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _input(event: InputEvent) -> void:
	if current_state != null:
		current_state.handle_input(event)


func on_state_transitioned( game_state: GameState, new_state_name : String, parameters : Dictionary ) -> void :
	if game_state != current_state:
		return
	var new_state : GameState = states.get( new_state_name )
	if !new_state:
		push_warning('requested state "%s" was not found.'%str(new_state_name))
		return
	if current_state:
		current_state.exit()
	new_state.enter( game_state.name, parameters )
	current_state = new_state


func request_change_level( level )->void:
	# @context
	# called by GameState.fsm.request_change_level()
	# to change the level
	pprint("request change level: %s"%level)
	var old_level = level_container.get_child(0)
	level_container.remove_child(old_level)
	old_level.queue_free()
	var new_level_inst = load( level ).instantiate()
	level_container.add_child( new_level_inst )
	current_level = new_level_inst
	pprint("current level: %s"%current_level.get_path())


func pprint(thing) -> void:
	print('[game state machine] %s'%thing)
