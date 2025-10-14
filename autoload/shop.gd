extends Node

var game_scene: GameScene

var items_container: Control
var refresh_button: CommonBtn
var shop_view: Control

const Item = Slot.Item
var skip_items = [Item.道具4, Item.道具7, Item.道具12, Item.道具14, Item.道具25]

var current_items = []
var refresh_item_times = 0

func _ready() -> void:
	refresh_items()


func reset():
	refresh_item_times = 0
	refresh_items()

func refresh_items():
	# 隨機選擇4個道具
	current_items.clear()
	var available_items = Main.item_datas.filter(
		func(item: ItemData):
			return item.id not in Slot.items and item.id not in skip_items
	)
	
	for i in range(4):
		if available_items.size() > 0:
			var random_index = randi() % available_items.size()
			current_items.append(available_items[random_index])
			available_items.remove_at(random_index)
	
	if shop_view:
		refresh_view()


func refresh_view():
	refresh_button.text = str(tr("刷新商品"), "  ", "%s" % get_refresh_item_cost())
	
	# 清除現有道具UI
	for child in items_container.get_children():
		child.queue_free()
	
	for i in current_items.size():
		var item = current_items[i]
		var item_panel = create_item_panel(item, i)
		var offset = item_panel.size.x + 10
		item_panel.position = Vector2(
			offset * i + (Main.screen_size.x - offset * 4) / 2.0,
			(Main.screen_size.y - item_panel.size.y) / 2.0 - 20
		)
		items_container.add_child(item_panel)


func create_item_panel(item_data: ItemData, index: int) -> ButtonEx:
	var font_size = 15
	var margin_size = 10
	
	# 創建主面板
	var panel = ButtonEx.new()
	panel.size = Vector2(170, 250)
	panel.pressed.connect(_on_item_purchased.bind(item_data, index))
	panel.add_theme_stylebox_override("normal", load("res://styles/style_btn_h.tres"))
	panel.add_theme_stylebox_override("hover", load("res://styles/style_btn_h.tres"))
	panel.add_theme_stylebox_override("pressed", load("res://styles/style_btn_h.tres"))
	
	# 添加邊距
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", margin_size)
	margin.add_theme_constant_override("margin_right", margin_size)
	margin.add_theme_constant_override("margin_top", margin_size)
	margin.add_theme_constant_override("margin_bottom", margin_size)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(margin)
	
	var content_vbox = VBoxContainer.new()
	#content_vbox.add_theme_constant_override("separation", 0)
	margin.add_child(content_vbox)
	
	var title_root = Control.new()
	title_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content_vbox.add_child(title_root)
	
	# 道具圖標
	var icon = TextureRect.new()
	icon.texture = item_data.get_img()
	title_root.add_child(icon)
	icon.position = Vector2.ZERO
	
	# 道具名稱
	var name_label = LabelEx.new()
	name_label.set_max_size(Vector2(panel.size.x - icon.size.x - margin_size * 3, icon.size.y))
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	name_label.position.x = icon.size.x + margin_size
	name_label.text = item_data.title
	name_label.add_theme_font_size_override("font_size", font_size + 5)
	name_label.add_theme_color_override("font_color", Main.theme_colors[0])
	#name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_root.add_child(name_label)
	
	title_root.custom_minimum_size.y = icon.size.y
	
	
	# 道具描述
	var desc_label_size = Vector2(panel.size.x - margin_size * 2, panel.size.y - margin_size * 2 - icon.size.y)
	var desc_label = LabelEx.new()
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.text = item_data.description
	desc_label.add_theme_font_size_override("font_size", font_size)
	desc_label.add_theme_color_override("font_color", Main.theme_colors[0])
	#desc_label.add_theme_color_override("default_color", Main.theme_colors[0])
	#desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content_vbox.add_child(desc_label)
	
	if item_data.usable_count > 0:
		var usable_label = LabelEx.new()
		usable_label.set_max_size(Vector2(panel.size.x - margin_size * 2, font_size))
		usable_label.text = str(tr("可用次數:"), " ", item_data.usable_count)
		usable_label.add_theme_font_size_override("font_size", font_size)
		usable_label.add_theme_color_override("font_color", Main.theme_colors[0])
		#usable_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		content_vbox.add_child(usable_label)
		desc_label_size.y -= usable_label.size.y
		
	if item_data.remark:
		var remark_label = LabelEx.new()
		remark_label.set_max_size(Vector2(panel.size.x - margin_size * 2, font_size * 2 + margin_size))
		remark_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		remark_label.text = item_data.remark
		remark_label.add_theme_font_size_override("font_size", font_size)
		remark_label.add_theme_color_override("font_color", Main.theme_colors[0])
		#remark_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		#remark_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content_vbox.add_child(remark_label)
		desc_label_size.y -= remark_label.size.y
	
	
	# 價格和購買按鈕的水平布局
	var hbox_bg = ColorRect.new()
	hbox_bg.color = Main.theme_colors[0]
	hbox_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(hbox_bg)
	
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox_bg.add_child(hbox)
	hbox.minimum_size_changed.connect(
		func ():
			hbox_bg.size = Vector2(panel.size.x, hbox.size.y)
			hbox_bg.position.y = panel.size.y - hbox_bg.size.y
			hbox.position = (hbox_bg.size - hbox.size) / 2.0
	)
	
	var v_icon = TextureRect.new()
	v_icon.texture = Images.voucher_icon_2
	v_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	v_icon.position = Vector2.ZERO
	hbox.add_child(v_icon)
	
	desc_label_size.y -= v_icon.size.y
	
	# 價格標籤
	var price_label = Label.new()
	price_label.text = str(item_data.cost)
	price_label.add_theme_font_size_override("font_size", font_size + 15)
	price_label.add_theme_color_override("font_color", Main.theme_colors[1])
	hbox.add_child(price_label)
	
	desc_label.set_max_size(desc_label_size)
	
	return panel

func get_refresh_item_cost() -> int:
	return refresh_item_times * refresh_item_times

func _on_refresh_button_pressed():
	if Slot.money >= get_refresh_item_cost():
		Slot.money -= get_refresh_item_cost()
		refresh_item_times += 1
		refresh_items()
		Main.current_scene.refresh_view()
	else:
		Main.show_tip("錢不夠")

func _on_item_purchased(item_data: ItemData, index: int):
	if Slot.items.size() >= Slot.max_item_size and !item_data.not_occupy:
		Main.show_tip("欄位不夠")
		return
	if item_data.cost > Slot.voucher:
		Main.show_tip("兌換券不夠")
		return
	Slot.voucher -= item_data.cost
	if Slot.get_buff(Slot.Item.道具40):
		Slot.add_buff(Slot.Item.道具40)
	Slot.add_item(item_data.id)
	current_items.remove_at(index)
	if current_items.size() < 1:
		refresh_items()
	Main.current_scene.refresh_view()


func setup():
	# 道具網格
	var grid = Control.new()
	shop_view.add_child(grid)
	items_container = grid
	
	# 刷新按鈕
	refresh_button = CommonBtn.new()
	refresh_button.size_to_fit = false
	refresh_button.name = "RefreshButton"
	refresh_button.text = "刷新商品"
	refresh_button.icon = Images.money_icon_2
	refresh_button.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	refresh_button.expand_icon = true
	var font_size = 35
	refresh_button.add_theme_font_size_override("font_size", font_size)
	refresh_button.pressed.connect(_on_refresh_button_pressed)
	refresh_button.minimum_size_changed.connect(
		func ():
			var string_size = refresh_button.get_theme_font("font").get_string_size(tr(refresh_button.text), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
			refresh_button.size = Vector2(string_size.x + 50, 50)
			refresh_button.position = Vector2(
				(Main.screen_size.x - refresh_button.size.x) / 2.0,
				game_scene.slot_bg.position.y + game_scene.slot_bg.size.y - refresh_button.size.y - 40
			)
	)
	refresh_button.position = Vector2.ZERO
	shop_view.add_child(refresh_button)

	refresh_view()
