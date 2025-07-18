extends Scene

@export var msg_lbl: Label
@export var total_lbl: Label
@export var cash_lbl: Label
@export var times_lbl: Label
@export var sym_panel: Control
@export var anim_panel: Control

const COLUMNS = Slot.COLUMNS
const ROWS = Slot.ROWS
const SYMBOLS = Slot.SYMBOLS
const SYMBOL_SIZE = Vector2(100, 100)

var grid_views = []

var anim_state: Anim_State
enum Anim_State {
	no_anim,
	spin_anim,
	reward_anim
}
var spin_speed = 1000
var spin_anim_timer: float = 0
var anim_grid_views = []
var anim_max_y: float
var anim_timer: Timer


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
	$"商店".pressed.connect(Shop.switch_shop)
	anim_timer = Timer.new()
	anim_timer.wait_time = 0.8
	anim_timer.one_shot = true
	add_child(anim_timer)


func _process(delta: float) -> void:
	if anim_state == Anim_State.spin_anim:
		run_spin_anim(delta)


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

func get_symbol_view(symbol: int) -> Control:
	var lbl = Label.new()
	lbl.add_theme_font_size_override("font_size", 50)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.size = SYMBOL_SIZE
	lbl.pivot_offset = lbl.size/2.0
	lbl.text = SYMBOLS[symbol]
	return lbl


func start_spin():
	if anim_state != Anim_State.no_anim:
		return
	if Slot.spin_times <= 0:
		return
	play_spin_anim(3)
	Slot.start_spin()
	refresh_view()
	#if Slot.rewards.size() > 0:
		#show_reward_anim()
		#var r = Slot.calculating_rewards()
		#show_msg("中了: " + str(r))
		#Slot.money += r
	#else:
		#show_msg("沒中")


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
			var symbol_view = get_symbol_view(Slot.grid[col][row])
			unit.add_child(symbol_view)
	# 黃標
	for gm: Vector2 in Slot.golden_modifiers:
		var unit: Control = grid_views[gm.x][gm.y]
		var gm_icon = ColorRect.new()
		gm_icon.color = Color.YELLOW
		gm_icon.size = Vector2(10, 10)
		gm_icon.position = Vector2(10, 10)
		unit.add_child(gm_icon)

	total_lbl.text = str("錢：", Slot.money)
	cash_lbl.text = str("票：", Slot.cash)
	times_lbl.text = str("剩餘轉數：",Slot.spin_times)


func play_spin_anim(rotate_times: float):
	anim_state = Anim_State.spin_anim
	anim_panel.visible = true
	spin_anim_timer = rotate_times
	# 清空
	for node in anim_panel.get_children():
		node.queue_free()
	anim_grid_views = []
	# 創建
	for col in COLUMNS:
		var view_column = []
		for row in ROWS+1:
			var offset_x = (anim_panel.size.x - SYMBOL_SIZE.x*COLUMNS)/2.0
			var offset_y = (anim_panel.size.y - SYMBOL_SIZE.y*ROWS)/2.0 - SYMBOL_SIZE.y
			var unit = ColorRect.new()
			unit.color = Color.GRAY
			unit.size = SYMBOL_SIZE
			unit.position = Vector2(offset_x + col * SYMBOL_SIZE.x, offset_y + row * SYMBOL_SIZE.y)
			anim_panel.add_child(unit)
			view_column.append(unit)
			# 圖示
			var symbol = Slot.grid[col][row-1] if row > 0 else Slot.get_unit()
			var symbol_view = get_symbol_view(symbol)
			unit.add_child(symbol_view)
		anim_grid_views.append(view_column)
	anim_max_y = anim_grid_views[0][-1].position.y + SYMBOL_SIZE.y

func run_spin_anim(delta: float):
	var is_end = true
	for col in COLUMNS:
		for row in ROWS+1:
			var unit: Control = anim_grid_views[col][row]
			if spin_anim_timer > 0:
				is_end = false
				unit.position.y += spin_speed * delta
				if unit.position.y >= anim_max_y:
					if col == COLUMNS-1 and row == ROWS:
						spin_anim_timer -= 1
						if spin_anim_timer <= 0:
							# 開啟動畫計時器
							anim_timer.start()
					unit.position.y -= SYMBOL_SIZE.y * (ROWS+1)
					unit.get_child(0).queue_free()
					unit.add_child(get_symbol_view(Slot.get_unit()))
			else:
				var new_speed = spin_speed * delta * (anim_timer.time_left/anim_timer.wait_time)
				if new_speed < 1:
					new_speed = 1
				if row != ROWS:
					var target_view: Control = grid_views[col][row]
					if unit.position.y > target_view.position.y:
						is_end = false
						unit.position.y += new_speed
						if unit.position.y >= anim_max_y:
							unit.position.y -= SYMBOL_SIZE.y * (ROWS+1)
							unit.get_child(0).queue_free()
							unit.add_child(get_symbol_view(Slot.grid[col][row]))
					else:
						unit.position.y += new_speed
						if unit.position.y >= target_view.position.y:
							unit.position = target_view.position
						else:
							is_end = false
				else:
					unit.position.y += new_speed
	if is_end:
		anim_timer.stop()
		anim_panel.visible = false
		show_reward_anim()


func show_reward_anim():
	anim_state = Anim_State.reward_anim
	
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
	
	anim_state = Anim_State.no_anim
	
	refresh_view()

func show_msg(msg: String):
	msg_lbl.text = msg


func reset():
	anim_state = Anim_State.no_anim
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
