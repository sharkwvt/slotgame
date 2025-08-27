extends Control
class_name SlotView

@export var mask: Control
@export var bingo_img: Texture

var sym_panel: Control
var anim_panel: Control

const COLUMNS = Slot.COLUMNS
const ROWS = Slot.ROWS
const SYMBOLS = Slot.SYMBOLS
const SYMBOL_SIZE = Vector2(160, 150)

const GridInfo = Slot.GridInfo

var grid_views = []

var anim_state: Anim_State
enum Anim_State {
	no_anim,
	spin_anim,
	reward_anim
}
var spin_speed = 1000
var anim_grid_views = []
var new_rows: int
var old_grid: Array

signal anim_finished


func _ready():
	setup()
	create_grid_view()


func create_grid_view():
	mask.size = get_slot_size()
	for col in range(COLUMNS):
		var view_column = []
		for row in range(ROWS):
			#var unit = Label.new()
			#unit.add_theme_font_size_override("font_size", 50)
			var offset_x = (sym_panel.size.x - get_slot_size().x) / 2.0
			var offset_y = (sym_panel.size.y - get_slot_size().y) / 2.0
			#unit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			#unit.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			var unit = ColorRect.new()
			unit.color = Color(Color.GRAY, 0)
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
	
	#var lbl = Label.new()
	#lbl.add_theme_font_size_override("font_size", 50)
	#lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	#lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	#lbl.size = SYMBOL_SIZE
	#lbl.pivot_offset = lbl.size/2.0
	#lbl.text = SYMBOLS[grid_info.symbol]
	#node.add_child(lbl)
	var view = TextureRect.new()
	view.texture = Images.symbols_imgs[grid_info.symbol]
	node.add_child(view)
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


func play_spin_anim():
	sym_panel.visible = false
	anim_state = Anim_State.spin_anim
	anim_panel.visible = true
	# 清空
	for node in anim_panel.get_children():
		node.queue_free()
	anim_grid_views = []
	# 創建
	var rotate_times = 3
	var anim_duration: float = 1
	new_rows = ROWS * (rotate_times + 1)
	var last_tween: Tween
	for col in COLUMNS:
		var view_column = []
		for row in new_rows:
			var offset_x = (anim_panel.size.x - get_slot_size().x)/2.0
			var offset_y = (anim_panel.size.y - get_slot_size().y)/2.0 - SYMBOL_SIZE.y * (new_rows - ROWS)
			var unit = ColorRect.new()
			unit.color = grid_views[0][0].color
			unit.size = SYMBOL_SIZE
			unit.position = Vector2(offset_x + col * SYMBOL_SIZE.x, offset_y + row * SYMBOL_SIZE.y)
			anim_panel.add_child(unit)
			view_column.append(unit)
			# 圖示
			var grid_info: GridInfo = Slot.get_grid_info()
			if row >= new_rows - ROWS:
				grid_info = old_grid[col][row - (new_rows - ROWS)]
			elif row < ROWS:
				grid_info = Slot.grid[col][row]
			set_symbol_view(unit, grid_info)
			# 動畫
			var tween = unit.create_tween()
			tween.tween_interval(anim_duration / COLUMNS * col)
			tween.tween_property(unit, "position:y", unit.position.y + (SYMBOL_SIZE.y * (new_rows - ROWS)), anim_duration)
			if col == COLUMNS-1 and row == new_rows -1:
				last_tween = tween
		anim_grid_views.append(view_column)
	
	await last_tween.finished
	sym_panel.visible = true
	anim_panel.visible = false
	show_reward_anim()

func show_reward_anim():
	anim_state = Anim_State.reward_anim
	
	var org_duration = 0.5
	var temp_tween: Tween
	for i in Slot.rewards.size():
		var data: Slot.RewardData = Slot.rewards[i]
		var duration = org_duration / ceil((i + 1) / 2.0)
		var g_tween: Tween
		for pos in data.grid:
			var target: ColorRect = grid_views[pos.x][pos.y]
			var tween = target.create_tween()
			var bingo_view = TextureRect.new()
			bingo_view.texture = bingo_img
			bingo_view.position = Vector2.ZERO
			bingo_view.position = (target.size - bingo_view.size) / 2.0
			bingo_view.modulate.a = 0.0
			target.add_child(bingo_view)
			#tween.tween_property(target, "rotation_degrees", 45, duration)
			#tween.tween_property(target, "rotation_degrees", -45, duration)
			#tween.tween_property(target, "rotation_degrees", 0, duration)
			#var org_color = target.color
			#tween.tween_property(target, "color", Color.RED, duration)
			#if Slot.grid[pos.x][pos.y].is_golden_modifiers:
				#tween.tween_property(target, "color", Color.YELLOW, duration)
				#g_tween = tween
			#tween.tween_property(target, "color", org_color, duration)
			tween.tween_property(bingo_view, "modulate:a", 1.0, duration)
			if Slot.grid[pos.x][pos.y].is_golden_modifiers:
				for j in 2:
					tween.tween_property(bingo_view, "modulate:a", 0.0, duration/3)
					tween.tween_property(bingo_view, "modulate:a", 1.0, duration/3)
				g_tween = tween
			tween.tween_property(bingo_view, "modulate:a", 0.0, duration)
			tween.tween_callback(tween.kill)
			temp_tween = tween
		if g_tween:
			temp_tween = g_tween
		await temp_tween.finished
	
	anim_state = Anim_State.no_anim
	
	refresh_view()
	
	anim_finished.emit()

func setup():
	sym_panel = Control.new()
	add_child(sym_panel)
	anim_panel = Control.new()
	add_child(anim_panel)
	

func reset():
	anim_state = Anim_State.no_anim
	anim_panel.visible = false
	refresh_view()

func get_slot_size() -> Vector2:
	return Vector2(SYMBOL_SIZE.x * COLUMNS, SYMBOL_SIZE.y * ROWS)
