extends Node3D

@export var autopilot_mode := false
var ap_noisex := FastNoiseLite.new()
var ap_noisez := FastNoiseLite.new()
var ap_aim_noisex := FastNoiseLite.new()
var ap_firing_noise := FastNoiseLite.new()
var is_ap_firing := false


var object_time = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	ap_noisex.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	ap_noisex.fractal_octaves = 4
	ap_noisex.fractal_type = FastNoiseLite.FRACTAL_FBM

	ap_noisez.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	ap_noisez.fractal_octaves = 4
	ap_noisez.fractal_type = FastNoiseLite.FRACTAL_FBM
	ap_noisez.seed = 2

	ap_aim_noisex.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	ap_aim_noisex.fractal_octaves = 4
	ap_aim_noisex.fractal_type = FastNoiseLite.FRACTAL_FBM
	ap_aim_noisex.seed = 3

	ap_firing_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	ap_firing_noise.fractal_octaves = 3
	ap_firing_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	ap_firing_noise.seed = 3


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed( "ui_reset" ):
		pprint("reset")
		$Player.global_position = Vector3.ZERO


#func _process(delta: float) -> void:
func _physics_process(delta: float) -> void:
	object_time += delta
	if autopilot_mode:
		var noise_dirx = ap_noisex.get_noise_1d(object_time*85.0+73.5)
		noise_dirx = remap(ease(remap(noise_dirx, -1.0, 1.0, 0.0, 1.0), -3.0), 0.0, 1.0, -1.0, 1.0)
		var noise_dir : Vector3 = Vector3( noise_dirx, 0.0, ap_noisez.get_noise_1d(object_time*60.0-73.5) *0.25 ).normalized() * 0.55
		var noise_aim : float = ap_aim_noisex.get_noise_1d( object_time*80.0 ) *2.0

		#$Player._exo_direction = noise_dir
		$Player.add_exo_direction(noise_dir)
		#$Player._exo_aim = Vector3(noise_aim, 0.0, 0.0)
		$Player.add_exo_aim(Vector3(noise_aim, 0.0, 0.0))

		var firing_noise = ap_firing_noise.get_noise_1d( object_time*60.0 )
		if firing_noise > 0.0:
			if not is_ap_firing:
				is_ap_firing = true
				$Player.primary_fire_start()
		else:
			if is_ap_firing:
				is_ap_firing = false
				$Player.primary_fire_stop()


func _on_change_autopilot_mode(value) -> void:
	pprint("_on_change_autopilot_mode: %s"%value)
	if value == false:
		#$Player.exo_direction = Vector3.ZERO
		#$Player.exo_aim = Vector3.ZERO
		$Player.primary_fire_stop()

	autopilot_mode = value


func pprint(thing) -> void:
	print("[player texting scene] %s"%thing)
