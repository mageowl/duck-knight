class_name Encounter extends Resource

@export var display_name := "monster"
@export var health := "*"
@export var gold := 0
@export var texture : Texture

@export_group("Effects")
@export var possible_traits : Array[ItemTrait]
@export var bonus_effects : Array[ItemTraitEffect]
