@tool
extends Control

class_name AnimGraphDisplay

@export var anim_player : AnimationPlayer
@export var graph_width := 250 : set = _set_width
@export var graph_height := 100 : set = _set_height
@export var nsamples := 250 : set = _set_nsamples

var samples :=[]
@onready var animation : Animation = anim_player.get_animation("path_ratio")
@onready var track_index : int=animation.find_track( "Path3D/PathFollow3D:progress_ratio" , Animation.TYPE_BEZIER)

var time_bar : Control


func _ready() -> void:
	# 
	pprint("animation list: %s"%anim_player.get_animation_list() )
	
	#-- sample the animation curve in AnimationPlayer:path_ratio
	pprint("animation: %s"%animation)
	pprint("track count: %s"%animation.get_track_count())
	pprint("track index: %s"%track_index)
	pprint("length: %s"%animation.length)
	sample_curve()
	pprint("n samples: %d"%samples.size())

	time_bar = preload("res://lib/AnimGraphDisplayPlaybar.gd").new()
	self.add_child(time_bar)
	time_bar.bar_height = graph_height
	time_bar.bar_width = 1.5


func _draw() -> void:
	pprint("draw()")
	draw_rect( Rect2( Vector2.ZERO, Vector2( graph_width, graph_height ) ), Color.WHEAT*Color(1.0,1.0,1.0, 0.25), false, 4.0 )
	var this_sample := []
	var last_sample = samples[0]
	var sample_width = graph_width / float(nsamples)
	for s in samples.size():
		if s!= nsamples-1:
			this_sample = samples[s+1]
		draw_line( Vector2( s*sample_width, graph_height-(last_sample[1]*graph_height) ), Vector2( (s+1)*sample_width, graph_height-(this_sample[1]*graph_height) ), Color.WHITE, 0.5, true  )
		last_sample = this_sample


func _process(delta: float) -> void:
	if anim_player.is_playing():
		time_bar.position = Vector2( graph_width * (anim_player.current_animation_position / float(animation.length)) , 0.0)


func _get_minimum_size() -> Vector2:
	return Vector2(graph_width, graph_height)


func _set_width(value)  -> void:
	graph_width = value
	#self._get_minimum_size()
	custom_minimum_size = Vector2( graph_width, graph_height )
	queue_redraw()


func _set_height(value) -> void:
	graph_height = value
	#self._get_minimum_size()
	custom_minimum_size = Vector2( graph_width, graph_height )
	queue_redraw()


func _set_nsamples(value) -> void:
	nsamples = value
	sample_curve()
	queue_redraw()


func sample_curve() -> void:
	samples.clear()
	if animation:
		for i in range(nsamples):
			var t = (animation.length / nsamples) * i
			var sample = animation.bezier_track_interpolate( track_index, t )
			#pprint("  t: %2.2f v:%2.4f"%[t, sample])
			samples.append([t, sample])


func pprint(thing) -> void:
	print("[AnimGraphDisplay] %s"%thing)
