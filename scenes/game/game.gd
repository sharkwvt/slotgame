extends Scene

const Item = Slot.Item

@export var shop_btn: ButtonEx
@export var slot_btn: ButtonEx
@export var items_view: Panel
@export var odds_view: Panel
@export var level_info_view: Panel

var now_level = 0
var last_wave = 3
var put_in_cash = 0
var target_cash = 0

func _ready() -> void:
	setup()
	refresh_view()

func setup():
	target_cash = get_target_cash()
	shop_btn.pressed.connect(_on_shop_btn_pressed)
	slot_btn.pressed.connect(_on_slot_btn_pressed)

func refresh_view():
	refresh_items_view()
	refresh_odds_view()
	refresh_level_info_view()

func get_target_cash() -> int:
	return now_level * 100 + 100

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
	pattern_odds_lbl.add_theme_font_size_override("font_size", 30)
	pattern_odds_lbl.text = pattern_odds_string
	pattern_odds_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	odds_view.add_child(pattern_odds_lbl)

func refresh_level_info_view():
	# 清空
	for child in level_info_view.get_children():
		child.queue_free()
	
	var temp_view = Control.new()
	var offset_x = 10
	
	var last_wave_string = str("剩餘機台使用次數: ", "%s" % last_wave)
	var last_wave_lbl = Label.new()
	last_wave_lbl.add_theme_font_size_override("font_size", 50)
	last_wave_lbl.text = last_wave_string
	last_wave_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	level_info_view.add_child(last_wave_lbl)
	
	temp_view = last_wave_lbl
	
	var put_in_string = str("已投入金額: ", "%s" % put_in_cash)
	var put_in_lbl = Label.new()
	put_in_lbl.add_theme_font_size_override("font_size", 50)
	put_in_lbl.text = put_in_string
	put_in_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	level_info_view.add_child(put_in_lbl)
	
	temp_view = put_in_lbl
	
	var target_cash_string = str("目標金額: ", "%s" % target_cash)
	var target_cash_lbl = Label.new()
	target_cash_lbl.add_theme_font_size_override("font_size", 50)
	target_cash_lbl.text = target_cash_string
	target_cash_lbl.position = Vector2(offset_x, temp_view.position.y + temp_view.size.y + offset_x)
	level_info_view.add_child(target_cash_lbl)
	
	temp_view = target_cash_lbl

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
		items_view.add_child(item_view)


func show_scene():
	refresh_view()

func return_scene():
	Main.to_scene(Main.SCENE.menu)


func _on_shop_btn_pressed():
	Shop.switch_shop()

func _on_slot_btn_pressed():
	Main.to_scene(Main.SCENE.demo)
