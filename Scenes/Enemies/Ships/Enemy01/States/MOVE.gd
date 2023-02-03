extends State
#Forward motion for time
var currenttime:float = 0.0
var originpos:Vector2 = Vector2.ZERO
var origindir:Vector2 = Vector2.ZERO
var targetpos:Vector2 = Vector2.ZERO
var targetdir:Vector2 = Vector2.ZERO
var target_time:float = 0.0
var movetopos:bool = false
var attargetpos:bool = false

func enter(_args:Dictionary = {}):
	attargetpos = false
	movetopos = false
	currenttime = 0.0
	originpos = _owner.snap(_owner.position)
	origindir = _owner.direction
	targetdir = origindir
	if _owner.current_move.has("LinearSpeed"):
		_owner.speed = _owner.current_move["LinearSpeed"]

	if _owner.current_move.has("Position"):
		movetopos = true
		var tp:Vector2 = str2var(_owner.current_move["Position"])
		targetpos = _owner.snap(originpos + tp)
		targetdir = originpos.direction_to(targetpos)
	if _owner.current_move.has("Time"):
		target_time = _owner.current_move["Time"]

	if _owner.current_move.has("Direction") and !movetopos:
		targetdir = str2var(_owner.current_move["Direction"])
	_owner.direction = targetdir
	
	
func exit(_args:Dictionary = {}):
	pass
	
func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	var _vel
	#Handle any startup delays
	if !_owner.offset_complete():
		return
		
	currenttime += _delta
	_vel = _owner.speed * _delta * targetdir
	if (currenttime < target_time and !movetopos) or (movetopos and !attargetpos):
		_owner.move(_vel)
		if movetopos:
			attargetpos = _owner.check_target(targetpos)
			if attargetpos:
				_owner.position = targetpos
	else:
		print(_owner.position)
		_owner.emit_signal("MoveComplete")

