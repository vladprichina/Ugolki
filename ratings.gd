extends Panel

const panel_elem = preload("rating_element.tscn")
var index = 0

# добавление элементов в рейтинг
func add_item(var name, var counter, var lost_step):
	var item = panel_elem.instance()
	index += 1
	item.get_node("name").text = String(name)
	item.get_node("counter").text = String(counter)
	item.get_node("lost_step").text = String(lost_step)
	item.rect_min_size = Vector2(300, 20)
	$scroll/scroller.add_child(item)
	
	pass

# ******* класс для сортировки
class MyCustomSorterRating:
	static func sort(a, b):
		if a["lost"] > b["lost"]:
			return true
		return false
		pass


func _ready():
	add_item("Name", "Step", "Lost Step")
	load_game()
	pass

# загрузка данных
func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return
		
	var rating = []
	save_game.open("user://savegame.save", File.READ)
	while not save_game.eof_reached():
		var current_line = parse_json(save_game.get_line())
		if !current_line:
			continue
		
		rating.push_back(current_line)
	pass
	save_game.close()
	
	rating.sort_custom(MyCustomSorterRating, "sort")
	for i in (10):
		if i >= rating.size():
			continue
			
		var line = rating[i]
		add_item(line["name"], line["count"], line["lost"])
	

	pass