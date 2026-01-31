extends Node3D
class_name LevelActionArea

# level camera that will drive the game camera
@export var camera_target : Camera3D

var _playter_start_position


func get_player_start_position() -> Transform3D:
	return find_child("PathFollow3D").transform


func get_camera_target() -> Camera3D:
	return camera_target
