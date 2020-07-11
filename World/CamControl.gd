extends Spatial

const MOVE_MARGIN = 20;
const CAMERA_SPEED = 30;
export var max_cam_dist = 40; # Arbitrary 40 picked
export var zoom_fov_increment = 5;
var MAX_CAMERA_RIGHT_DISTANCE_X = max_cam_dist;
var MAX_CAMERA_LEFT_DISTANCE_X = -1 * max_cam_dist;
var MAX_CAMERA_TOP_DISTANCE_Z = max_cam_dist;
var MAX_CAMERA_BOTTOM_DISTANCE_Z = -1 * max_cam_dist;

const ray_length = 1000;
onready var cam = $Camera;
onready var cameraNode = get_node("Camera");
onready var navMesh = get_node("../Navigation");

var team = 0;
onready var selection_box = $SelectionBox
var selected_units: Array = [];
var start_sel_pos = Vector2();
var currentCameraDistanceX = 0;
var currentCameraDistanceZ = 0;

func _input(ev):
	if Input.is_action_just_pressed("CreateUnitKey"):
		var m_pos: Vector2 = get_viewport().get_mouse_position();
		var results = raycast_from_mouse(m_pos, 1);
		var newUnitScene = load("res://Actors/Unit.tscn");
		var newUnit = newUnitScene.instance();
		newUnit.global_translate(results.position);
		newUnit.team = 0;
		navMesh.add_child(newUnit);
		
	if Input.is_action_just_pressed("CreateBuildingKey"):
		var m_pos: Vector2 = get_viewport().get_mouse_position();
		var results = raycast_from_mouse(m_pos, 1);
		var newBuildingScene = load("res://UI/House.tscn");
		var newBuilding = newBuildingScene.instance();
		newBuilding.global_translate(results.position);
		navMesh.add_child(newBuilding);
	
	if ev is InputEventMouseButton:
		if ev.button_index == BUTTON_WHEEL_UP:
			if (cameraNode.fov > 40):
				cameraNode.fov -= zoom_fov_increment;
		if ev.button_index == BUTTON_WHEEL_DOWN:
			if (cameraNode.fov < 80):
				cameraNode.fov += zoom_fov_increment;

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
	var results = raycast_from_mouse(m_pos, 1);
	if results:
		for unit in selected_units:
			unit.move_to(results.position);

func select_units(m_pos) -> void:
	var new_selected_units = []
	if m_pos.distance_squared_to(start_sel_pos) < 16:
		var u = get_unit_under_mouse(m_pos)
		if u != null:
			new_selected_units.append(u)
	else:
		new_selected_units = get_units_in_box(start_sel_pos, m_pos)
	if new_selected_units.size() != 0:
		for unit in selected_units:
			unit.deselect()
		for unit in new_selected_units:
			unit.select()
		selected_units = new_selected_units
	else:
		for unit in selected_units:
			unit.deselect()
			selected_units = [];

func get_unit_under_mouse(m_pos):
	var result = self.raycast_from_mouse(m_pos, 3) # collision mask 0...011
	if result and "team" in result.collider and result.collider.team == team:
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

func raycast_from_mouse(m_pos, collision_mask):
	var ray_start = cam.project_ray_origin(m_pos)
	var ray_end = ray_start + cam.project_ray_normal(m_pos) * ray_length;
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(ray_start, ray_end, [], collision_mask);
