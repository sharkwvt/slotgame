extends Control
class_name StartViews

@export var game_scene: GameScene

@export var start_btn: ButtonEx
@export var gallery_btn: ButtonEx
@export var setting_btn: ButtonEx
@export var exit_btn: ButtonEx

func _ready() -> void:
	var start_btns = [start_btn, gallery_btn, setting_btn, exit_btn]
	for i in start_btns.size():
		start_btns[i].pressed.connect(_on_btn_pressed.bind(i))


func _on_btn_pressed(id: int):
	match id:
		0: # 開始遊戲
			game_scene.switch_view(game_scene.VIEW_STATE.menu)
		1: # 回想
			game_scene.book_views.progress = 0
			game_scene.book_views.return_view = game_scene.VIEW_STATE.start
			game_scene.switch_view(game_scene.VIEW_STATE.book)
		2: # 設定
			#Main.show_setting_view()
			game_scene.switch_view(game_scene.VIEW_STATE.setting)
		3: # 關閉遊戲
			get_tree().quit()
