extends TileMap
export (Color) var backgroundcolour
export (Dictionary) var collisiontiles

func _ready():
	self.material.set_shader_param("background_colour",backgroundcolour)
