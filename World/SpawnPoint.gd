extends Position3D

var objects_local := 0;
var queued_spawn_navs = [];

func queue_spawn(nav: Navigation):
	queued_spawn_navs.append(nav);
	if objects_local == 0:
		spawn();


func spawn():
	if queued_spawn_navs.size() <= 0:
		return;
	var newUnitScene = load("res://Actors/Unit.tscn");
	var newUnit = newUnitScene.instance();
	newUnit.team = 2;
	queued_spawn_navs.pop_front().add_child(newUnit);
	newUnit.global_translate(self.global_transform.origin);
	newUnit.get_target();


func _on_Area_body_entered(body: Node) -> void:
	objects_local+=1;

func _on_Area_body_exited(body: Node) -> void:
	objects_local-=1;
	if queued_spawn_navs.size() > 0:
		spawn();
