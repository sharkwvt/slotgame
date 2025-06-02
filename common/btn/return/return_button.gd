extends ButtonEx

@export var type = 0
@export var img_n: Texture
@export var img_s: Texture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()

func setup():
	if type == 1:
		remove_theme_color_override("icon_pressed_color")
		button_up.connect(_on_button_up)
		icon = img_n

func _on_button_down() -> void:
	Main.play_btn_sfx()
	if type == 1:
		icon = img_s

func _on_button_up():
	if type == 1:
		icon = img_n
	
