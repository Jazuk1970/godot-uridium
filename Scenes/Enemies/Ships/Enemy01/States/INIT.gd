extends State
func enter(_args:Dictionary = {}):
	_owner.direction = Vector2.RIGHT
	_owner.offset_complete = false
	fsm.state_change("ForwardMotion")
	
func exit(_args:Dictionary = {}):
	pass
	
func logic(_args:Dictionary = {}):
	pass
