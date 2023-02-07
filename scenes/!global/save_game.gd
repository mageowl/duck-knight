class_name SaveGameInstance extends Node

signal inventory_item_added
signal inventory_item_removed
signal equipment_change

const SAVE_PATH = "user://save_game.txt"
const SAVE_PATH_DEBUG = "res://save_game.txt"
const PREV_NAME_PATH = "user://prev_names.txt"

var latest_item_id := 0

var inventory : Dictionary = {}
var equipped : Dictionary = {}
var gold : int = 0
var bored_on : int = -1
var returns_on : int = -1
var duck_name : String = ""

var main_menu_continued = false

func _ready():
	pass

func save_game():
	var file = FileAccess.open(SAVE_PATH if not OS.is_debug_build() else SAVE_PATH_DEBUG, FileAccess.WRITE)
	var save_data := {
		"inventory": {}
	}
	
	for id in inventory:
		var item_data : ItemData = inventory[id]
		save_data.inventory[id] = item_data.get_save_data()
	
	save_data.equipped = equipped
	save_data.gold = gold
	save_data.bored_on = bored_on
	save_data.returns_on = returns_on
	save_data.duck_name = duck_name
	
	if returns_on != -1:
		save_data.quest_log = QuestManager.quest_log
	
	var base64 = Marshalls.utf8_to_base64(JSON.stringify(save_data))
	file.store_string(base64)

func load_game():
	var file = FileAccess.open(SAVE_PATH if not OS.is_debug_build() else SAVE_PATH_DEBUG, FileAccess.READ)
	
	var text = Marshalls.base64_to_utf8(file.get_as_text())
	var save_data = JSON.parse_string(text)
	
	equipped = save_data.equipped
	
	for id in save_data.inventory:
		var item_json : Dictionary = save_data.inventory[id]
		var item_data := ItemData.from_json(item_json)
		
		if equipped.values().has(id): item_data.is_equipped = true
		
		inventory[id] = item_data
	
	gold = save_data.gold
	bored_on = save_data.bored_on
	returns_on = save_data.returns_on
	duck_name = save_data.duck_name
	latest_item_id = int(save_data.inventory.keys().reduce(func (a, b): 
		if a == null or b == null: return a if b == null else b
		return a if int(a) > int(b) else b
	)) + 1
	
	if is_available() and save_data.has("quest_log"):
		QuestManager.quest_log = save_data.quest_log
		returns_on = -1

func is_available() -> bool:
	return Utility.get_seconds() >= returns_on

func clear_game():
	DirAccess.remove_absolute(SAVE_PATH)

func new_game():
	ItemData.new("res://scenes/inventory/item/item_types/sword.tres", ["res://scenes/inventory/item/traits/blunt.tres", "res://scenes/inventory/item/traits/flaming.tres"], -1, duck_name + "'s training sword")
	bored_on = Utility.get_seconds() + Utility.HOUR * 72
	save_game()

func game_exists():
	return FileAccess.file_exists(SAVE_PATH if not OS.is_debug_build() else SAVE_PATH_DEBUG)

func create_item_id(item: ItemData):
	var id = "it" + str(latest_item_id)
	
	inventory[id] = item
	latest_item_id += 1
	
	inventory_item_added.emit()
	return id

func remove_item(id: String):
	inventory[id] = null
	
	var i = equipped.values().find(id)
	if i != -1:
		equipped[equipped.keys()[i]] = null
	
	inventory_item_removed.emit()

func _notification(what):
	var can_save = not OS.has_feature("no_save")
	
	if what == MainLoop.NOTIFICATION_APPLICATION_PAUSED and can_save:
		save_game()
