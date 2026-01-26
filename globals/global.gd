extends Node

# -- alternative run-scene
#var is_f6_scene: bool # true if scene has been ran with F6
var alternative_run_scene_path := ""
var _do_f6_scene_check := true


func _ready():
	# Check for already connected controllers
	for device_id in Input.get_connected_joypads():
		print("Connected Joypad: ", Input.get_joy_name(device_id), " (ID: ", device_id, ")")
		# You might want to register/map it here if needed


func is_f6_scene( path : String ) -> bool:
	# https://github.com/godotengine/godot-proposals/issues/11835
	#pprint( "is_f6_sene path: %s" %path )
	#pprint( "(_do_f6_scene_check: %s)" %_do_f6_scene_check )
	if _do_f6_scene_check:
		var main_scene_path := ResourceUID.get_id_path(
			ResourceUID.text_to_id(
				ProjectSettings.get_setting("application/run/main_scene")
			)
		)
		#return get_tree().current_scene.scene_file_path != main_scene_path
		#pprint("check 'path' != main_scene_path: %s"%(path != main_scene_path))
		#pprint("check 'path' == current_scene: %s"%(path ==get_tree().current_scene.scene_file_path))
		var result = (path != main_scene_path) and (path ==get_tree().current_scene.scene_file_path)
		#pprint("    return result: %s"%[result])
		return result
	else:
		#pprint("    return false")
		return false


# -----------------------------------------------------------------------------
func run_alternative_scene(scene_path: String) -> void:
	pprint("current scene path: %s"%get_tree().current_scene.scene_file_path)
	alternative_run_scene_path = scene_path#get_tree().current_scene.alternative_run_scene
	pprint("alternative run-scene: %s"%self.alternative_run_scene_path)

	get_tree().current_scene.set_process(false)
	get_tree().current_scene.set_physics_process(false)
	get_tree().current_scene.set_process_input(false)
	#get_tree().current_scene.set_process_unhandled_input(false)
	
	_do_f6_scene_check = false
	get_tree().change_scene_to_file.call_deferred(self.alternative_run_scene_path)
	#var res = get_tree().change_scene_to_file(self.alternative_run_scene_path)
	#pprint("changing scene (%s)"%res)


# -----------------------------------------------------------------------------
func pprint(thing) -> void:
	print("[Gloabl autoload] %s"%thing)
