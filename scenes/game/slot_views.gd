extends Control
class_name SlotViews

@export var game_scene: GameScene

@export var spin_spine: SpineSpriteEx

@export var spin_btn: ButtonEx
@export var slot_view: SlotView
@export var symbols_panel: Control

@export var info_lbl_3d: Label3D

var cumulative_amount = 0
var in_spin = false
var item_btn_on_enter = false
var spin_btn_on_enter = false

var Anim_State = SlotView.Anim_State


func _ready():
	spin_btn.pressed.connect(start_spin)
	spin_btn.mouse_entered.connect(_on_spin_btn_mouse_entered)
	spin_btn.mouse_exited.connect(_on_spin_btn_mouse_exited)
	var slot_size = slot_view.get_slot_size()
	symbols_panel.set_deferred("size", slot_size)
	symbols_panel.position -= slot_size / 2.0


func start_spin():
	if !can_spin():
		return
	in_spin = true
	spin_spine.set_skin("push_0")
	spin_spine.play_first_anim(false)
	slot_view.old_grid = Slot.grid.duplicate(true)
	
	Slot.triggered_items.clear()
	Slot.trigger_count = 0
	# 轉時效果
	Slot.effect_before_spin()
	game_scene.show_triggered_items()
	await game_scene.triggered_anim_finish
	Slot.destroy_item_check()
	# 轉動
	Slot.start_spin()
	game_scene.refresh_view()
	if !Main.debug or !Main.skip_anim:
		slot_view.play_spin_anim()
		await slot_view.spin_anim_finished
		slot_view.show_reward_anim()
		await slot_view.reward_anim_finished
	# 轉後效果
	Slot.effect_after_spin()
	game_scene.show_triggered_items()
	await game_scene.triggered_anim_finish
	game_scene.refresh_view()
	_on_spin_finish()


func can_spin() -> bool:
	return !(in_spin or Slot.spin_times <= 0)


func refresh_info_label():
	info_lbl_3d.text = "%s\n" % Slot.spin_times
	info_lbl_3d.text += "%s\n" % Slot.money
	info_lbl_3d.text += "%s" % game_scene.target_money


func refresh_view():
	slot_view.refresh_view()
	refresh_info_label()

func reset():
	slot_view.reset()
	refresh_view()


func _on_spin_finish():
	if Slot.rewards.size() > 0:
		var r = Slot.calculating_rewards()
		slot_view.show_reward_tip(str(r))
		Logger.log(str("中了 ", r))
		cumulative_amount += r
		Slot.money += r
		Steamworks.set_achievement(Steamworks.ACHIEVEMENT_12)
		if r >= 100:
			Steamworks.set_achievement(Steamworks.ACHIEVEMENT_3)
		if r >= 300:
			Steamworks.set_achievement(Steamworks.ACHIEVEMENT_4)
		if r >= 500:
			Steamworks.set_achievement(Steamworks.ACHIEVEMENT_5)
		if r >= 1000:
			Steamworks.set_achievement(Steamworks.ACHIEVEMENT_6)
		await slot_view.reward_tip_finished
	
	Slot.used_items.clear()
	
	game_scene.refresh_view()
	
	#spin_img.texture = spin_n
	#item_btn_img.texture = item_btn_n
	
	if Slot.spin_times <= 0:
		await Main.show_talk_view("拉霸次數用完了").finished
		game_scene.slot_end()
		if !game_scene.result_check():
			game_scene.switch_view(game_scene.VIEW_STATE.menu)
			await game_scene.zoomed
	
	in_spin = false
	if can_spin():
		if spin_btn_on_enter:
			spin_spine.set_skin("push_1")
	game_scene.refresh_view()

func _on_spin_btn_mouse_entered():
	spin_btn_on_enter = true
	if can_spin():
		spin_spine.set_skin("push_1")

func _on_spin_btn_mouse_exited():
	spin_btn_on_enter = false
	spin_spine.set_skin("push_0")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("ui_accept"):
			start_spin()
