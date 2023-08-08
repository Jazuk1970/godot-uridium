extends BaseLevel
export (int) var backgroundtile
export (PackedScene) var minelauncher


var levelobjects:Object
#var size 
#var ratio:float  = 0.15
#var pos
#var offset



func _ready():
	var en_start_pos:Vector2 = Vector2(200,100)
	var en_offset:Vector2 = Vector2(0,0)
	var en_repeats:int = 5
	var en_delay:float = 7
	var dir:Vector2 = Vector2.RIGHT
	
	spawn_enemy(en_start_pos,en_offset,en_repeats,en_delay,dir,"Type_01",[2])
	#pass
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

func spawn_enemy(pos:Vector2,ofset:Vector2,rpts:int,delay:float,dir:Vector2,type:String,pattern:Array):
	var enemies = get_tree().get_root().get_node("Game/CurrentLevel/Enemies")
	for r in range(rpts):
		var e = enemy.instance()
		e.position = e.snap(pos + (ofset *r))
		e.offset_count = delay * (r+1)
		e.direction = dir
		e.enemy_data = level_data["Enemies"][type]
		e.sprite_frame = e.enemy_data["SpriteFrame"]
		e.pattern_index = pattern[r % pattern.size()]
		enemies.add_child(e)
