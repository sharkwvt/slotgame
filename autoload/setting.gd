extends Node

var config = ConfigFile.new()
var setting_path = "user://setting.cfg"
var setting_section = "setting"

var setting_lang_key = "LANG"
var setting_music_key = "MUSIC"
var setting_sfx_key = "SFX"
var setting_screen_key = "SCREEN_MODE"
var setting_data: Dictionary = {}

var langs = ["zhc", "zh", "en"]
var pj_size: Vector2

enum SCREEN_MODE {
	視窗720p,
	視窗1080p,
	視窗1440p,
	視窗2160p,
	全螢幕
}

func _init() -> void:
	default_settings()
	load_setting()

func default_settings():
	setting_data[setting_music_key] = 0.5
	setting_data[setting_sfx_key] = 0.5
	setting_data[setting_screen_key] = SCREEN_MODE.視窗720p
	load_lang()


func load_lang():
	var lang
	if "TW" or "HK" in OS.get_locale():
		lang = "zhc"
	else:
		lang = OS.get_locale_language()
	setting_data[setting_lang_key] = lang
	TranslationServer.set_locale(lang)


func load_setting():
	var err = config.load(setting_path)
	if err != OK:
		reset_setting()
		return
	for key in setting_data.keys():
		if config.has_section_key(setting_section, key):
			setting_data[key] = config.get_value(setting_section, key)
	
	set_music_db(setting_data[setting_music_key])
	set_sound_db(setting_data[setting_sfx_key])
	set_screen_mode(setting_data[setting_screen_key])
	set_lang(setting_data[setting_lang_key])


func set_setting(key, value):
	setting_data[key] = value
	config.set_value(setting_section, key, value)
	config.save(setting_path)


func reset_setting():
	config.clear()
	config.save(setting_path)


func set_lang(value):
	TranslationServer.set_locale(value)
	set_setting(setting_lang_key, value)


func set_music_db(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), 60 * (value - 1))
	set_setting(setting_music_key, value)


func set_sound_db(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), 60 * (value - 1))
	set_setting(setting_sfx_key, value)


func set_screen_mode(mode: SCREEN_MODE):
	var is_window = mode != SCREEN_MODE.全螢幕
	var to_window = DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]
	if is_window and to_window:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		#await get_tree().process_frame # 等待下一幀
		await get_tree().create_timer(0.1).timeout
	
	match mode:
		SCREEN_MODE.視窗720p:
			DisplayServer.window_set_size(Vector2i(1280, 720))
		SCREEN_MODE.視窗1080p:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		SCREEN_MODE.視窗1440p:
			DisplayServer.window_set_size(Vector2i(2560, 1440))
		SCREEN_MODE.視窗2160p:
			DisplayServer.window_set_size(Vector2i(3840, 2160))
		SCREEN_MODE.全螢幕:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	
	if is_window:
		center_window()
	
	set_setting(setting_screen_key, mode)
	
# 視窗置中
func center_window():
	var screen_size = DisplayServer.screen_get_size(0)
	var window_size = DisplayServer.window_get_size()
	var new_position = (screen_size - window_size) / 2
	DisplayServer.window_set_position(new_position)
