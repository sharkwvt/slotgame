extends Control
class_name SlotViews

@export var game_scene: GameScene

@export var spin_spine: SpineSpriteEx

@export var item_btn_img: TextureRect
@export var item_btn_n: Texture
@export var item_btn_p: Texture

@export var use_item_btn: ButtonEx
@export var spin_btn: ButtonEx
@export var slot_view: SlotView
@export var symbols_panel: Control

@export var info_lbl_3d: Label3D

var cumulative_amount = 0
var btn_used = false
var in_spin = false
var btn_on_enter = false

var Anim_State = SlotView.Anim_State


func _ready():
	use_item_btn.pressed.connect(_on_item_btn_pressed)
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
	in_spin = false
	if btn_on_enter and can_spin():
		spin_spine.set_skin("push_1")
	game_scene.refresh_view()
	_on_spin_finish()

func refresh_info_label():
	info_lbl_3d.text = "剩餘次數："
	info_lbl_3d.text += "\n%s" % Slot.spin_times
	info_lbl_3d.text += "\n持有總額："
	info_lbl_3d.text += "\n%s" % Slot.money
	info_lbl_3d.text += "\n目標金額："
	info_lbl_3d.text += "\n%s" % game_scene.target_money


func refresh_view():
	slot_view.refresh_view()
	refresh_info_label()

func reset():
	btn_used = false
	use_item_btn.disabled = false
	slot_view.reset()
	refresh_view()


func _on_item_btn_pressed():
	if not btn_used and not in_spin:
		item_btn_img.texture = item_btn_p
		Slot.triggered_items.clear()
		Slot.use_items()
		btn_used = true
		use_item_btn.disabled = true
		game_scene.show_triggered_items()
		await game_scene.triggered_anim_finish
		game_scene.refresh_view()


func _on_spin_finish():
	btn_used = false
	use_item_btn.disabled = false
	if Slot.rewards.size() > 0:
		var r = Slot.calculating_rewards()
		slot_view.show_reward_tip(str(r), 1)
		Logger.log(str("中了 ", r))
		cumulative_amount += r
		Slot.money += r
	
	#spin_img.texture = spin_n
	item_btn_img.texture = item_btn_n
	game_scene.refresh_view()
	
	if Slot.spin_times <= 0:
		await Main.show_talk_view("拉霸次數用完了").finished
		Slot.slot_end()
		game_scene.slot_end()
		if !game_scene.result_check():
			game_scene.switch_view(game_scene.VIEW_STATE.menu)
			game_scene.refresh_view()

func can_spin() -> bool:
	return !(in_spin or Slot.spin_times <= 0)

func _on_spin_btn_mouse_entered():
	btn_on_enter = true
	if can_spin():
		spin_spine.set_skin("push_1")

func _on_spin_btn_mouse_exited():
	btn_on_enter = false
	spin_spine.set_skin("push_0")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("ui_accept"):
			start_spin()
