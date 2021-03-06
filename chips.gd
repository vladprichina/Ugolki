extends Area2D

var press_state = false
var intersected = false
var id_first = Vector2(0,0) setget set_firstID, get_firstID		# нужна для сброса
var id_cur = id_first setget set_curID, get_curID
var id_next = id_first	# нужна для поиска пути
var id_final = id_next
var first_index = 0
var player = true

onready var sprite = get_node("sprite")
var spt_normal = preload("res://res/red.png")
var spt_over = preload("res://res/red_over.png")
var spt_press = preload("res://res/red_press.png")
var spt_evil = preload("res://res/blue.png")

func _ready():
	if player:
		connect("mouse_entered", self, "over_start")
		connect("mouse_exited", self, "over_end")
	else:
		sprite.set_texture(spt_evil) 
		
	press_state = false;
	first_index = z_index
	pass

func set_state(var normal = true):
	if normal:
		if !press_state:
			sprite.set_texture(spt_normal) 
		else:
			sprite.set_texture(spt_press) 
	else:
		sprite.set_texture(spt_over)
	
	pass

func over_end():
	set_state(true)
	intersected = false
	pass
	
func over_start():
	set_state(false)
	intersected = true
	pass
	
func press():
	press_state = !press_state
	set_state(true)
	pass
	
func _input_event(viewport, event, shape_idx):
	if !player:
		return
	
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		self.on_click()

func on_click():
	var parent = get_parent();
	parent.click_player(self)
	pass
	
func set_firstID(new_value):
	id_first = new_value
	pass

func get_firstID():
	return id_first
	pass
	
func set_curID(new_value):
	id_cur = new_value
	id_next = id_cur
	pass

func get_curID():
	return id_cur
	pass
	
	
	
	
	
	
	
	
	
	
	
	
	