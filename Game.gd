extends Node

onready var camera = $Camera2D
onready var player = $Player/Player
onready var level = $CurrentLevel
var map:Object
#var play_area:Rect2	
var fps
var level_data:Dictionary = {}





# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.set_target_fps(Engine.get_iterations_per_second())
	map = level.get_node("Level")
	if map:
		player.play_area = map.play_area
		var bgc = map.backgroundcolour
		VisualServer.set_default_clear_color(bgc)
		#Connect the player speed change to the level  scroll speed
#		player.connect("Position_Changed",map,"set_scroll")
		map.player = player
		camera.player = player
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(_delta):
	#fps = Engine.get_frames_per_second()
	#camera.position.x = player.position.x
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if player:
		camera.position.x = player.position.x


#func getplayarea():

#	play_area = Rect2(level.tilemap_area.position * cellsize,level.tilemap_area.end * cellsize)		
#	children = level.get_children()
#	for child in children:
##		if child.name == "MAP":
#		if child is TileMap:
#			tilemap_area = child.get_used_rect()
#			play_area = Rect2(tilemap_area.position * child.cell_size,tilemap_area.end * child.cell_size)



## NOTES:
## Uridium ship speed is min speed to max but always moving, when below min direction is changed.
## vertical movement not that fast (small accel and high friction)
## horintal movement reasonably fast
## currently pressing and holding fire and moving UP rotates to +90, holding down rotates -90. Releasing fire and doing the opposite changes back to normal view or changing left/right direction also reset normal view.

## Enemies
## mine - once released tracks the player with accell and friction applied so overshoots and comes back on itself. Lives for a time only
## ships - various attack patterns, mostly spawn either in front heading toward the player, or from behind heading the same way as the player.
## ship movments vary but the follow have been observed
## 1. straight on approach then a 360 loop and back on the same original corse until off screen
## 2. straight for a while, then drop back in speed and adjust height, then back to normal speed until off screen
## 3. same as above but 1 enemy vertically tracks the player
## 4. other types.. need more study.

## Things to sort
## hit detection with ship elements that are raised
## hit detection for items of ship which can be destroyed
## proximity detect for mine launch
## destruction of ship
## landing
## shadow of main ship (possibly enemies also? can this just be a dynamic source?
## launch ship and sequence
## end of level mini game.

#yield(VisualServer,"frame_post_draw")
#var img2=get_viewport().get_texture().get_data()

#img2.flip_y()
#img2.convert(Image.FORMAT_ETC2_RGBA8)
#img2.save_png("vp2.png")
