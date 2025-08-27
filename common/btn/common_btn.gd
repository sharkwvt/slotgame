extends ButtonEx
class_name CommonBtn

@export var size_to_fit: bool = true

var style_n_path = "res://styles/style_btn_n.tres"
var style_h_path = "res://styles/style_btn_h.tres"
var style_p_path = "res://styles/style_btn_p.tres"

var org_size: int
var temp_txt: String

func _init() -> void:
	super()
	add_theme_color_override("font_color", Main.theme_colors[0])
	add_theme_color_override("font_hover_color", Main.theme_colors[0])
	add_theme_color_override("font_pressed_color", Main.theme_colors[1])
	add_theme_stylebox_override("normal", load(style_n_path))
	add_theme_stylebox_override("hover", load(style_h_path))
	add_theme_stylebox_override("pressed", load(style_p_path))


func _ready() -> void:
	org_size = get_theme_font_size("font_size")
	adjust_font_size_to_fit()


func _process(_delta: float) -> void:
	if temp_txt != tr(text) && size_to_fit:
		adjust_font_size_to_fit()
		temp_txt = tr(text)


func adjust_font_size_to_fit():
	if not has_theme_font("font"):
		Logger.log("%s 必須指定 font 才能自動縮放！" % name)
		return

	var base_font: Font = get_theme_font("font")
	var font_data = base_font.get_data()
	
	if font_data == null:
		Logger.log("%s Font 沒有 data" % name)
		return
	
	var font_size = org_size
	var string_size = get_theme_font("font").get_string_size(tr(text), HORIZONTAL_ALIGNMENT_LEFT, -1, org_size)
	if string_size.x > size.x:
		font_size = org_size * (size.x / string_size.x)
	add_theme_font_size_override("font_size", font_size)
