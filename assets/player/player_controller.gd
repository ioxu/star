extends CharacterBody3D

@export var camera : Camera3D

var MAX_SPEED = 100.0

var pos_spring = HarmonicMotion.Spring3.new( 60.0, 20.0 )   #Spring2( 80.0, 10.0 )
var desired_position := Vector3.ZERO

var action_plane = Plane(Vector3.UP, Vector3.ZERO) # used for returning objects to the main plane of action

#-- screen bounds
var screen_pos : Vector2
@export var limit_to_frustum := true
@export var frustum_limit_margin := Vector2(0.05,0.1) * 2.0

#-- weapons
var is_primary_firing := false

const bullet = preload("res://assets/player/bullet.tscn")


var immediate_mesh = ImmediateMesh.new()

func _ready() -> void:
	if self.camera == null:
		push_error("%s has no camera assigned!"%[self])
	
	pprint("start")

	$weapons/primary/machine_gun/muzzle/muzzle_flash.visible = false
	$weapons/primary/machine_gun/muzzle2/muzzle_flash2.visible = false

	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = immediate_mesh
	var mat : StandardMaterial3D = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.albedo_color = Color(0.0, 0.852, 0.232, 1.0)
	mesh_instance.material_override = mat
	mesh_instance.top_level = true
	add_child(mesh_instance)


func _physics_process(delta: float) -> void:
	var direction = Vector3(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		0.0,
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	desired_position += direction * delta * MAX_SPEED
	
	
	#-- limit against camera frustum
	var vp_size = Vector2(get_viewport().size)
	# position on screen
	screen_pos = camera.unproject_position( self.global_position )
	#var depth = (camera.global_position - self.global_position).length()
	var depth = camera.global_position.distance_to( self.global_position )
	# limits projected to world
	#var s_min = camera.project_position( vp_size * frustum_limit_margin, depth)
	#var s_max = camera.project_position( vp_size * (Vector2.ONE - frustum_limit_margin), depth)
	# test and bound
	#if self.global_position.x < s_min.x:
		#desired_position.x = s_min.x + 5.0 # should be by the error
	#if self.global_position.z < s_min.z:
		#desired_position.z = s_min.z + 5.0 # should be by the error
	#if self.global_position.x > s_max.x:
		#desired_position.x = s_max.x - 5.0 # should be by the error
	#if self.global_position.z > s_max.z:
		#desired_position.z = s_max.z - 5.0 # should be by the error

	#var s_tl = camera.project_position( vp_size * frustum_limit_margin, depth*1)
	#var s_tr = camera.project_position( vp_size * Vector2(1.0 - frustum_limit_margin.x , frustum_limit_margin.y), depth*1)
	#var s_br = camera.project_position(  vp_size * (Vector2.ONE - frustum_limit_margin), depth*1)
	#var s_bl = camera.project_position( vp_size * Vector2(frustum_limit_margin.x, 1.0-frustum_limit_margin.y), depth*1)
#
	#var frustum_planes : Array[Plane] = camera.get_frustum() # near, far, left, top, right, bottom

	## clamp to frustum_limit_margin (is screen pixels)
	#
	#var smin = vp_size * frustum_limit_margin
	#var smax = vp_size * (Vector2.ONE - frustum_limit_margin)
	#if screen_pos.x < smin.x or screen_pos.x > smax.x or screen_pos.y < smin.y or screen_pos.y > smax.y:
		#print("out of bounds: %0.0v -- %0.0v -- %0.0v"%[screen_pos, smin, smax] )
		#
		#var error := Vector2.ZERO
		#if screen_pos.x < smin.x:
			#error.x = smin.x - screen_pos.x
		#elif screen_pos.x > smax.x:
			#error.x = smax.x - screen_pos.x
		#if screen_pos.y < smin.y:
			#error.y = smin.y - screen_pos.y
		#elif screen_pos.y > smax.y:
			#error.y = smax.y - screen_pos.y
		#
		##screen_pos = clamp(screen_pos, vp_size * frustum_limit_margin, vp_size * (Vector2.ONE - frustum_limit_margin) )
		##screen_pos.clamp(vp_size * frustum_limit_margin, vp_size * (Vector2.ONE - frustum_limit_margin) ) 
		#screen_pos = screen_pos.clamp(vp_size * frustum_limit_margin, vp_size * (Vector2.ONE - frustum_limit_margin) ) + error
		#print("clamped: %0.0v"%screen_pos)
		#
		#### calc error
		##print("error %0.1v"%error)
		##screen_pos += (error*5)
		#
		##calc screen_pos_depth
		#var action_plane = Plane(Vector3.UP, Vector3.ZERO)
		##var screen_pos_depth = camera.global_position.distance_to( action_plane.intersects_ray(camera.global_position, camera.project_ray_normal( screen_pos ) ) )
		#depth = camera.global_position.distance_to( action_plane.intersects_ray(camera.global_position, camera.project_ray_normal( screen_pos ).normalized() ) )
		#
		##desired_position = camera.project_position( screen_pos, depth)
		#desired_position = camera.project_position( screen_pos, depth)
		##desired_position.y = 0.0
		#print("desired_position.y %0.1f"%desired_position.y)
	##print("%0.2v -- %0.2v -- %0.2v"%[screen_pos, vp_size * frustum_limit_margin, vp_size * (Vector2.ONE - frustum_limit_margin)] )

	# TODO - move to class scope object that only gets updated on signal from screen resolution change
	var screen_points := [
		#Vector2(0.0, 0.0),
		#Vector2(vp_size.x, 0.0),
		#Vector2(vp_size.x, vp_size.y),
		#Vector2(0.0, vp_size.y)
		
		# 4 points, in screen resolution coordinates, minus the frustum_limit_margin
		Vector2(vp_size.x * frustum_limit_margin.x, vp_size.y * frustum_limit_margin.y),
		Vector2(vp_size.x * (1.0 - frustum_limit_margin.x), vp_size.y * frustum_limit_margin.y),
		Vector2(vp_size.x * (1.0 - frustum_limit_margin.x), vp_size.y * (1.0 - frustum_limit_margin.y)),
		Vector2(vp_size.x * frustum_limit_margin.x, vp_size.y * (1.0 - frustum_limit_margin.y))
	]

	#print(screen_points)

	# screen points to world points
	var world_points : Array[Vector3]
	for sp in screen_points:
		var origin: Vector3 = camera.project_ray_origin(sp)
		var dir: Vector3 = camera.project_ray_normal(sp)
		
		var intersection = action_plane.intersects_ray(origin, dir )
		world_points.append( intersection )

	# 2d polygon
	var poly : PackedVector2Array
	for wp in world_points:
		poly.append( Vector2(wp.x, wp.z) )

	#print(poly)
	
	# in world polygon?
	var pos2d = Vector2( self.global_position.x, self.global_position.z )
	if Geometry2D.is_point_in_polygon( pos2d, poly):
		$screen_pos_indicator.global_position = self.global_position

	else:
		# outside?
		# move to closest point on polygon
		print("OUT OF BOUNDS")
		
		var nearest := _closest_point_on_polygon( pos2d, poly )
		$screen_pos_indicator.global_position = Vector3( nearest.x, 0.0, nearest.y )
		
		var nearest3 = Vector3( nearest.x, 0.0, nearest.y )
		desired_position = nearest3
		self.global_position = nearest3
		$desired_position_indicator.global_position = desired_position


	#desired_position = camera.project_position( screen_pos, depth*1)

	pos_spring.target = desired_position
	$desired_position_indicator.global_position = desired_position
	self.global_position = pos_spring.tick( delta, self.position )


	$Label3D.text = "screen_pos <%d, %d>\nworld_pos <%0.1f, %0.1f>\ndepth %0.1f\nheight %0.1f"%[screen_pos.x, screen_pos.y, global_position.x, global_position.z, depth, self.global_position.y]

	#pos_spring.target = desired_position
	#$desired_position_indicator.global_position = desired_position
	#self.global_position = pos_spring.tick( delta, self.position )



	# draw frustum limit margin
	#immediate_mesh.clear_surfaces()
	#immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	#immediate_mesh.surface_add_vertex(camera.project_position( vp_size * frustum_limit_margin, depth*1))
	#immediate_mesh.surface_add_vertex(camera.project_position( vp_size * Vector2(1.0 - frustum_limit_margin.x , frustum_limit_margin.y), depth*1))
	#immediate_mesh.surface_add_vertex(camera.project_position( vp_size * (Vector2.ONE - frustum_limit_margin), depth*1))
	#immediate_mesh.surface_add_vertex(camera.project_position( vp_size * Vector2(frustum_limit_margin.x, 1.0-frustum_limit_margin.y), depth*1))
	#immediate_mesh.surface_add_vertex(camera.project_position( vp_size * frustum_limit_margin, depth*1))
	#immediate_mesh.surface_end()

	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	immediate_mesh.surface_add_vertex(world_points[0])
	immediate_mesh.surface_add_vertex(world_points[1])
	immediate_mesh.surface_add_vertex(world_points[2])
	immediate_mesh.surface_add_vertex(world_points[3])
	immediate_mesh.surface_add_vertex(world_points[0])
	immediate_mesh.surface_end()



func _process(delta: float) -> void:
	
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


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("player_fire_primary"):
		self.is_primary_firing = true
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
			b.global_position = $weapons/primary/machine_gun/muzzle.global_position + Vector3(0.0, 0.0, -5.0)
			b.apply_impulse(Vector3(0.0, 0.0, -2000.0))
		1:
			var b : RigidBody3D = bullet.instantiate()
			get_parent().add_child(b)
			b.global_position = $weapons/primary/machine_gun/muzzle2.global_position + Vector3(0.0, 0.0, -5.0)
			b.apply_impulse(Vector3(0.0, 0.0, -2000.0))


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
	
	
	
