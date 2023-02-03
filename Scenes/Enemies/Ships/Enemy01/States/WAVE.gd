extends State
var currenttime:float = 0.0
var targettime:float = 0.0
var originpos:Vector2 = Vector2.ZERO
var origindir:Vector2 = Vector2.ZERO
var targetpos:Vector2 = Vector2.ZERO
var targetdir:Vector2 = Vector2.RIGHT
var amplitude:float = 0.0
var frequency:float = 0.0
var lastposition:Vector2

#NOte: needs to be able to wave in each direction. currently coded only for y wave!

var movetopos:bool = false
var attargetpos:bool = false

func enter(_args:Dictionary = {}):
	originpos = _owner.snap(_owner.position)
	origindir = _owner.direction
	currenttime = 0.0
	if _owner.current_move.has("LinearSpeed"):
		_owner.speed = _owner.current_move["LinearSpeed"]

	if _owner.current_move.has("Amplitude"):
		amplitude = _owner.current_move["Amplitude"]
	if _owner.current_move.has("Frequency"):
		frequency = _owner.current_move["Frequency"]
	if _owner.current_move.has("Time"):
		targettime = _owner.current_move["Time"]
	if _owner.current_move.has("Direction") and !movetopos:
		targetdir = str2var(_owner.current_move["Direction"])


func exit(_args:Dictionary = {}):
	pass
	
func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	var _vel
	#Handle any startup delays
	if !_owner.offset_complete():
		return
		
	currenttime += _delta
	_vel = 50.0 * _delta * targetdir
	var displacement = sin(currenttime * frequency) * amplitude
	if (currenttime < targettime) or !_owner.check_target(Vector2(_owner.position.x,originpos.y)):
		_owner.move(_vel)
		_owner.setpos(Vector2(_owner.position.x,_owner.position.y - displacement))
	else:
		_owner.setpos(Vector2(_owner.position.x,originpos.y))
		_owner.emit_signal("MoveComplete")
	
