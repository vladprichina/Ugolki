extends Node2D

var points = []
var spt = preload("res://res/over_cell.png")

func _draw():
	for i in (points):
    	draw_texture(spt, i)
	pass

func _process(delta):
	update()
	pass

func _ready():
	pass
	
func clear():
	points.clear()
	pass

func push(var value):
	points.push_back(value)
	pass
