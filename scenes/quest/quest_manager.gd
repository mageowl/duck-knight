class_name QuestManagerInstance  extends Node

enum EventType {
	NONE,
	ATTACK,
	MISS,
	STATUS_EFFECT_APPLY,
	STATUS_EFFECT_DAMAGE,
	STATUS_EFFECT_REMOVED,
	DEATH,
	COLLECT,
	ENCOUNTER,
	SET_MAX_HEALTH
}

enum Entity {
	PLAYER,
	ENCOUNTER
}

const ENCOUNTERS = [
	preload("res://scenes/quest/encounters/whomped_willow.tres"),
	preload("res://scenes/quest/encounters/wolf.tres"),
	preload("res://scenes/quest/encounters/chest.tres")
]

var quest_log : Array[Dictionary] = []
var event_index := 0
var quest_finished := false

func log_entity_event(event: EventType, entity: Entity, amount = -1) -> void:
	quest_log.push_back({
		"event": event,
		"entity": entity,
		"amount": amount
	})

func log_encounter(texture: String, encounter_name: String) -> void:
	quest_log.push_back({
		"event": EventType.ENCOUNTER,
		"texture": texture,
		"name": encounter_name
	})

func get_effects(traits, base_stats, effects = []) -> Dictionary:
	var stats : Dictionary = base_stats.duplicate()
	var turn_effects := []
	
	for item_trait in traits:
		for effect in item_trait.effects:
			var type : ItemTraitEffect.EffectType = effect.effect_type
			
			match type:
				ItemTraitEffect.EffectType.DAMAGE, ItemTraitEffect.EffectType.STATUS_EFFECT, ItemTraitEffect.EffectType.GET_ITEM:
					turn_effects.push_back(effect)
				
				ItemTraitEffect.EffectType.MODIFY_STATISTIC:
					stats[effect.statistic] += effect.amount
	
	for effect in effects:
		var type : ItemTraitEffect.EffectType = effect.effect_type
		
		match type:
			ItemTraitEffect.EffectType.DAMAGE, ItemTraitEffect.EffectType.STATUS_EFFECT, ItemTraitEffect.EffectType.GET_ITEM:
				turn_effects.push_back(effect)
			
			ItemTraitEffect.EffectType.MODIFY_STATISTIC:
				stats[effect.statistic] += effect.amount
	
	return {
		"stats": stats,
		"turn_effects": turn_effects
	}

func simulate_encounter(level: int, player_data: Dictionary) -> Dictionary:
	var encounter_type : Encounter = ENCOUNTERS.pick_random()
	var encounter_stats = {
		Player.Statistic.MAX_HEALTH: Utility.randi_string(encounter_type.health) if encounter_type.health != "*" else -1,
		Player.Statistic.DODGE_CHANCE: 0,
		Player.Statistic.DEFENCE: 0
	}
	
	var encounter_traits = []
	var power = 0
	while power < level and encounter_type.possible_traits.size() > 0:
		var encounter_trait : ItemTrait = encounter_type.possible_traits.pick_random()
		encounter_traits.push_back(encounter_trait)
		power += -1 if encounter_trait.curse else 1
	
	var encounter_effect_data := get_effects(encounter_traits, encounter_stats, encounter_type.bonus_effects)
	var encounter_turn_effects : Array[ItemTraitEffect] = encounter_effect_data.turn_effects
	
	encounter_stats = encounter_effect_data.stats
	
	var encounter_health : int = encounter_stats[Player.Statistic.MAX_HEALTH]
	var encounter_has_health : bool = encounter_stats[Player.Statistic.MAX_HEALTH] != -1
	var encounter_status_effects = {
		ItemTraitEffect.StatusEffect.FIRE: 0,
		ItemTraitEffect.StatusEffect.FROZEN: 0,
		ItemTraitEffect.StatusEffect.VENOM: 0
	}
	
	var player_health : int = player_data.health
	var player_status_effects = player_data.effects
	
	var time_elapsed = 0
	
	log_entity_event(EventType.SET_MAX_HEALTH, Entity.ENCOUNTER, encounter_health)
	log_encounter(encounter_type.texture.resource_path, encounter_type.display_name)
	
	var is_players_turn = true
	while player_health > 0 and (encounter_health > 0 or not encounter_has_health):
		if is_players_turn and encounter_has_health: # Player Turn
			var frozen_modifier = 0.3 if encounter_status_effects[ItemTraitEffect.StatusEffect.FROZEN] > 0 else 1
			var venom_modifier = 1.2 if encounter_status_effects[ItemTraitEffect.StatusEffect.VENOM] > 0 else 1
			
			for effect in player_data.turn_effects:
				if effect.effect_type == ItemTraitEffect.EffectType.DAMAGE:
					if randf() > encounter_stats[Player.Statistic.DODGE_CHANCE] * frozen_modifier:
						var amount = ceil(Utility.randi_string(effect.damage) * venom_modifier) - encounter_stats[Player.Statistic.DEFENCE]
						encounter_health -= amount
						
						log_entity_event(EventType.ATTACK, Entity.PLAYER, amount)
					else:
						log_entity_event(EventType.MISS, Entity.PLAYER)
					
				elif effect.effect_type == ItemTraitEffect.EffectType.STATUS_EFFECT:
					if randf() < effect.chance and encounter_status_effects[effect.status_effect] < effect.duration:
							encounter_status_effects[effect.status_effect] = effect.duration
							log_entity_event(EventType.STATUS_EFFECT_APPLY, Entity.ENCOUNTER, effect.status_effect)
			
			if player_status_effects[ItemTraitEffect.StatusEffect.FIRE] > 0:
				player_health -= 1
				log_entity_event(EventType.STATUS_EFFECT_DAMAGE, Entity.PLAYER, 1)
			
			for effect in player_status_effects:
				if player_status_effects[effect] > 0:
					player_status_effects[effect] -= 1
					
					if player_status_effects[effect] == 0:
						print("effecto removeis")
						log_entity_event(EventType.STATUS_EFFECT_REMOVED, Entity.PLAYER, effect)
		else: # Enemy Turn
			var frozen_modifier = 0.3 if player_status_effects[ItemTraitEffect.StatusEffect.FROZEN] > 0 else 1
			var venom_modifier = 1.2 if player_status_effects[ItemTraitEffect.StatusEffect.VENOM] > 0 else 1
			
			for effect in encounter_turn_effects:
				if effect.effect_type == ItemTraitEffect.EffectType.DAMAGE:
					if randf() > player_data.stats[Player.Statistic.DODGE_CHANCE] * frozen_modifier:
						var amount = ceil(Utility.randi_string(effect.damage) * venom_modifier) - player_data.stats[Player.Statistic.DEFENCE]
						player_health -= amount
						
						log_entity_event(EventType.ATTACK, Entity.ENCOUNTER, amount)
					else:
						log_entity_event(EventType.MISS, Entity.ENCOUNTER)
					
				elif effect.effect_type == ItemTraitEffect.EffectType.GET_ITEM:
					log_entity_event(EventType.COLLECT, Entity.ENCOUNTER, level)
					
				elif effect.effect_type == ItemTraitEffect.EffectType.STATUS_EFFECT:
					if randf() < effect.chance and player_status_effects[effect.status_effect] < effect.duration:
							player_status_effects[effect.status_effect] = effect.duration
							log_entity_event(EventType.STATUS_EFFECT_APPLY, Entity.PLAYER, effect.status_effect)
			
			encounter_has_health = true
			
			if encounter_status_effects[ItemTraitEffect.StatusEffect.FIRE] > 0:
				encounter_health -= 1
				log_entity_event(EventType.STATUS_EFFECT_DAMAGE, Entity.ENCOUNTER, 1)
			
			for effect in encounter_status_effects:
				if encounter_status_effects[effect] > 0:
					encounter_status_effects[effect] -= 1
					
					if encounter_status_effects[effect] == 0:
						log_entity_event(EventType.STATUS_EFFECT_REMOVED, Entity.ENCOUNTER, effect)
		
		is_players_turn = not is_players_turn
		time_elapsed += player_data.stats[Player.Statistic.TURN_TIME]
	
	if player_health > 0:
		log_entity_event(EventType.DEATH, Entity.ENCOUNTER)
		SaveGame.gold += encounter_type.gold * (1 + 0.1 * level)
	
	return {"player_health": player_health, "time": time_elapsed, "player_status_effects": player_status_effects}

func generate_quest(level: int):
	var item_traits = Utility.flatten(SaveGame.equipped.values().map( func (id): return SaveGame.inventory[id].traits ))
	
	var effect_data = get_effects(item_traits, Player.base_stats.duplicate())
	
	var player_stats = effect_data.stats
	var player_turn_effects = effect_data.turn_effects
	var player_health = player_stats[Player.Statistic.MAX_HEALTH]
	var player_status_effects = {
		ItemTraitEffect.StatusEffect.FIRE: 0,
		ItemTraitEffect.StatusEffect.FROZEN: 0,
		ItemTraitEffect.StatusEffect.VENOM: 0
	}
	
	var time_elapsed = 0
	
	log_entity_event(EventType.SET_MAX_HEALTH, Entity.PLAYER, player_health)
	
	while player_health > 0:
		var result = simulate_encounter(level, {
			"health": player_health,
			"turn_effects": player_turn_effects,
			"stats": player_stats,
			"effects": player_status_effects
		})
		
		player_health = result.player_health
		time_elapsed += result.time
		player_status_effects = result.player_status_effects
	
	log_entity_event(EventType.DEATH, Entity.PLAYER)
	
	SaveGame.returns_on = Utility.get_seconds() + time_elapsed * Utility.MINUTE
#	SaveGame.returns_on = Utility.get_seconds() + 1 * Utility.MINUTE

func get_next_event() -> Dictionary:
	if quest_log.size() <= event_index:
		quest_finished = true
		return {
			"event": EventType.NONE
		}
	
	var event = quest_log[event_index]
	
	event_index += 1
	quest_finished = event_index == quest_log.size()
	
	return event

func has_quest() -> bool:
	return quest_log.size() > 0
