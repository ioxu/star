extends Control

@export var bar_height := 100
@export var bar_width := 1


func _ready() -> void:
	pass


func _draw() -> void:
	draw_line(Vector2.ZERO, Vector2(0.0, bar_height), Color.RED * Color(2.0, 2.0, 2.0, 1.0), bar_width, true)
