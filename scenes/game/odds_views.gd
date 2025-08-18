extends Control
class_name OddsViews

@export var symbols_odds_view: Panel
@export var pattern_btn: ButtonEx
@export var pattern_odds_view: Panel
@export var symbols_btn: ButtonEx

func _ready() -> void:
	pattern_btn.pressed.connect(
		func ():
			pattern_odds_view.visible = true
			symbols_odds_view.visible = false
	)
	symbols_btn.pressed.connect(
		func ():
			symbols_odds_view.visible = true
			pattern_odds_view.visible = false
	)

func refresh_view():
	# 清空
	for child in symbols_odds_view.get_children():
		child.queue_free()
	for child in pattern_odds_view.get_children():
		child.queue_free()
	
	var symblos_odds_string = ""
	for i in Slot.SYMBOLS.size():
		symblos_odds_string += str(Slot.SYMBOLS[i], ": %s$  %0.2f" % [Slot.symbols_odds[i], Slot.probability[i]*100], "%\n")
	symblos_odds_string += "符號倍率: %s" % Slot.symbols_multiplier
	var symblos_odds_lbl = Label.new()
	symbols_odds_view.add_child(symblos_odds_lbl)
	symblos_odds_lbl.add_theme_font_size_override("font_size", 40)
	symblos_odds_lbl.text = symblos_odds_string
	symblos_odds_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	symblos_odds_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	symblos_odds_lbl.position = Vector2.ZERO
	symblos_odds_lbl.position = (symbols_odds_view.size - symblos_odds_lbl.size) / 2.0
	
	var pattern_odds_string = ""
	for i in Slot.Pattern.size():
		pattern_odds_string += str(Slot.Pattern.keys()[i], ": x%s" % (Slot.pattern_odds[i]), "\n")
	pattern_odds_string += "圖形倍率: %s" % Slot.pattern_multiplier
	var pattern_odds_lbl = Label.new()
	pattern_odds_view.add_child(pattern_odds_lbl)
	pattern_odds_lbl.add_theme_font_size_override("font_size", 30)
	pattern_odds_lbl.text = pattern_odds_string
	pattern_odds_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pattern_odds_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pattern_odds_lbl.position = Vector2.ZERO
	pattern_odds_lbl.position = (pattern_odds_view.size - pattern_odds_lbl.size) / 2.0
