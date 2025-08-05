extends Scene
class_name ResultScene

@export var directions_img: Texture

@export var result_img_view: TextureRect
@export var btn: ButtonEx

var is_success: bool
var level: int

func _ready() -> void:
	btn.pressed.connect(_on_btn_pressed)
	
	$"說明".pressed.connect(Main.show_directions.bind(directions_img))


func refresh():
	if is_success:
		result_img_view.visible = true
		var img = Main.current_character_data.get_cg_path(level)
		result_img_view.texture = load(img)
		if level < Main.current_character_data.level:
			btn.text = "繼續"
		else:
			btn.text = "返回"
	else:
		result_img_view.visible = false
		btn.text = "返回"


func _on_btn_pressed():
	if is_success and level < Main.current_character_data.level:
		Main.to_scene(Main.SCENE.game)
	else:
		Main.to_scene(Main.SCENE.menu)
