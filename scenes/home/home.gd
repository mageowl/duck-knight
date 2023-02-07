class_name HomeScene extends Control

@onready var click = $Audio/Click
@onready var woosh = $Audio/Woosh
@onready var error = $Audio/Error
@onready var footstep = $Audio/Footstep
@onready var animation_player = $AnimationPlayer
@onready var player_name = $PlayerName
@onready var coins = $Coins
@onready var timer = $Timer

@onready var player = $Player
@onready var inventory_panel = $Inventory
var inventory_open := false

func _ready():
	if not SaveGame.is_available():
		get_tree().change_scene_to_file("res://scenes/home/not_available.tscn")
	
	if QuestManager.has_quest():
		get_tree().change_scene_to_file("res://scenes/quest/viewer/encounter_viewer.tscn")
	
	if SaveGame.bored_on <= Utility.get_seconds():
		get_tree().change_scene_to_file("res://scenes/game_over/game_over.tscn")
	
	position.x = get_viewport_rect().size.x
	create_tween().tween_property(self, "position:x", 0, 0.52).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	player_name.text = SaveGame.duck_name
	coins.text = str(SaveGame.gold)

func _on_inventory_btn_pressed():
	woosh.play()
	create_tween().tween_property(inventory_panel, "position:y", 0, 0.25)
	inventory_open = true

func _process(_delta):
	var total_minutes = ceil((SaveGame.bored_on - Utility.get_seconds()) / Utility.MINUTE)
	var hours = floor(total_minutes / 60)
	var minutes = total_minutes % 60
	timer.text = str("%d:%d" % [hours, minutes])

func _on_player_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if SaveGame.equipped.size() <= 0:
			error.play()
			return
		
		footstep.play()
		animation_player.play("Walk")
		
		var distance = get_viewport_rect().size.x + 500
		var tween = create_tween()
		tween.tween_property(player, "position:x", get_viewport_rect().size.x + 200, (distance - player.position.x) / 200)
		
		await tween.finished
		footstep.stop()
		
		var equipped_levels = SaveGame.equipped.values().map(func (x): return SaveGame.inventory[x]).map(func (d: ItemData): return max(d.level, 1))
		print(equipped_levels)
		QuestManager.generate_quest(max(1, equipped_levels.reduce(func (a, b): return a + Utility.not_null(b), 0) / equipped_levels.size()))
		if not OS.has_feature("no_save"):
			SaveGame.save_game()
		
		var screen_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		screen_tween.tween_property(self, "position:x", get_viewport_rect().size.x, 0.52)
		
		await screen_tween.finished
		get_tree().change_scene_to_file("res://scenes/home/not_available.tscn")

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position:x", get_viewport_rect().size.x, 0.52)
		
		await tween.finished
		get_tree().change_scene_to_file("res://scenes/title/title_screen.tscn")
