extends Scene

@export var msg_lbl: Label
@export var total_lbl: Label
@export var cash_lbl: Label
@export var times_lbl: Label
@export var slot_view: SlotView

var Anim_State = SlotView.Anim_State

func _ready():
	reset()
	#Slot.add_item(Slot.Item.道具1)
	#for i in 1000:
		#start_spin()
	#print(total)
	$"數值".pressed.connect(Slot.show_probability)
	$"使用道具".pressed.connect(Slot.use_items)
	$"新一輪".pressed.connect(new_wave)
	$"商店".pressed.connect(Shop.switch_shop)


func start_spin():
	if slot_view.anim_state != Anim_State.no_anim:
		return
	if Slot.spin_times <= 0:
		return
	slot_view.play_spin_anim(3)
	Slot.start_spin()
	refresh_view()
	#if Slot.rewards.size() > 0:
		#show_reward_anim()
		#var r = Slot.calculating_rewards()
		#show_msg("中了: " + str(r))
		#Slot.money += r
	#else:
		#show_msg("沒中")


func new_wave():
	Slot.assign_spin(7)
	refresh_view()


func refresh_view():
	slot_view.refresh_view()
	total_lbl.text = str("錢：", Slot.money)
	cash_lbl.text = str("票：", Slot.cash)
	times_lbl.text = str("剩餘轉數：",Slot.spin_times)

func show_msg(msg: String):
	msg_lbl.text = msg


func reset():
	slot_view.reset()
	refresh_view()

func show_items():
	var window = Window.new()
	window.title = "道具"
	window.size = Vector2(1500, 800)
	window.close_requested.connect(window.queue_free)
	window.set_position(Vector2(100, 100))

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	window.add_child(scroll)
	
	var vc = VBoxContainer.new()
	scroll.add_child(vc)

	for i in Main.item_datas.size():
		var data: ItemData = Main.item_datas[i]
		var c = Control.new()
		c.custom_minimum_size = Vector2(200, 100)
		vc.add_child(c)
		var c_box = CheckBox.new()
		c_box.scale = Vector2(3, 3)
		c_box.position = Vector2(50, 50)
		c_box.button_pressed = i in Slot.items
		c.add_child(c_box)
		var lbl = Label.new()
		lbl.text = str(data.title, ": ", data.description)
		lbl.position = Vector2(120, 50)
		lbl.add_theme_font_size_override("font_size", 50)
		c.add_child(lbl)
		c_box.toggled.connect(test.bind(i))

	get_tree().get_root().add_child(window)
	window.popup_centered()

func test(selected: bool, item: Slot.Item):
	if selected:
		Slot.add_item(item)
	else:
		Slot.remove_item(item)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("ui_accept"):
			start_spin()
