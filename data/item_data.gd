extends Node
class_name ItemData

var id: int
var title: String
var description: String
var cost: int
var active_item: bool
var usable_count: int

func get_buff() -> Slot.Buff:
	Logger.log("觸發 " + title)
	var buff = Slot.Buff.new()
	buff.from = id
	var Item = Slot.Item
	var Effect = Slot.Effect
	buff.type = Effect.other
	match id:
		Item.道具1:
			buff.type = Effect.luck
			buff.value = 4
		Item.道具3:
			buff.type = Effect.luck
			buff.value = 7
		Item.道具4:
			# TODO 利息
			pass
		Item.道具5:
			buff.type = Effect.luck
			buff.value = 4
		Item.道具6:
			buff.type = Effect.symbols_multiplier
			buff.value = 1
		Item.道具7:
			# TODO 利息
			pass
		Item.道具8:
			buff.type = Effect.symbols_multiplier
			buff.value = 1
		Item.道具9:
			buff.type = Effect.spin_times
			buff.value = 2
		Item.道具11:
			buff.type = Effect.item_size
			buff.value = -1
		Item.道具12:
			buff.type = Effect.item_size
			buff.value = -1
		Item.道具13:
			buff.type = Effect.luck
			buff.value = 5
		Item.道具14:
			# TODO 利息
			pass
		Item.道具17:
			pass
		Item.道具18:
			pass
		Item.道具20:
			pass
		Item.道具21:
			buff.type = Effect.symbols_odds
			buff.value = 2
		Item.道具22:
			buff.type = Effect.pattern_odds
			buff.value = 2
		Item.道具23:
			buff.type = Effect.luck
			buff.value = 5
		Item.道具24:
			buff.type = Effect.luck
			buff.value = 7
		Item.道具26:
			buff.type = Effect.datum
			buff.value = [0, 2]
		Item.道具27:
			buff.type = Effect.datum
			buff.value = [1, 2]
		Item.道具28:
			buff.type = Effect.datum
			buff.value = [2, 2]
		Item.道具29:
			buff.type = Effect.datum
			buff.value = [3, 2]
		Item.道具30:
			buff.type = Effect.datum
			buff.value = [4, 2]
		Item.道具31:
			buff.type = Effect.datum
			buff.value = [5, 2]
		Item.道具32:
			buff.type = Effect.datum
			buff.value = [6, 2]
		Item.道具33:
			buff.type = Effect.symbols_odds
			buff.value = [0, 2]
		Item.道具34:
			buff.type = Effect.symbols_odds
			buff.value = [1, 2]
		Item.道具35:
			buff.type = Effect.symbols_odds
			buff.value = [2, 2]
		Item.道具36:
			buff.type = Effect.symbols_odds
			buff.value = [3, 2]
		Item.道具37:
			buff.type = Effect.symbols_odds
			buff.value = [4, 2]
		Item.道具38:
			buff.type = Effect.symbols_odds
			buff.value = [5, 2]
		Item.道具39:
			buff.type = Effect.symbols_odds
			buff.value = [6, 2]
		Item.道具40:
			buff.value = 0.02
	return buff
