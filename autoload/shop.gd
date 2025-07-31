extends Node

var shop_title: Label
var items_container: GridContainer
var refresh_button: Button

var current_items = []
var shop_view

func _ready() -> void:
	refresh_items()


func refresh_items():
	# 隨機選擇4個道具
	current_items.clear()
	var available_items = Main.item_datas.filter(
		func(item: ItemData):
			return item.id not in Slot.items
	)
	
	for i in range(4):
		if available_items.size() > 0:
			var random_index = randi() % available_items.size()
			current_items.append(available_items[random_index])
			available_items.remove_at(random_index)


func refresh_item_ui():
	# 清除現有道具UI
	for child in items_container.get_children():
		child.queue_free()
	
	for i in range(current_items.size()):
		var item = current_items[i]
		var item_panel = create_item_panel(item, i)
		items_container.add_child(item_panel)


func create_item_panel(item_data: ItemData, index: int) -> Panel:
	# 創建主面板
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(600, 330)
	
	# 添加背景顏色
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.2, 0.3, 0.8)
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.4, 0.4, 0.6)
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style_box)
	
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
	
	# 道具圖標（使用文字代替圖片）
	var icon_label = Label.new()
	icon_label.text = get_item_emoji(item_data.name)
	icon_label.add_theme_font_size_override("font_size", 50)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content_vbox.add_child(icon_label)
	
	# 道具名稱
	var name_label = Label.new()
	name_label.text = item_data.title
	name_label.add_theme_font_size_override("font_size", 30)
	name_label.add_theme_color_override("font_color", Color.YELLOW)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content_vbox.add_child(name_label)
	
	# 道具描述
	var desc_label = Label.new()
	desc_label.text = item_data.description
	desc_label.add_theme_font_size_override("font_size", 30)
	desc_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_vbox.add_child(desc_label)
	
	# 價格和購買按鈕的水平布局
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	content_vbox.add_child(hbox)
	
	# 價格標籤
	var price_label = Label.new()
	price_label.text = str(item_data.cost)
	price_label.add_theme_font_size_override("font_size", 30)
	price_label.add_theme_color_override("font_color", Color.GOLD)
	hbox.add_child(price_label)
	
	# 間隔
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(10, 0)
	hbox.add_child(spacer)
	
	# 購買按鈕
	var buy_button = Button.new()
	buy_button.text = "購買"
	buy_button.add_theme_font_size_override("font_size", 30)
	buy_button.pressed.connect(_on_item_purchased.bind(item_data, index))
	buy_button.size.y = 40
	hbox.add_child(buy_button)
	
	return panel

func get_item_emoji(item_name: String) -> String:
	match item_name:
		_: return "📦"


func switch_shop():
	if !shop_view:
		create_shop()
	else:
		shop_view.visible = !shop_view.visible


func _on_refresh_button_pressed():
	print("刷新商品...")
	refresh_items()
	refresh_item_ui()

func _on_item_purchased(item_data: ItemData, index: int):
	if Slot.items.size() >= Slot.max_item_size:
		Main.show_tip("欄位不夠")
		return
	if item_data.cost > Slot.voucher:
		Main.show_tip("錢不夠")
		return
	print("購買道具: ", item_data.title, " 價格: ", item_data.cost)
	Slot.voucher -= item_data.cost
	Slot.add_item(item_data.id)
	current_items.remove_at(index)
	refresh_item_ui()
	Main.current_scene.refresh_view()


func create_shop():
	var window = ColorRect.new()
	shop_view = window
	
	var main_vbox = VBoxContainer.new()
	main_vbox.name = "VBoxContainer"
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 20)
	window.add_child(main_vbox)
	
	# 道具網格
	var grid = GridContainer.new()
	grid.name = "ItemsGrid"
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 15)
	grid.add_theme_constant_override("v_separation", 15)
	main_vbox.add_child(grid)
	items_container = grid
	
	# 刷新按鈕
	refresh_button = Button.new()
	refresh_button.name = "RefreshButton"
	refresh_button.text = "🔄 刷新商品"
	refresh_button.custom_minimum_size = Vector2(0, 40)
	refresh_button.add_theme_font_size_override("font_size", 30)
	refresh_button.pressed.connect(_on_refresh_button_pressed)
	main_vbox.add_child(refresh_button)

	refresh_item_ui()
	
	get_tree().get_root().add_child(window)
	
	# 調整大小
	await get_tree().process_frame
	window.size = main_vbox.size
	window.position = ((Main.screen_size as Vector2) - window.size) / 2.0
