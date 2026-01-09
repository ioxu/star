extends CharacterBody3D

@export var camera : Camera3D

#-- object
var object_time := 0.0


#-- move
var MAX_SPEED = 120.0

#var pos_spring : HarmonicMotion.Spring3 = HarmonicMotion.Spring3.new( 60.0, 20.0 )   #Spring2( 80.0, 10.0 )
var action_plane = Plane(Vector3.UP, Vector3.ZERO) # used for returning objects to the main plane of action

var target_velocity := Vector3.ZERO
var friction := 0.0002
var acceleration := 200
var ms_collided := false

var tilt := 0.0 # -1.0 left to 1.0 right
var tilt_spring : HarmonicMotion.Spring1 = HarmonicMotion.Spring1.new( 70.0, 5.0 )
var yaw := 0.0
var yaw_spring : HarmonicMotion.Spring1 = HarmonicMotion.Spring1.new( 50.0, 10.0 )

#-- screen bounds
var screen_pos : Vector2
@export var limit_to_frustum := true
@export var frustum_limit_margin := Vector2(0.05,0.1) * 1.0

#-- weapons
var is_primary_firing := false

const bullet = preload("res://assets/player/bullet.tscn")


func _ready() -> void:
	if Global.is_f6_scene(self.scene_file_path):
		Global.run_alternative_scene( "res://assets/player/player_testing_scene.tscn" )

	if self.camera == null:
		push_warning("%s has no camera assigned!"%[self])
		self.camera = get_viewport().get_camera_3d()
	
	pprint("start")

	$weapons/primary/machine_gun/muzzle/muzzle_flash.visible = false
	$weapons/primary/machine_gun/muzzle2/muzzle_flash2.visible = false


func _physics_process(delta: float) -> void:
	var direction = Vector3(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		0.0,
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	#-- input velocities
	target_velocity = direction * MAX_SPEED
	velocity = velocity.move_toward( target_velocity, acceleration * delta )
	velocity = velocity.move_toward( Vector3.ZERO, friction *  delta )
	$target_velocity_indicator.position = (target_velocity / MAX_SPEED) * 4.5

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
	tilt_spring.target = direction.x
	yaw_spring.target = direction.x
	#tilt_spring.spring_coefficient = 70.0
	#tilt_spring.damping_coefficient = 5.5
	#yaw_spring.spring_coefficient = 50.0
	#yaw_spring.damping_coefficient = 10.0
	tilt = tilt_spring.tick(delta, tilt)
	rotation.z = tilt * -1.2
	yaw = yaw_spring.tick(delta, yaw)
	rotation.y = yaw * -0.65

	screen_pos = camera.unproject_position( self.global_position )
	$Label3D.text = "screen_pos <%d, %d>\nworld_pos <%0.1f, %0.1f>\nheight %0.1f"%[screen_pos.x, screen_pos.y, global_position.x, global_position.z, self.global_position.y]


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
		self.is_primary_firing = true
		_on_right_left_barrel_timer_timeout(0)
		$weapons/primary/machine_gun/right_barrel_timer.start()
		await get_tree().create_timer(0.05).timeout
		$weapons/primary/machine_gun/left_barrel_timer.start()
	elif Input.is_action_just_released("player_fire_primary"):
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


func _closest_point_on_polygon( point: Vector2, poly: PackedVector2Array ) -> Vector2:
	# returns closest point on polygon (a PackedVector2Array of 2d vertices describing the polygon)
	var best = Vector2.ZERO
	var best_dist2 = INF
	var n = poly.size()
	for i in range(n):
		var cp = Geometry2D.get_closest_point_to_segment( point, poly[i], poly[(i+1)%n] )
		var d2 = point.distance_squared_to(cp)
		if d2 < best_dist2:
			best_dist2 = d2
			best = cp
	return best
	
	
	
