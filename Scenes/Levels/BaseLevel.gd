class_name BaseLevel
extends Node
signal UpdateScore(points)
var parent
var tiles:Dictionary = {}

#External Objects
var player:Object

#Objects
var map:TileMap
var objects:TileMap
var cellsize:Vector2
var map_area:Rect2
var play_area:Rect2
var bkgnd_scroll:Object
var bkgnd_scroll_pos:Vector2

#Level generic data
export (Color) var backgroundcolour
export (Dictionary) var collisiontiles
export (String) var levelname
export (bool) var replace_bkgnd_colour
export (bool) var scroll_with_player
export (Vector2) var scroll_ratio = Vector2(0.00005,0.0)
export (Vector2) var scroll_oversize_ratio = Vector2(12.5,50.0)
export (PackedScene) var enemy

var level_data:Dictionary = {}

#Defaults
export (int) var default_points = 10

func _ready():
	parent = get_parent()
	map = get_node("MAP")
	objects = get_node("OBJECTS")
	bkgnd_scroll = get_node("Background_Scroll")
	if map:
		tiles[map.name] = parse_tiles(map)
		cellsize = map.cell_size
		map_area = map.get_used_rect()
		play_area = Rect2(map_area.position * cellsize,map_area.end * cellsize)
		if map.material:
			map.material.set_shader_param("background_colour",backgroundcolour)
			map.material.set_shader_param("replace_bkgnd_colour",replace_bkgnd_colour)
		
	if bkgnd_scroll:
		bkgnd_scroll.material.set_shader_param("scroll_ratio",scroll_ratio)
		bkgnd_scroll.material.set_shader_param("colour_base",backgroundcolour)
		var size = play_area.size + Vector2(abs(play_area.position.x),abs(play_area.position.y))
		var ratio = scroll_oversize_ratio / 100.0
		var offset = (size * ratio) /2
		bkgnd_scroll.rect_size = size * (Vector2.ONE + ratio)
		bkgnd_scroll.rect_position = play_area.position - offset

	if objects:
		tiles[objects.name] = parse_tiles(objects)
	process_map()
	level_data = load_level_data(levelname)
	
func _physics_process(_delta):
	if bkgnd_scroll:
		if player and scroll_with_player:
			bkgnd_scroll_pos = player.position
		bkgnd_scroll.material.set_shader_param("scroll_pos",bkgnd_scroll_pos)

func _process(_delta):
	pass

func process_map():
	pass
	
func get_collision_details(_position:Vector2,_tilemap:TileMap) -> Array:
	var _result:Array = []
	var _tile = get_tile_at_location(_position,_tilemap)
	if _tile != []:
		var _tile_id = _tile[0]
		var _tile_position = _tile[1]
		var _tile_attributes = tiles[_tilemap.name][_tile_id]

		if !_tile_attributes.has("HasCollision"):
			return []
		
		if _tile_attributes.has("Multi"):
			var _multi = _tile_attributes["Multi"].split(",")
			var _tile_xy = get_offset_vector(_multi[0])
			var _offset = _tile_xy -Vector2.ONE
			_tile_position -= _tile_xy-Vector2.ONE
			var _newtile = get_tile_at_position(_tile_position,_tilemap)
			_tile_attributes = get_tile_details(_newtile[0],_tilemap)

		_result = [_tile_id,_tile_position,_tile_attributes]


	return _result
	
func get_tile_details(_tile_id:int,_tilemap:TileMap) -> Dictionary:
	var _tile_attributes = tiles[_tilemap.name][_tile_id]
	return _tile_attributes
	
func get_tile_at_location(pos,_map:TileMap) -> Array:
#Get the tile ID and tile map position from the given world position
	if _map:
		var _tile_map_position = get_tile_map_position(pos,_map)
		if _tile_map_position != Vector2.INF:
			var _t = _map.get_cellv(_tile_map_position)
			return [_t,_tile_map_position]
		else:
			return []

	else:
		return []

func get_tile_map_position(pos,_map:TileMap) -> Vector2:
	if _map:
		var localposition = _map.to_local(pos)
		var tilemapposition = _map.world_to_map(localposition)
		return tilemapposition
	else:
		return Vector2.INF
		
func get_tile_at_position(pos,_map:TileMap) -> Array:
	if _map:
		var _t = _map.get_cellv(pos)
		return [_t,pos]
	else:
		return []

func get_offset_vector(str_vector:String) -> Vector2:
	var _offset = str_vector.to_int()
	var _xoffset = int(_offset /10)
	var _yoffset = int(_offset % 10)
	return Vector2(_xoffset,_yoffset)

func parse_tilename(tilename:String)-> Dictionary:
	var opcodes = {
		'A':'Action',
		'M':'Multi',
		'D':'Destroyed',
		'R':'Replace',
		'P':'Points'
	}
	var _ret = {}
	var _parameters = tilename.split('/')
	
	for _p in _parameters:
		var _param_data = _p.split(':',true,1)
		if _param_data.size() > 1:
			if opcodes.has(_param_data[0]):
				_ret[opcodes[_param_data[0]]] = _param_data[1]
			else:
				_ret[_param_data[0]] = _param_data[1]
		else:
			_ret['Tilename'] = _param_data[0]
	return _ret
	
func parse_tiles(_tilemap:TileMap)->Dictionary:
	var _newtiles:Dictionary = {}
	var _tileset:TileSet = _tilemap.tile_set
	if _tileset:
		for _tile in _tileset.get_tiles_ids():
			var _newtile = parse_tilename(_tileset.tile_get_name(_tile))
			var _shapes = _tileset.tile_get_shapes(_tile)
			if _shapes:
				_newtile["HasCollision"] = true
			_newtiles[_tile] = _newtile
	return _newtiles

func destroy_tile_object(_tilemap:TileMap,_tile_id:int,_position:Vector2,_tile_attributes:Dictionary):
	var points = default_points
	if _tile_attributes.has("Points"):
		points = _tile_attributes["Points"].to_int()

	if _tile_attributes.has("Multi"):
		var multi = _tile_attributes["Multi"].split(",",true,1)
		var size:Vector2 = get_offset_vector(String(multi[1]))
		for x in range(size.x):
			for y in range(size.y):
				var current_position = _position+ Vector2(x,y)
				var current_tile_id = _tilemap.get_cellv(current_position)
				var replace_tile = get_replacement_tile(current_tile_id,_tilemap)
				_tilemap.set_cellv(Vector2(current_position),replace_tile)
	else:
		var replace_tile = get_replacement_tile(_tile_id,_tilemap)
		_tilemap.set_cellv(Vector2(_position),replace_tile)		
	emit_signal("UpdateScore",points)

func get_replacement_tile(_tile_id:int,_tilemap:TileMap) -> int:
	var _new_tile:int = -1
	var _tile_attributes = get_tile_details(_tile_id,_tilemap)
	if _tile_attributes.has("Replace"):
		_new_tile = _tile_attributes["Replace"].to_int()
	return _new_tile

func load_level_data(_level:String) -> Dictionary:
	var _fname = "res://Level_Data/" + _level + ".json"
	var _data = FS.LoadFile(_fname)
	if _data[0] == 0:
		return _data[1].Level
	else:
		return {}

func spawn_enemy(_pos:Vector2,_ofset:Vector2,_rpts:int,_delay:float,_dir:Vector2,_type:String):
	pass
