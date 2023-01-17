tool
extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var p = get_parent()
	var area:Rect2 = p.get_used_rect()
	for y in area.size.y:
		for x in area.size.x:
			set_cellv(area.position + Vector2(x,y),0)




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
