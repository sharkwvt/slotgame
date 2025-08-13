extends Scene
class_name GameScene

const Item = Slot.Item

@export var start_view: Control
@export var menu_view: Control
@export var game_view: Control

@export var items_views: ItemsViews
@export var odds_views: OddsViews
@export var infos_views: InfosViews
@export var slot_views: SlotViews
@export var result_views: ResultViews

# menu_view
@export var shop_btn: ButtonEx
@export var slot_btn: ButtonEx
@export var select_spin_view: Panel
@export var spin_7_btn: ButtonEx
@export var spin_3_btn: ButtonEx

enum VIEW_STATE {
	start,
	menu,
	game,
	result
}

const SLOT_TIMES = 3 # 每輪可用機台次數
const INTEREST = 0.05 # 基礎利息

var view_state: VIEW_STATE

var now_level = 0
var last_slot_times = 0
var put_in_money = 0
var target_money = 0
var now_interest = 0
var data: CharacterData
var triggered_item_tween: Tween

signal triggered_anim_finish

func _ready() -> void:
	setup()
	switch_view(VIEW_STATE.start)
	reset()


func slot_end():
	Slot.money += int(put_in_money * now_interest)
	refresh_view()
	
	if last_slot_times <= 0 and Slot.money + put_in_money < target_money:
		Main.show_talk_view("失敗了").finished.connect(
			func ():
				switch_view(VIEW_STATE.start)
				reset()
		)


func to_next_level():
	now_level += 1
	show_result_scene(true)
	Shop.reset()
	target_money = get_target_cash()
	if Item.道具20 in Slot.items:
		var get_voucher = int(Slot.voucher/3.0)
		if get_voucher > 0:
			if get_voucher > 10:
				get_voucher = 10
			Slot.voucher += get_voucher
	Slot.next_level()
	Slot.voucher += get_bonus_voucher()
	last_slot_times = SLOT_TIMES
	refresh_view()


func get_target_cash() -> int:
	var offset = now_level + 1
	return 50 * offset * offset

func get_bonus_voucher() -> int:
	return last_slot_times * 5


func setup():
	Main.instance_scenes[Main.SCENE.game] = self
	Main.current_scene = self
	Slot.setup()
	shop_btn.pressed.connect(_on_shop_btn_pressed)
	slot_btn.pressed.connect(_on_slot_btn_pressed)
	spin_7_btn.pressed.connect(_on_select_slot_pressed.bind(0))
	spin_3_btn.pressed.connect(_on_select_slot_pressed.bind(1))


func show_result_scene(is_success: bool):
	result_views.is_success = is_success
	result_views.level = now_level
	result_views.refresh_view()
	switch_view(VIEW_STATE.result)


func show_triggered_items():
	# 排除道具
	var skip_items = [Item.道具40]
	for i in Slot.SYMBOLS.size():
		skip_items.append(Item.道具33 + i)
	var items = Slot.triggered_items.filter(func (item): return item not in skip_items)
	
	if items.size() > 0:
		var last_tween: Tween
		var offset = 50
		for i in items.size():
			var item: Slot.Item = items[i]
			var item_data: ItemData = Main.item_datas[item]
			var item_img = TextureRect.new()
			add_child(item_img)
			item_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			item_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			item_img.size = Vector2(100, 100)
			item_img.texture = item_data.get_img()
			item_img.position = Vector2(
				offset,
				Main.screen_size.y
			)
			var tween = item_img.create_tween()
			tween.tween_interval(i * 0.5)
			tween.tween_property(item_img, "position:y", Main.screen_size.y - item_img.size.y - offset, 0.5)
			tween.tween_property(item_img, "position:y", Main.screen_size.y, 0.5)
			tween.finished.connect(
				func ():
					item_img.queue_free()
					tween.kill()
			)
			last_tween = tween
		triggered_item_tween = last_tween
		Slot.triggered_items.clear()
		await triggered_item_tween.finished
		triggered_anim_finish.emit()
	else:
		await get_tree().process_frame
		triggered_anim_finish.emit()


func refresh_view():
	odds_views.refresh_view()
	items_views.refresh_view()
	infos_views.refresh_view()
	slot_views.refresh_view()


func switch_view(state: VIEW_STATE):
	start_view.visible = state == VIEW_STATE.start
	odds_views.visible = state != VIEW_STATE.start
	items_views.visible = state != VIEW_STATE.start
	
	menu_view.visible = state == VIEW_STATE.menu
	infos_views.visible = state == VIEW_STATE.menu
	$GalleryButton.visible = state == VIEW_STATE.menu
	if state == VIEW_STATE.menu:
		select_spin_view.visible = false
		slot_btn.visible = true
		refresh_view()
	
	game_view.visible = state == VIEW_STATE.game
	if state == VIEW_STATE.game:
		slot_views.cumulative_amount = 0
		refresh_view()
	
	result_views.visible = state == VIEW_STATE.result
	
	view_state = state


func reset():
	Slot.reset()
	Shop.reset()
	now_level = 0
	put_in_money = 0
	target_money = get_target_cash()
	last_slot_times = SLOT_TIMES
	now_interest = INTEREST
	select_spin_view.visible = false
	refresh_view()


func return_scene():
	if Shop.shop_view and Shop.shop_view.visible:
		Shop.switch_shop()
	elif view_state == VIEW_STATE.menu:
		switch_view(VIEW_STATE.start)


func _on_shop_btn_pressed():
	Shop.switch_shop()

func _on_put_in_btn_pressed():
	var put_money = int(target_money / 10.0)
	if put_money > Slot.money:
		put_money = Slot.money
	Slot.money -= put_money
	put_in_money += put_money
	refresh_view()
	if put_in_money >= target_money:
		to_next_level()

func _on_slot_btn_pressed():
	if last_slot_times > 0:
		select_spin_view.visible = true
		slot_btn.visible = false
	else:
		Main.show_tip("請投入現金")

func _on_select_slot_pressed(id: int):
	match id:
		0:
			Slot.assign_spin(7)
			Slot.voucher += 1
		1:
			Slot.assign_spin(3)
			Slot.voucher += 2
	Slot.next_wave()
	last_slot_times -= 1
	switch_view(VIEW_STATE.game)
