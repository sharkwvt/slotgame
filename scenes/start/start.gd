extends Scene
class_name StartScene

func _ready():
	Main.instance_scenes[Main.SCENE.start] = self
	Main.current_scene = self
	$StartButton.pressed.connect(_on_btn_pressed.bind(0))
	$GalleryButton.pressed.connect(_on_btn_pressed.bind(1))
	$SettingButton.pressed.connect(_on_btn_pressed.bind(2))
	$ExitButton.pressed.connect(_on_btn_pressed.bind(3))
	
	await get_tree().process_frame
	Main.instantiate_scenes()


func _on_btn_pressed(id: int):
	match id:
		0: # 開始遊戲
			Main.to_scene(Main.SCENE.menu)
		1: # 回想
			pass
		2: # 設定
			Main.show_setting_view()
		3: # 關閉遊戲
			get_tree().quit()
