extends Navigation


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_Button_pressed() -> void:
	var points = get_tree().get_nodes_in_group("infected_spawn");
	if points.size() == 0:
		return;
	var point = points[0];
	var newUnitScene = load("res://Actors/Unit.tscn");
	var newUnit = newUnitScene.instance();
	newUnit.global_translate(point.global_transform.origin);
	newUnit.team = 1;
	self.add_child(newUnit);
