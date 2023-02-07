@tool
class_name GameOverRow extends Label

@onready var label = $Label
@export var amount := 0 :
	set(v):
		amount = v
		
		if label != null:
			label.text = str(v)

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = str(amount)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
