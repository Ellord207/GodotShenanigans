extends KinematicBody

export var team: int = 0;
export var hp_max: int = 100;
export var attack_range: float = 5;
class_name Unit
var team_colors = {
	0: preload("res://Actors/Team_One_Material.tres"),
	1: preload("res://Actors/Team_Two_Material.tres"),
}

var hp: int = hp_max;

var path = [];
var path_ind = 0;
const move_speed = 12;
onready var nav = get_parent()

func _ready():
	if team in team_colors:
		$Body.material_override = team_colors[team];
	var cylinder: CylinderShape = $AttackRange/CollisionShape.shape;
	cylinder.radius = attack_range;

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

func adjust_hp(num: int) -> int:
	hp += num;
	return hp;

func _on_AttackRange_tree_entered() -> void:
	#print_debug("Target!")
	pass;
