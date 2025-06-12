extends Scene

@export var msg_lbl: Label
@export var total_lbl: Label
@export var times_lbl: Label
@export var sym_panel: Control

const COLUMNS = Slot.COLUMNS
const ROWS = Slot.ROWS
const SYMBOLS = Slot.SYMBOLS
const SYMBOL_SIZE = Vector2(100, 100)

var grid_views = []
var playing_anim = false

var total = 0

func _ready():
	Main.current_scene = self
	create_grid_view()
	reset()
	#Slot.add_item(Slot.Item.道具1)
	#for i in 1000:
		#start_spin()
	#print(total)
	$"數值".pressed.connect(Slot.show_probability)
	$"使用道具".pressed.connect(Slot.use_items)
	$"新一輪".pressed.connect(new_wave)
	$"商店".pressed.connect(Shop.show_shop)


func create_grid_view():
	for col in range(COLUMNS):
		var view_column = []
		for row in range(ROWS):
			#var unit = Label.new()
			#unit.add_theme_font_size_override("font_size", 50)
			var offset_x = (sym_panel.size.x - SYMBOL_SIZE.x*COLUMNS)/2.0
			var offset_y = (sym_panel.size.y - SYMBOL_SIZE.y*ROWS)/2.0
			#unit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			#unit.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			var unit = ColorRect.new()
			unit.color = Color.GRAY
			unit.size = SYMBOL_SIZE
			unit.position = Vector2(offset_x + col * SYMBOL_SIZE.x, offset_y + row * SYMBOL_SIZE.y)
			#unit.pivot_offset = unit.size/2.0
			sym_panel.add_child(unit)
			view_column.append(unit)
		grid_views.append(view_column)


func start_spin():
	if playing_anim:
		return
	if !Slot.start_spin():
		return
	refresh_view()
	if Slot.rewards.size() > 0:
		show_reward_anim()
		var r = Slot.calculating_rewards()
		show_msg("中了: " + str(r))
		total += r
	else:
		show_msg("沒中")


func new_wave():
	Slot.assign_spin(7)
	refresh_view()


func refresh_view():
	for col in Slot.grid.size():
		for row in Slot.grid[col].size():
			# 清空
			var unit: Control = grid_views[col][row]
			for c in unit.get_children():
				c.queue_free()
			# 圖示
			var lbl = Label.new()
			lbl.add_theme_font_size_override("font_size", 50)
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.size = SYMBOL_SIZE
			lbl.pivot_offset = lbl.size/2.0
			lbl.text = SYMBOLS[Slot.grid[col][row]]
			unit.add_child(lbl)
	# 黃標
	for gm: Vector2 in Slot.golden_modifiers:
		var unit: Control = grid_views[gm.x][gm.y]
		var gm_icon = ColorRect.new()
		gm_icon.color = Color.YELLOW
		gm_icon.size = Vector2(10, 10)
		gm_icon.position = Vector2(10, 10)
		unit.add_child(gm_icon)

	total_lbl.text = str(total)
	times_lbl.text = str(Slot.spin_times)


func show_reward_anim():
	playing_anim = true
	var duration = 0.5
	var temp_tween: Tween
	for data: Slot.RewardData in Slot.rewards:
		for pos in data.grid:
			var target: ColorRect = grid_views[pos.x][pos.y]
			var tween = target.create_tween()
			#tween.tween_property(target, "rotation_degrees", 45, duration)
			#tween.tween_property(target, "rotation_degrees", -45, duration)
			#tween.tween_property(target, "rotation_degrees", 0, duration)
			var org_color = target.color
			tween.tween_property(target, "color", Color.RED, duration)
			if pos in Slot.golden_modifiers:
				tween.tween_property(target, "color", Color.YELLOW, duration)
			tween.tween_property(target, "color", org_color, duration)
			tween.tween_callback(tween.kill)
			temp_tween = tween
		await temp_tween.finished
	playing_anim = false

func show_msg(msg: String):
	msg_lbl.text = msg


func reset():
	refresh_view()

func show_items():
	var window = Window.new()
	window.title = "道具"
	window.size = Vector2(1500, 800)
	window.close_requested.connect(window.queue_free)
	window.set_position(Vector2(100, 100))

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	window.add_child(scroll)
	
	var vc = VBoxContainer.new()
	scroll.add_child(vc)

	for i in Main.item_datas.size():
		var data: ItemData = Main.item_datas[i]
		var c = Control.new()
		c.custom_minimum_size = Vector2(200, 100)
		vc.add_child(c)
		var c_box = CheckBox.new()
		c_box.scale = Vector2(3, 3)
		c_box.position = Vector2(50, 50)
		c_box.button_pressed = i in Slot.items
		c.add_child(c_box)
		var lbl = Label.new()
		lbl.text = str(data.title, ": ", data.description)
		lbl.position = Vector2(120, 50)
		lbl.add_theme_font_size_override("font_size", 50)
		c.add_child(lbl)
		c_box.toggled.connect(test.bind(i))

	get_tree().get_root().add_child(window)
	window.popup_centered()

func test(selected: bool, item: Slot.Item):
	if selected:
		Slot.add_item(item)
	else:
		Slot.remove_item(item)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("ui_accept"):
			start_spin()
