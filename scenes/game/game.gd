extends Scene
class_name GameScene

const Item = Slot.Item

@export var slot_img: TextureRect
@export var slot_bg: TextureRect
@export var camera: Camera2D
@export var zoom_anim_view: Control

@export var start_view: Control
@export var setting_view: Control
@export var menu_view: Control
@export var game_view: Control
@export var shop_view: Control
@export var select_spin_view: Control

@export var items_views: ItemsViews
@export var odds_views: OddsViews
@export var infos_views: InfosViews
@export var slot_views: SlotViews
@export var book_views: BookViews

# menu_view
@export var shop_btn: ButtonEx
@export var slot_btn: ButtonEx
@export var spin_7_btn: ButtonEx
@export var spin_3_btn: ButtonEx

enum VIEW_STATE {
	start,
	setting,
	menu,
	shop,
	select_spin,
	game,
	book
}

const SLOT_TIMES = 3 # 每輪可用機台次數
#const INTEREST = 0.05 # 基礎利息
const INTEREST = 0.00 # 基礎利息
const MAX_LEVEL = 3

var view_state: VIEW_STATE

var now_level = 0
var last_slot_times = 0
var put_in_money = 0
var target_money = 0
var now_interest = 0
var triggered_item_tween: Tween
var cam_tween: Tween

var has_dialog: bool
var dialog

signal triggered_anim_finish
signal zoomed

func _ready() -> void:
	setup()
	switch_view(VIEW_STATE.start)
	reset()


func slot_end():
	#Slot.money += int(put_in_money * now_interest)
	refresh_view()

func result_check() -> bool:
	var has_result = false
	#if last_slot_times <= 0 and Slot.money + put_in_money < target_money:
		#Main.show_talk_view("失敗了").finished.connect(
			#func ():
				#switch_view(VIEW_STATE.start)
				#reset()
		#)
	if last_slot_times <= 0 and Slot.money < target_money:
		has_result = true
		Main.show_talk_view("失敗了").finished.connect(
			func ():
				switch_view(VIEW_STATE.start)
				reset()
		)
	elif Slot.money >= target_money:
		has_result = now_level >= MAX_LEVEL
		#if view_state == VIEW_STATE.game:
			#Main.show_talk_view("達成目標").finished.connect(
				#func ():
					#to_next_level()
			#)
		#else:
			#to_next_level()
		to_next_level()
	return has_result

func to_next_level():
	if now_level >= MAX_LEVEL:
		Main.game_data.progress += 1
		Main.save_game()
		if cam_tween and cam_tween.is_running():
			await cam_tween.finished
			show_result_scene()
		else:
			show_result_scene()
		return
		
	now_level += 1
	
	Shop.reset()
	target_money = get_target_money()
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

func get_bonus_voucher() -> int:
	return last_slot_times * 5

func get_target_money() -> int:
	var num: int
	match now_level:
		0:
			num = 50
			#num = 5
		1:
			num = 100
			#num = 10
		2:
			num = 360
			#num = 3
		3:
			num = 1200
			#num = 12
	return num


func setup():
	Main.instance_scenes[Main.SCENE.game] = self
	Main.current_scene = self
	Main.main_cam = $Camera2D
	Shop.game_scene = self
	Shop.shop_view = shop_view
	Shop.setup()
	Slot.setup()
	shop_btn.pressed.connect(_on_shop_btn_pressed)
	slot_btn.pressed.connect(_on_slot_btn_pressed)
	spin_7_btn.pressed.connect(_on_select_slot_pressed.bind(0))
	spin_3_btn.pressed.connect(_on_select_slot_pressed.bind(1))
	$Menu/ReturnButton.pressed.connect(switch_view.bind(VIEW_STATE.start))
	$Shop/ReturnButton.pressed.connect(switch_view.bind(VIEW_STATE.menu))
	$SelectSpinViews/ReturnButton.pressed.connect(switch_view.bind(VIEW_STATE.menu))
	$SlotImage/ReturnButton.pressed.connect(_on_shutdown_btn_pressed)
	$SlotImage/BookButton.pressed.connect(
		func ():
			if slot_views.in_spin:
				return
			book_views.return_view = VIEW_STATE.game
			switch_view(VIEW_STATE.book)
	)
	slot_img.pivot_offset = slot_img.size / 2.0
	slot_bg.pivot_offset = slot_bg.size / 2.0


func show_result_scene():
	reset()
	book_views.return_view = VIEW_STATE.start
	switch_view(VIEW_STATE.book)
	await zoomed
	if Main.game_data.progress <= book_views.max_img_count:
		Main.show_talk_view("成功解鎖")
		#await get_tree().create_timer(0.5).timeout
		book_views.new_page_anim()
	else:
		book_views.set_index(int((Main.game_data.progress - 1)/ 2.0))
		Main.show_talk_view("已全解鎖")


func show_triggered_items():
	# 排除道具
	var skip_items = [Item.道具40]
	for i in Slot.SYMBOLS.size():
		skip_items.append(Item.道具33 + i)
	var items = Slot.triggered_items.filter(func (item): return item not in skip_items)
	
	if items.size() > 0:
		var last_tween: Tween
		#var offset = 50
		for i in items.size():
			var item: Slot.Item = items[i]
			#var item_data: ItemData = Main.item_datas[item]
			var item_view = items_views.get_item_view(item)
			var item_img = TextureRect.new()
			add_child(item_img)
			item_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			item_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			#item_img.size = Vector2(100, 100)
			#item_img.texture = item_data.get_img()
			#item_img.position = Vector2(
				#offset,
				#Main.screen_size.y
			#)
			item_img.size = item_view.size
			item_img.texture = item_view.texture
			item_img.position = item_view.global_position
			item_img.pivot_offset = item_img.size / 2.0
			var tween = item_img.create_tween()
			#tween.tween_interval(i * 0.5)
			#tween.tween_property(item_img, "position:y", Main.screen_size.y - item_img.size.y - offset, 0.5)
			#tween.tween_property(item_img, "position:y", Main.screen_size.y, 0.5)
			tween.tween_property(item_img, "scale", Vector2(2.0, 2.0), 0.5)
			tween.tween_property(item_img, "scale", Vector2(1.0, 1.0), 0.5)
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
	view_state = state
	
	var target_zoom: Vector2
	match state:
		VIEW_STATE.start:
			target_zoom = Vector2(2, 2)
		VIEW_STATE.setting:
			target_zoom = Vector2(2, 2)
		VIEW_STATE.menu:
			target_zoom = Vector2(2, 2)
			slot_btn.visible = true
			refresh_view()
		VIEW_STATE.shop:
			target_zoom = Vector2(2, 2)
		VIEW_STATE.select_spin:
			target_zoom = Vector2(2, 2)
		VIEW_STATE.game:
			target_zoom = Vector2(1, 1)
			slot_views.cumulative_amount = 0
			refresh_view()
		VIEW_STATE.book:
			target_zoom = Vector2(1, 1)
	
	zoom_anim(target_zoom)
	await zoomed
	
	start_view.visible = state == VIEW_STATE.start
	
	setting_view.visible = state == VIEW_STATE.setting
	
	menu_view.visible = state == VIEW_STATE.menu
	items_views.visible = state == VIEW_STATE.menu
	infos_views.visible = state == VIEW_STATE.menu
	if state == VIEW_STATE.menu: result_check()
	
	shop_view.visible = state == VIEW_STATE.shop
	
	select_spin_view.visible = state == VIEW_STATE.select_spin
	
	game_view.visible = state == VIEW_STATE.game
	#odds_views.visible = state == VIEW_STATE.game
	#$Viewport3D.visible = state == VIEW_STATE.game
	
	book_views.visible = state == VIEW_STATE.book
	if state == VIEW_STATE.book: book_views.show_anim()

func zoom_anim(target_zoom: Vector2):
	if camera.zoom == target_zoom:
		await get_tree().process_frame
		zoomed.emit()
		return
	var anim_bg = TextureRect.new()
	anim_bg.expand_mode = slot_bg.expand_mode
	anim_bg.stretch_mode = slot_bg.stretch_mode
	anim_bg.texture = slot_bg.texture
	anim_bg.size = slot_bg.size
	anim_bg.pivot_offset = slot_bg.pivot_offset
	anim_bg.position = slot_bg.position
	anim_bg.modulate.a = 0.0
	#add_child(anim_bg)
	zoom_anim_view.add_child(anim_bg)
	#var anim_img = TextureRect.new()
	#anim_img.expand_mode = slot_img.expand_mode
	#anim_img.stretch_mode = slot_img.stretch_mode
	#anim_img.texture = slot_img.texture
	#anim_img.size = slot_img.size
	#anim_img.scale = slot_img.scale
	#anim_img.pivot_offset = slot_img.pivot_offset
	#anim_img.modulate.a = 0.0
	#add_child(anim_img)
	var set_anim_a = func (a: float):
		#anim_img.modulate.a = a
		anim_bg.modulate.a = a
	cam_tween = camera.create_tween()
	cam_tween.tween_method(set_anim_a, 0.0, 1.0, 0.5)
	cam_tween.parallel().tween_property(camera, "zoom", target_zoom, 0.5)
	cam_tween.tween_callback(zoomed.emit)
	cam_tween.tween_method(set_anim_a, 1.0, 0.0, 0.5)
	cam_tween.finished.connect(
		func ():
			anim_bg.queue_free()
			#anim_img.queue_free()
			cam_tween.kill()
	)


func reset():
	Slot.reset()
	Shop.reset()
	now_level = 0
	put_in_money = 0
	target_money = get_target_money()
	last_slot_times = SLOT_TIMES
	now_interest = INTEREST
	refresh_view()


func return_scene():
	match view_state:
		VIEW_STATE.setting:
			switch_view(VIEW_STATE.start)
		VIEW_STATE.menu:
			switch_view(VIEW_STATE.start)
		VIEW_STATE.shop:
			switch_view(VIEW_STATE.menu)
		VIEW_STATE.select_spin:
			switch_view(VIEW_STATE.menu)
		VIEW_STATE.book:
			book_views.visible = false
			switch_view(book_views.return_view)


func _on_shop_btn_pressed():
	switch_view(VIEW_STATE.shop)

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
		switch_view(VIEW_STATE.select_spin)
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

func _on_shutdown_btn_pressed():
	if has_dialog:
		return
	has_dialog = true
	dialog = Main.create_dialog_view()
	dialog.title.text = "提示"
	dialog.msg.text = "確定要退出嗎？"
	dialog.confirm_btn.pressed.connect(_on_return_confirm)
	dialog.cancel_btn.pressed.connect(_on_dialog_cancel)

func close_dialog():
	dialog.queue_free()
	has_dialog = false

func _on_return_confirm():
	close_dialog()
	switch_view(VIEW_STATE.menu)
	
func _on_dialog_cancel():
	close_dialog()
