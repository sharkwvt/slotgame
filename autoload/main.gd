extends Node

var screen_size = Vector2i(1920, 1080)

var debug = true

var items_json_path = "res://data/json/items.json"
var talk_json_path = "res://data/json/talk.json"
var game_save_path = "user://moragame.sav"
var csv_path = "res://categorys/%s/csv"

# 視窗
var setting_view = preload("res://common/setting/setting_view.tscn")
var talk_view = preload("res://common/talk/talk.tscn")
var dialog_view = preload("res://common/dialog/dialog.tscn")

var music_1 = preload("res://sound/maou_bgm_acoustic50.mp3")
var btn_sfx = preload("res://sound/maou_se_system47.mp3")

var mouse_click_effect = preload("res://common/mouse_click_effect.tscn")
var mouse_trail_effect: GPUParticles2D

var item_datas = []
var character_datas = []

var instance_talk_view: Control

var current_scene: Control

var instance_scenes = [] # 實例化場景
enum SCENE {
	start,
	category,
	menu,
	game,
	review
}


var music_player: AudioStreamPlayer

var this_platform: String = "other" # 遊戲平台

const STAT_KEY_Characters = "characters_data"
const STAT_KEY_Achievements = "achievements_data"
# 要同步的數據
var statistics: Dictionary = {
	STAT_KEY_Characters: [],
	STAT_KEY_Achievements: []
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance_scenes.resize(SCENE.size())
	reload_data()
	Input.set_custom_mouse_cursor(load("res://image/mouse.png"),Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(load("res://image/mouse2.png"),Input.CURSOR_POINTING_HAND)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#move_mouse_trail()
	pass


func move_mouse_trail():
	if mouse_trail_effect == null:
		create_mouse_trail()
	mouse_trail_effect.position = get_tree().root.get_mouse_position()
	

func create_mouse_trail():
	mouse_trail_effect = GPUParticles2D.new()
	mouse_trail_effect.texture = load("res://image/spark_particle2.png")
	var ppm := ParticleProcessMaterial.new()
	ppm.gravity = Vector3.ZERO # 清除重力
	mouse_trail_effect.process_material = ppm
	mouse_trail_effect.amount = 10
	mouse_trail_effect.speed_scale = 2
	mouse_trail_effect.emitting = true
	get_tree().root.add_child(mouse_trail_effect)


func play_music(music):
	if not music_player:
		music_player = AudioStreamPlayer.new()
		music_player.bus = "Music"
		music_player.finished.connect(_on_music_finished)
		add_child(music_player)
	music_player.stream = music
	music_player.play()


func to_scene(scene: SCENE, anim_type = 0):
	if instance_scenes[scene] is Control:
		# 使用已創建的場景
		instance_scenes[scene].move_to_front()
		instance_scenes[scene].show_scene()
		# 避免閃爍
		await get_tree().process_frame
		instance_scenes[scene].visible = true
	else:
		# 創建場景
		#match scene:
			#SCENE.category:
				#instance_scenes[scene] = category_scene.instantiate()
			#SCENE.menu:
				#instance_scenes[scene] = menu_scene.instantiate()
			#SCENE.game:
				#instance_scenes[scene] = game_scene.instantiate()
			#SCENE.review:
				#instance_scenes[scene] = review_scene.instantiate()
		get_tree().root.add_child(instance_scenes[scene])
		
	TransitionEffect.start_transition(current_scene, anim_type)
	current_scene = instance_scenes[scene]
	
	# 滑鼠特效移到最前
	#mouse_trail_effect.move_to_front()

#region Save and load
func reload_data():
	Logger.log("platform: " + Main.this_platform)
	load_items_data()
	load_game_save()

func load_items_data():
	item_datas.clear()
	var json_data = get_json_data(items_json_path)
	if !json_data.is_empty():
		var items: Array = json_data["items"]
		for dic: Dictionary in items:
			var data = ItemData.new()
			for key in dic.keys():
				if key in data:
					data.set(key, dic[key])
			item_datas.append(data)


func save_game():
	statistics[STAT_KEY_Characters] = []
	var save_file = FileAccess.open(game_save_path, FileAccess.WRITE)
	
	for data: CharacterData in character_datas:
		var dic = {
			"id" = data.id,
			"progress" = data.progress,
			"has_bonus" = data.has_bonus
		}
		statistics[STAT_KEY_Characters].append(dic)
	
	statistics[STAT_KEY_Achievements] = Steamworks.achievements
	#save_file.store_line(JSON.stringify(statistics))
	save_file.store_var(statistics)


func load_game_save():
	if not FileAccess.file_exists(game_save_path):
		print("存擋不存在")
		return
		
	var file := FileAccess.open(game_save_path, FileAccess.READ)
	if not file:
		print("讀取存擋失敗")
		return
		
	var save_data = file.get_var()
	file.close()
	if save_data == null:
		print("存擋為空")
		return
		
	statistics = save_data
	for data: CharacterData in character_datas:
		for obj in statistics[STAT_KEY_Characters]:
			if obj["id"] == data.id:
				data.progress = obj["progress"]
				data.has_bonus = obj["has_bonus"]
	
	if statistics.find_key(STAT_KEY_Achievements):
		Steamworks.achievements = statistics[STAT_KEY_Achievements]
#endregion

func get_json_data(path: String) -> Dictionary:
	var json = JSON.new()
	if not FileAccess.file_exists(path):
		print(path + " 不存在")
		return {}
		
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		print("讀取" + path + "失敗")
		return {}
		
	var content := file.get_as_text()
	file.close()
	
	var pares_result := json.parse(content)
	if pares_result != OK:
		print(path + "內容錯誤")
		return {}
	
	return json.data


func show_setting_view():
	get_tree().root.add_child(setting_view.instantiate())


func show_talk_view(text):
	if instance_talk_view:
		instance_talk_view.queue_free()
	instance_talk_view = talk_view.instantiate()
	get_tree().root.add_child(instance_talk_view)
	instance_talk_view.show_talk_anim(text)


func show_tip(msg: String):
	var lbl := Label.new()
	lbl.add_theme_font_size_override("font_size", 50)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.grow_horizontal = Control.GROW_DIRECTION_BOTH
	lbl.grow_vertical = Control.GROW_DIRECTION_BEGIN
	lbl.text = msg
	lbl.position = get_viewport().get_mouse_position()
	get_tree().root.add_child(lbl)
	var tween: Tween = lbl.create_tween()
	tween.set_parallel(true)
	tween.tween_property(lbl, "position:y", lbl.position.y - 100, 3)
	tween.tween_property(lbl, "modulate:a", 0, 3)
	#tween.finished.connect(lbl.queue_free)
	await tween.finished
	lbl.queue_free()
	tween.kill()


func show_dialog(msg: String):
	var dialog = ConfirmationDialog.new()
	current_scene.add_child(dialog)
	dialog.dialog_text = msg
	dialog.popup_centered()
	dialog.confirmed.connect(func(): print("okokok1"))
	dialog.canceled.connect(func(): print("okokok2"))


func create_dialog_view() -> DialogView:
	var dialog = dialog_view.instantiate()
	get_tree().root.add_child(dialog)
	return dialog


func play_sfx(sfx):
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = sfx
	audio_player.bus = "SFX"
	audio_player.finished.connect(audio_player.queue_free)
	get_tree().root.add_child(audio_player)
	audio_player.play()

func play_btn_sfx():
	play_sfx(btn_sfx)


func _on_music_finished():
	music_player.play()


func _input(event):
	# 滑鼠任何鍵
	if event is InputEventMouseButton and event.pressed:
		var click_effect: GPUParticles2D = mouse_click_effect.instantiate()
		click_effect.emitting = true
		click_effect.position = Vector2(event.position.x+0,event.position.y+0)
		get_tree().root.add_child(click_effect)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("scale_time"):
		#get_tree().paused = not get_tree().paused
		Engine.time_scale = 1.0 if Engine.time_scale == 0.01 else 0.01
		show_setting_view()
	
	if event.is_action_pressed("ui_cancel"):
		if Steamworks.dlc_tip:
			Steamworks.dlc_tip.queue_free()
			return
		if !TransitionEffect.main and current_scene.visible:
			current_scene.return_scene()
