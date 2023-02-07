class_name Player extends TextureRect

enum Statistic {
	MAX_HEALTH,
	TURN_TIME,
	DODGE_CHANCE,
	DEFENCE
}

const base_stats = {
	Statistic.MAX_HEALTH: 12,
	Statistic.TURN_TIME: 5, # (minutes)
	Statistic.DODGE_CHANCE: 0, # (percent)
	Statistic.DEFENCE: 0
}

@onready var sword = $Sword
@onready var boots = $Boots
@onready var charm = $Charm

# Called when the node enters the scene tree for the first time.
func _ready():
	update_equipment()
	SaveGame.equipment_change.connect(update_equipment)

func update_equipment():
	if SaveGame.equipped.has("sword"): sword.texture = SaveGame.inventory[SaveGame.equipped.sword].item_texture
	else: sword.texture = null
	
	if SaveGame.equipped.has("boots"): boots.texture = SaveGame.inventory[SaveGame.equipped.boots].item_texture
	else: boots.texture = null
	
	if SaveGame.equipped.has("charm"): charm.texture = SaveGame.inventory[SaveGame.equipped.charm].item_texture
	else: charm.texture = null
