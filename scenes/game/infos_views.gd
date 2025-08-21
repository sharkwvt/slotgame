extends Control
class_name InfosViews

@export var game_scene: GameScene

@export var money_lbl: LabelEx
@export var voucher_lbl: LabelEx

@export var level_info_view: Control
@export var level_info_label_3d: Label3D 


func refresh_view():
	refresh_level_info_view()
	refresh_info_view()


func refresh_level_info_view():
	# 清空
	for child in level_info_view.get_children():
		child.queue_free()
	
	var temp_view = Control.new()
	var offset_x = 10
	
	var last_wave_string = str("剩餘機台使用次數: ", "%s" % game_scene.last_slot_times)
	var last_wave_lbl = Label.new()
	last_wave_lbl.add_theme_font_size_override("font_size", 50)
	last_wave_lbl.text = last_wave_string
	last_wave_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
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
	
	var target_cash_string = str("目標金額: ", "%s" % game_scene.target_money)
	var target_cash_lbl = Label.new()
	target_cash_lbl.add_theme_font_size_override("font_size", 50)
	target_cash_lbl.text = target_cash_string
	target_cash_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	level_info_view.add_child(target_cash_lbl)
	
	temp_view = target_cash_lbl
	
	var cash_string = str("當前金額: ", "%s" % Slot.money)
	var cash_lbl = Label.new()
	cash_lbl.add_theme_font_size_override("font_size", 50)
	cash_lbl.text = cash_string
	cash_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	level_info_view.add_child(cash_lbl)
	
	temp_view = cash_lbl
	
	var bonus_string = str("結算獎勵: ", "%s兌換券" % game_scene.get_bonus_voucher())
	var bonus_lbl = Label.new()
	bonus_lbl.add_theme_font_size_override("font_size", 50)
	bonus_lbl.text = bonus_string
	bonus_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	level_info_view.add_child(bonus_lbl)
	
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
