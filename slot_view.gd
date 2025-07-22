extends Control
class_name SlotView

var sym_panel: Control
var anim_panel: Control

const COLUMNS = Slot.COLUMNS
const ROWS = Slot.ROWS
const SYMBOLS = Slot.SYMBOLS
const SYMBOL_SIZE = Vector2(100, 100)

const GridInfo = Slot.GridInfo

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

signal anim_finished


func _ready():
	setup()
	create_grid_view()

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

func set_symbol_view(node:Node, grid_info: GridInfo):
	# 清空
	for child in node.get_children():
		child.queue_free()
	
	var lbl = Label.new()
	lbl.add_theme_font_size_override("font_size", 50)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.size = SYMBOL_SIZE
	lbl.pivot_offset = lbl.size/2.0
	lbl.text = SYMBOLS[grid_info.symbol]
	node.add_child(lbl)
	if grid_info.is_golden_modifiers:
		var gm_icon = ColorRect.new()
		gm_icon.color = Color.YELLOW
		gm_icon.size = Vector2(10, 10)
		gm_icon.position = Vector2(10, 10)
		node.add_child(gm_icon)


func refresh_view():
	for col in Slot.grid.size():
		for row in Slot.grid[col].size():
			# 清空
			var unit: Control = grid_views[col][row]
			for c in unit.get_children():
				c.queue_free()
			
			var grid_info: GridInfo = Slot.grid[col][row]
			set_symbol_view(unit, grid_info)


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
			var grid_info: GridInfo = Slot.grid[col][row-1] if row > 0 else Slot.get_grid_info()
			set_symbol_view(unit, grid_info)
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
					set_symbol_view(unit, Slot.get_grid_info())
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
							set_symbol_view(unit, Slot.grid[col][row])
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
			if Slot.grid[pos.x][pos.y].is_golden_modifiers:
				tween.tween_property(target, "color", Color.YELLOW, duration)
			tween.tween_property(target, "color", org_color, duration)
			tween.tween_callback(tween.kill)
			temp_tween = tween
		await temp_tween.finished
	
	anim_state = Anim_State.no_anim
	
	refresh_view()
	
	anim_finished.emit()

func setup():
	sym_panel = Control.new()
	add_child(sym_panel)
	anim_panel = Control.new()
	add_child(anim_panel)
	anim_timer = Timer.new()
	anim_timer.wait_time = 0.8
	anim_timer.one_shot = true
	add_child(anim_timer)
	

func reset():
	anim_state = Anim_State.no_anim
	anim_panel.visible = false
	refresh_view()
