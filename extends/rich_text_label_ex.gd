extends RichTextLabel
class_name RichTextLabelEx

@export var size_to_fit: bool = true
@export var max_size: Vector2

var org_size: Vector2
var org_font_size: int
var org_scale: Vector2
var temp_txt: String
var is_autowrap: bool

func _ready() -> void:
	# 讓 RichTextLabel 內容自適應大小
	self.fit_content = true
	
	org_font_size = get_theme_font_size("font_size")
	org_scale = self.scale
	org_size = self.size
	
	is_autowrap = (autowrap_mode != TextServer.AUTOWRAP_OFF)
	# RichTextLabel 依賴 fit_content 和 autowrap 屬性
	if not is_autowrap and max_size.x <= 0:
		LogList.log(self.name + " autowrap關閉時，max_size.x 應設定為 > 0 以限制寬度")
		
	adjust_font_size_to_fit()
	temp_txt = tr(text)

func _process(_delta: float) -> void:
	# 依賴 RichTextLabel 的內建邏輯
	if temp_txt != tr(text):
		adjust_font_size_to_fit()
		temp_txt = tr(text)


func set_max_size(value: Vector2):
	max_size = value
	self.size = max_size

# 調整字體大小以適應 RichTextLabel
func adjust_font_size_to_fit():
	# 獲取實際內容的 Y 軸高度
	# 注意：在設置寬度限制 (size.x) 之後，get_content_height() 才會得到正確的多行高度
	var content_height = get_content_height()
	var target_height = max_size.y if max_size.y > 0 else org_size.y
	
	if content_height > target_height:
		# 計算縮放比例
		var scale_ratio = target_height / content_height
		
		if size_to_fit:
			var new_font_size = org_font_size * scale_ratio
			add_theme_font_size_override("font_size", new_font_size)
			self.scale = org_scale # 重置 scale
		else:
			self.scale = org_scale * scale_ratio
			add_theme_font_size_override("font_size", org_font_size) # 重置 font_size
