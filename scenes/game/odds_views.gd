extends Control
class_name OddsViews

@export var slot_view: SlotView

@export var symbols_odds_view: Control
@export var pattern_btn: ButtonEx
@export var pattern_odds_view: Control
@export var symbols_btn: ButtonEx
@export var bg_switch: TextureRect

func _ready() -> void:
	pattern_btn.pressed.connect(
		func ():
			pattern_odds_view.visible = true
			symbols_odds_view.visible = false
			bg_switch.visible = false
	)
	symbols_btn.pressed.connect(
		func ():
			pattern_odds_view.visible = false
			symbols_odds_view.visible = true
			bg_switch.visible = true
	)

func refresh_view():
	refresh_symbols_odds()
	refresh_pattern_odds()

func refresh_symbols_odds():
	# 清空
	for child in symbols_odds_view.get_children():
		child.queue_free()
	
	var odds_view = symbols_odds_view
	var offset = 20
	var gc = GridContainer.new()
	gc.columns = 5
	gc.add_theme_constant_override("v_separation", 10)
	odds_view.add_child(gc)
	for i in Slot.SYMBOLS.size():
		var icon = TextureRect.new()
		icon.texture = Images.symbols_imgs_s[i]
		gc.add_child(icon)
		
		var spacer = Control.new()
		spacer.custom_minimum_size.x = offset
		gc.add_child(spacer)
		
		var icon_money = TextureRect.new()
		icon_money.texture = Images.money_icon
		gc.add_child(icon_money)
		
		var money_lbl = LabelEx.new()
		money_lbl.text = str(Slot.symbols_odds[i])
		money_lbl.add_theme_font_size_override("font_size", 40)
		money_lbl.custom_minimum_size.x = 100
		gc.add_child(money_lbl)
		
		var probability_lbl = Label.new()
		probability_lbl.text = str("%0.2f" % (Slot.probability[i]*100), "%")
		probability_lbl.add_theme_font_size_override("font_size", 40)
		probability_lbl.custom_minimum_size.x = 100
		probability_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		gc.add_child(probability_lbl)
	gc.position = Vector2.ZERO
	gc.position = (odds_view.size - gc.size) / 2.0
	gc.position.y = 50
	var odds_bg = ColorRect.new()
	odds_bg.color = Main.theme_colors[0]
	odds_view.add_child(odds_bg)
	
	var odds_lbl = Label.new()
	odds_lbl.add_theme_font_size_override("font_size", 40)
	odds_lbl.text = "符號倍率:"
	odds_lbl.position.x = offset
	odds_bg.add_child(odds_lbl)
	
	var multiplier_lbl = Label.new()
	multiplier_lbl.add_theme_font_size_override("font_size", 40)
	multiplier_lbl.text = "x%s" % int(Slot.symbols_multiplier)
	multiplier_lbl.position = Vector2.ZERO
	odds_bg.add_child(multiplier_lbl)
	
	var money_icon = TextureRect.new()
	money_icon.texture = Images.money_icon
	odds_bg.add_child(money_icon)
	
	# 定位
	odds_bg.size = Vector2(
		symbols_odds_view.size.x - offset * 2,
		odds_lbl.size.y
	)
	odds_bg.position = Vector2(
		offset,
		odds_view.size.y - odds_bg.size.y
	)
	multiplier_lbl.position.x = odds_bg.size.x - offset - multiplier_lbl.size.x
	money_icon.position.x = multiplier_lbl.position.x - money_icon.size.x


func refresh_pattern_odds():
	# 清空
	for child in pattern_odds_view.get_children():
		child.queue_free()
		
	var odds_view = pattern_odds_view
	var offset = 20
	var gc = GridContainer.new()
	gc.columns = 4
	#gc.add_theme_constant_override("v_separation", 1)
	odds_view.add_child(gc)
	for i in Slot.Pattern.size():
		var icon = TextureRect.new()
		icon.texture = Images.pattern_imgs[i]
		gc.add_child(icon)
		
		var spacer = Control.new()
		spacer.custom_minimum_size.x = offset * 3
		gc.add_child(spacer)
		
		var icon_money = TextureRect.new()
		icon_money.texture = Images.money_icon
		icon_money.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_money.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_money.custom_minimum_size = Vector2(50, icon.size.y)
		gc.add_child(icon_money)
		
		var money_lbl = Label.new()
		money_lbl.text = "x%s" % (Slot.pattern_odds[i])
		money_lbl.add_theme_font_size_override("font_size", 30)
		gc.add_child(money_lbl)
	gc.position = Vector2.ZERO
	gc.position = (odds_view.size - gc.size) / 2.0
	gc.position.y = offset
	var odds_bg = ColorRect.new()
	odds_bg.color = Main.theme_colors[0]
	odds_view.add_child(odds_bg)
	
	var odds_lbl = Label.new()
	odds_lbl.add_theme_font_size_override("font_size", 40)
	odds_lbl.text = "圖形倍率:"
	odds_lbl.position.x = offset
	odds_bg.add_child(odds_lbl)
	
	var multiplier_lbl = Label.new()
	multiplier_lbl.add_theme_font_size_override("font_size", 40)
	multiplier_lbl.text = "x%s" % int(Slot.pattern_multiplier)
	multiplier_lbl.position = Vector2.ZERO
	odds_bg.add_child(multiplier_lbl)
	
	var money_icon = TextureRect.new()
	money_icon.texture = Images.money_icon
	odds_bg.add_child(money_icon)
	
	# 定位
	odds_bg.size = Vector2(
		odds_view.size.x - offset * 2,
		odds_lbl.size.y
	)
	odds_bg.position = Vector2(
		offset,
		odds_view.size.y - odds_bg.size.y
	)
	multiplier_lbl.position.x = odds_bg.size.x - offset - multiplier_lbl.size.x
	money_icon.position.x = multiplier_lbl.position.x - money_icon.size.x
