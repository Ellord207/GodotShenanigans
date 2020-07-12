extends Spatial

export (int) var hpMax = 1000
export (String) var type = "building"
export (String) var buildingType = "Farm" #enum buildingTypes {Farm, Hospital, Jail, Bank}

onready var door_position = $DoorPosition;

var hp: int = hpMax
var maxWorkers = 0
var currentWorkers = 0
var workDone = 0
var requiredWork = 0
var output = 0
var workMultiplier = 0
var workers = []

var unitNode

signal building_destroyed(building)
signal updateUI(building)

# Called when the node enters the scene tree for the first time.
func _ready():
	#yield(get_tree().create_timer(0.1),"timeout")
	unitNode = get_node("/root/Spatial/Navigation/Unit")
	
	if buildingType == "Farm":
		requiredWork = 1000
		output = 1000
		maxWorkers = 6
		workMultiplier = 5
	elif buildingType == "Bank":
		requiredWork = 1000
		output = 100
		maxWorkers = 4
		workMultiplier = 6
	elif buildingType == "Jail":
		requiredWork = 1000
		output = 1
		maxWorkers = 8
		workMultiplier = 5
	elif buildingType == "Hospital":
		requiredWork = 500
		output = 1
		maxWorkers = 4
		workMultiplier = 4
	
	pass # Replace with function body.

func get_door_position() -> Vector3:
	return door_position.global_transform.origin;

# returns true if output is generated
func doWork() -> bool:
	workDone += currentWorkers * currentWorkers * workMultiplier
	if workDone >= requiredWork:
		workDone -= requiredWork
		return true
	return false

func adjust_hp(num: int) -> int:
	hp += num;
	if hp <= 0:
		kill();
	return hp;

func kill() -> void:
	emit_signal("building_destroyed", self);
	self.queue_free();
	
func select() -> void:
	if $SelectionRing == null:
		$StaticBody/SelectionRing.show()
	else:
		$SelectionRing.show()
		
	#addWorker(unitNode)
	
func deselect() -> void:
	if $SelectionRing == null:
		$StaticBody/SelectionRing.hide()
	else:
		$SelectionRing.hide()
		
	#removeWorker()

func enterBuilding(villager):
	currentWorkers += 1
	workers.append(villager)
	villager.set_physics_process(false)
	villager.visible = false
	villager.translate(Vector3(0, 200, 0));
	emit_signal("updateUI", self)
	
func leaveBuilding(villager):
	currentWorkers -= 1
	var workerIndex = 0
	for worker in workers:
		if worker == villager:
			workers.remove(workerIndex)
			break
		workerIndex += 1
	#var worker = workers.pop_back()
	villager.translate(Vector3(0, -200, 0));
	villager.set_physics_process(true)
	villager.visible = true
