class_name ItemCard extends Panel

@onready var name_label = $Container/Label
@onready var icon = $Container/Icon
@onready var equip_btn = $EquipButton
@onready var unequip_btn = $UnequipButton
@onready var trait_list = $Container/TraitList
@onready var ding = $Ding
@onready var click = $Click

var data : ItemData
var is_ready = false

func _ready():
	is_ready = true
	
	if data != null: update_elements()

func load_data(item_data: ItemData) -> void:
	data = item_data
	
	if is_ready: update_elements()

func update_elements():
	name_label.text = data.display_name.as_string()
	icon.texture = data.item_texture
	set_equip_btn_type(not data.is_equipped)
	data.unequipped.connect(_on_unequip)
	
	trait_list.text = "[color=47e044]level %s[/color]\n\n" % ("0" if data.level == -1 else str(data.level))
	
	for item_trait in data.traits:
		trait_list.append_text(item_trait.display_name + "\n")

func set_equip_btn_type(equip: bool):
	equip_btn.disabled = not equip
	equip_btn.visible = equip
	unequip_btn.disabled = equip
	unequip_btn.visible = not equip

func _on_equip_button_pressed():
	ding.play()
	
	data.equip()
	set_equip_btn_type(false)

func _on_unequip():
	set_equip_btn_type(true)


func _on_unequip_button_pressed():
	click.play()
	data.unequip()
