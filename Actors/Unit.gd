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

onready var team_models = {
	0: $BaldMan,
	1: $InfectedModel,
	2: $InfectedModel,
}
var hp: int = hp_max;
var fireball_scene = preload("res://Actors/Fireball.tscn");

var type = "unit"
var path = [];
var path_ind := 0;

var targets_in_range: Array = [];
var target: Unit = null;
var worker_building: Spatial = null;

var cooldown_timer: Timer = null;
var attack_ready := true;

const move_speed := 12;
const complete_dist := 0.15;
onready var nav: Navigation = get_parent()
onready var model = $BaldMan;

signal unit_death(unit);
signal unit_team_changed(unit);

func _ready():
	#init timer
	cooldown_timer = Timer.new();
	cooldown_timer.one_shot = true;
	cooldown_timer.wait_time = attack_delay_sec;
	cooldown_timer.connect("timeout", self, "_on_timeout_complete");
	add_child(cooldown_timer);
	
	set_team(team);

func get_target() -> Spatial:
	var buildings = get_tree().get_nodes_in_group("buildings");
	if buildings.size() <= 0:
		return null;
	var building = buildings[0];
	var dist: int = 10000; # something larget to easily
	for b in buildings:
		var temp = self.global_transform.origin.distance_to(b.global_transform.origin);
		if temp < dist:
			dist = temp;
			building = b;
	move_to(building.get_door_position());
	return building;

func move_to(target_pos):
	var origin = global_transform.origin;
	path = nav.get_simple_path(origin, target_pos);
	path_ind = 0;
	model.animation_run();

func move_to_building(building: Spatial):
	move_to(building.get_door_position());
	if "type" in building and building.type == "building":
		worker_building = building;
	
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
			if worker_building and self.global_transform.origin.distance_to(worker_building.get_door_position()) < 1:
				worker_building.enterBuilding(self)
				worker_building = null;
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

func is_infected() -> bool:
	return not team == 0;

func set_infection(is_infected: bool) -> void:
	if team == 0:
		emit_signal("unit_team_changed", self);
		set_team(1);

func set_team(team_arg: int):
	team = team_arg;
	if team in team_models:
		team_models[0].visible = false;
		team_models[team].visible = true;
	var cylinder: CylinderShape = $AttackRange/CollisionShape.shape;
	cylinder.radius = attack_range;
	# layer 2 generic unit
	# layer 3 villager
	# layer 4 infected
	# layer 5 building
	if team == 0: # villager
		scale = Vector3(1, 1, 1);
		self.set_collision_layer_bit(3, true); # attacked by infected
		self.set_collision_layer_bit(4, false); # attacked by villagers
		$AttackRange.set_collision_mask_bit(3, false); # attacks villagers
		$AttackRange.set_collision_mask_bit(4, true); # attacks infected
		$AttackRange.set_collision_mask_bit(5, false); # attacks building
	elif team == 1: # infected villager
		scale = Vector3(1, 1, 1);
		self.set_collision_layer_bit(3, true); # attacked by infected
		self.set_collision_layer_bit(4, false); # attacked by villagers
		$AttackRange.set_collision_mask_bit(3, true); # attacks villagers
		$AttackRange.set_collision_mask_bit(4, true); # attacks infected
		$AttackRange.set_collision_mask_bit(5, true); # attacks building
	elif team == 2: # infected
		scale = Vector3(1.5, 1.5, 1.5);
		self.set_collision_layer_bit(3, false); # attacked by infected
		self.set_collision_layer_bit(4, true); # attacked by villagers
		$AttackRange.set_collision_mask_bit(3, true); # attacks villagers
		$AttackRange.set_collision_mask_bit(4, false); # attacks infected
		$AttackRange.set_collision_mask_bit(5, true); # attacks building

func kill() -> void:
	emit_signal("unit_death", self);
	self.queue_free();

func rng_virius() -> void:
	if randi() % 100 > 90:
		set_infection(true);

func attack_target() -> void:
	if target:
		spawn_fireball();
		attack_ready = false;
		cooldown_timer.start();
		look_at(target.transform.origin, Vector3.UP);
		if is_infected():
			target.rng_virius();
		if target.adjust_hp(-1 * attack_str) <= 0:
			drop_target(target);

func spawn_fireball():
	var newFireball = fireball_scene.instance();
	newFireball.target = target;
	nav.add_child(newFireball);
	#newFireball.global_translate(self.global_transform.origin);


func drop_target(body: Unit) -> void:
	if body:
		body.disconnect("unit_team_changed", self, "_filter_targets_in_range");
		body.disconnect("unit_death", self, "drop_target");
	targets_in_range.erase(body);
	if body == target:
		if targets_in_range.size() > 0:
			target = get_next_target();
		else:
			target = null;

func add_target(body: Unit) -> void:
	targets_in_range.append(body);
	body.connect("unit_team_changed", self, "_filter_targets_in_range");
	body.connect("unit_death", self, "drop_target");
	if target == null:
		target = body;
		look_at(target.transform.origin, Vector3.UP);

func is_selected() -> bool:
	return $SelectionRing.visible;

func get_next_target() -> Unit:
	var next: Unit = targets_in_range[0];
	var dist: int = 10000; # something large
	for unit in targets_in_range:
		var temp = self.transform.origin.distance_to(unit.transform.origin);
		if temp < dist:
			dist = temp;
			next = unit;
	return next;
	
func _filter_targets_in_range(turnCoat: Unit):
	if team == 0:
		if turnCoat.team == 0 or turnCoat.team == 1:
			drop_target(turnCoat);
	if team == 1: # infected villager
		if turnCoat.team == 1:
			drop_target(turnCoat);
	if team == 2: # infected
		if turnCoat.team == 2:
			drop_target(turnCoat);

func _on_timeout_complete() -> void:
	self.attack_ready = true;

func _on_AttackRange_body_entered(body: Node) -> void:
	if not "team" in body or body.team == self.team:
		if team == 0  or "type" in body:
			return;
	add_target(body);

func _on_AttackRange_body_exited(body: Node) -> void:
	if not "team" in body or body.team == self.team:
		return;
	drop_target(body);
