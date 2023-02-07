class_name DuckNotAvailable extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Utility.get_seconds() >= SaveGame.returns_on:
		await create_tween().tween_property(self, "modulate:a", 0, 0.5).finished
		get_tree().change_scene_to_file("res://scenes/home/home.tscn")
