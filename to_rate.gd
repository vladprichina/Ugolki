extends Button
	
func save_game():
	var save_game = File.new()
	var rating = []
	
	var name = get_node("/root/main_node/game_node/field")
	var node_data = name.call("save");
	rating.push_back(node_data)
	
	if save_game.file_exists("user://savegame.save"):
		save_game.open("user://savegame.save", File.READ)
		while not save_game.eof_reached():
			var current_line = parse_json(save_game.get_line())
			if !current_line:
				continue
			
			var save_dict = current_line
			rating.push_back(save_dict)
		pass
		save_game.close()
	
	save_game.open("user://savegame.save", File.WRITE)
	
	for i in (rating):
		save_game.store_line(to_json(i))
	save_game.close()
	pass

func _pressed ():
	save_game()
	get_tree().change_scene("res://ratings.tscn")
	pass

