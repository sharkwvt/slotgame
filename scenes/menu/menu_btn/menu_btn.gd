extends Control

@export var character_img: TextureRect
@export var btn: ButtonEx

var character_data: CharacterData
var preview_imgs = []
var preview_size = Vector2(100, 100)

func set_data(data: CharacterData):
	character_data = data
	for i in character_data.level:
		preview_imgs.append(load(character_data.get_cg_path(i)))
	refresh()

func refresh():
	character_img.texture = load(character_data.get_cg_path(0))
	# 清空
	for node in character_img.get_children():
		node.queue_free()
	# 預覽圖
	for i in character_data.level:
		var preview = TextureRect.new()
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		preview.size = preview_size
		if character_data.progress > i:
			preview.texture = preview_imgs[i]
		else:
			preview.texture = load("res://image/option_bg.png")
		var offset_x = preview_size.x + 10
		preview.position = Vector2(
			i * offset_x + (size.x - offset_x * character_data.level) / 2.0,
			character_img.size.y + 10
		)
		character_img.add_child(preview)
	
