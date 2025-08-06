extends Scene
class_name GameScene

@export var directions_img: Texture

const Item = Slot.Item

@export var shop_btn: ButtonEx
@export var slot_btn: ButtonEx
@export var select_spin_view: Panel
@export var spin_7_btn: ButtonEx
@export var spin_3_btn: ButtonEx
@export var items_view: Panel
@export var odds_view: Panel
@export var level_info_view: Panel
@export var money_lbl: LabelEx
@export var voucher_lbl: LabelEx

const SLOT_TIMES = 3 # 每輪可用機台次數
const INTEREST = 0.05 # 基礎利息

var now_level = 0
var last_slot_times = 0
var put_in_money = 0
var target_money = 0
var now_interest = 0
var data: CharacterData

func _ready() -> void:
	setup()
	reset()
	
	$"說明".pressed.connect(Main.show_directions.bind(directions_img))


func slot_end():
	Slot.money += int(put_in_money * now_interest)
	
	if last_slot_times <= 0 and Slot.money + put_in_money < target_money:
		await TransitionEffect.anim_finished
		Main.show_talk_view("失敗了").finished.connect(
			func ():
				show_result_scene(false)
				await TransitionEffect.anim_finished
				reset()
		)


func to_next_level():
	now_level += 1
	show_result_scene(true)
	
	await TransitionEffect.anim_finished
	Shop.reset()
	target_money = get_target_cash()
	last_slot_times = SLOT_TIMES
	if Item.道具20 in Slot.items:
		var get_voucher = int(Slot.voucher/3.0)
		if get_voucher > 0:
			if get_voucher > 10:
				get_voucher = 10
			Slot.voucher += get_voucher
	Slot.next_level()
	refresh_view()


func get_target_cash() -> int:
	var offset = now_level + 1
	return 50 * offset * offset


func setup():
	$ReturnButton.pressed.connect(return_scene)
	Slot.setup()
	shop_btn.pressed.connect(_on_shop_btn_pressed)
	slot_btn.pressed.connect(_on_slot_btn_pressed)
	spin_7_btn.pressed.connect(_on_select_slot_pressed.bind(0))
	spin_3_btn.pressed.connect(_on_select_slot_pressed.bind(1))
	data = Main.current_character_data


func show_item_info_view(item: Item):
	var item_data: ItemData = Main.item_datas[item]
	
	var offset = 30
	var temp_view: Control
	
	var mouse_pos = get_viewport().get_mouse_position()
	var window = ColorRect.new()
	window.size = Main.screen_size
	window.color = Color(Color.WHITE, 0)
	window.gui_input.connect(
		func (event: InputEvent):
			if event.is_pressed():
				window.queue_free()
	)
	add_child(window)
	
	var bg = ColorRect.new()
	bg.color = Color(Color.BLACK)
	window.add_child(bg)
	
	var title_lbl = Label.new()
	title_lbl.add_theme_font_size_override("font_size", 30)
	title_lbl.text = item_data.title
	title_lbl.position = Vector2(offset, offset)
	bg.add_child(title_lbl)
	temp_view = title_lbl
	
	var description_lbl = Label.new()
	description_lbl.size = Vector2(500, 30)
	description_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_lbl.add_theme_font_size_override("font_size", 30)
	description_lbl.text = item_data.description
	description_lbl.position = Vector2(
		offset,
		temp_view.position.y + temp_view.size.y + offset
	)
	bg.add_child(description_lbl)
	temp_view = description_lbl
	
	if item in Slot.items_usable.keys():
		var usable_lbl = Label.new()
		usable_lbl.add_theme_font_size_override("font_size", 30)
		usable_lbl.text = "剩餘次數: %s" % Slot.items_usable[item]
		usable_lbl.position = Vector2(
			offset,
			temp_view.position.y + temp_view.size.y + offset
		)
		bg.add_child(usable_lbl)
		temp_view = usable_lbl
	
	if item_data.remark:
		var remark_lbl = Label.new()
		remark_lbl.add_theme_font_size_override("font_size", 30)
		remark_lbl.text = item_data.remark
		remark_lbl.position = Vector2(
			offset,
			temp_view.position.y + temp_view.size.y + offset
		)
		bg.add_child(remark_lbl)
		temp_view = remark_lbl
	
	var remove_btn = ButtonEx.new()
	remove_btn.add_theme_font_size_override("font_size", 30)
	remove_btn.text = "銷毀"
	remove_btn.position = Vector2(
		offset,
		temp_view.position.y + temp_view.size.y + offset
	)
	remove_btn.pressed.connect(
		func ():
			Slot.remove_item(item)
			window.queue_free()
			refresh_view()
	)
	bg.add_child(remove_btn)
	temp_view = remove_btn
	
	bg.size = Vector2(
		max(title_lbl.size.x, description_lbl.size.x) + offset * 2.0,
		temp_view.position.y + temp_view.size.y + offset
	)
	bg.position = mouse_pos
	bg.position.x -= bg.size.x + offset
	bg.position.y -= bg.size.y / 2.0


func show_result_scene(is_success: bool):
	Main.to_scene(Main.SCENE.result)
	var result_scene: ResultScene = Main.instance_scenes[Main.SCENE.result]
	result_scene.is_success = is_success
	result_scene.level = now_level
	result_scene.refresh()


func refresh_view():
	refresh_items_view()
	refresh_odds_view()
	refresh_level_info_view()
	refresh_info_view()

func refresh_odds_view():
	# 清空
	for child in odds_view.get_children():
		child.queue_free()
	
	var temp_view = Control.new()
	var offset_x = 10
	
	var probability_string = "機率: "
	for i in Slot.SYMBOLS.size():
		probability_string += str(Slot.SYMBOLS[i], "%0.2f" % (Slot.probability[i]*100), "%  ")
	var probability_lbl = Label.new()
	probability_lbl.add_theme_font_size_override("font_size", 50)
	probability_lbl.text = probability_string
	probability_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	odds_view.add_child(probability_lbl)
	
	temp_view = probability_lbl
	
	var symblos_odds_string = "符號價值: "
	for i in Slot.SYMBOLS.size():
		symblos_odds_string += str(Slot.SYMBOLS[i], ": %s" % (Slot.symbols_odds[i]), "  ")
	symblos_odds_string += "\n符號倍率: %s" % Slot.symbols_multiplier
	var symblos_odds_lbl = Label.new()
	symblos_odds_lbl.add_theme_font_size_override("font_size", 50)
	symblos_odds_lbl.text = symblos_odds_string
	symblos_odds_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	odds_view.add_child(symblos_odds_lbl)
	
	temp_view = symblos_odds_lbl
	
	var pattern_odds_string = "圖形價值: "
	for i in Slot.Pattern.size():
		pattern_odds_string += str(Slot.Pattern.keys()[i], ": %s" % (Slot.pattern_odds[i]), "  ")
	pattern_odds_string += "\n圖形倍率: %s" % Slot.pattern_multiplier
	var pattern_odds_lbl = Label.new()
	pattern_odds_lbl.add_theme_font_size_override("font_size", 40)
	pattern_odds_lbl.text = pattern_odds_string
	pattern_odds_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	odds_view.add_child(pattern_odds_lbl)

func refresh_level_info_view():
	# 清空
	for child in level_info_view.get_children():
		child.queue_free()
	
	var temp_view = Control.new()
	var offset_x = 10
	
	var last_wave_string = str("剩餘機台使用次數: ", "%s" % last_slot_times)
	var last_wave_lbl = Label.new()
	last_wave_lbl.add_theme_font_size_override("font_size", 50)
	last_wave_lbl.text = last_wave_string
	last_wave_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	level_info_view.add_child(last_wave_lbl)
	
	temp_view = last_wave_lbl
	
	var put_in_string = str("已投入金額: ", "%s" % put_in_money)
	var put_in_lbl = Label.new()
	put_in_lbl.add_theme_font_size_override("font_size", 50)
	put_in_lbl.text = put_in_string
	put_in_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	level_info_view.add_child(put_in_lbl)
	
	temp_view = put_in_lbl
	
	var interest_string = str("利息: ", "%s" % (now_interest * 100), "%")
	var interest_lbl = Label.new()
	interest_lbl.add_theme_font_size_override("font_size", 50)
	interest_lbl.text = interest_string
	interest_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	level_info_view.add_child(interest_lbl)
	
	temp_view = interest_lbl
	
	var target_cash_string = str("目標金額: ", "%s" % target_money)
	var target_cash_lbl = Label.new()
	target_cash_lbl.add_theme_font_size_override("font_size", 50)
	target_cash_lbl.text = target_cash_string
	target_cash_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	level_info_view.add_child(target_cash_lbl)
	
	temp_view = target_cash_lbl
	
	var put_in_btn = ButtonEx.new()
	put_in_btn.add_theme_font_size_override("font_size", 50)
	put_in_btn.text = "投入"
	put_in_btn.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	put_in_btn.pressed.connect(_on_put_in_btn_pressed)
	level_info_view.add_child(put_in_btn)
	
	temp_view = put_in_btn

func refresh_items_view():
	# 清空
	for child in items_view.get_children():
		child.queue_free()
	
	var item_size = Vector2(100, 100)
	var offset_x = item_size.x + 10
	for i in Slot.items.size():
		var item: Item = Slot.items[i]
		var item_view = TextureRect.new()
		item_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		item_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		item_view.size = item_size
		item_view.texture = Main.item_datas[item].get_img()
		item_view.position = Vector2(
			i * offset_x + (items_view.size.x - offset_x * Slot.ITEMS_SIZE)/2.0,
			(items_view.size.y - item_size.y) / 2.0
		)
		item_view.gui_input.connect(
			func (event: InputEvent):
				if event.is_pressed():
					show_item_info_view(item)
		)
		items_view.add_child(item_view)

func refresh_info_view():
	money_lbl.text = str(Slot.money)
	voucher_lbl.text = str(Slot.voucher)


func reset():
	Slot.reset()
	Shop.reset()
	now_level = 0
	put_in_money = 0
	target_money = get_target_cash()
	last_slot_times = SLOT_TIMES
	now_interest = INTEREST
	select_spin_view.visible = false
	refresh_view()


func show_scene():
	if data != Main.current_character_data:
		data = Main.current_character_data
		reset()
	select_spin_view.visible = false
	refresh_view()

func return_scene():
	if Shop.shop_view.visible:
		Shop.switch_shop()
	else:
		Main.to_scene(Main.SCENE.menu)


func _on_shop_btn_pressed():
	Shop.switch_shop()

func _on_put_in_btn_pressed():
	var put_money = int(target_money / 10.0)
	if put_money > Slot.money:
		put_money = Slot.money
	Slot.money -= put_money
	put_in_money += put_money
	refresh_view()
	if put_in_money >= target_money:
		to_next_level()

func _on_slot_btn_pressed():
	if last_slot_times > 0:
		select_spin_view.visible = true
	else:
		Main.show_tip("請投入現金")

func _on_select_slot_pressed(id: int):
	match id:
		0:
			Slot.assign_spin(7)
			Slot.voucher += 1
		1:
			Slot.assign_spin(3)
			Slot.voucher += 2
	Slot.next_wave()
	last_slot_times -= 1
	Main.to_scene(Main.SCENE.slot)
