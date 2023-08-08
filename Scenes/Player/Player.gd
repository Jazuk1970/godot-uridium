extends KinematicBody2D
export (PackedScene) var oBullet
#signal Explode(_position)
#signal Destroy(_position,_type)
#signal Position_Changed

onready var sprite = $ViewportContainer/Viewport/AnimatedSprite
onready var anim = $AnimationPlayer
onready var rolltimer = $RollTimer
onready var shootdelay = $ShootDelay
onready var bulletspawnpoint = $BulletSpawn
onready var player_viewport = $ViewportContainer/Viewport
onready var shadow = $Shadow

var player_tex:Texture
#var shadow_tex:Texture
var levelobject:Object# = self
var play_area:Rect2
var play_area_bounds:Vector2 = Vector2(50,15)
var collided
var collisions:Array
var last_collision:String
var current_anim:String

#Speed Variables
var max_speed = 375.0
var min_speed = 100.0
var velocity = Vector2.ZERO
var acceleration = Vector2(800.0,800.0) #Vector2(0.08,0.25)
var direction = Vector2.RIGHT
var vertical_speed = 175
#var speed:Vector2
#var last_speed:Vector2 = Vector2.INF

#Roll Variables
var rollgracetime:float = .3
var rolldirection:Vector2 = Vector2.ZERO
var rollrequest:bool = false
var shiproll:float
var _newrollreq:float

#Shooting Variables
var oktoshoot:bool = true
export var bulletcooldown:float = 0.03

var input:Vector2 = Vector2.ZERO





func _ready():
	DebugOverlay.add_property(self,"collided","")
	levelobject = get_tree().get_root().get_node('Game/CurrentLevel/Bullets')
	change_direction(Vector2.RIGHT)
	velocity = Vector2(min_speed,0.0)
	#speed = Vector2(min_speed,0)
	collisions.clear()


func get_input():
	var _input:Vector2
	_input.x = int(Input.is_action_pressed('right')) - int(Input.is_action_pressed('left'))
	_input.y = int(Input.is_action_pressed('down')) - int(Input.is_action_pressed('up'))
	_newrollreq = int(Input.is_action_just_pressed("RollDown"))-int(Input.is_action_just_pressed("RollUp"))
	if _newrollreq and !rollrequest:
		if rolltimer.time_left > 0:
			if (_newrollreq == rolldirection.x) or (_newrollreq == shiproll):
				#This is a second roll request so do a 360
				rolldirection.y = _newrollreq
				rolldirection.x = 0
				rolltimer.stop()
				rollrequest = true
		else:
			if shiproll and shiproll != _newrollreq:
				#We must be rolling back from a 90 to normal
				match shiproll:
					1.0:
						rolldirection = Vector2(_newrollreq,1)
					-1.0:
						rolldirection = Vector2(_newrollreq,-1)
				rolltimer.start(rollgracetime)
			elif shiproll != _newrollreq:
				rolldirection.x = _newrollreq
				rolltimer.start(rollgracetime)
			else:
				rolltimer.start(rollgracetime)
	if oktoshoot and Input.is_action_just_pressed("fire"):
		shoot()		
	return _input

func _physics_process(delta):
	#update()
	input = get_input()
	if position.x <= play_area.position.x + play_area_bounds.x:
		input.x = 1
	elif position.x >= play_area.size.x - play_area_bounds.x:
		input.x = -1
	if rollrequest:
		roll(rolldirection)
	if input.x != 0:
		velocity.x = move_toward(velocity.x,max_speed * input.x,acceleration.x * delta)
		if velocity.x < min_speed  and velocity.x > 0.0 and input.x < 0:
			velocity.x = -min_speed
			change_direction(input)
		elif velocity.x > -min_speed and velocity.x < 0.0 and input.x > 0:
			velocity.x = min_speed
			change_direction(input)

	velocity.y = move_toward(velocity.y,vertical_speed * input.y,acceleration.y * delta)
	var newpos:Vector2
	newpos = velocity * delta
	collided = check_for_collision(newpos)
	if collided:
		pass
#		remove_collision(last_collision,collisions)
#		last_collision = ''
#	else:
#		if (collided[2].has("Class") and collided[2]["Class"]) != last_collision or (!collided[2].has("Class") and collided[2]["Tilename"] != last_collision):
#			remove_collision(last_collision,collisions)
#			add_collision(collided[2]["Class"],collisions)
#			last_collision = collided[1]
#			match collided[1]: #Match the collision action
#				'Explode':
#					emit_signal("Explode",position)
#				'Destroy':
#					emit_signal("Destroy",collided)
#				_:
#					print('Unhandled collision :', str(position,collided))
	position += newpos
	position.y = clamp(position.y,play_area.position.y - play_area_bounds.y,play_area.size.y+play_area_bounds.y)
	
	#update the shadow shader texture
	#shadow.material.set_shader_param("player_ship",player_viewport.get_texture())
	player_tex = player_viewport.get_texture()
	$Shadow.texture = player_tex
	
	
func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Flip_RL":
			anim.play("Left")
		"Flip_LR":
			anim.play("Right")

func change_direction(new_direction:Vector2):
	match new_direction.x:
		-1.0:
			if new_direction != direction:
				direction = new_direction
				anim.play("Flip_RL")
				shiproll = 0.0
		1.0:
			if new_direction != direction:
				direction = new_direction
				anim.play("Flip_LR")
				shiproll = 0.0

#func calculate_speed(_direction) -> Vector2:
#	if _direction.x == 0.0:
#		return Vector2.ZERO
#	if speed.x > 0.0:
#		if _direction.x > 0:
#			speed.x = lerp(speed.x,max_speed,acceleration.x)
#		else:
#			speed.x = lerp(speed.x,0,acceleration.x)
#	if speed.x < 0.0:
#		if _direction.x < 0:
#			speed.x = lerp(speed.x,-max_speed,acceleration.x)
#		else:
#			speed.x = lerp(speed.x,0,acceleration.x)
#
#	if abs(speed.x) < min_speed:
#		speed.x = min_speed * _direction.x
#	if speed.x > 0:
#		return Vector2.RIGHT
#	else:
#		return Vector2.LEFT

func roll(_direction):
	match _direction:
		Vector2(1,0):#-90 deg roll
			anim.play("Roll_0_-90")
			shiproll = 1
		Vector2(-1,0):#90 deg roll
			anim.play("Roll_0_90")
			shiproll = -1
		Vector2(0,1): # 360 rolls
			match shiproll: #Check if the ship is currently on its side or not
				1.0:
					anim.play("Roll_-90_360")
				-1.0:
					anim.play("Roll_90_0_360")
				0.0:	
					anim.play("Roll_360")
			shiproll = 0
		Vector2(0,-1):	#-360 rolls
			match shiproll:#Check if the ship is currently on its side or not
				1.0:
					anim.play("Roll_-90_0_360")
				-1.0:
					anim.play("Roll_90_360")
				0.0:	
					anim.play_backwards("Roll_360")
			shiproll = 0
		Vector2(-1,1):	#-90 deg roll back to normal
			anim.play_backwards("Roll_0_-90")
			shiproll = 0
		Vector2(1,-1):	#90 deg roll back to normal
			anim.play_backwards("Roll_0_90")
			shiproll = 0
	rollrequest = false
	rolldirection = Vector2.ZERO

func _on_RollTimer_timeout():
	rolltimer.stop()
	if rolldirection.x:
		rollrequest = true

func _on_Area2D_body_entered(_body):
#	if body is TileMap:
#		var _a = $Area2D.get_overlapping_bodies()
#		var tile = get_tile_at_location(body.collider(position),body)
#		collided = tile
	pass

func _on_Area2D_body_exited(_body):
#	collided = null
	pass


func check_for_collision(_newpos) -> bool:
	var _result:bool = false
	var _collision_info = move_and_collide(_newpos,true,true,true)
	if _collision_info:
		var _collision = _collision_info.collider
		match _collision.name:
			"MAP":
				#Call the function on the map to get the tile at a given location
				var level = _collision.get_parent()
				var _collision_details = level.get_collision_details(_collision_info.position,_collision)
				if _collision_details:
						if !collisions.has(_collision_details[1]):
							add_collision(_collision_details[1],collisions)
							if _collision_details[2].has("Action"):
								if _collision_details[2]["Action"] == "Block":
									print ("Boom!")

							_result = true
				else:
					collisions.clear()
	else:
		collisions.clear()
	return _result

func remove_collision(_collision,_collisions):
	if _collisions.has(_collision):
		_collisions.remove(_collision)

func add_collision(_collision,_collisions):
	_collisions.append(_collision)
			
func _on_Player_Explode(_pos):
	print ('Boom at' + str(_pos))




func _on_Player_Destroy(_tile_object:Array):
	print ('Destroy at' + str(_tile_object[3][2],_tile_object[0]))
	if _tile_object.back() is TileMap:
		var level = _tile_object.back().get_parent()
		level.destroy_tile_at_tile_position(_tile_object)
		
func shoot():
	var bullet = oBullet.instance()
	bullet.position = position + (bulletspawnpoint.position * direction.x)
	bullet.direction.x = direction.x
	levelobject.add_child(bullet)
	shootdelay.start(bulletcooldown)
	oktoshoot = false
	

func _on_ShootDelay_timeout():
	oktoshoot = true

#func _draw():
	#$Shadow.material.set_shader_param("player_ship",$AnimatedSprite.get_sprite_frames().get_frame($AnimatedSprite.animation,$AnimatedSprite.get_frame()))
