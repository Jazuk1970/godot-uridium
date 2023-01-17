extends Area2D
onready var sprite = $AnimatedSprite
onready var coll = $CollisionShape2D
onready var timer = $LifeTime

var speed:float = 150.0
var steer_force:float = 35.0

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var target = null

func _ready():
	timer.start()

func start(_position,_target):
	global_position = _position
	target = _target

func seek():
	var steer = Vector2.ZERO
	if target:
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	return steer

func _physics_process(delta):
	acceleration += seek()
	velocity += acceleration * delta
	velocity = velocity.clamped(speed)
	rotation = velocity.angle()
	position += velocity * delta


func _on_LifeTime_timeout():
	queue_free()
