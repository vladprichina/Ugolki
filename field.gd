extends Node
export (PackedScene) var chips
export (PackedScene) var chips_ai

# стандартные параметры поля
const field_size = 8
const field_shift = Vector2(302, 60)
const cell_size = 97

# ********* class MapArray ***********
class MapArray:
	var array = []
	
	func _init(var array_new):
		array = array_new
		pass
	
	func get_elem(var x, var y):
		var index = x + field_size * y
		if x < 0 or y < 0 or index >= array.size():
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

# карта для оценки
var prices = [0,   75,  125, 150, 200, 250, 300, 320,
			  75,  100, 135, 175, 250, 350, 400, 420,
			  125, 135, 150, 200, 300, 450, 500, 520,
			  150, 175, 200, 300, 350, 550, 600, 700,
			  200, 250, 300, 350, 450, 730, 750, 800,
			  250, 350, 450, 550, 730, 800, 850, 930,
			  300, 400, 500, 600, 750, 850, 930, 950,
			  320, 420, 520, 700, 800, 930, 950, 1000]
var price_map = MapArray.new(prices)

# карта текущего располажения объектов
var cells = null

# начальные позиции игрока и противника
var index_player = [Vector2(5,5), Vector2(5,6), Vector2(5,7),
		Vector2(6,5), Vector2(6,6), Vector2(6,7),
		Vector2(7,5), Vector2(7,6), Vector2(7,7)]
		
var index_ai = [Vector2(0,0), Vector2(0,1), Vector2(0,2),
		Vector2(1,0), Vector2(1,1), Vector2(1,2),
		Vector2(2,0), Vector2(2,1), Vector2(2,2)]

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
	
	# закомментировать, для теста
	var price_player = price_map.calculate(cells, CELL_PLAYER)
	var price_ai = price_map.calculate(cells, CELL_AI)
	var x = 0
	
	pass
	
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
	
	activate_cells()
	
	pass

func activate_cells():
	
	pass

func _process(delta):
	
	pass
