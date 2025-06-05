extends Node

var steam_appid: int = 3668520
#var steam_appid: int = 480 # 測試用
#var steam_appid: int = 3681730 # playtest
var steam_id: int = 0
var steam_name: String = "You"

var img_path = "res://image/steam/%s"
var spine_path = "res://spine/dlc/%s.tres"

const ACHV_Win = "ACHIEVEMENT_1"
const ACHV_InToilet = "ACHIEVEMENT_2"
const ACHV_InToilet2 = "ACHIEVEMENT_3"
const ACHV_Paper = "ACHIEVEMENT_4"
const ACHV_Rock = "ACHIEVEMENT_5"
const ACHV_Scissor = "ACHIEVEMENT_6"
const ACHV_InBuilding = "ACHIEVEMENT_7"
const ACHV_Fail = "ACHIEVEMENT_8"
const ACHV_Draw = "ACHIEVEMENT_9"
const ACHV_Fail2 = "ACHIEVEMENT_10"
const ACHV_Draw2 = "ACHIEVEMENT_11"
const ACHV_Win2 = "ACHIEVEMENT_12"
const ACHV_Play30 = "ACHIEVEMENT_13"
const ACHV_Play60 = "ACHIEVEMENT_14"
const ACHV_Review = "ACHIEVEMENT_15"
var achievements: Dictionary = {
	ACHV_Win: false, # 首勝
	ACHV_InToilet: false, # 進廁所
	ACHV_InToilet2: false, # 進階廁所
	ACHV_Paper: false, # 布
	ACHV_Rock: false, # 石頭
	ACHV_Scissor: false, # 剪刀
	ACHV_InBuilding: false, # 進建築
	ACHV_Fail: false, # 輸
	ACHV_Draw: false, # 平手
	ACHV_Fail2: false, # 輸3
	ACHV_Draw2: false, # 平手3
	ACHV_Win2: false, # 贏3
	ACHV_Play30: false, # 30分鐘
	ACHV_Play60: false, # 60分鐘
	ACHV_Review: false # 回想
}

var dlc_data: Array
enum DLC {
	醫院 = 3728980,
	學校 = 3728990,
	大樓 = 3729000,
	動畫1 = 3756280
}

var dlc_tip: Control
var return_btn_path = "res://common/btn/return/return_button.tscn"

func _init() -> void:
	initialize_steam()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func is_steam_enabled() -> bool:
	if Main.this_platform == "steam":
		return true
	return false


# steam 初始化
func initialize_steam() -> void:
	if Engine.has_singleton("Steam"):
		var initialized: Dictionary = Steam.steamInitEx(steam_appid, true)
		
		Logger.log("[STEAM] 初始化: %s" % initialized)
		
		if initialized['status'] != Steam.STEAM_API_INIT_RESULT_OK:
			Logger.log("Steam初始化失敗, 停用功能: %s" % initialized)
			return
		
		Main.this_platform = "steam"
		steam_id = Steam.getSteamID()
		steam_name = Steam.getPersonaName()
		Logger.log("steam_id " + str(steam_id))
		Logger.log("steam_name " + steam_name)
		
		connect_steam_callbacks()
		dlc_check()


func connect_steam_callbacks() -> void:
	Steam.current_stats_received.connect(_on_steam_stats_ready)
	Steam.user_stats_received.connect(_on_steam_stats_ready)
	Steam.dlc_installed.connect(_on_dlc_installed)


func dlc_check():
	dlc_data = Steam.getDLCData()
	#Logger.log("dlc_data: %s" % str(dlc_data))
	for dic: Dictionary in dlc_data:
		if Steam.isDLCInstalled(dic["id"]):
			Logger.log("isDLCInstalled: %s" % str(dic["id"]))
			PckLoader.load_dlc_pck(dic["id"])


func _on_steam_stats_ready(this_game: int, this_result: int, this_user: int) -> void:
	Logger.log("開始接收Steam數據和成就: %s / %s / %s" % [this_user, this_result, this_game])
	if this_user != steam_id:
		Logger.log("玩家不符, 本地:%s Steam:%s" % [steam_id, this_user])
		return
	if this_game != steam_appid:
		Logger.log("App ID 不符, 本地:%s Steam:%s" % [steam_appid, this_game])
		return
	if this_result != Steam.RESULT_OK:
		Logger.log("Steam數據和成就接收失敗:%s" % this_result)
		return
	load_steam_stats()
	load_steam_achievements()


# 讀取數據
func load_steam_stats() -> void:
	var statistics := Main.statistics
	for this_stat in statistics.keys():
		var steam_stat: int = Steam.getStatInt(this_stat)
		if statistics[this_stat] != steam_stat:
			Logger.log("數據 %s 數值不同, 取最大, 本地:%s Steam:%s" % [this_stat, statistics[this_stat], steam_stat])
			set_statistic(this_stat, statistics[this_stat] if statistics[this_stat] > steam_stat else steam_stat)
		else:
			Logger.log("數據 %s 數值相同" % this_stat)
	Logger.log("Steam數據讀取完成")


# 讀取成就
func load_steam_achievements() -> void:
	Logger.log(str("成就資料: ", achievements))
	for this_achievement in achievements.keys():
		var steam_achievement: Dictionary = Steam.getAchievement(this_achievement)
		
		if not steam_achievement['ret']:
			Logger.log("Steam不存在 %s 成就" % this_achievement)
			break
		if achievements[this_achievement] == steam_achievement['achieved']:
			Logger.log("成就 %s 狀態相同, 不需更改" % this_achievement)
			break
		
		set_achievement(this_achievement)
	
	Logger.log("Steam成就讀取完成")


# 設定數據
func set_statistic(this_stat: String, new_value: int = 0) -> void:
	var statistics := Main.statistics
	if not statistics.has(this_stat):
		Logger.log("數據 %s 不存在" % this_stat)
		return
	
	statistics[this_stat] = new_value
	
	if not Steam.setStatInt(this_stat, new_value):
		Logger.log("數據 %s 設定成 %s 失敗" % [this_stat, new_value])
		return
		
	Logger.log("數據 %s 設定 %s 成功" % [this_stat, new_value])
	
	if not Steam.storeStats():
		Logger.log("數據觸發失敗")
		return
	
	Logger.log("數據傳送完成")


# 設定成就
func set_achievement(this_achievement: String) -> void:
	if !Steamworks.is_steam_enabled():
		Logger.log("Steam未啟動")
		return
	
	if not achievements.has(this_achievement):
		Logger.log("成就不存在: %s" % this_achievement)
		return
	
	achievements[this_achievement] = true
	Main.save_game()
	
	if not Steam.setAchievement(this_achievement):
		Logger.log("成就設定失敗: %s" % this_achievement)
		return
	
	Logger.log("設定成就: %s" % this_achievement)
	
	if not Steam.storeStats():
		Logger.log("觸發成就失敗")
		return
	
	Logger.log("成就設定完成")


func show_DLC_tip(id: int = steam_appid):
	Logger.log(str("show_DLC_tip: ", id))
	
	if dlc_tip:
		dlc_tip.queue_free()
	
	if !is_steam_enabled():
		Main.show_tip("需購買DLC")
		return
	
	if not Main.debug:
		for dlc: Dictionary in dlc_data:
			if dlc["id"] == id:
				if dlc["available"] == false:
					id = 0
	
	var img_name = ""
	var title = ""
	var spine: SpineSpriteEx
	match id:
		DLC.醫院:
			img_name = "dlc_banner_b.png"
			#title = (Main.categorys_data[1] as CategoryData).category_title
		DLC.學校:
			img_name = "dlc_banner_a.png"
			#title = (Main.categorys_data[2] as CategoryData).category_title
		DLC.大樓:
			img_name = "dlc_banner_c.png"
			#title = (Main.categorys_data[3] as CategoryData).category_title
		DLC.動畫1:
			img_name = "dlc_banner_a.png"
			spine = SpineSpriteEx.new()
			spine.skeleton_data_res = load(spine_path % "sex_girl_b2")
			spine.play_first_anim()
			title = "動畫包"
		_:
			Main.show_tip("尚未開放")
			return
	
	var mask = ColorRect.new()
	get_tree().root.add_child(mask)
	mask.color = Color(Color.BLACK, 0.0)
	mask.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	mask.gui_input.connect(func(event:InputEvent): if event.is_pressed(): mask.queue_free())
	var img_view = TextureRect.new()
	mask.add_child(img_view)
	img_view.texture = load(img_path % img_name)
	if spine:
		img_view.self_modulate = Color(0, 0, 0, 0)
		img_view.add_child(spine)
	var title_lbl = Label.new()
	mask.add_child(title_lbl)
	title_lbl.text = title
	title_lbl.add_theme_font_size_override("font_size", 50)
	var close_btn = ButtonEx.new()
	mask.add_child(close_btn)
	close_btn.icon = load(img_path % "close.png")
	close_btn.pressed.connect(mask.queue_free)
	close_btn.flat = true
	var btn = ButtonEx.new()
	mask.add_child(btn)
	btn.icon = load(img_path % "buy_dlc.png")
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.flat = true
	btn.text = "立即購買"
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 50)
	img_view.position = Vector2.ZERO # 不知為何這樣才能取到size
	btn.position = Vector2.ZERO
	img_view.position = Vector2(
		(mask.size.x - img_view.size.x)/2.0,
		(mask.size.y - img_view.size.y)/2.0,
	)
	if spine:
		spine.position = Vector2(
			img_view.size.x / 2.0,
			img_view.size.y / 2.0,
		)
	title_lbl.position = Vector2(
		img_view.position.x + 150,
		img_view.position.y + 80
	)
	close_btn.position = Vector2(
		img_view.position.x + img_view.size.x - 160,
		img_view.position.y + 70
	)
	btn.position = Vector2(
		(mask.size.x - btn.size.x)/2.0,
		img_view.position.y + img_view.size.y - btn.size.y - 80
	)
	btn.pressed.connect(Steam.activateGameOverlayToStore.bind(id))
	
	dlc_tip = mask


func _on_dlc_installed(dlc_id: int):
	Logger.log("DLC安裝完成：%s" % dlc_id)
	PckLoader.load_dlc_pck(dlc_id)
