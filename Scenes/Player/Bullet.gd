extends Node2D
#Signals
signal Destroy(_position,_type)
#Exports
export var speed:float = 1200.0

#Onready Vars
onready var sprite = $Node/Sprite
onready var node = $Node
onready var ray1 = $Node/RayCast2D1
onready var ray2 = $Node/RayCast2D2

#Vars
var direction = Vector2.ZERO
var collided:Array
var collisions:Array

func _ready():
	collisions.clear()
	node.scale.x = direction.x

func _physics_process(delta):
	collided = check_for_collision()
	if collided[0]:
		match collided[1]:
			"Block":
				remove_bullet()
				
			"Destroy":
				destroy_object(collided)
				remove_bullet()
	else:
		position.x += speed * delta * direction.x
	
func check_for_collision() -> Array:
	var _result:Array = [false,[false,null,null,null]]
	_result = check_ray(ray1)
	if not _result[0]:
		_result = check_ray(ray2)
		if !_result[0]:
			collisions.clear()
	return _result[1]

func check_ray(rc:RayCast2D) -> Array:
	var _result:Array = [false,[false,null,null,null]]
	var _colliding:bool = false
	if rc.is_colliding():
		_colliding = true
		_result[0] = _colliding
		var _collision = rc.get_collider() #move_and_collide(_newpos,true,true,true)
		if _collision:
			var _pos = rc.get_collision_point()
			_result[1] = collision_match(_collision,_pos)
			_result[1].append(_collision)
	return _result	

#TODO:
# This could perhaps move the acutal result of collision into the collider.
# So for example if collider.has("Collision_Check").. call collsion?

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
