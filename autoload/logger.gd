extends Node

var logs = []
var log_window: Window
var lbl: RichTextLabel
var to_close: bool

func show_log():
	if log_window:
		return
	log_window = Window.new()
	log_window.title = "Log"
	log_window.size = Vector2(1500, 800)
	log_window.close_requested.connect(close)
	log_window.set_position(Vector2(100, 100))

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	log_window.add_child(scroll)
	
	lbl = RichTextLabel.new()
	lbl.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	lbl.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	lbl.add_theme_font_size_override("normal_font_size", 30)
	lbl.bbcode_enabled = true
	lbl.scroll_active = true
	lbl.scroll_following = true
	scroll.add_child(lbl)

	for line in logs:
		lbl.append_text("[color=white]" + str(line) + "[/color]\n")

	# 添加關閉按鈕
	#var close_button := Button.new()
	#close_button.text = "Close"
	#close_button.pressed.connect(close)
	#vbox.add_child(close_button)

	get_tree().get_root().add_child(log_window)
	log_window.popup_centered()


func refresh():
	if lbl:
		var s = ""
		for line: String in logs:
			s += line + "\n"
		lbl.text = s


func log(msg: String):
	print(msg)
	logs.append(msg)
	refresh()


func close():
	if log_window:
		log_window.queue_free()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("show_log"):
		Logger.show_log()
	
	if event.is_action_pressed("ui_cancel"):
		close()
