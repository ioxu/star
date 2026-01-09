extends Node3D





func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed( "ui_reset" ):
		pprint("reset")


func pprint(thing) -> void:
	print("[player texting scene] %s"%thing)
	$Player.global_position = Vector3.ZERO
