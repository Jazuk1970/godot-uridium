extends Node2D
signal Destroy(_position,_type)

onready var sprite = $Node/Sprite
onready var node = $Node
onready var ray1 = $Node/RayCast2D1
onready var ray2 = $Node/RayCast2D2

var velocity = Vector2.ZERO
var acceleration = Vector2(0.08,0.25)
var direction = Vector2.ZERO

export var speed:float = 500.0

var play_area:Rect2
var play_area_bounds:Vector2 = Vector2(50,50)
var collided
var collisions:Array
var last_collision:String


func _ready():
	collisions.clear()
	node.scale.x = direction.x

func _physics_process(delta):
	collided = check_for_collision()
	if collided[0] == true:
		match collided[1]:
			"Block":
				remove_bullet()
				
			"Destroy":
				destroy_object(collided)
				remove_bullet()
	else:
		position.x += speed * delta * direction.x
	
func check_for_collision() -> Array:
	var _result:Array = [false,null,null,null]
	var _colliding:bool = false
	if ray1.is_colliding():
		_colliding = true
		var _collision = ray1.get_collider() #move_and_collide(_newpos,true,true,true)
		if _collision:
			var _pos = ray1.get_collision_point()
			_result = collision_match(_collision,_pos)
			_result.append(_collision)
	if _result == [false,null,null,null] and ray2.is_colliding():
		_colliding = true
		var _collision = ray2.get_collider() #move_and_collide(_newpos,true,true,true)
		if _collision:
			var _pos = ray2.get_collision_point()
			_result = collision_match(_collision,_pos)
			_result.append(_collision)
	if !_colliding:
		collisions.clear()
	return _result

func collision_match(_collision,_pos) -> Array:
	var _result:Array = [false,null,null]
	match _collision.name:
		"MAP":
			#Call the function on the map to get the tile at a given location
			var level = _collision.get_parent()
			var _collision_details = level.get_collision_details(_pos,_collision)
			if _collision_details:
					if !collisions.has(_collision_details[1]):
						add_collision(_collision_details[1],collisions)
						if _collision_details[2].has("Action"):
							var _action = _collision_details[2]["Action"]
							match _action:
								"Block","Destroy":
									_result = [true,_action,_collision_details]
	return _result
	

func remove_collision(_collision,_collisions):
	if _collisions.has(_collision):
		_collisions.remove(_collision)

func add_collision(_collision,_collisions):
	_collisions.append(_collision)

func remove_bullet():
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	remove_bullet()

func destroy_object(collision_object):
	if collision_object[3] is TileMap:
		destroy_tile_object(collision_object)
	else:
		print("Destruction of object: ",collision_object, " requested.")	
		

func destroy_tile_object(collision_object):
	var tile = collision_object[2][0]
	var tile_position = collision_object[2][1]
	var tile_attributes = collision_object[2][2]
	var tilemap = collision_object[3]
	var level = collision_object[3].get_parent()
	level.destroy_tile_object(tilemap,tile,tile_position,tile_attributes)
