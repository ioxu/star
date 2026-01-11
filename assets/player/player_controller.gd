extends CharacterBody3D

@export var camera : Camera3D
@export var draw_debug := false


#-- object
var object_time := 0.0


#-- move
var MAX_SPEED = 120.0

#var pos_spring : HarmonicMotion.Spring3 = HarmonicMotion.Spring3.new( 60.0, 20.0 )   #Spring2( 80.0, 10.0 )
var action_plane = Plane(Vector3.UP, Vector3.ZERO) # used for returning objects to the main plane of action

@export var take_user_input := true
var exo_direction := Vector3.ZERO # a writeable force for being driven externally
var exo_aim := Vector3.ZERO
 # I think this should be driven by the world y rotation of the action plane
# i.e. this is where the y rotation of the lavel drives the orientation of the player
var exo_yaw := 0.0

var target_velocity := Vector3.ZERO
var friction := 0.0002
var acceleration := 200
var ms_collided := false

var tilt := 0.0 # -1.0 left to 1.0 right
@export var tilt_spring_coeff := 70.0
@export var tilt_damp_coeff := 5.0
var tilt_spring : HarmonicMotion.Spring1 = HarmonicMotion.Spring1.new( tilt_spring_coeff, tilt_damp_coeff )
var yaw := 0.0
@export var yaw_spring_coeff := 50.0
@export var yaw_damp_coeff := 10.0
var yaw_spring : HarmonicMotion.Spring1 = HarmonicMotion.Spring1.new( yaw_spring_coeff, yaw_damp_coeff )

#-- screen bounds
var screen_pos : Vector2
@export var limit_to_frustum := true
@export var frustum_limit_margin := Vector2(0.05,0.1) * 1.0

#-- weapons
var is_primary_firing := false

const bullet = preload("res://assets/player/bullet.tscn")

var debug = MeshInstance3D.new()
var debug_mesh = ImmediateMesh.new()
#var debug_points : Array[Vector3]


func _ready() -> void:
	if Global.is_f6_scene(self.scene_file_path):
		Global.run_alternative_scene( "res://assets/player/player_testing_scene.tscn" )

	if self.camera == null:
		push_warning("%s has no camera assigned!"%[self])
		self.camera = get_viewport().get_camera_3d()
	
	pprint("start")

	$weapons/primary/machine_gun/muzzle/muzzle_flash.visible = false
	$weapons/primary/machine_gun/muzzle2/muzzle_flash2.visible = false


	debug.mesh = debug_mesh
	var mat : StandardMaterial3D = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.albedo_color = Color.WHITE#Color(0.0, 0.852, 0.232, 1.0)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	debug.material_override = mat
	debug.top_level = true
	add_child(debug)


func _physics_process(delta: float) -> void:
	# left stick input
	var input_direction : Vector3
	var direction : Vector3
	var aim : Vector3
	if take_user_input:
		input_direction = Vector3(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			0.0,
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		)
		
		# right stick input
		aim = Vector3(
			Input.get_action_strength("ui_aim_right") - Input.get_action_strength("ui_aim_left"),
			0.0,
			Input.get_action_strength("ui_aim_down") - Input.get_action_strength("ui_aim_up")
		)

	#-- input velocities
	# make direction relative to camera orientation
	# TODO: generate this basis from the action plane instead ..
	var camy : Vector3 = (camera.global_basis.y * Vector3(1.0, 0.0, 1.0)).normalized()
	var camx : Vector3 = (camera.global_basis.x * Vector3(1.0, 0.0, 1.0)).normalized()

	direction = input_direction.x * camx + input_direction.z * -camy

	if draw_debug:
		debug_mesh.clear_surfaces()
		debug_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		debug_mesh.surface_set_color(Color.GREEN)
		debug_mesh.surface_add_vertex(Vector3.ZERO)
		debug_mesh.surface_add_vertex(camy*25.0)
		debug_mesh.surface_set_color(Color.RED)
		debug_mesh.surface_add_vertex(Vector3.ZERO)
		debug_mesh.surface_add_vertex(camx*25.0)
		debug_mesh.surface_end()
		debug.global_position = self.global_position + (Vector3.UP * 5.0)

	direction = direction + exo_direction
	aim = aim + exo_aim
	if direction.length() > 1.0:
		direction = direction.normalized()

	target_velocity = direction * MAX_SPEED
	velocity = velocity.move_toward( target_velocity, acceleration * delta )
	velocity = velocity.move_toward( Vector3.ZERO, friction *  delta )
	$target_velocity_indicator.global_position = self.global_position + (target_velocity / MAX_SPEED) * 4.5

	#-- bounds
	var bounds = camera.is_out_of_bounds(Vector2( self.global_position.x, self.global_position.z ))
	if bounds.oob:
		velocity += position.direction_to( Vector3(bounds.closest.x, 0.0, bounds.closest.y) ) * 1000.0 * delta

	#-- move
	set_velocity( velocity )
	set_up_direction(Vector3.UP)
	ms_collided = move_and_slide()
	self.global_position.y = 0

	#-- tilt and yaw
	yaw = yaw_spring.tick(delta, yaw)
	rotation.y = exo_yaw + yaw * -0.65

	tilt_spring.target = input_direction.x
	yaw_spring.target = input_direction.x + aim.x
	tilt = tilt_spring.tick(delta, tilt)
	rotation.z = tilt * -1.2


func _process(delta: float) -> void:
	object_time += delta
	#-- weapons
	if self.is_primary_firing:
		# right
		if $weapons/primary/machine_gun/right_barrel_timer.time_left > 0.05:
			$weapons/primary/machine_gun/muzzle/muzzle_flash.visible = true
		else:
			$weapons/primary/machine_gun/muzzle/muzzle_flash.visible = false
		# left
		if $weapons/primary/machine_gun/left_barrel_timer.time_left > 0.05:
			$weapons/primary/machine_gun/muzzle2/muzzle_flash2.visible = true
		else:
			$weapons/primary/machine_gun/muzzle2/muzzle_flash2.visible = false


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("player_fire_primary"):
		primary_fire_start()
	elif Input.is_action_just_released("player_fire_primary"):
		primary_fire_stop()


func primary_fire_start() -> void:
	self.is_primary_firing = true
	_on_right_left_barrel_timer_timeout(0)
	$weapons/primary/machine_gun/right_barrel_timer.start()
	await get_tree().create_timer(0.05).timeout
	$weapons/primary/machine_gun/left_barrel_timer.start()


func primary_fire_stop() -> void:
	self.is_primary_firing = false
	$weapons/primary/machine_gun/right_barrel_timer.stop()
	$weapons/primary/machine_gun/left_barrel_timer.stop()
	$weapons/primary/machine_gun/muzzle/muzzle_flash.visible = false
	$weapons/primary/machine_gun/muzzle2/muzzle_flash2.visible = false


func pprint(thing) -> void:
	print("[player controller] %s"%thing)


func _on_right_left_barrel_timer_timeout(side) -> void:
	match side:
		0:
			var b : RigidBody3D = bullet.instantiate()
			get_parent().add_child(b)
			b.global_position = $weapons/primary/machine_gun/muzzle.global_position
			b.global_transform.basis = $weapons/primary/machine_gun/muzzle.global_transform.basis
			#b.apply_impulse(Vector3(0.0, 0.0, -2000.0))
			b.apply_impulse( b.global_transform.basis.z * -2000 )
		1:
			var b : RigidBody3D = bullet.instantiate()
			get_parent().add_child(b)
			b.global_position = $weapons/primary/machine_gun/muzzle2.global_position
			b.global_transform.basis = $weapons/primary/machine_gun/muzzle2.global_transform.basis
			#b.apply_impulse(Vector3(0.0, 0.0, -2000.0))
			b.apply_impulse( b.global_transform.basis.z * -2000 )
