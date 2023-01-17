extends BaseLevel
export (int) var backgroundtile
export (PackedScene) var minelauncher
var levelobjects:Object
#var size
#var ratio:float  = 0.15
#var pos
#var offset



func _ready():
	pass
#	size = play_area.size + Vector2(abs(play_area.position.x),abs(play_area.position.y))
#	offset = (size * ratio) /2
#	bkgnd.rect_size = size * (1 + ratio)
#	bkgnd.rect_position = play_area.position - offset
#	size = bkgnd.rect_size
#	pos = bkgnd.rect_position
	

#func set_scroll(pos:Vector2):
#	bkgnd.material.set_shader_param("pos",pos.x)
func process_map():
	levelobjects = get_node("LevelObjects")
	var active_tiles = get_active_tiles()
	for tilelocation in objects.get_used_cells():
		var tile = objects.get_cellv(tilelocation)
		if active_tiles.has(tile):
			match tile:
				0:
					spawn_minelauncher(tilelocation)
	

func get_active_tiles() -> Array:
	var atr = [0]
	return atr

func spawn_minelauncher(_tilelocation):
	var pos = map.map_to_world(_tilelocation)
	var ml = minelauncher.instance()
	ml.global_position = pos
	ml.mineowner = get_parent().get_node("Enemies")
	ml.name = "MineLauncher_" + str(_tilelocation)
	levelobjects.add_child(ml)
	


func _on_Level_UpdateScore(points):
	print("Score Updated: ",points)
