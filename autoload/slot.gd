extends Node

var money = 0
var cash = 5


const COLUMNS = 5
const ROWS = 3

const SYMBOLS = ["🍋", "🍒", "🍀", "🔔", "💎", "💰", "7️⃣"]
const ORG_DATUM = [2.5, 2.5, 2.0, 2.0, 1.5, 1.5, 1.0]
const ORG_SYMBOLS_ODDS = [2, 2, 3, 3, 5, 5, 7]
const ORG_SYMBOLS_MUL = 1
const ITEMS_SIZE = 7

enum Pattern {
	橫向,
	縱向,
	斜角,
	橫4,
	橫5,
	反V,
	V,
	正三角,
	倒三角,
	圖案,
	滿版
}
const ORG_PATTERN_ODDS = [
	1, # 橫向
	1, # 縱向
	1, # 斜
	2, # 4
	3, # 5
	4, # ^
	4, # v
	7, # 正三角
	7, # 倒三角
	8, # ?
	10 # 滿
]
const ORG_PATTERN_MUL = 1

class RewardData:
	var grid = []
	var symbol: int
	var type: Pattern

enum Event {
	事件1, # 7基準+1
	事件2 # 🍀,🔔機率減半
}

enum Item {
	道具1, # 拉霸後觸發，10%機率，額外添加1次拉霸，額外拉霸幸運+4
	道具2, # 道具觸發機率加倍
	道具3, # 最後一轉幸運+7
	道具4, # 當次拉霸觸發3次獎金，獲得利息 TODO
	道具5, # 使用後當次拉霸幸運+4
	道具6, # 拉霸後有被動道具觸發，符號倍率+1，沒道具觸發重置
	道具7, # 利息增加15%，每輪遞減3%，0%丟棄 TODO
	道具8, # 符號倍率+1，當次拉霸觸發5次獎金，符號倍率再+1
	道具9, # 每輪次數+2
	道具10, # 每5張幸運券，符號倍率+1
	道具11, # 主動觸發道具，額外觸發1次，道具欄位-1
	道具12, # 電話亭能力觸發2次，道具欄位-1
	道具13, # 連續2次拉霸沒獎勵，下一次幸運+5
	道具14, # 利息+5% TODO
	道具15, # 重置主動道具可用次數
	道具16, # 兌換券+4
	道具17, # 黃色符號觸發次數+1，檸檬鈴鐺金幣7
	道具18, # 非黃色符號觸發次數+1，櫻桃幸運草鑽石
	道具19, # 獲得當前債務30% TODO
	道具20, # 每次清算，每擁有3張兌換券，額外獲得1張，最多10張 TODO
	道具21, # 當次拉霸觸發3次獎金，該輪符號價值x2
	道具22, # 當次拉霸觸發3次獎金，該輪圖案價值+1倍
	道具23, # 拉霸後觸發，20%機率，當次幸運+5
	道具24, # 拉霸後觸發，15%機率，當次幸運+7
	道具25, # 出現666組合，轉化為普通符號，道具銷毀 TODO
	道具26, # 本輪檸檬出現機率+2
	道具27, # 本輪櫻桃出現機率+2
	道具28, # 本輪幸運草出現機率+2
	道具29, # 本輪鈴鐺出現機率+2
	道具30, # 本輪鑽石出現機率+2
	道具31, # 本輪金幣出現機率+2
	道具32, # 本輪7出現機率+2
	道具33, # 出現黃金標記機率+20%，符號價值永久+2
	道具34, # 出現黃金標記機率+20%，符號價值永久+2
	道具35, # 出現黃金標記機率+20%，符號價值永久+3
	道具36, # 出現黃金標記機率+20%，符號價值永久+3
	道具37, # 出現黃金標記機率+20%，符號價值永久+5
	道具38, # 出現黃金標記機率+20%，符號價值永久+5
	道具39, # 出現黃金標記機率+20%，符號價值永久+7
	道具40 # 符號出現幸運草標記提升2%，每購買一次道具提升1%(最高25%)，標記觸發獎金+1兌換券
}

enum Effect {
	luck,
	symbols_multiplier,
	symbols_odds,
	pattern_odds,
	spin_times,
	item_size,
	datum,
	probability
}

class Buff:
	var from: Item
	var type: Effect
	var value

var grid = []
var spin_times = 7
var probability = []
var luck: int
var symbols_datum: Array
var symbols_odds: Array
var pattern_odds: Array
var symbols_multiplier: float
var pattern_multiplier: float

var rewards = []
var rewards_waves = []
var golden_modifiers = []
var events = []
var items = []
var items_usable = {}
var max_item_size = 7
var buffs = []
var trigger_count = 0

func _ready() -> void:
	refresh_state()
	create_grid()


#region grid and spin
func create_grid():
	for col in range(COLUMNS):
		var column = []
		for row in range(ROWS):
			column.append(get_unit())
		grid.append(column)


func new_wave():
	rewards_waves.clear()
	assign_spin(7)
	
	var datas = Main.item_datas
	if Item.道具5 in items:
		var data: ItemData = datas[Item.道具5]
		if items_usable[Item.道具5] > data.usable_count:
			items_usable[Item.道具5] += 1
	
	if Item.道具21 in items:
		remove_buff(Item.道具21)
	if Item.道具22 in items:
		remove_buff(Item.道具22)


func assign_spin(count: int):
	spin_times = count
	if buffs.size() > 0:
		for buff: Buff in buffs:
			match buff.type:
				Effect.spin_times:
					spin_times += buff.value
	cash += 1


func start_spin():
	spin_times -= 1
	trigger_count = 0
	
	# 轉時效果
	effect_before_spin()
	
	rewards.clear()
	var temp_grid = []
	var temp_rewards = []
	var temp_gm = []
	var temp_r = 0
	# 幸運 = 轉多次取最大
	for i in range(luck):
		spin()
		check_rewards()
		var new_r = calculating_rewards()
		if new_r > temp_r:
			temp_grid = grid.duplicate(true)
			temp_rewards = rewards.duplicate(true)
			temp_gm = golden_modifiers.duplicate(true)
			temp_r = new_r
	if temp_r != 0:
		grid = temp_grid.duplicate(true) 
		rewards = temp_rewards.duplicate(true)
		golden_modifiers = temp_gm.duplicate(true)
	
	rewards_waves.append(calculating_rewards())
	
	# 轉後效果
	effect_after_spin()

func spin():
	golden_modifiers.clear()
	for i in grid.size():
		for j in grid[i].size():
			grid[i][j] = get_unit()
			if (Item.道具33 + grid[i][j]) in items:
				var p = 0.2
				if Item.道具40 in items:
					p += get_buff(Item.道具40).value
				if randf() <= p:
					golden_modifiers.append(Vector2(i, j))

func get_unit() -> int:
	var temp = []
	for i in SYMBOLS.size():
		for j in probability[i]*100:
			temp.append(i)
	return temp.pick_random()


func check_rewards():
	rewards.clear()
	for i in Pattern.size():
		check_reward(i)
	
	if rewards.size() > 0 and (get_buff(Item.道具17) or get_buff(Item.道具18)):
		var new_r = rewards.duplicate(true)
		var offset = 0
		for i in rewards.size():
			var reward: RewardData = rewards[i]
			if get_buff(Item.道具17) and reward.symbol in [0, 3, 5, 6]:
				new_r.insert(i+offset, reward)
				offset += 1
			if get_buff(Item.道具18) and reward.symbol in [1, 2, 4]:
				new_r.insert(i+offset, reward)
				offset += 1
		rewards = new_r.duplicate(true)

func check_reward(type: Pattern):
	var pos_A = [Vector2(0, 2), Vector2(1, 1), Vector2(2, 0), Vector2(3, 1), Vector2(4, 2)]
	var pos_V = [Vector2(0, 0), Vector2(1, 1), Vector2(2, 2), Vector2(3, 1), Vector2(4, 0)]
	match type:
		Pattern.橫向:
			# 檢查橫向
			for row in range(ROWS):
				var count = 1
				var temp_grid = []
				for col in range(1, COLUMNS):
					temp_grid.append(Vector2(col - 1, row))
					if grid[col][row] == grid[col - 1][row]:
						count += 1
					else:
						if count >= 3:
							var data = RewardData.new()
							match count:
								3:
									data.type = Pattern.橫向
								4:
									data.type = Pattern.橫4
								5:
									data.type = Pattern.橫5
							data.grid = temp_grid
							data.symbol = grid[col - 1][row]
							rewards.append(data)
						count = 1
						temp_grid = []
				if count >= 3:
					temp_grid.append(Vector2(COLUMNS - 1, row))
					var data = RewardData.new()
					match count:
						3:
							data.type = Pattern.橫向
						4:
							data.type = Pattern.橫4
						5:
							data.type = Pattern.橫5
					data.grid = temp_grid
					data.symbol = grid[COLUMNS - 1][row]
					rewards.append(data)
		Pattern.縱向:
			# 檢查縱向
			for col in range(COLUMNS):
				for row in range(ROWS - 2):
					var pos = [Vector2(col, row), Vector2(col, row+1), Vector2(col, row+2)]
					if has_pattern(pos):
						var data = RewardData.new()
						data.symbol = grid[pos[0].x][pos[0].y]
						data.type = Pattern.縱向
						data.grid = [Vector2(col, row), Vector2(col, row+1), Vector2(col, row+2)]
						rewards.append(data)
		Pattern.斜角:
			# 檢查斜角左上到右下
			for col in range(COLUMNS - 2):
				for row in range(ROWS - 2):
					var pos = [Vector2(col, row), Vector2(col+1, row+1), Vector2(col+2, row+2)]
					if has_pattern(pos):
						var data = RewardData.new()
						data.symbol = grid[pos[0].x][pos[0].y]
						data.type = Pattern.斜角
						data.grid = [Vector2(col, row), Vector2(col+1, row+1), Vector2(col+2, row+2)]
						rewards.append(data)
			# 檢查斜角左下到右上
			for col in range(COLUMNS - 2):
				for row in range(2, ROWS):
					var pos = [Vector2(col, row), Vector2(col+1, row-1), Vector2(col+2, row-2)]
					if has_pattern(pos):
						var data = RewardData.new()
						data.symbol = grid[pos[0].x][pos[0].y]
						data.type = Pattern.斜角
						data.grid = [Vector2(col, row), Vector2(col+1, row-1), Vector2(col+2, row-2)]
						rewards.append(data)
		Pattern.反V:
			# 檢查^
			if has_pattern(pos_A):
				var data = RewardData.new()
				data.symbol = grid[pos_A[0].x][pos_A[0].y]
				data.type = Pattern.反V
				data.grid = pos_A
				rewards.append(data)
		Pattern.V:
			# 檢查V
			if has_pattern(pos_V):
				var data = RewardData.new()
				data.symbol = grid[pos_V[0].x][pos_V[0].y]
				data.type = Pattern.V
				data.grid = pos_V
				rewards.append(data)
		Pattern.正三角:
			# 檢查正三角
			var pos_t = []
			for i in COLUMNS:
				pos_t.append(Vector2(i, 2))
			pos_t += pos_A
			if has_pattern(pos_t):
				var data = RewardData.new()
				data.symbol = grid[pos_t[0].x][pos_t[0].y]
				data.type = Pattern.正三角
				data.grid = pos_t
				rewards.append(data)
		Pattern.倒三角:
			# 檢查倒三角
			var pos_int = []
			for i in COLUMNS:
				pos_int.append(Vector2(i, 0))
			pos_int += pos_V
			if has_pattern(pos_int):
				var data = RewardData.new()
				data.symbol = grid[pos_int[0].x][pos_int[0].y]
				data.type = Pattern.倒三角
				data.grid = pos_int
				rewards.append(data)
		Pattern.圖案:
			# TODO 檢查圖案
			pass
		Pattern.滿版:
			# 檢查滿版
			var pos_all = []
			for i in COLUMNS:
				for j in ROWS:
					pos_all.append(Vector2(i, j))
			if has_pattern(pos_all):
				var data = RewardData.new()
				data.symbol = grid[pos_all[0].x][pos_all[0].y]
				data.type = Pattern.滿版
				data.grid = pos_all
				rewards.append(data)

func has_pattern(pos: Array) -> bool:
	var has = true
	var symbol = grid[pos[0].x][pos[0].y]
	for i in pos.size():
		if symbol != grid[pos[i].x][pos[i].y]:
			has = false
			break
	return has


func calculating_rewards() -> int:
	var total_reward = 0
	for data: RewardData in rewards:
		var r = symbols_odds[data.symbol] * pattern_odds[data.type]
		total_reward += r * symbols_multiplier * pattern_multiplier
	return total_reward
#endregion

func use_items():
	for item: Item in items:
		var data: ItemData = Main.item_datas[item]
		if data.active_item:
			add_buff(item)
			if Item.道具11 in items:
				add_buff(item)


func add_item(item: Item):
	var data: ItemData = Main.item_datas[item]
	# 消耗型道具
	match item:
		Item.道具15:
			for key in items_usable.keys():
				items_usable[key] = data.usable_count
			return
		Item.道具16:
			cash += 4
			return
		Item.道具19:
			# TODO 債務
			return
	items.append(item)
	if data.usable_count > 0:
		items_usable[item] = data.usable_count
	# 即效型道具
	if item in [Item.道具7, Item.道具8, Item.道具9, Item.道具11, Item.道具12, Item.道具14, Item.道具40]:
		add_buff(item)
	refresh_state()

func remove_item(item: Item):
	items.erase(item)
	remove_buff(item)
	refresh_state()


# 轉時效果
func effect_before_spin():
	if items.size() > 0:
		var offset_p = 2 if Item.道具2 in items else 1
		if Item.道具23 in items:
			if randf() <= 0.2 * offset_p:
				add_buff(Item.道具23)
				trigger_count += 1
		if Item.道具24 in items:
			if randf() <= 0.15 * offset_p:
				add_buff(Item.道具24)
				trigger_count += 1
	refresh_state()

# 轉後效果
func effect_after_spin():
	if buffs.size() > 0:
		remove_buff(Item.道具1)
		remove_buff(Item.道具3)
		remove_buff(Item.道具5)
		remove_buff(Item.道具13)
		remove_buff(Item.道具17)
		remove_buff(Item.道具18)
		remove_buff(Item.道具23)
		remove_buff(Item.道具24)
	if items.size() > 0:
		var offset_p = 2 if Item.道具2 in items else 1
		if Item.道具1 in items:
			if randf() <= 0.1 * offset_p:
				spin_times += 1
				add_buff(Item.道具1)
				trigger_count += 1
		
		if Item.道具3 in items:
			if spin_times == 1:
				add_buff(Item.道具3)
				trigger_count += 1
		
		if Item.道具4 in items:
			if rewards.size() >= 3:
				add_buff(Item.道具4)
				trigger_count += 1
		
		if Item.道具8 in items:
			if rewards.size() >= 5:
				add_buff(Item.道具8)
				trigger_count += 1
		
		if Item.道具13 in items:
			if rewards_waves.size() >= 2:
				if rewards_waves[-1] == 0 and rewards_waves[-2] == 0:
					add_buff(Item.道具13)
					trigger_count += 1
		
		if Item.道具21 in items:
			if rewards.size() >= 3:
				add_buff(Item.道具21)
				trigger_count += 1
		
		if Item.道具22 in items:
			if rewards.size() >= 3:
				add_buff(Item.道具22)
				trigger_count += 1
		
		if Item.道具23 in items:
			if items_usable[Item.道具23] <= 0:
				remove_item(Item.道具23)
		
		if Item.道具24 in items:
			if items_usable[Item.道具24] <= 0:
				remove_item(Item.道具24)
		
		if Item.道具6 in items:
			if trigger_count > 0:
				for i in trigger_count:
					add_buff(Item.道具6)
			else:
				remove_buff(Item.道具6)
		
		# 計算黃標
		for gm: Vector2 in golden_modifiers:
			for reward: RewardData in rewards:
				if gm in reward.grid:
					add_buff(Item.道具33 + reward.symbol)
					if get_buff(Item.道具40):
						add_buff(Item.道具40)
	
	refresh_state()


func add_buff(from: Item):
	# 次數判定
	var data: ItemData = Main.item_datas[from]
	if data.usable_count > 0:
		if items_usable[from] > 0:
			items_usable[from] -= 1
		else:
			return
	
	if from == Item.道具6 and get_buff(from):
		get_buff(from).value += 1
		return
	if from == Item.道具8 and get_buff(from):
		get_buff(from).value += 1
		return
	if from == Item.道具22 and get_buff(from):
		get_buff(from).value += 1
		return
	if from == Item.道具40 and get_buff(from):
		if get_buff(from).value < 0.25:
			get_buff(from).value += 0.01
		return
	# 黃標
	for i in SYMBOLS.size():
		if from == (Item.道具33 + i) and get_buff(from):
			get_buff(from).value[1] += 1
			return
	
	buffs.append(data.get_buff())

func get_buff(from: Item) -> Buff:
	for buff: Buff in buffs:
		if buff.from == from:
			return buff
	return null

func remove_buff(from: Item):
	buffs = buffs.filter(func(buff: Buff): return buff.from != from)


func refresh_state():
	luck = 1
	symbols_datum = ORG_DATUM.duplicate(true)
	symbols_odds = ORG_SYMBOLS_ODDS.duplicate(true)
	pattern_odds = ORG_PATTERN_ODDS.duplicate(true)
	symbols_multiplier = ORG_SYMBOLS_MUL
	pattern_multiplier = ORG_PATTERN_MUL
	max_item_size = ITEMS_SIZE
	if buffs.size() > 0:
		for buff: Buff in buffs:
			match buff.type:
				Effect.luck:
					luck += buff.value
				Effect.symbols_multiplier:
					symbols_multiplier += buff.value
				Effect.item_size:
					max_item_size += buff.value
				Effect.symbols_odds:
					if buff.from == Item.道具21:
						for i in symbols_odds.size():
							symbols_odds[i] *= buff.value
					else:
						symbols_odds[buff.value[0]] *= buff.value[1]
				Effect.pattern_odds:
					for i in pattern_odds.size():
						pattern_odds[i] *= buff.value
				Effect.datum:
					symbols_datum[buff.value[0]] += buff.value[1]
				Effect.probability:
					symbols_datum[buff.value[0]] += buff.value[1]
	if Item.道具10 in items:
		symbols_multiplier += int(cash/5.0)
	refresh_probability()


func refresh_probability():
	probability.clear()
	
	var value_mul = 2 if Item.道具12 in items else 1
	# 基準計算
	for event in events:
		match event:
			Event.事件1: # 7基準+1
				symbols_datum[6] += 1 * value_mul
	
	# 計算機率
	var all_datum: float = 0
	for datum in symbols_datum:
		all_datum += datum
	for i in SYMBOLS.size():
		probability.append(symbols_datum[i] / all_datum)
	
	# 機率道具要在基準計算取得機率後
	var half_symbols = []
	for event in events:
		match event:
			Event.事件2: # 🍀,🔔機率減半
				half_symbols.append_array([2, 3])
				if Item.道具12 in items:
					half_symbols.append_array([2, 3])

	if half_symbols.size() > 0:
		# 計算機率差
		var halving_p: float = 0.0
		for i in SYMBOLS.size():
			if i in half_symbols:
				var count = half_symbols.count(i)
				var mul = 1 - 0.5 * count
				if mul < 0:
					mul = 0
				var value = probability[i] * mul
				halving_p += probability[i] - value
				probability[i] = value
		# 將機率差以基準值回補
		var total_datum = 0
		for i in SYMBOLS.size():
			if i not in half_symbols:
				total_datum += symbols_datum[i]
		for i in SYMBOLS.size():
			if i not in half_symbols:
				probability[i] += halving_p * (symbols_datum[i] / total_datum)


func show_probability():
	var s = "機率\n"
	for i in SYMBOLS.size():
		s += str(SYMBOLS[i], "%0.2f" % (probability[i]*100), "%\n")
	s += "\n符號價值\n"
	for i in SYMBOLS.size():
		s += str(SYMBOLS[i], ": %s" % (symbols_odds[i]), "\n")
	s += "\n符號倍率: %s\n" % symbols_multiplier
	s += "\n圖形價值\n"
	for i in Pattern.size():
		s += str(Pattern.keys()[i], ": %s" % (pattern_odds[i]), "\n")
	s += "\n圖形倍率: %s\n" % pattern_multiplier
	
	var window = Window.new()
	window.title = "道具"
	window.size = Vector2(1500, 800)
	window.close_requested.connect(window.queue_free)
	window.set_position(Vector2(100, 100))

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	window.add_child(scroll)
	
	var lbl = Label.new()
	lbl.add_theme_font_size_override("font_size", 60)
	lbl.text = s
	scroll.add_child(lbl)

	get_tree().get_root().add_child(window)
	window.popup_centered()
