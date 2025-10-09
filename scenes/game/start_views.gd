extends Control
class_name StartViews

@export var game_scene: GameScene

@export var start_btn: ButtonEx
@export var gallery_btn: ButtonEx
@export var setting_btn: ButtonEx
@export var exit_btn: ButtonEx
@export var logo_view: TextureRect

func _ready() -> void:
	var start_btns = [start_btn, gallery_btn, setting_btn, exit_btn]
	for i in start_btns.size():
		start_btns[i].pressed.connect(_on_btn_pressed.bind(i))
	start_anim()

func start_anim():
	var org_pos = logo_view.position
	logo_view.top_level = true
	logo_view.position = (self.size - logo_view.size) / 2.0
	var tween = logo_view.create_tween()
	tween.tween_property(logo_view, "position", org_pos, 1)
	tween.tween_callback(func (): logo_view.top_level = false)
	tween.finished.connect(tween.kill)
	
	start_btn.visible = false
	gallery_btn.visible = false
	setting_btn.visible = false
	exit_btn.visible = false
	await game_scene.zoomed
	start_btn.visible = true
	gallery_btn.visible = true
	setting_btn.visible = true
	exit_btn.visible = true
	

func _on_btn_pressed(id: int):
	match id:
		0: # 開始遊戲
			game_scene.switch_view(game_scene.VIEW_STATE.menu)
		1: # 回想
			game_scene.book_views.set_index(0)
			game_scene.book_views.return_view = game_scene.VIEW_STATE.start
			game_scene.switch_view(game_scene.VIEW_STATE.book)
		2: # 設定
			#Main.show_setting_view()
			game_scene.switch_view(game_scene.VIEW_STATE.setting)
		3: # 關閉遊戲
			get_tree().quit()
