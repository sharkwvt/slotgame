extends Control
class_name ItemsViews

const Item = Slot.Item

@export var game_scene: GameScene

@export var items_view: Panel

func refresh_view():
	# 清空
	for child in items_view.get_children():
		child.queue_free()
	
	var item_size = Vector2(100, 100)
	var offset_x = item_size.x + 10
	for i in Slot.items.size():
		var item: Item = Slot.items[i]
		var item_view = TextureRect.new()
		item_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		item_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		item_view.size = item_size
		item_view.texture = Main.item_datas[item].get_img()
		item_view.position = Vector2(
			i * offset_x + (items_view.size.x - offset_x * Slot.ITEMS_SIZE)/2.0,
			(items_view.size.y - item_size.y) / 2.0
		)
		item_view.gui_input.connect(
			func (event: InputEvent):
				if event.is_pressed():
					show_item_info_view(item)
		)
		items_view.add_child(item_view)


func show_item_info_view(item: Item):
	var item_data: ItemData = Main.item_datas[item]
	
	var offset = 30
	var temp_view: Control
	
	var mouse_pos = get_viewport().get_mouse_position()
	var window = ColorRect.new()
	window.size = Main.screen_size
	window.color = Color(Color.WHITE, 0)
	window.gui_input.connect(
		func (event: InputEvent):
			if event.is_pressed():
				window.queue_free()
	)
	game_scene.add_child(window)
	
	var bg = ColorRect.new()
	bg.color = Color(Color.BLACK)
	window.add_child(bg)
	
	var title_lbl = Label.new()
	title_lbl.add_theme_font_size_override("font_size", 30)
	title_lbl.text = item_data.title
	title_lbl.position = Vector2(offset, offset)
	bg.add_child(title_lbl)
	temp_view = title_lbl
	
	var description_lbl = Label.new()
	description_lbl.size = Vector2(500, 30)
	description_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_lbl.add_theme_font_size_override("font_size", 30)
	description_lbl.text = item_data.description
	description_lbl.position = Vector2(
		offset,
		temp_view.position.y + temp_view.size.y + offset
	)
	bg.add_child(description_lbl)
	temp_view = description_lbl
	
	if item in Slot.items_usable.keys():
		var usable_lbl = Label.new()
		usable_lbl.add_theme_font_size_override("font_size", 30)
		usable_lbl.text = "剩餘次數: %s" % Slot.items_usable[item]
		usable_lbl.position = Vector2(
			offset,
			temp_view.position.y + temp_view.size.y + offset
		)
		bg.add_child(usable_lbl)
		temp_view = usable_lbl
	
	if item_data.remark:
		var remark_lbl = Label.new()
		remark_lbl.add_theme_font_size_override("font_size", 30)
		remark_lbl.text = item_data.remark
		remark_lbl.position = Vector2(
			offset,
			temp_view.position.y + temp_view.size.y + offset
		)
		bg.add_child(remark_lbl)
		temp_view = remark_lbl
	
	var remove_btn = ButtonEx.new()
	remove_btn.add_theme_font_size_override("font_size", 30)
	remove_btn.text = "銷毀"
	remove_btn.position = Vector2(
		offset,
		temp_view.position.y + temp_view.size.y + offset
	)
	remove_btn.pressed.connect(
		func ():
			Slot.remove_item(item)
			window.queue_free()
			game_scene.refresh_view()
	)
	bg.add_child(remove_btn)
	temp_view = remove_btn
	
	bg.size = Vector2(
		max(title_lbl.size.x, description_lbl.size.x) + offset * 2.0,
		temp_view.position.y + temp_view.size.y + offset
	)
	bg.position = mouse_pos
	bg.position.x -= bg.size.x + offset
	bg.position.y -= bg.size.y
