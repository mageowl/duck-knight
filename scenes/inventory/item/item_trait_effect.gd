@tool
class_name ItemTraitEffect extends Resource

enum EffectType {
	DAMAGE,
	STATUS_EFFECT,
	MODIFY_STATISTIC,
	GET_ITEM
}

enum StatusEffect {
	FIRE,
	FROZEN,
	VENOM
}

@export var effect_type : EffectType:
	set(value):
		effect_type = value
		notify_property_list_changed()

var damage = "1"

var status_effect := 0
var duration := 1
var chance : float = 1.0

var statistic := 0
var amount := 1.0

func _get_property_list():
	var properties = []
	
	if effect_type == EffectType.DAMAGE:
		properties.append({
			"name": "damage",
			"type": TYPE_STRING
		})
	elif effect_type == EffectType.STATUS_EFFECT:
		properties.append_array([
			{
				"name": "status_effect",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "Fire,Frozen,Venom"
			},
			{
				"name": "duration",
				"type": TYPE_INT
			},
			{
				"name": "chance",
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0,1"
			}
		])
	elif effect_type == EffectType.MODIFY_STATISTIC:
		properties.append_array([
			{
				"name": "statistic",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "Max Health,Turn Time,Dodge Chance,Defence"
			},
			{
				"name": "amount",
				"type": TYPE_FLOAT
			}
		])

	return properties
