class_name GameState extends Node

#-------------------------------------------------------------------------------
# https://www.youtube.com/watch?v=ow_Lum-Agbs
# Bitlytic
#-------------------------------------------------------------------------------

@warning_ignore("unused_signal")
signal transitioned


@warning_ignore("unused_parameter")
func enter( from_state_name : String, parameters : Dictionary ) -> void:
	pass


func exit() -> void:
	pass


@warning_ignore("unused_parameter")
func update( delta ) -> void:
	pass


@warning_ignore("unused_parameter")
func physics_update( delta ) -> void:
	pass


@warning_ignore("unused_parameter")
func handle_input(event: InputEvent) -> void:
	pass
