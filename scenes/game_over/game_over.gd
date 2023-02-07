class_name GameOverScreen extends Control

const ROW = preload("res://scenes/game_over/row.tscn")

@onready var player_name = $Container/Name
@onready var coin_label = $Container/CoinLabel/Text
@onready var monster_row : GameOverRow = $Container/MonsterRow
@onready var click = $Click

# Called when the node enters the scene tree for the first time.
func _ready():
	player_name.text = SaveGame.duck_name
	monster_row.amount = SaveGame.gold
	
	for item_id in SaveGame.inventory:
		var item_data : ItemData = SaveGame.inventory[item_id]
		var row = ROW.instantiate()
		
		row.amount = 100 + 50 * item_data.traits.size()
		add_child(row)
	
	SaveGame.clear_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_ok_button_pressed():
	click.play()
	await click.finished
	
	get_tree().change_scene_to_file("res://scenes/title/title_screen.tscn")
