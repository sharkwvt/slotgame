extends Label
class_name LabelEx

@export var size_to_fit: bool = true

var org_size: int
var temp_txt: String

func _init() -> void:
	clip_text = true
	org_size = get_theme_font_size("font_size")
	adjust_font_size_to_fit()

func _process(_delta: float) -> void:
	if temp_txt != tr(text) && size_to_fit:
		adjust_font_size_to_fit()
		temp_txt = tr(text)


func adjust_font_size_to_fit():
	if not has_theme_font("font"):
		Logger.log("%s Label 必須指定 font 才能自動縮放！" % name)
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
	
