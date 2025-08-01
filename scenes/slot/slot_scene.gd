extends Scene
class_name SlotScene

@export var directions_img: Texture

@export var cumulative_amount_lbl: Label
@export var slot_view: SlotView

var cumulative_amount = 0

var Anim_State = SlotView.Anim_State


func _ready():
	reset()
	$"數值".pressed.connect(Slot.show_probability)
	$"使用道具".pressed.connect(Slot.use_items)
	$"拉霸".pressed.connect(start_spin)
	slot_view.anim_finished.connect(_on_spin_finish)
	
	$"說明".pressed.connect(Main.show_directions.bind(directions_img))


func start_spin():
	if slot_view.anim_state != Anim_State.no_anim:
		return
	if Slot.spin_times <= 0:
		return
	slot_view.play_spin_anim(3)
	Slot.start_spin()
	refresh_view()


func refresh_view():
	slot_view.refresh_view()
	cumulative_amount_lbl.text = "累積金額：%s" % cumulative_amount

func reset():
	slot_view.reset()
	refresh_view()


func show_scene():
	cumulative_amount = 0
	refresh_view()


func _on_spin_finish():
	if Slot.rewards.size() > 0:
		var r = Slot.calculating_rewards()
		Logger.log(str("中了 ", r))
		cumulative_amount += r
		Slot.money += r
	if Slot.spin_times <= 0:
		var game_scene: GameScene = Main.instance_scenes[Main.SCENE.game]
		game_scene.slot_end()
		Main.to_scene(Main.SCENE.game)
	refresh_view()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("ui_accept"):
			start_spin()
