extends Area2D
class_name Enemy

#Signals
signal UpdateScore(_points)
signal Hit(_object)
signal Spawned(_object)
signal AtTarget
signal MoveComplete

#Onready Variables
onready var spr = $Sprite
onready var col = $CollisionShape2D
onready var timer = $Timer
onready var parent = get_parent()

#Exports
export (String) var enemytype = 'EnemyType'
export (String) var enemyclass = 'EnemyClass'
export (int) var points = 50
export (int) var life = 1
export (int) var speed = 250


#External Objects
var player:Object = null

#Local Variables
var fsm:StateMachine = StateMachine.new()
var collisions:Array = []
var spawner:Object = null
var direction:Vector2 = Vector2.ZERO
var Epsilon:float = 1
var enemy_data:Dictionary = {}
var current_move:Dictionary = {}
var total_moves:int = 0
var total_patterns:int = 0
var pattern_index:int = -1
var move_index:int = 0
var move_list:Array = []
var pattern_list:Array = []
var sprite_frame:int = 0
var debugstatename:String
var offset_completed:bool = false
var offset_count:int = 0
var pattern:String = ''
var next_pattern:String = ''



func _ready():
	_base_initialise()

func _process(_delta):
	pass

func _physics_process(_delta):
	if fsm.state != null:
		debugstatename = fsm.statename
		var _args = {"delta":_delta}
		fsm.state.logic(_args)

func _on_area_entered(area):
	if not collisions.has(area):
		collisions.append(area)
		_collided(area)

func _on_area_exited(area):
	if collisions.has(area):
		collisions.erase(area)

func _collided(_a):
	#collided function to be overidden in instances
	pass

func _exit_tree():
	pass

func _hit():
	#hit function to be overidden in instances
	_free(true)

func _self_destruct():
	#hit function to be overidden in instances
	_free(true)

func _free(_deferred):
	if _deferred:
		self.call_deferred("free")
	else:
		self.queue_free()

func _base_initialise():
	set_process(true)
	add_to_group(enemytype)
	add_to_group(enemyclass)
	var _result = self.connect("MoveComplete",self,"_on_BaseEnemey_MoveComplete")
	fsm._owner = self	
	if $States:
		fsm.add_states($States)
		if fsm.states.has("INIT"):
			fsm.state_change("INIT")
		else:
			if enemy_data.has("Moves"):
				total_patterns = enemy_data["Moves"].size()
#				pattern_list.clear()
#				pattern_list = enemy_data["Moves"].keys()
				move_index = 0
				if pattern_index < 0: # or !pattern_list.has(next_pattern):
					pattern_index = 0
#					pattern = pattern_list[pattern_index]
#					next_pattern = pattern
#				else:
#					pattern = next_pattern
				move_list = get_move_list(pattern_index)
				total_moves = move_list.size()
				process_current_move(move_index)
	spr.frame = sprite_frame

func initialise(_args):
	pass
	
func move(_vel:Vector2):
	var np:Vector2 = position + _vel
	position = snap(np)

func setpos(_pos:Vector2):
	position = snap(_pos)

func snap(_pos:Vector2) -> Vector2:
	return Vector2(int(round(_pos.x)),int(round(_pos.y)))
		
func check_target(target_position:Vector2) -> bool:
	var posdif:Vector2 = target_position - position
	var posdif1:Vector2 = posdif * direction
	if posdif1.x <= Epsilon and posdif1.y <= Epsilon:
#	if abs(position.x-target_position.x) <= Epsilon and abs(position.y-target_position.y) <= Epsilon:
		emit_signal("AtTarget")
		return true
	else:
		return false

func process_current_move(cm:int):
	current_move = move_list[cm]
	if current_move:
		if current_move.has("OpCode"):
			if current_move["OpCode"] == "REPEAT":
				#Reset the index counter and call move complete which will increment the index counter and process the next move.
				move_index = -1
				emit_signal("MoveComplete")
			elif fsm.states.has(current_move["OpCode"]):
				fsm.state_change(current_move["OpCode"])
			else:
				print("move has no opcode! : ",current_move)
		pass



func _on_BaseEnemey_MoveComplete():
	move_index += 1
	if move_index >= total_moves:
		move_index = 0
	process_current_move(move_index)

func set_move_pattern(mp:int):
	if mp <= total_patterns:
		pattern_index = mp
		move_index = 0

func get_move_list(pn:int) -> Array:
	#var pi = pattern_list.find(pn)
	return enemy_data["Moves"][pn]

func offset_complete() -> bool:
	if !offset_completed:
		offset_count -= 1
		if offset_count <= 0:
			offset_completed = true
			offset_count = 0
	return offset_completed
