extends State
#Move in a loop
var originpos:Vector2
var origindir:Vector2
var targetdir:Vector2
var looporigin:Vector2
var currentangle:float = 0.0
var endangle:float = 0.0
var targetangle:float
var rotspeed:float
var loop_radius:float = 0.0
var linearspeed:float = 0.0

func enter(_args:Dictionary = {}):
	#need to calculate the start origin as if its always 0 deg start.. so need to calc this position when the start is actually not 0.
	currentangle = 0.0
	originpos = _owner.snap(_owner.position)
	origindir = _owner.direction
	targetdir = origindir
	loop_radius = _owner.current_move["Radius"]
	rotspeed = 360 / _owner.current_move["Time"]
	linearspeed = _owner.current_move["LinearSpeed"]
	if _owner.current_move.has("StartAngle"):
		currentangle = _owner.current_move["StartAngle"]
		originpos = calculate_origin(_owner.position,currentangle,loop_radius)
	if _owner.current_move.has("EndAngle"):
		endangle = _owner.current_move["EndAngle"]
		targetangle = endangle
	else:
		targetangle = currentangle + 360.0
	looporigin = originpos - Vector2(0,loop_radius)
	
	if _owner.current_move.has("Direction"):
		targetdir = str2var(_owner.current_move["Direction"])

func exit(_args:Dictionary = {}):
	pass
	
func logic(_args:Dictionary = {}):
	var _delta = _args["delta"]
	#Handle any startup delays
	if !_owner.offset_complete():
		return

	currentangle += rotspeed * _delta * targetdir.x
	if abs(currentangle) < targetangle:
		var rad = deg2rad(currentangle)
		var _offset = Vector2(sin(rad),cos(rad))
		looporigin += linearspeed * _owner.direction * _delta
		_owner.setpos(looporigin + _offset * loop_radius)
	else:
		_owner.emit_signal("MoveComplete")

func calculate_origin(pos:Vector2,startangle:float,radius:float) -> Vector2:
	var calcorigin:Vector2 = pos
	var oppositeangle = startangle - 180.0
	if oppositeangle < 0.0:
		oppositeangle += 360.0
	var oarad = deg2rad(oppositeangle)
	calcorigin = pos + (Vector2(sin(oarad),cos(oarad)) * radius)
	calcorigin.y += radius
	return calcorigin
	
