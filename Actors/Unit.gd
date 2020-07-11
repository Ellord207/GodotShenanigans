extends KinematicBody

export(int, "Zero", "One") var team = "Zero";
export var hp_max: int = 100;
export var attack_range: float = 5;
class_name Unit
var team_colors = {
	0: preload("res://Actors/Team_Zero_Material.tres"),
	1: preload("res://Actors/Team_One_Material.tres"),
}

var hp: int = hp_max;

var targets_in_range: Array = [];
var path = [];
var path_ind := 0;
var target: Unit = null;
const move_speed := 12;
onready var nav: Navigation = get_parent()

func _ready():
	if team in team_colors:
		$Body.material_override = team_colors[team];
	var cylinder: CylinderShape = $AttackRange/CollisionShape.shape;
	cylinder.radius = attack_range;
	if team == 0:
		self.set_collision_layer_bit(3, true);
		$AttackRange.set_collision_mask_bit(4, true);
	else:
		self.set_collision_layer_bit(4, true);
		$AttackRange.set_collision_mask_bit(3, true);

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
			if target == null:
				look_at(transform.origin + move_vec, Vector3.UP);
			else:
				look_at(target.transform.origin, Vector3.UP);
			move_and_slide(move_vec * move_speed, Vector3.UP); 
	#if target != null:
	#	look_at(target.transform.origin, Vector3.UP);

func select():
	$SelectionRing.show();
	
func deselect():
	$SelectionRing.hide();

func adjust_hp(num: int) -> int:
	hp += num;
	return hp;

func is_selected() -> bool:
	return $SelectionRing.visible;

func get_next_target() -> Unit:
	return targets_in_range[0];

func _on_AttackRange_body_entered(body: Node) -> void:
	if  body.team == self.team:
		return;
	targets_in_range.append(body);
	if target == null:
		target = body;
		look_at(target.transform.origin, Vector3.UP);


func _on_AttackRange_body_exited(body: Node) -> void:
	if  body.team == self.team:
		return;
	targets_in_range.erase(body);
	if target && body.get_instance_id() == target.get_instance_id():
		if targets_in_range.size() > 0:
			target = get_next_target();
		else:
			target = null;
