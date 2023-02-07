extends Control

@onready var quest_title = $QuestTitle
@onready var animation_player = $AnimationPlayer

@onready var player_name = $Spot1/PlayerName
@onready var player_health = $Spot1/PlayerHealth

@onready var encounter_sprite = $Spot2/Encounter
@onready var encounter_name = $Spot2/EncounterName
@onready var encounter_health = $Spot2/EncounterHealth
@onready var encounter_item = $Spot2/Item

@onready var player_particle_effects = {
	ItemTraitEffect.StatusEffect.FIRE: $Spot1/Player/Fire,
	ItemTraitEffect.StatusEffect.FROZEN: $Spot1/Player/Frozen,
	ItemTraitEffect.StatusEffect.VENOM: $Spot1/Player/Venom
}
@onready var encounter_particle_effects = {
	ItemTraitEffect.StatusEffect.FIRE: $Spot2/Encounter/Fire,
	ItemTraitEffect.StatusEffect.FROZEN: $Spot2/Encounter/Frozen,
	ItemTraitEffect.StatusEffect.VENOM: $Spot2/Encounter/Venom
}

var player_max_health = 12
var player_current_health = 12
var encounter_max_health = 4
var encounter_current_health = 4
var encounter_has_health = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player_name.text = SaveGame.duck_name
	
	await get_tree().create_timer(1).timeout
	animation_player.play("SlideIn")
	quest_title.text = "[center][tornado freq=3 radius=5]%s vs. the world" % SaveGame.duck_name
	var tween = create_tween()
	tween.tween_property(quest_title, "visible_ratio", 1, 1)
	tween.tween_interval(1)
	tween.tween_property(quest_title, "modulate:a", 0, 0.5)
	
	await tween.finished
	handle_event()


func handle_event():
	
	var event = QuestManager.get_next_event()
	var animation_played = false
	var event_type : QuestManagerInstance.EventType = event.event
	
	match event_type:
		QuestManager.EventType.ATTACK:
			animation_played = true
			animation_player.play("%sAttack" % ("Player" if event.entity == QuestManager.Entity.PLAYER else "Encounter"))
			
			if event.amount != -1:
				if event.entity == QuestManager.Entity.ENCOUNTER:
					player_current_health -= event.amount
					player_health.text = "%d/%d" % [max(player_current_health, 0), player_max_health]
				elif event.entity == QuestManager.Entity.PLAYER:
					encounter_current_health -= event.amount
					encounter_health.text = "%d/%d" % [max(encounter_current_health, 0), encounter_max_health]
					
		
		QuestManager.EventType.ENCOUNTER:
			encounter_sprite.texture = load(event.texture)
			animation_played = true
			if event.has("name"):
				encounter_name.text = event.name
			
			animation_player.play("Encounter")
			encounter_name.visible = true
			if encounter_has_health:
				encounter_health.visible = true
		
		QuestManager.EventType.DEATH:
			if event.entity == QuestManager.Entity.ENCOUNTER:
				animation_played = true
				animation_player.play("EncounterDead")
				
				encounter_name.visible = false
				encounter_health.visible = false
				encounter_has_health = false
			elif event.entity == QuestManager.Entity.PLAYER:
				animation_played = true
				animation_player.play("PlayerDead")
		
		QuestManager.EventType.MISS:
			animation_played = true
			animation_player.play("%sMiss" % ("Player" if event.entity == QuestManager.Entity.PLAYER else "Encounter"))
		
		QuestManager.EventType.COLLECT:
			if event.entity == QuestManager.Entity.ENCOUNTER:
				if event.amount > 0:
					var item = ItemData.generate(event.amount)
					encounter_item.texture = item.item_texture
				
				animation_played = true
				animation_player.play("PlayerAttack")
				await animation_player.animation_finished
				encounter_item.visible = true
				animation_player.play("Collect")
				
		
		QuestManager.EventType.SET_MAX_HEALTH:
			if event.entity == QuestManager.Entity.PLAYER:
				player_max_health = event.amount
				player_current_health = event.amount
				player_health.text = "%d/%d" % [player_current_health, player_max_health]
			
			if event.entity == QuestManager.Entity.ENCOUNTER:
				encounter_max_health = event.amount
				encounter_current_health = event.amount
				encounter_has_health = event.amount != -1
				encounter_health.text = "%d/%d" % [encounter_current_health, encounter_max_health]
		
		QuestManager.EventType.STATUS_EFFECT_APPLY:
			var status_effect : ItemTraitEffect.StatusEffect = event.amount
			if event.entity == QuestManager.Entity.PLAYER and player_particle_effects.has(status_effect):
				player_particle_effects[status_effect].emitting = true
			if event.entity == QuestManager.Entity.ENCOUNTER and encounter_particle_effects.has(status_effect):
				player_particle_effects[status_effect].emitting = true
		
		QuestManager.EventType.STATUS_EFFECT_REMOVED:
			var status_effect : ItemTraitEffect.StatusEffect = event.amount
			print("yoholoe")
			
			if event.entity == QuestManager.Entity.PLAYER and player_particle_effects.has(status_effect):
				print("yhhhadfo")
				player_particle_effects[status_effect].emitting = false
			if event.entity == QuestManager.Entity.ENCOUNTER and encounter_particle_effects.has(status_effect):
				encounter_particle_effects[status_effect].emitting = false
	
	if animation_played: await animation_player.animation_finished
	
	if not QuestManager.quest_finished:
		handle_event()
	else:
		QuestManager.quest_log = []
		SaveGame.save_game()
		
		await create_tween().tween_property(self, "position:x", -get_viewport_rect().size.x, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).finished
		get_tree().change_scene_to_file("res://scenes/home/home.tscn")
