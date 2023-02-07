class_name ItemData

signal unequipped
signal equipped

const ITEM_TYPES = [
	"res://scenes/inventory/item/item_types/boots.tres", 
	"res://scenes/inventory/item/item_types/charm.tres", 
	"res://scenes/inventory/item/item_types/sword.tres"
]

var type_path : String = ""
var trait_paths : Array[String] = []
var id : String

var type : ItemType
var traits : Array[ItemTrait]
var display_name : ItemName
var texture_id : int
var level := -1

var item_texture : Texture

var is_equipped := false

static func generate(level: int) -> ItemData:
	var type : String = ITEM_TYPES.pick_random()
	var type_object : ItemType = load(type)
	var traits : Array[String] = []
	
	var current_level = 0
	while current_level < level:
		var item_trait = type_object.possible_traits.pick_random()
		current_level += 1 if not item_trait.curse else -1
		traits.push_back(item_trait.resource_path)
	
	var item = new(type, traits, randi_range(0, type_object.textures.size() - 1), "", "")
	item.level = level
	return item

static func from_json(json: Dictionary) -> ItemData:
	var item = new(json.type, json.traits, json.texture, json.display_name, json.id)
	item.level = json.level
	return item

func _init(item_type: String, item_traits: Array, texture: int, display_text: String = "", set_id: String = ""):
	type_path = item_type
	type = load(type_path)
	
	trait_paths = item_traits
	traits = trait_paths.map(func (path):
		return load(path)
	)
	
	texture_id = texture
	if texture_id >= 0:
		item_texture = type.textures[texture_id]
	else:
#		Special key-code
		if texture_id == -1:
			item_texture = load("res://scenes/inventory/item/item_types/sprites/sword/wooden-sword.png")
	
	display_name = ItemName.new(type, traits.pick_random(), display_text)
	
	if set_id != "":
		id = set_id
	else:
		id = SaveGame.create_item_id(self)

func get_save_data() -> Dictionary:
	return {
		"id": id,
		"type": type_path,
		"traits": trait_paths,
		"level": level,
		"texture": texture_id,
		"display_name": display_name.as_string()
	}

func get_type_string() -> String:
	var regex = RegEx.create_from_string("[^/]+(?=\\.tres$)").search(type_path)
	return regex.get_string()

func equip() -> void:
	if is_equipped: return
	is_equipped = true
	
	var key = get_type_string()
	if SaveGame.equipped.has(key): 
		SaveGame.inventory[SaveGame.equipped[key]].unequip()
	
	SaveGame.equipped[key] = id
	
	equipped.emit()
	SaveGame.equipment_change.emit()

func unequip() -> void:
	if not is_equipped: return
	is_equipped = false
	
	SaveGame.equipped.erase(get_type_string())
	
	unequipped.emit()
	SaveGame.equipment_change.emit()
