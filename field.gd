extends Area2D
export (PackedScene) var chips
export (PackedScene) var chips_ai
onready var cells_render = get_node("cells_render")

# стандартные параметры поля
const field_size = 8
const field_shift = Vector2(60, 60)
const cell_size = 97

# ********* class MapArray ***********
class MapArray:
	var array = []
	
	func _init(var array_new):
		array = array_new
		pass
	
	func get_elem(var x, var y):
		var index = x + field_size * y
		if x < 0 or y < 0 or index >= array.size() or x >= field_size or y >= field_size:
			return null
		return array[index]
		pass
		
	func set_elem(var x, var y, var value):
		var index = x + field_size * y
		if index < array.size():
			array[index] = value
		pass
		
	# оценочная функция - для определенного типа игрок1/игрок2 проверяет количество набранных очков
	func calculate(var figures, var type): 
		var counter = 0
		var price = 0
		for i in (figures.array):
			if i == type:
				price += array[counter]
			counter = counter + 1
		pass
		
		return price	
		pass
# ********* end class MapArray ***********

enum { CELL_EMPTY = 0, CELL_PLAYER = 1, CELL_AI = 2 }

var player_chips = []	# фишки игрока
var ai_chips = []		# фишки противника
var pressed_chip = null # активная фишка игрока
var active_cells = []   # возможные варианты шагов игрока

# карта для оценки
var prices = [0,   75,  125, 150, 200, 250, 300, 320,
			  75,  100, 135, 175, 250, 350, 400, 420,
			  125, 135, 150, 200, 320, 450, 500, 520,
			  150, 175, 200, 300, 350, 550, 600, 700,
			  200, 250, 320, 350, 450, 730, 750, 800,
			  250, 350, 450, 550, 730, 800, 850, 930,
			  300, 400, 500, 600, 750, 850, 930, 950,
			  320, 420, 520, 700, 800, 930, 950, 1000]
var price_map = MapArray.new(prices)

# карта текущего расположения объектов
var cells = null

# начальные позиции игрока и противника
var index_player = [Vector2(5,5), Vector2(5,6), Vector2(5,7),
		Vector2(6,5), Vector2(6,6), Vector2(6,7),
		Vector2(7,5), Vector2(7,6), Vector2(7,7)]
		
var index_ai = [Vector2(0,0), Vector2(0,1), Vector2(0,2),
		Vector2(1,0), Vector2(1,1), Vector2(1,2),
		Vector2(2,0), Vector2(2,1), Vector2(2,2)]
		
# смещение для шагов
var shift_steps = [Vector2(1,0), Vector2(1,1), Vector2(0,1),
		Vector2(-1,0), Vector2(-1,-1), Vector2(0,-1),
		Vector2(-1,1), Vector2(1,-1)]


# ************* functions **********
# загрузка начальный данных
func _ready():
	var pos = Vector2(0,0)
	
	#загрузка клеток
	var cells_temp = []
	for i in (64):
		cells_temp.push_back(CELL_EMPTY)
	cells = MapArray.new(cells_temp)
	
	#загрузка фишек игрока
	for i in (index_player):
		var chip = chips.instance()
		add_child(chip)
		pos = field_shift + Vector2(i.x * cell_size, i.y * cell_size)
		chip.position = pos
		chip.id_first = i
		chip.id_cur = i
		cells.set_elem(i.x, i.y, CELL_PLAYER)
		player_chips.push_back(chip)
	
	#загрузка фишек противника
	for i in (index_ai):
		var chip = chips_ai.instance()
		add_child(chip)
		pos = field_shift + Vector2(i.x * cell_size, i.y * cell_size)
		chip.position = pos
		cells.set_elem(i.x, i.y, CELL_AI)
		ai_chips.push_back(chip)
	pass
	
	# закомментировать, для теста оценочной функции
	var price_player = price_map.calculate(cells, CELL_PLAYER)
	var price_ai = price_map.calculate(cells, CELL_AI)
	var x = 0
	
	pass
	
# обработчик клика по фишке игрока
func click_player(var chip):
	if pressed_chip == null:
		pressed_chip = chip
		pressed_chip.press()
	elif pressed_chip == chip:
		pressed_chip.press()
		pressed_chip = null
	else:
		pressed_chip.press()
		pressed_chip = chip
		pressed_chip.press()
	
	active_cells.clear()
	if pressed_chip != null:
		get_steps(pressed_chip.id_cur, cells, active_cells, false)
		
	activate_cells()
	pass
	
# получить все шаги (TODO, можно оптимизировать перебирая только ходы в сторону противника)
func get_steps(var chip_index, var map, var steps, var recursive):
	var elem = null
	
	# бегаем по всем направлениям
	for shift in (shift_steps):
		var new_pos = chip_index + shift
		if steps.find(new_pos) != -1:
			continue
			
		elem = map.get_elem(new_pos.x, new_pos.y)
		if elem == null:
			continue
		
		# если клетка пустая и мы НЕ рекурсивно прыгаем через несколько клеток, то отмечаем её
		if elem == CELL_EMPTY:
			if !recursive:
				steps.push_back(new_pos)
		else:
			new_pos += shift
			if steps.find(new_pos) != -1:
				continue
			
			# рекурсивно пробуем прыгнуть еще через несколько
			elem = map.get_elem(new_pos.x, new_pos.y)
			if elem != null and elem == CELL_EMPTY:
				steps.push_back(new_pos)
				get_steps(new_pos, map, steps, true)
	
	pass

# функция для поиска пути, можно было собирать пути на этапе отмечания клеток, но тогда при частом рекурсивном вызове были бы лишние массивы
func get_path(var chip_index, var chip_find, var map, var steps, var recursive,  var array_buf, var array_ret):
	var elem = null
	var array = []
	var find = false
	var new_pos = null
	
	if chip_index == chip_find:
		var array_for_buf = array_buf.duplicate()
		array_for_buf.push_back(chip_index)
		array_ret.push_back(array_for_buf)
		return
	
	if map.get_elem(chip_index.x, chip_index.y) == null:
		return
	
	# бегаем по всем направлениям
	for shift in (shift_steps):
		array.clear()
		
		if chip_index == Vector2(7,4):
			var vlad = 0
		
		new_pos = chip_index + shift
		if steps.find(new_pos) != -1:
			continue
			
		elem = map.get_elem(new_pos.x, new_pos.y)
		if elem == null:
			continue
		
		# если клетка пустая и мы НЕ рекурсивно прыгаем через несколько клеток, то отмечаем её
		if elem == CELL_EMPTY:
			if !recursive and chip_find == new_pos:
				steps.push_back(new_pos)
				array.push_back(new_pos)
				find = true
		else:
			new_pos += shift
			if new_pos == chip_find:
				var array_for_buf = array_buf.duplicate()
				array_for_buf.push_back(chip_find)
				array_ret.push_back(array_for_buf)
				return
			
			if steps.find(new_pos) != -1:
				continue
			
			# рекурсивно пробуем прыгнуть еще через несколько
			elem = map.get_elem(new_pos.x, new_pos.y)
			if elem != null and elem == CELL_EMPTY:
				steps.push_back(new_pos)
				array = array_buf.duplicate()
				array.push_back(new_pos)
				if new_pos == chip_find:
					find = true
				else:
					get_path(new_pos, chip_find, map, steps, true, array, array_ret)
	
		if find:
			var array_for_buf = array.duplicate()
			array_ret.push_back(array_for_buf)
			find = false
	pass

# активация подсветки клеток куда можем походить
func activate_cells():
	cells_render.clear()
	
	if pressed_chip != null:
		var pos = null
		for i in (active_cells):
			pos = field_shift + Vector2(i.x * cell_size, i.y * cell_size)
			cells_render.push(pos)
	pass
	
# проверка нахождения точки в круге
func is_point_inside_circle(var point, var circle_pos, var circle_radius):
	var dist = point - circle_pos
	var lenght = dist.length()
	return lenght <= circle_radius;
	pass
	
# обработчик инпутов
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		self.click_field(viewport.get_mouse_position())
	pass
	
# обработчик клика по полю
func click_field(var position):
	
	for i in (active_cells):
		var pos = Vector2(240,0)
		pos += field_shift + Vector2(i.x * cell_size, i.y * cell_size)
		# если кликнули по клетке, в которую можем походить, - ходим
		if is_point_inside_circle(position, pos, 50):
			player_step(i)
			break
	
	pass

# шаг игрока
func player_step(var index):
	# выключаем подсветку клеток
	active_cells.clear()
	cells_render.clear()
	
	# расчет и начало перемещения
	var array_motion = []
	var buf = []
	get_path(pressed_chip.id_cur, index, cells, active_cells, false, buf, array_motion)
	start_motion(pressed_chip, array_motion)
	
	# обновление параметров
	cells.set_elem(pressed_chip.id_cur.x, pressed_chip.id_cur.y, CELL_EMPTY)
	pressed_chip.id_cur = index
	cells.set_elem(pressed_chip.id_cur.x, pressed_chip.id_cur.y, CELL_PLAYER)
	
	active_cells.clear()
	pressed_chip.press()
	#pressed_chip = null
	pass
	
# ******* класс для сортировки, используется как предикат для сравнения длинн массивов
class MyCustomSorter:
	static func sort(a, b):
		if a.size() < b.size():
			return true
		return false
		pass
	
# движение фишки
func start_motion(var chip, var array_motion):
# сортируем все возможные шаги
	array_motion.sort_custom(MyCustomSorter, "sort")
	
	var delay = 0
	var time = 0.5
	var last_pos = chip.position
	var tween = get_node("Tween")
	
	for i in (array_motion[0]):
		var pos = field_shift + Vector2(i.x * cell_size, i.y * cell_size)
		tween.interpolate_property(chip, "position", last_pos, pos, time, Tween.TRANS_LINEAR, Tween.EASE_IN, delay)
		tween.interpolate_property(chip, "scale", Vector2(1, 1), Vector2(1.3, 1.3), time / 2, Tween.TRANS_LINEAR, Tween.EASE_IN, delay)
		tween.interpolate_property(chip, "scale", Vector2(1.3, 1.3), Vector2(1, 1), time / 2, Tween.TRANS_LINEAR, Tween.EASE_IN, delay + 0.25)
		last_pos = pos
		delay += time
		pass
	
	tween.interpolate_callback(self, delay, "end_motion")
	tween.start()	
	chip.z_index = 1000

	pass
	
func end_motion():
	pressed_chip.z_index = pressed_chip.first_index
	pressed_chip = null
	pass

func _process(delta):
	
	pass
