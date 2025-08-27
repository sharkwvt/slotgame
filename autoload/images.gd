extends Node

var symbols_img_path = "res://image/symbols"
var pattern_img_path = "res://image/pattern"

var item_imgs = []
var symbols_imgs = []
var symbols_imgs_s = []
var pattern_imgs = []

var money_icon: Texture
var voucher_icon: Texture
var voucher_icon_2: Texture

func _ready() -> void:
	money_icon = load("res://image/slot/money.png")
	voucher_icon = load("res://image/slot/money_3.png")
	voucher_icon_2 = load("res://image/slot/money_3.png")
	load_symbols_imgs()
	load_pattern_imgs()


func load_symbols_imgs():
	for i in Slot.SYMBOLS:
		var path = symbols_img_path.path_join(i + ".png")
		if FileAccess.file_exists(path):
			symbols_imgs.append(load(path))
		var s_path = symbols_img_path.path_join("s").path_join(i + ".png")
		if FileAccess.file_exists(s_path):
			symbols_imgs_s.append(load(s_path))

func load_pattern_imgs():
	for i in Slot.Pattern.size():
		var path = pattern_img_path.path_join(str("line_", i + 1, ".png"))
		if FileAccess.file_exists(path):
			pattern_imgs.append(load(path))
