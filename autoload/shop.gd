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
		refresh_item_ui()


func refresh_item_ui():
	refresh_button.text = "刷新商品 (%s$)" % get_refresh_item_cost()
	refresh_button.position = Vector2(
		(Main.screen_size.x - refresh_button.size.x) / 2.0,
		game_scene.slot_bg.position.y + game_scene.slot_bg.size.y - refresh_button.size.y - 40
	)
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
	# 創建主面板
	var panel = ButtonEx.new()
	panel.size = Vector2(170, 250)
	panel.pressed.connect(_on_item_purchased.bind(item_data, index))
	panel.add_theme_stylebox_override("normal", load("res://styles/style_btn_h.tres"))
	panel.add_theme_stylebox_override("hover", load("res://styles/style_btn_h.tres"))
	panel.add_theme_stylebox_override("pressed", load("res://styles/style_btn_h.tres"))
	
	# 創建垂直布局容器
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)
	
	# 添加邊距
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	vbox.add_child(margin)
	
	var content_vbox = VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 5)
	margin.add_child(content_vbox)
	
	var title_root = Control.new()
	content_vbox.add_child(title_root)
	
	# 道具圖標（使用文字代替圖片）
	var icon = TextureRect.new()
	icon.texture = item_data.get_img()
	title_root.add_child(icon)
	icon.position = Vector2.ZERO
	#var icon_label = Label.new()
	#icon_label.text = get_item_emoji(item_data.name)
	#icon_label.add_theme_font_size_override("font_size", 50)
	#icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	#title_root.add_child(icon_label)
	#icon_label.position = Vector2.ZERO
	
	# 道具名稱
	var name_label = LabelEx.new()
	name_label.size = Vector2(panel.size.x - icon.size.x - 30, icon.size.y)
	name_label.position.x = icon.size.x + 10
	name_label.text = item_data.title
	name_label.add_theme_font_size_override("font_size", font_size + 5)
	name_label.add_theme_color_override("font_color", Main.theme_colors[0])
	#name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_root.add_child(name_label)
	
	title_root.custom_minimum_size.y = icon.size.y
	
	
	# 道具描述
	var desc_label = Label.new()
	desc_label.text = item_data.description
	desc_label.add_theme_font_size_override("font_size", font_size)
	desc_label.add_theme_color_override("font_color", Main.theme_colors[0])
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_vbox.add_child(desc_label)
	
	if item_data.usable_count > 0:
		var usable_label = Label.new()
		usable_label.text = "可用次數: %s" % item_data.usable_count
		usable_label.add_theme_font_size_override("font_size", font_size)
		usable_label.add_theme_color_override("font_color", Main.theme_colors[0])
		usable_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		usable_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content_vbox.add_child(usable_label)
		
	if item_data.remark:
		var remark_label = Label.new()
		remark_label.text = item_data.remark
		remark_label.add_theme_font_size_override("font_size", font_size)
		remark_label.add_theme_color_override("font_color", Main.theme_colors[0])
		remark_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		remark_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content_vbox.add_child(remark_label)
		
	
	# 價格和購買按鈕的水平布局
	var hbox_bg = ColorRect.new()
	hbox_bg.color = Main.theme_colors[0]
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
	hbox.add_child(v_icon)
	
	# 價格標籤
	var price_label = Label.new()
	price_label.text = str(item_data.cost)
	price_label.add_theme_font_size_override("font_size", font_size + 15)
	price_label.add_theme_color_override("font_color", Main.theme_colors[1])
	hbox.add_child(price_label)
	
	return panel

func get_item_emoji(item_name: String) -> String:
	match item_name:
		_: return "📦"

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
	Slot.add_item(item_data.id)
	if Slot.get_buff(Slot.Item.道具40):
		Slot.add_buff(Slot.Item.道具40)
	current_items.remove_at(index)
	if current_items.size() < 1:
		refresh_items()
	refresh_item_ui()
	Main.current_scene.refresh_view()


func setup():
	# 道具網格
	var grid = Control.new()
	shop_view.add_child(grid)
	items_container = grid
	
	# 刷新按鈕
	refresh_button = CommonBtn.new()
	refresh_button.name = "RefreshButton"
	refresh_button.text = "刷新商品"
	refresh_button.add_theme_font_size_override("font_size", 35)
	refresh_button.pressed.connect(_on_refresh_button_pressed)
	refresh_button.size = Vector2(250, 50)
	refresh_button.position = Vector2.ZERO
	shop_view.add_child(refresh_button)

	refresh_item_ui()
