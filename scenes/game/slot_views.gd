extends Control
class_name SlotViews

@export var game_scene: GameScene

@export var cumulative_amount_lbl: Label
@export var use_item_btn: ButtonEx
@export var spin_btn: ButtonEx
@export var slot_view: SlotView
@export var symbols_panel: Control

var cumulative_amount = 0
var btn_used = false
var in_spin = false

var Anim_State = SlotView.Anim_State


func _ready():
	use_item_btn.pressed.connect(_on_item_btn_pressed)
	spin_btn.pressed.connect(start_spin)
	var slot_size = slot_view.get_slot_size()
	symbols_panel.set_deferred("size", slot_size)
	symbols_panel.position -= slot_size / 2.0


func start_spin():
	if in_spin:
		return
	if Slot.spin_times <= 0:
		return
	in_spin = true
	slot_view.old_grid = Slot.grid.duplicate(true)
	
	# 轉時效果
	Slot.triggered_items.clear()
	Slot.effect_before_spin()
	game_scene.show_triggered_items()
	await game_scene.triggered_anim_finish
	# 轉動
	Slot.start_spin()
	game_scene.refresh_view()
	slot_view.play_spin_anim()
	await slot_view.anim_finished
	# 轉後效果
	Slot.effect_after_spin()
	game_scene.show_triggered_items()
	await game_scene.triggered_anim_finish
	in_spin = false
	game_scene.refresh_view()
	_on_spin_finish()


func refresh_view():
	slot_view.refresh_view()
	cumulative_amount_lbl.text = "累積金額：%s" % cumulative_amount
	cumulative_amount_lbl.text += "\n剩餘次數：%s" % Slot.spin_times

func reset():
	btn_used = false
	use_item_btn.disabled = false
	slot_view.reset()
	refresh_view()


func _on_item_btn_pressed():
	if not btn_used:
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
		Logger.log(str("中了 ", r))
		cumulative_amount += r
		Slot.money += r
	
	game_scene.refresh_view()
	
	if Slot.spin_times <= 0:
		await Main.show_talk_view("拉霸次數用完了").finished
		Slot.slot_end()
		game_scene.slot_end()
		game_scene.switch_view(game_scene.VIEW_STATE.menu)
		game_scene.refresh_view()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("ui_accept"):
			start_spin()
