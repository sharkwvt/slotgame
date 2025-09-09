extends Control
class_name InfosViews

@export var game_scene: GameScene

@export var money_lbl: LabelEx
@export var voucher_lbl: LabelEx

@export var level_info_view: Control
@export var wave_lbl: Label


func refresh_view():
	wave_lbl.text = str(tr("當前輪次:"), " ", game_scene.now_level + 1)
	refresh_level_info_view()
	refresh_info_view()


func refresh_level_info_view():
	# 清空
	for child in level_info_view.get_children():
		child.queue_free()
	
	var temp_view = Control.new()
	var offset_x = 0
	var font_color = Main.theme_colors[0]
	var font_size = 30
	
	var last_wave_string = str(tr("剩餘機台使用次數:"), " %s" % game_scene.last_slot_times)
	var last_wave_lbl = LabelEx.new()
	last_wave_lbl.add_theme_color_override("font_color", font_color)
	last_wave_lbl.add_theme_font_size_override("font_size", font_size)
	last_wave_lbl.text = last_wave_string
	last_wave_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	last_wave_lbl.size = Vector2(level_info_view.size.x, font_size + 10)
	level_info_view.add_child(last_wave_lbl)
	
	temp_view = last_wave_lbl
	
	#var put_in_string = str("已投入金額: ", "%s" % game_scene.put_in_money)
	#var put_in_lbl = Label.new()
	#put_in_lbl.add_theme_font_size_override("font_size", 40)
	#put_in_lbl.text = put_in_string
	#put_in_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	#level_info_view.add_child(put_in_lbl)
	#
	#temp_view = put_in_lbl
	
	#var interest_string = str("利息: ", "%s" % (game_scene.now_interest * 100), "%")
	#var interest_lbl = Label.new()
	#interest_lbl.add_theme_font_size_override("font_size", 40)
	#interest_lbl.text = interest_string
	#interest_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	#level_info_view.add_child(interest_lbl)
	#
	#temp_view = interest_lbl
	
	var target_cash_string = str(tr("目標金額:"), " %s" % game_scene.target_money)
	var target_cash_lbl = LabelEx.new()
	target_cash_lbl.add_theme_color_override("font_color", font_color)
	target_cash_lbl.add_theme_font_size_override("font_size", font_size)
	target_cash_lbl.text = target_cash_string
	target_cash_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	target_cash_lbl.size = Vector2(level_info_view.size.x, font_size + 10)
	level_info_view.add_child(target_cash_lbl)
	
	temp_view = target_cash_lbl
	
	var cash_string = str(tr("當前金額:"), " %s" % Slot.money)
	var cash_lbl = LabelEx.new()
	cash_lbl.add_theme_color_override("font_color", font_color)
	cash_lbl.add_theme_font_size_override("font_size", font_size)
	cash_lbl.text = cash_string
	cash_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	cash_lbl.size = Vector2(level_info_view.size.x, font_size + 10)
	level_info_view.add_child(cash_lbl)
	
	temp_view = cash_lbl
	
	#var bonus_string = str(tr("結算獎勵:"), " %s" % game_scene.get_bonus_voucher())
	var bonus_string = tr("結算獎勵:")
	var bonus_lbl = LabelEx.new()
	bonus_lbl.add_theme_color_override("font_color", font_color)
	bonus_lbl.add_theme_font_size_override("font_size", font_size)
	bonus_lbl.text = bonus_string
	bonus_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	bonus_lbl.max_size = Vector2(150, font_size + 10)
	bonus_lbl.size_to_fit = false
	level_info_view.add_child(bonus_lbl)
	var voucher_count = Label.new()
	voucher_count.add_theme_color_override("font_color", font_color)
	voucher_count.add_theme_font_size_override("font_size", font_size)
	voucher_count.text = str(game_scene.get_bonus_voucher())
	level_info_view.add_child(voucher_count)
	var voucher_icon = TextureRect.new()
	voucher_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	voucher_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	voucher_icon.texture = Images.voucher_icon
	voucher_icon.size = Vector2(bonus_lbl.size.y, bonus_lbl.size.y)
	level_info_view.add_child(voucher_icon)
	var set_voucher_view = func ():
		voucher_count.position = bonus_lbl.position
		voucher_count.position.x += bonus_lbl.size.x * bonus_lbl.scale.x
		voucher_icon.position = voucher_count.position
		voucher_icon.position.x += voucher_count.size.x
	set_voucher_view.call()
	bonus_lbl.minimum_size_changed.connect(set_voucher_view)
	
	temp_view = bonus_lbl
	
	#var put_in_btn = ButtonEx.new()
	#put_in_btn.add_theme_font_size_override("font_size", 40)
	#put_in_btn.text = "投入"
	#put_in_btn.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	#put_in_btn.pressed.connect(game_scene._on_put_in_btn_pressed)
	#level_info_view.add_child(put_in_btn)
	#
	#temp_view = put_in_btn

func refresh_info_view():
	money_lbl.text = str(Slot.money)
	voucher_lbl.text = str(Slot.voucher)
