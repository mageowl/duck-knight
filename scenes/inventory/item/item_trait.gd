class_name ItemTrait extends Resource

@export var display_name : String = ""
@export var curse : bool = false
@export var effects : Array[ItemTraitEffect] = []

@export_group("Adjectives")
@export var adjectives : Array[String] = []
@export var post_adjectives : Array[String] = []
