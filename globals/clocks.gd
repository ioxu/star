extends Node

var global_time := 0.0


func _ready() -> void:
	pprint("_ready")


func _process(delta: float) -> void:
	global_time += delta


func pprint(thing) -> void:
	print("[clocks] %s"%thing)
