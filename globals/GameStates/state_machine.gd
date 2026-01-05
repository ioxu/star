extends Node
class_name StateMachine

#-------------------------------------------------------------------------------
# https://www.youtube.com/watch?v=ow_Lum-Agbs
# Bitlytic
#-------------------------------------------------------------------------------

@export var initial_state : GameState

var current_state : GameState
var states: Dictionary = {}


func _ready() -> void:
	for child in get_children():
		if child is GameState:
			states[child.name] = child
			child.transitioned.connect( on_state_transitioned )

	if initial_state:
		initial_state.enter()
		current_state = initial_state


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _input(event: InputEvent) -> void:
	if current_state != null:
		current_state.handle_input(event)


func on_state_transitioned( GameState, new_state_name) -> void :
	if GameState != current_state:
		return

	var new_state = states.get( new_state_name )
	if !new_state:
		return
		
	if current_state:
		current_state.exit()
		
	new_state.enter()
	
	current_state = new_state
	
	
