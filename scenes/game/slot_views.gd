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

var Anim_State = SlotView.Anim_State


func _ready():
	use_item_btn.pressed.connect(_on_item_btn_pressed)
	spin_btn.pressed.connect(start_spin)
	slot_view.anim_finished.connect(_on_spin_finish)
	var slot_size = slot_view.get_slot_size()
	symbols_panel.set_deferred("size", slot_size)
	symbols_panel.position = (Main.screen_size as Vector2 - symbols_panel.size) / 2.0


func start_spin():
	if slot_view.anim_state != Anim_State.no_anim:
		return
	if Slot.spin_times <= 0:
		return
	slot_view.old_grid = Slot.grid.duplicate(true)
	Slot.start_spin()
	slot_view.play_spin_anim()
	game_scene.refresh_view()


func refresh_view():
	slot_view.refresh_view()
	cumulative_amount_lbl.text = "累積金額：%s" % cumulative_amount

func reset():
	btn_used = false
	slot_view.reset()
	refresh_view()


func _on_item_btn_pressed():
	if not btn_used:
		Slot.use_items()
		btn_used = true
		game_scene.refresh_view()


func _on_spin_finish():
	btn_used = false
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
