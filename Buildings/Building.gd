extends Spatial

export (int) var hpMax = 1000
export (String) var type = "building"
export (String) var buildingType = "Farm" #enum buildingTypes {Farm, Hospital, Jail, Bank}

var hp: int = hpMax
var maxWorkers = 0
var currentWorkers = 0
var workDone = 0
var requiredWork = 0
var output = 0
var workMultiplier = 0

signal building_destroyed(building)

# Called when the node enters the scene tree for the first time.
func _ready():
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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
	
func deselect() -> void:
	if $SelectionRing == null:
		$StaticBody/SelectionRing.hide()
	else:
		$SelectionRing.hide()
