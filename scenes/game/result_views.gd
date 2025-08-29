extends Control
class_name ResultViews

@export var game_scene: GameScene

@export var result_img_view: TextureRect

var is_success: bool
var level: int


func refresh_view():
	if is_success:
		result_img_view.visible = true
		#var max_level = Main.current_character_data.level
		#level = max_level if level > max_level else level
		#var img = Main.current_character_data.get_cg_path(level)
		var img = Main.current_character_data.get_cg_path(0)
		result_img_view.texture = load(img)
	else:
		result_img_view.visible = false


func _input(event):
	# 滑鼠任何鍵
	if event is InputEventMouseButton and event.pressed and visible:
		game_scene.switch_view(game_scene.VIEW_STATE.start)
		game_scene.reset()
