extends Control

var lang_lbl: Label
var display_lbl: Label
var music_lbl: Label
var sound_lbl: Label
var lang_option: OptionButton
var display_option: OptionButton
var option_btns = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()
	refresh()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		queue_free()


func setup():
	lang_lbl = $SettingBG/LangLabel
	display_lbl = $SettingBG/DisplayLabel
	music_lbl = $SettingBG/MusicLabel
	sound_lbl = $SettingBG/SoundLabel
	lang_option = $SettingBG/LangLabel/OptionButton
	display_option = $SettingBG/DisplayLabel/OptionButton
	option_btns.append(lang_option)
	option_btns.append(display_option)


func refresh():
	var music_db = Setting.setting_data[Setting.setting_music_key]
	var sound_db = Setting.setting_data[Setting.setting_sfx_key]
	$SettingBG/MusicLabel/MusicSlider.value = music_db
	$SettingBG/SoundLabel/SoundSlider.value = sound_db
	lang_option.selected = Setting.langs.find(Setting.setting_data[Setting.setting_lang_key])
	display_option.selected = Setting.setting_data[Setting.setting_screen_key]
	for op_btn: OptionButton in option_btns:
		var popup: PopupMenu = op_btn.get_popup()
		popup.add_theme_font_size_override("font_size", 50) # 改字體大小
	
	# 排版
	var offset_y = 100
	var lbl_count = $SettingBG.get_children().size()
	$SettingBG.size.y = offset_y * (lbl_count + 1)
	for i in lbl_count:
		var lbl: Control = $SettingBG.get_children()[i]
		lbl.position.y = $SettingBG.size.y/2.0 + offset_y * (i - lbl_count/2.0)


func _on_music_slider_value_changed(value: float) -> void:
	Setting.set_music_db(value)


func _on_sound_slider_value_changed(value: float) -> void:
	Setting.set_sound_db(value)


func _on_sound_slider_drag_ended(_value_changed: bool) -> void:
	$SettingBG/SoundLabel/SoundSlider/AudioStreamPlayer.play()


func _on_close_button_pressed() -> void:
	queue_free()


func _on_lang_option_item_selected(index: int) -> void:
	Main.play_btn_sfx()
	Setting.set_lang(Setting.langs[index])


func _on_display_option_item_selected(index: int) -> void:
	Main.play_btn_sfx()
	Setting.set_screen_mode(index)

func _on_option_button_pressed() -> void:
	Main.play_btn_sfx()
