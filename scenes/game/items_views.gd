extends Control
class_name ItemsViews

const Item = Slot.Item

@export var game_scene: GameScene

@export var items_view: Panel
@export var items_view_slot: Control
@export var item_bg: Texture

var item_views = []

func refresh_view():
	refresh_menu_items_view()
	refresh_slot_items_view()


func refresh_menu_items_view():
	# 清空
	for child in items_view.get_children():
		child.queue_free()
	
	var view_size = Vector2(60, 60)
	#var offset_x = view_size.x + 10
	var offset_x = (items_view.size.x - view_size.x * Slot.ITEMS_SIZE) / (Slot.ITEMS_SIZE + 1)
	for i in Slot.items.size():
		var item: Item = Slot.items[i]
		var item_view = TextureRect.new()
		item_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		item_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		item_view.size = view_size
		item_view.texture = Main.item_datas[item].get_img()
		item_view.position = Vector2(
			#i * offset_x + (items_view.size.x - offset_x * Slot.ITEMS_SIZE)/2.0,
			offset_x + i * (view_size.x + offset_x),
			(items_view.size.y - view_size.y) / 2.0
		)
		item_view.gui_input.connect(
			func (event: InputEvent):
				if event.is_pressed():
					show_item_info_view(item)
		)
		items_view.add_child(item_view)

func refresh_slot_items_view():
	# 清空
	for child in items_view_slot.get_children():
		child.queue_free()
	item_views.clear()
	
	for i in Slot.ITEMS_SIZE:
		var item_bg_view = TextureRect.new()
		item_bg_view.texture = item_bg 
		item_bg_view.position = Vector2.ZERO
		var offset_x = item_bg_view.size.x + 1
		item_bg_view.position = Vector2(i * offset_x + 10, -item_bg_view.size.y / 2.0)
		items_view_slot.add_child(item_bg_view)
		if i < Slot.items.size():
			var item_icon = TextureRect.new()
			var item: Item = Slot.items[i]
			item_icon.texture = Main.item_datas[Slot.items[i]].get_img()
			item_icon.gui_input.connect(
				func (event: InputEvent):
					if event.is_pressed():
						show_item_info_view(item)
			)
			item_bg_view.add_child(item_icon)
			item_views.append(item_icon)

func get_item_view(item_id: int) -> TextureRect:
	for i in Slot.items.size():
		if Slot.items[i] == item_id:
			return item_views[i]
	return

func show_item_info_view(item: Item):
	var item_data: ItemData = Main.item_datas[item]
	
	var font_size = 20 if Main.in_zoom else 40
	var offset = 10
	var temp_view: Control
	
	var mouse_pos = get_global_mouse_position()
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
	title_lbl.add_theme_font_size_override("font_size", font_size)
	title_lbl.text = item_data.title
	title_lbl.position = Vector2(offset, offset)
	bg.add_child(title_lbl)
	temp_view = title_lbl
	
	var description_lbl = Label.new()
	description_lbl.size = Vector2(250, 30) if Main.in_zoom else Vector2(500, 60)
	description_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_lbl.add_theme_font_size_override("font_size", font_size)
	description_lbl.text = item_data.description
	description_lbl.position = Vector2(
		offset,
		temp_view.position.y + temp_view.size.y + offset
	)
	bg.add_child(description_lbl)
	temp_view = description_lbl
	
	if item in Slot.items_usable.keys():
		var usable_lbl = Label.new()
		usable_lbl.add_theme_font_size_override("font_size", font_size)
		usable_lbl.text = "剩餘次數: %s" % Slot.items_usable[item]
		usable_lbl.position = Vector2(
			offset,
			temp_view.position.y + temp_view.size.y + offset
		)
		bg.add_child(usable_lbl)
		temp_view = usable_lbl
	
	if item_data.remark:
		var remark_lbl = Label.new()
		remark_lbl.add_theme_font_size_override("font_size", font_size)
		remark_lbl.text = item_data.remark
		remark_lbl.position = Vector2(
			offset,
			temp_view.position.y + temp_view.size.y + offset
		)
		bg.add_child(remark_lbl)
		temp_view = remark_lbl
	
	var remove_btn = ButtonEx.new()
	remove_btn.add_theme_font_size_override("font_size", font_size)
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
	if mouse_pos.x < Main.screen_size.x / 2.0:
		bg.position.x += offset
	else:
		bg.position.x -= bg.size.x + offset
	if Main.in_zoom:
		bg.position.y -= bg.size.y
