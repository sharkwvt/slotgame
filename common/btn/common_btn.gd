extends ButtonEx
class_name CommonBtn

var style_n_path = "res://styles/style_btn_n.tres"
var style_h_path = "res://styles/style_btn_h.tres"
var style_p_path = "res://styles/style_btn_p.tres"

func _init() -> void:
	super()
	add_theme_color_override("font_color", Main.theme_colors[0])
	add_theme_color_override("font_hover_color", Main.theme_colors[0])
	add_theme_color_override("font_pressed_color", Main.theme_colors[1])
	add_theme_stylebox_override("normal", load(style_n_path))
	add_theme_stylebox_override("hover", load(style_h_path))
	add_theme_stylebox_override("pressed", load(style_p_path))
