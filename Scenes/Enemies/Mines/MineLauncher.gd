extends Area2D
onready var sprite = $Sprite
onready var collision = $CollisionShape2D
onready var anim = $AnimationPlayer
onready var timer = $Timer
var mineowner:Object = null
export(PackedScene) var mine
var mines:int = 0

var cooldowntime:float = 5.0
var target:Object = null


# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("Idle")
	timer.start(cooldowntime)

func _process(delta):
	mines = getminecount()
	
func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		'Launch':
			anim.play("Idle")
			lauchmine(target)
		
		_:
			return



func _on_MineLauncher_body_entered(body):
	if timer.time_left > 0 or mines > 0:
		return
	
	timer.start(cooldowntime)
	anim.play("Launch")	
	target = body

func lauchmine(_target):
	var m = mine.instance()
	m.start(sprite.global_position,_target)
	if mineowner:
		mineowner.add_child(m)
	
func getminecount()-> int:
	var nodes = get_tree().get_nodes_in_group("mine")
	return nodes.size()
		
