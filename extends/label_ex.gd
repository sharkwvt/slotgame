extends Label
class_name LabelEx

@export var size_to_fit: bool = true
@export var max_size: Vector2

var org_size: Vector2
var org_font_size: int
var org_scale: Vector2
var temp_txt: String
var is_autowrap: bool

func _ready() -> void:
	org_font_size = get_theme_font_size("font_size")
	org_scale = self.scale
	org_size = self.size
	is_autowrap = (autowrap_mode and autowrap_mode != TextServer.AUTOWRAP_OFF)
	if is_autowrap:
		if max_size:
			self.minimum_size_changed.connect(_on_size_changed)
		else:
			Logger.log(self.name + " autowrap必須設定max_size")
	else:
		adjust_font_size_to_fit()
	#if is_autowrap:
		#adjust_font_size_to_fit()

func _process(_delta: float) -> void:
	if temp_txt != tr(text):
		if is_autowrap:
			_on_size_changed()
		else:
			adjust_font_size_to_fit()
		temp_txt = tr(text)


func set_max_size(value: Vector2):
	max_size = value
	self.size = max_size


func adjust_font_size_to_fit():
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

func _on_size_changed():
	if self.size.y > max_size.y:
		var font_size = org_font_size
		var new_scale = org_scale
		if size_to_fit:
			font_size = org_font_size * (max_size.y / self.size.y)
		else:
			new_scale = max_size.y / self.size.y
		add_theme_font_size_override("font_size", font_size)
		self.scale = new_scale
	else:
		# 單行字可能超出卻size不變
		var s1 = get_theme_font("font").get_string_size(tr(text), HORIZONTAL_ALIGNMENT_LEFT, -1, org_font_size)
		var s2 = get_theme_font("font").get_multiline_string_size(tr(text), HORIZONTAL_ALIGNMENT_LEFT, max_size.x, org_font_size)
		if s2.y <= s1.y:
			adjust_font_size_to_fit()
