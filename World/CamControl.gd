extends Spatial

const MOVE_MARGIN = 20;
const CAMERA_SPEED = 100;
export var max_cam_dist = 300;
export var zoom_fov_increment = 5;
var MAX_CAMERA_RIGHT_DISTANCE_X = max_cam_dist;
var MAX_CAMERA_LEFT_DISTANCE_X = -1 * max_cam_dist;
var MAX_CAMERA_TOP_DISTANCE_Z = max_cam_dist;
var MAX_CAMERA_BOTTOM_DISTANCE_Z = -1 * max_cam_dist;


#var playerHUD = load("res://UI/PlayerHUD.gd").new()
signal unitSelected(objects)
signal deselected()
signal buildingSelected(objects)

const ray_length = 1000;
onready var cam = $Camera;
onready var cameraNode = get_node("Camera");
onready var navMesh = get_node("../Navigation");
onready var controlNode = get_node("../CamControl/Control")

var team = 0;
onready var selection_box = $SelectionBox
var selected_units: Array = [];
var selected_buildings: Array = []
var start_sel_pos = Vector2();
var currentCameraDistanceX = 0;
var currentCameraDistanceZ = 0;

var unitNode

func _input(ev):
	if ev is InputEventMouseButton:
		if ev.button_index == BUTTON_WHEEL_UP:
			if (cameraNode.fov > 40):
				cameraNode.fov -= zoom_fov_increment;
		if ev.button_index == BUTTON_WHEEL_DOWN:
			if (cameraNode.fov < 80):
				cameraNode.fov += zoom_fov_increment;
				
	if Input.is_action_just_pressed("CreateUnitKey"):
		var m_pos: Vector2 = get_viewport().get_mouse_position();
		var results = raycast_from_mouse(m_pos, 1);
		if not "position" in results:
			return;
		var newUnitScene = load("res://Actors/Unit.tscn");
		var newUnit = newUnitScene.instance();
		newUnit.global_translate(results.position);
		newUnit.team = 0;
		navMesh.add_child(newUnit);
		VillageManager.money -= 10;

	if Input.is_action_just_pressed("CreateBuildingKey"):
		var m_pos: Vector2 = get_viewport().get_mouse_position();
		var results = raycast_from_mouse(m_pos, 1);
		if not "position" in results:
			return;
		var newUnitScene = load("res://Actors/Unit.tscn");
		var newUnit = newUnitScene.instance();
		newUnit.global_translate(results.position);
		newUnit.team = 2;
		navMesh.add_child(newUnit);
		newUnit.get_target();
		VillageManager.money -= 20;

func _process(delta: float) -> void:
	var m_pos: Vector2 = get_viewport().get_mouse_position();
	calc_move(m_pos, delta);
	if Input.is_action_just_pressed("alt_command"):
		move_selected_units(m_pos);
	if Input.is_action_just_pressed("main_command"):
		selection_box.start_sel_pos = m_pos;
		start_sel_pos = m_pos
	if Input.is_action_pressed("main_command"):
		selection_box.is_visible = true;
		selection_box.m_pos = m_pos;
	else:
		selection_box.is_visible = false;
	if Input.is_action_just_released("main_command"):
		select_units(m_pos);

func calc_move(m_pos, delta) -> void:
	var v_size = get_viewport().size;
	var move_vec = Vector3();
	if m_pos.x < MOVE_MARGIN or Input.is_key_pressed(KEY_LEFT):
		if (currentCameraDistanceX > MAX_CAMERA_LEFT_DISTANCE_X and get_viewport().get_mouse_position() != null):
			currentCameraDistanceX -= 1;
			move_vec.x -= 1;
	if m_pos.y < MOVE_MARGIN or Input.is_key_pressed(KEY_UP):
		if (currentCameraDistanceZ > MAX_CAMERA_BOTTOM_DISTANCE_Z and get_viewport().get_mouse_position() != null):
			currentCameraDistanceZ -= 1;
			move_vec.z -= 1;
	if m_pos.x > v_size.x - MOVE_MARGIN or Input.is_key_pressed(KEY_RIGHT):
		if (currentCameraDistanceX < MAX_CAMERA_RIGHT_DISTANCE_X and get_viewport().get_mouse_position() != null):
			currentCameraDistanceX += 1;
			move_vec.x += 1;
	if m_pos.y > v_size.y - MOVE_MARGIN or Input.is_key_pressed(KEY_DOWN):
		if (currentCameraDistanceZ < MAX_CAMERA_TOP_DISTANCE_Z and get_viewport().get_mouse_position() != null):
			currentCameraDistanceZ += 1;
			move_vec.z += 1;
	
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation_degrees.y);
	global_translate(move_vec * delta * CAMERA_SPEED);

func move_selected_units(m_pos: Vector2):
	var result = raycast_from_mouse(m_pos, 17); # terrain and buildings
	if result:
		for unit in selected_units:
			if "type" in result.collider and str(result.collider.type) == "building":
				unit.move_to_building(result.collider);
			else:
				unit.move_to(result.position);

func dehighlight_unit(unit: Unit):
	unit.disconnect("unit_death", self, "_on_unit_death");
	unit.disconnect("unit_team_changed", self, "_on_unit_turn");
	unit.deselect()

func highlight_unit(unit: Unit):
	unit.connect("unit_death", self, "_on_unit_death");
	unit.connect("unit_team_changed", self, "_on_unit_turn");
	unit.select()

func select_units(m_pos) -> void:
	var new_selected_units = []
	var new_selected_buildings = []
	
	if controlNode.canDeselect:
		for unit in selected_units:
			dehighlight_unit(unit)
			selected_units = [];
					
		for building in selected_buildings:
			building.deselect()
			selected_buildings = []
					
		emit_signal("deselected")
	
	if m_pos.distance_squared_to(start_sel_pos) < 16:
		var u = get_unit_under_mouse(m_pos)
		if u != null:
			new_selected_units.append(u)
		else:
			# try and get building under mouse
			u = get_building_under_mouse(m_pos)
			if u != null: 
				new_selected_buildings.append(u)
	else:
		new_selected_units = get_units_in_box(start_sel_pos, m_pos)
		if new_selected_units.size() == 0:
			new_selected_buildings = get_buildings_in_box(start_sel_pos, m_pos)
	if new_selected_units.size() != 0:
		for unit in selected_units:
			dehighlight_unit(unit)
		for unit in new_selected_units:
			highlight_unit(unit);
		selected_units = new_selected_units
		
		#adding in events/signals for HUD to subscribe to
		emit_signal("unitSelected", selected_units)
	else:
		# try and get buildings in box
		if new_selected_buildings.size() != 0:
			for building in selected_buildings:
				building.deselect()
			for building in new_selected_buildings:
				building.select()
			selected_buildings = new_selected_buildings
			emit_signal("buildingSelected", selected_buildings)

func get_unit_under_mouse(m_pos):
	var result = self.raycast_from_mouse(m_pos, 3) # collision mask 0...011
	if result and "team" in result.collider and result.collider.team == team:
		 return result.collider;
		
func get_building_under_mouse(m_pos):
	var result = self.raycast_from_mouse(m_pos, 17) # collision mask 0...011
	if "collider" in result:
		if "type" in result.collider or result.collider.is_in_group("buildings"):
			if (str(result.collider.type) == "building" or str(result.collider.type) == "EmptyPlot"):
				return result.collider;

func get_units_in_box(top_left: Vector2, bot_right: Vector2) -> Array:
		# ensure top and bottom are not swapped
	if top_left.x > bot_right.x:
		var tmp = top_left.x
		top_left.x = bot_right.x
		bot_right.x = tmp;
	if top_left.y > bot_right.y:
		var tmp = top_left.y
		top_left.y = bot_right.y
		bot_right.y = tmp;
	var box = Rect2(top_left, bot_right - top_left)
	var box_selected_units = [];
	var units = get_tree().get_nodes_in_group("units");
	for unit in units:
		if unit.team == team && box.has_point(cam.unproject_position(unit.global_transform.origin)):
				box_selected_units.append(unit)
	return box_selected_units;
	
func get_buildings_in_box(top_left: Vector2, bot_right: Vector2) -> Array:
		# ensure top and bottom are not swapped
	if top_left.x > bot_right.x:
		var tmp = top_left.x
		top_left.x = bot_right.x
		bot_right.x = tmp;
	if top_left.y > bot_right.y:
		var tmp = top_left.y
		top_left.y = bot_right.y
		bot_right.y = tmp;
	var box = Rect2(top_left, bot_right - top_left)
	var box_selected_buildings = [];
	var buildings = get_tree().get_nodes_in_group("buildings");
	buildings += get_tree().get_nodes_in_group("Plots")
	for building in buildings:
		if box.has_point(cam.unproject_position(building.global_transform.origin)):
				box_selected_buildings.append(building)
				
	return box_selected_buildings;

func raycast_from_mouse(m_pos, collision_mask):
	var ray_start = cam.project_ray_origin(m_pos)
	var ray_end = ray_start + cam.project_ray_normal(m_pos) * ray_length;
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(ray_start, ray_end, [], collision_mask);

func _on_unit_turn(unit: Unit) -> void:
	if unit.team != team:
		dehighlight_unit(unit)
		selected_units.erase(unit);

func _on_unit_death(unit: Unit) -> void:
	unit.disconnect("unit_death", self, "_on_unit_death");
	selected_units.erase(unit);
