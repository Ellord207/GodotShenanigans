extends KinematicBody

class_name Unit
export (int) var team = 0;
export (int)  var hp_max = 100;
export (float) var attack_range = 5;
export (int) var attack_str = 20;
export (float) var attack_delay_sec = 0.5;
export (bool) var isFoodWorker = false;
export (bool) var isMedicalWorker = false;
export (bool) var isMoneyWorker = false;

var team_colors = {
	0: preload("res://Actors/Team_Zero_Material.tres"),
	1: preload("res://Actors/Team_One_Material.tres"),
}
var hp: int = hp_max;
var fireball_scene = preload("res://Actors/Fireball.tscn");

var path = [];
var path_ind := 0;

var targets_in_range: Array = [];
var target: Unit = null;
var target_building: Spatial = null;

var cooldown_timer: Timer = null;
var attack_ready := true;

const move_speed := 12;
const complete_dist := 0.15;
onready var nav: Navigation = get_parent()
onready var model = $BaldMan;

signal unit_death(unit);

func _ready():
	#init timer
	cooldown_timer = Timer.new();
	cooldown_timer.one_shot = true;
	cooldown_timer.wait_time = attack_delay_sec;
	cooldown_timer.connect("timeout", self, "_on_timeout_complete");
	add_child(cooldown_timer);
	
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
		$AttackRange.set_collision_mask_bit(1, true);
		get_target();

func get_target():
	var buildings = get_tree().get_nodes_in_group("buildings");
	if buildings.size() <= 0:
		return;
	var building = buildings[0];
	var dist: int = 10000; # something larget to easily
	for b in buildings:
		var temp = self.transform.origin.distance_to(b.transform.origin);
		if temp < dist:
			dist = temp;
			building = b;
	move_to(building.transform.origin);

func move_to(target_pos):
	var origin = global_transform.origin;
	path = nav.get_simple_path(origin, target_pos);
	path_ind = 0;
	model.animation_run();

func move_to_building(building: Spatial):
	var origin = global_transform.origin;
	path = nav.get_simple_path(origin, building.get_door_position());
	path_ind = 0;
	model.animation_run();
	if "type" in building and building.type == "building":
		target_building = building;
	
func _physics_process(delta: float) -> void:
	if attack_ready and target:
		attack_target();
	if path_ind < path.size():
		var move_vec: Vector3 = (path[path_ind] - global_transform.origin)
		if move_vec.length() < complete_dist:
			path_ind += 1;
			if path_ind >= path.size():
				model.animation_stop();
		else:
			move_vec = move_vec.normalized()
			if target == null:
				if transform.origin + move_vec != Vector3.UP:
					look_at(transform.origin + move_vec, Vector3.UP);
			else:
				if transform.origin + move_vec != Vector3.UP:
					look_at(target.transform.origin, Vector3.UP);
			if target_building and self.global_transform.origin.distance_to(target_building.get_door_position()) < 1:
				target_building = null;
				## unit enter building here
				pass;
			move_and_slide(move_vec * move_speed, Vector3.UP);
	
func select() -> void:
	$SelectionRing.show();
	
func deselect() -> void:
	$SelectionRing.hide();

func adjust_hp(num: int) -> int:
	hp += num;
	if hp <= 0:
		kill();
	return hp;

func kill() -> void:
	emit_signal("unit_death", self);
	self.queue_free();

func attack_target() -> void:
	if target:
		spawn_fireball();
		attack_ready = false;
		cooldown_timer.start();
		look_at(target.transform.origin, Vector3.UP);
		if target.adjust_hp(-1 * attack_str) <= 0:
			drop_target(target);

func spawn_fireball():
	var newFireball = fireball_scene.instance();
	newFireball.target = target;
	nav.add_child(newFireball);
	#newFireball.global_translate(self.global_transform.origin);


func drop_target(body: Unit) -> void:
	targets_in_range.erase(body);
	if target && body.get_instance_id() == target.get_instance_id():
		if targets_in_range.size() > 0:
			target = get_next_target();
		else:
			target = null;

func is_selected() -> bool:
	return $SelectionRing.visible;

func get_next_target() -> Unit:
	var next: Unit = targets_in_range[0];
	var dist: int = 10000; # something larget to easily
	for unit in targets_in_range:
		var temp = self.transform.origin.distance_to(unit.transform.origin);
		if temp < dist:
			dist = temp;
			next = unit;
	return next;
	#return targets_in_range[0];

func _on_timeout_complete() -> void:
	self.attack_ready = true;

func _on_AttackRange_body_entered(body: Node) -> void:
	if not "team" in body or body.team == self.team:
		if not team == 0:
			pass; # target build
		return;
	targets_in_range.append(body);
	if target == null:
		target = body;
		look_at(target.transform.origin, Vector3.UP);

func _on_AttackRange_body_exited(body: Node) -> void:
	if not "team" in body or body.team == self.team:
		return;
	drop_target(body);
