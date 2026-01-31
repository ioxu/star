extends Camera3D

#@export var action_plane : Plane = Plane(Vector3.ZERO, 0.0)


var time := 0.0

var initial_position : Vector3
var initial_rotation : Vector3

#-- action plane
var action_plane = Plane(Vector3.UP, Vector3.ZERO) 								# used for returning objects to the main plane of action

#-- bounds
@export var frustum_limit_margin := Vector2(0.05,0.1) * 1.0
@export var draw_bounds := false
var frustum_bounds_mesh = ImmediateMesh.new() 									# intersection of camera frstum with action_plane
var screen_bounds_points : Array[Vector2]
var world_bounds_points : Array[Vector3]
var bounds_poly2d : PackedVector2Array 											# the bounds polygon in 2d space in the action_plane


func _ready() -> void:
	initial_position = self.global_position
	initial_rotation = self.rotation
	
	var frustum_bounds_instance = MeshInstance3D.new()
	frustum_bounds_instance.mesh = frustum_bounds_mesh
	var mat : StandardMaterial3D = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.albedo_color = Color(0.0, 0.852, 0.232, 1.0)
	frustum_bounds_instance.material_override = mat
	frustum_bounds_instance.top_level = true
	add_child(frustum_bounds_instance)


func _process(delta: float) -> void:
	time += delta
	
	##-- movement
	#self.position.x = initial_position.x + sin(time*0.3)* 30
	#self.position.y = initial_position.y + sin(time*0.5)* 30
	#self.position.z = initial_position.z + cos(time*0.4)* 30
	#self.rotation.y = initial_rotation.y + sin((time+0.375)*1.5) *0.15


	#-- frustum bounds
	var vp_size = Vector2(get_viewport().size)
	# screen points
	screen_bounds_points = [
		# 4 points, in screen resolution coordinates, minus the frustum_limit_margin
		Vector2(vp_size.x * frustum_limit_margin.x, vp_size.y * frustum_limit_margin.y),
		Vector2(vp_size.x * (1.0 - frustum_limit_margin.x), vp_size.y * frustum_limit_margin.y),
		Vector2(vp_size.x * (1.0 - frustum_limit_margin.x), vp_size.y * (1.0 - frustum_limit_margin.y)),
		Vector2(vp_size.x * frustum_limit_margin.x, vp_size.y * (1.0 - frustum_limit_margin.y))
	]
	
	# screen points to world points
	world_bounds_points.clear()
	for sp in screen_bounds_points:
		var origin: Vector3 = self.project_ray_origin(sp)
		var dir: Vector3 = self.project_ray_normal(sp)
		
		var intersection = action_plane.intersects_ray(origin, dir )
		world_bounds_points.append( intersection )

	# 2d polygon
	bounds_poly2d.clear()
	for wp in world_bounds_points:
		bounds_poly2d.append( Vector2(wp.x, wp.z) )

	if draw_bounds:
		frustum_bounds_mesh.clear_surfaces()
		frustum_bounds_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
		frustum_bounds_mesh.surface_add_vertex(world_bounds_points[0])
		frustum_bounds_mesh.surface_add_vertex(world_bounds_points[1])
		frustum_bounds_mesh.surface_add_vertex(world_bounds_points[2])
		frustum_bounds_mesh.surface_add_vertex(world_bounds_points[3])
		frustum_bounds_mesh.surface_add_vertex(world_bounds_points[0])
		frustum_bounds_mesh.surface_end()
	else:
		frustum_bounds_mesh.clear_surfaces()


func is_out_of_bounds(pos2d : Vector2) -> Dictionary:
	if Geometry2D.is_point_in_polygon( pos2d, self.bounds_poly2d):
		# inside?
		return {"oob":false, "closest":Vector2.ZERO}
	else:
		# outside?
		return {"oob": true, "closest": _closest_point_on_polygon( pos2d, self.bounds_poly2d ) }


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
