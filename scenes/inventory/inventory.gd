class_name Inventory extends Control

const ITEM_CARD_SCENE = preload("res://scenes/inventory/item/item.tscn")

@onready var item_container = $Items
@onready var click = $Click

var dragging = false
var drag_velocity : Vector2
var page = 0

func _ready():
	var inventory = SaveGame.inventory.values()
	
	for item in inventory:
		var item_card = ITEM_CARD_SCENE.instantiate()
		item_card.load_data(item)
		
		item_container.add_child(item_card)

func _on_exit_button_pressed():
	click.play()
	create_tween().tween_property(self, "position:y", get_viewport_rect().size.y, 0.25)

func _unhandled_input(event):
	if event is InputEventScreenDrag:
		drag_velocity = event.velocity
		dragging = true
	elif event is InputEventScreenTouch and not event.is_pressed() and dragging:
		process_drag()
		dragging = false

func process_drag():
	var direction = drag_velocity.normalized()
	
#		Too slow/short
	if drag_velocity.length() < 1000: return
#		Too sloped
	if abs(direction.x) + abs(direction.y) >= 1.3: return
#		Not horizontal
	if abs(direction.y) > abs(direction.x): return
	
	var cards_per_page = floor(get_viewport_rect().size.x / 980)
	var page_count = item_container.get_child_count() / cards_per_page
	page = clamp(page - sign(direction.x), 0, ceil(page_count - 1))
	create_tween().tween_property(item_container, "position:x", -page * (cards_per_page * 980 + 50) + 50, 0.1)
	
	drag_velocity = Vector2.ZERO

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_exit_button_pressed()
