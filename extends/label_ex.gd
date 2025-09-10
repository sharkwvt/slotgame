extends Label
class_name LabelEx

@export var size_to_fit: bool = true
@export var autowrap: bool = false
@export var max_size: Vector2

var org_size: Vector2
var org_font_size: int
var org_scale: Vector2
var temp_txt: String

func _ready() -> void:
	org_font_size = get_theme_font_size("font_size")
	org_scale = self.scale
	org_size = self.size
	if autowrap:
		self.autowrap_mode = TextServer.AUTOWRAP_WORD
		_on_autowrap()
	else:
		adjust_font_size_to_fit()

func _process(_delta: float) -> void:
	if temp_txt != tr(text):
		if autowrap:
			_on_autowrap()
		else:
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
	
	
	var string_size = get_theme_font("font").get_string_size(tr(text), HORIZONTAL_ALIGNMENT_LEFT, -1, org_font_size)
	var target_size = max_size if max_size else org_size
	var font_size = org_font_size
	var new_scale = org_scale
	if string_size.x > target_size.x:
		if size_to_fit:
			font_size = org_font_size * (target_size.x / string_size.x)
		else:
			new_scale = target_size / string_size
	add_theme_font_size_override("font_size", font_size)
	self.scale = new_scale

func _on_autowrap():
	var string_size = get_theme_font("font").get_string_size(tr(text), HORIZONTAL_ALIGNMENT_LEFT, -1, org_font_size)
	var font_size = org_font_size
	if string_size.x > self.size.x:
		font_size *= 0.7
	add_theme_font_size_override("font_size", font_size)
