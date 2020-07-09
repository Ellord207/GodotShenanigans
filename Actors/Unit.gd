extends KinematicBody

export var team: int = 0;
class_name Unit
var team_colors = {
	0: preload("res://Actors/TeamOneMaterial.tres"),
	1: preload("res://Actors/TeamTwoMaterial.tres"),
}

var path = [];
var path_ind = 0;
const move_speed = 12;
onready var nav = get_parent()
onready var model: UnitModel = $UnitModel

func _ready():
	if team in team_colors:
		model.material_override(team_colors[team])

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos);
	path_ind = 0;
	
func _physics_process(delta: float) -> void:
	if path_ind < path.size():
		var move_vec: Vector3 = (path[path_ind] - global_transform.origin)
		if move_vec.length() < 0.1:
			path_ind += 1;
		else:
			move_vec = move_vec.normalized()
			look_at(transform.origin + move_vec, Vector3.UP);
			move_and_slide(move_vec * move_speed, Vector3.UP); 

func select():
	$SelectionRing.show();
	
func deselect():
	$SelectionRing.hide();
