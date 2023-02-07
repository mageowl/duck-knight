class_name TitleScreen extends Control

signal confirm_box_closed

@onready var contiue_button = $Buttons/ContiueButton
@onready var new_game_button = $Buttons/NewGameButton
@onready var about_button = $Buttons/AboutButton
@onready var audio_click = $Audio/Click
@onready var audio_ding = $Audio/Ding
@onready var audio_duck_knight = $Audio/DuckKnight
@onready var animation_player = $AnimationPlayer
@onready var name_input = $NameInput
@onready var title = $Title
@onready var confirm = $Confirm
@onready var about_panel = $AboutPanel

@onready var title_normal_text : String = title.text
var title_shake_text := "[center][shake level=100 rate=20]duck  knight"
var duck_knight_timer : SceneTreeTimer
var did_confirm = false

func _ready():
	animation_player.play("RESET")
	
	if SaveGame.game_exists():
		contiue_button.visible = true
		
		if not SaveGame.main_menu_continued:
			SaveGame.load_game()
			SaveGame.main_menu_continued = true
			
			get_tree().change_scene_to_file("res://scenes/home/home.tscn")
			return
	
	await get_tree().create_timer(1).timeout
	animation_player.play("Open")
	
	for button in find_children("", "Button"): 
		button.pressed.connect(button_press_noise)
	

func button_press_noise():
	audio_click.play()

func _on_new_game_button_pressed():
	if SaveGame.game_exists():
		confirm.visible = true
		
		await confirm_box_closed
		
		confirm.visible = false
		if not did_confirm: return
	
	animation_player.play("New Game")
	
	contiue_button.disabled = true
	new_game_button.disabled = true
	about_button.disabled = true
	
	await animation_player.animation_finished
	
	create_tween().tween_property(name_input, "modulate:a", 1, 0.25)
	name_input.mouse_filter = MOUSE_FILTER_STOP
	name_input.editable = true
	name_input.visible = true
	name_input.grab_focus()
	name_input.text_submitted.connect(func (text):
		SaveGame.duck_name = text
		SaveGame.new_game()
		
		create_tween().tween_property(self, "position:x", -get_viewport_rect().size.x, 0.52).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		audio_ding.play()
		await audio_ding.finished
		get_tree().change_scene_to_file("res://scenes/home/home.tscn")
	)

func _on_title_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.is_action_pressed("click"):
			title.text = title_shake_text
			
			duck_knight_timer = get_tree().create_timer(3)
			await duck_knight_timer.timeout
			
			if duck_knight_timer != null:
				audio_duck_knight.play()
				duck_knight_timer = null
				
				await audio_duck_knight.finished
				title.text = title_normal_text
		elif event.is_action_released("click"):
			if duck_knight_timer != null and duck_knight_timer.time_left > 0:
				title.text = title_normal_text
				duck_knight_timer = null


func _on_contiue_button_pressed():
	SaveGame.load_game()
	
	create_tween().tween_property(self, "position:x", -get_viewport_rect().size.x, 0.52).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await audio_click.finished
	get_tree().change_scene_to_file("res://scenes/home/home.tscn")

func _on_confirm_pressed():
	did_confirm = true
	audio_ding.play()
	
	confirm_box_closed.emit()

func _on_deny_button_pressed():
	did_confirm = false
	confirm_box_closed.emit()

func _on_about_button_pressed():
	print(about_panel.position.y, 0)
	create_tween().tween_property(about_panel, "position:y", 0, 0.25)


func _on_about_exit_button_pressed():
	audio_click.play()
	create_tween().tween_property(about_panel, "position:y", get_viewport_rect().size.y, 0.25)
