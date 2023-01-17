tool
#C64 CharPad Level Importer
extends Node

export(bool) var create_tilemap setget CreateTileMap
export(bool) var create_tileset setget CreateTileSet

export(String) var tileset_name = 'Destination_Tileset_Name'
export(String) var tilemap_name = 'Destination_Tilemap_Name'
export(String, FILE, "*.png") var tileset_image
export(String, FILE, "*.asm") var C64level_name
export(String, FILE, "*.tres") var tileset_tres
export(Vector2) var tile_size = Vector2(8,8)

var tiles:Vector2
var texture_size:Vector2

var c64data:Array
var mapsize:Vector2
var mapdata:Array
var mapsizefound:bool
var mapdatafound:bool
var tileset:TileSet

func _ready():
	#CreateTileSet(true)
	#CreateTileMap(true)
	pass
	
func CreateTileSet(_val):
	if _val:
		CreateTiles()
		print("Tilemap: " + tilemap_name + " created. " + str(tileset.get_last_unused_tile_id() -1) + " tiles included")
	create_tileset = _val	

func CreateTileMap(_val):
	if _val:
		mapsizefound = false
		mapdatafound = false
		ReadC64LevelData(C64level_name)
		CreateMap(mapdata)
	create_tilemap = _val	


#func _process(delta):
#	if Input.is_action_just_pressed("ui_cancel"):
#		get_tree().quit()

func CreateTiles():
	#Load in the tile texture into the sprite
	var id = 0
	var sprite = Sprite.new()
	var reg:Rect2
	sprite.texture = load(tileset_image)
	texture_size = sprite.texture.get_size()
	tiles = texture_size / tile_size

	#create tileset
	tileset = TileSet.new()
	for y in range(tiles.y):
		for x in range(tiles.x):
			#calculate the sprite region
			reg = Rect2(x*tile_size.x,y*tile_size.y,tile_size.x,tile_size.y)
			tileset.create_tile(id)
			tileset.tile_set_name(id,"%04d" % id)
			tileset.tile_set_texture(id,sprite.texture)
			tileset.tile_set_region(id,reg)
			id += 1
	ResourceSaver.save("res://Utils/LevelImporter/Levels/" + tileset_name + ".tres", tileset)
	
func ReadC64LevelData(file):
	c64data.clear()
	mapdata.clear()
	var f = File.new()
	f.open(file, File.READ)
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		c64data.append(line)
		C64mapdataprocess(line)
	f.close()
	return

func C64mapdataprocess(line):
	if mapsizefound and mapdatafound:
		if line.left(5) == ".byte":
			var linedata = line.substr(6,-1)
			linedata = linedata.replace("$","0x")
			var data = linedata.split(",")
			for i in range(data.size()):
				mapdata.append(data[i].hex_to_int())
	else:
		#Look for the map size
		if line.left(12) == '; MAP DATA :':
			var mapsizestr = line.split(":")
			var start = mapsizestr[1].find("(") + 1
			var end = mapsizestr[1].find(")") 
			var sizestr = mapsizestr[1].substr(start,end-start).split("x")
			mapsize.x = sizestr[0].to_int()
			mapsize.y = sizestr[1].to_int()
			mapsizefound = true	
		#Look for the start of the map data
		if line.left(8) == "map_data":
			mapdatafound = true

func CreateMap(md):
	var tilemap = TileMap.new()
	add_child(tilemap)
	tilemap.set_owner(get_tree().get_edited_scene_root())
	tilemap.clear()
	tilemap.name = tilemap_name
	var ts:TileSet = load(tileset_tres)
	print (ts)
	tilemap.tile_set = ts
	tilemap.cell_size = tile_size
	print ("Map size: " + str(mapsize) + " Map data size: " + str(mapdata.size()))
	if mapsize.x * mapsize.y != mapdata.size():
		print ("Error map size does not align, expected:" + str(mapsize.x * mapsize.y)+ ", got: " + str(mapdata.size()))
		return
	for x in range(mapsize.x):
		for y in range(mapsize.y):
			tilemap.set_cellv(Vector2(x,y),mapdata[x+ (y*mapsize.x)])
	tilemap = null


