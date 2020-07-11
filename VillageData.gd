extends Node

export var food = 100;
export var medicine = 3;
export var money = 50;

var _timer = null;

func _ready():
	
	_timer = Timer.new();
	add_child(_timer);
	
	_timer.connect("timeout", self, "_on_timer_timeout");
	_timer.set_wait_time(5);
	_timer.set_one_shot(false);
	_timer.start();
	
func _on_timer_timeout():
	var foodIncome = 0;
	var foodConsumption = 0;
	var medicineIncome = 0;
	var moneyIncome = 0;
	var childNodes = get_node("../TestWorld").get_children();
	for node in childNodes:
		if node.name == "Navigation":
			var navigationChildren = node.get_children();
			for navNode in navigationChildren:
				if navNode is Unit:
					# Here we want to check what buildings the villagers are working in and increment a counter for each type
					if navNode.team == 0:
						foodConsumption += 1;
						if navNode.isFoodWorker == true:
							foodIncome += 1;
						if navNode.isMedicalWorker == true:
							medicineIncome += 1;
						if navNode.isMoneyWorker == true:
							moneyIncome += 1;

	# TODO: Remove these print statements when we get a UI showing these food values
	print("Food at start of hour: %s" % food);
	food -= foodConsumption;
	food += foodIncome;
	print("Food after the hour passes: %s" % food);
	print("Medicine at start of hour: %s" % medicine);
	medicine += medicineIncome;
	print("Medicine after the hour passes: %s" % medicine);
	print("Money at start of hour: %s" % money);
	money += moneyIncome;
	print("Money after the hour passes: %s" % money);
