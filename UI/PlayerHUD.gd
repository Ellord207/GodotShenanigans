extends Node

class_name PlayerHUD

var statsGrid : Node
var commandsGrid : Node
var selectedLabel : Node
var selectedIcon : Node

# village resource labels
var timeLabel
var villagerLabel
var foodLabel
var medicineLabel
var moneyLabel

var unitTexture
var buildingTexture
var plotTexture

var canDeselect = true

var buttonWorkerMap = {}
var plotButtonMap = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	statsGrid = $HBoxContainer/VBoxStats/MarginStatsInfo/ScrollContainerInfo/GridStatsInfo
	commandsGrid = $HBoxContainer/VBoxCommands/MarginCommands/GridCommands
	selectedLabel = $HBoxContainer/VBoxSelectedItem/LabelSelectedItem
	selectedIcon = $HBoxContainer/VBoxSelectedItem/MarginContainer/TextureRect
	timeLabel = $VBoxContainer/TimeLabel
	villagerLabel = $VBoxContainer/VillagerLabel
	foodLabel = $VBoxContainer/FoodLabel
	medicineLabel = $VBoxContainer/MedicineLabel
	moneyLabel = $VBoxContainer/MoneyLabel
	unitTexture = load("res://Resources/UnitIcon.JPG")
	buildingTexture = load("res://Resources/BuildingIcon.JPG")
	plotTexture = load("res://Resources/PlotIcon.JPG")
	
	VillageManager.connect("villageTick", self, "updateVillageResources")
	
	timeLabel.text = "Day: " + str(VillageManager.day) + ", Time: " + str(VillageManager.time) + ":00"
	villagerLabel.text = "Villagers: " + str(VillageManager.villagers.size())
	foodLabel.text = "Food: " + str(VillageManager.food)
	medicineLabel.text = "Medicine: " + str(VillageManager.medicine)
	moneyLabel.text = "Money: " + str(VillageManager.money)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func updateVillageResources(village):
	timeLabel.text = "Day: " + str(village.day) + ", Time: " + str(village.time) + ":00"
	villagerLabel.text = "Villagers: " + str(village.villagers.size())
	foodLabel.text = "Food: " + str(village.food)
	medicineLabel.text = "Medicine: " + str(village.medicine)
	moneyLabel.text = "Money: " + str(village.money)

func _on_CamControl_unitSelected(objects):
	
	var tree = get_tree()
	
	# clear current labels
	for child in statsGrid.get_children():
		statsGrid.remove_child(child)
	for child in commandsGrid.get_children():
		commandsGrid.remove_child(child)
	
	# get all relevant properties
	var type = objects[0].get_class()
	if type == "KinematicBody":
		selectedLabel.text = "Unit"
		selectedIcon.texture = unitTexture
	
	for object in objects:
		var label = Label.new()
		(label as Label).text = "Name: " + object.name
		(statsGrid as GridContainer).add_child(label)
		label = Label.new()
		(label as Label).text = "Health: " + str(object.hp)
		(statsGrid as GridContainer).add_child(label)
		label = Label.new()
		(label as Label).text = "Speed: " + str(object.move_speed)
		(statsGrid as GridContainer).add_child(label)
		label = Label.new()
		(label as Label).text = "Team: " + str(object.team)
		(statsGrid as GridContainer).add_child(label)


func _on_CamControl_deselected():
	for child in statsGrid.get_children():
		statsGrid.remove_child(child)
		
	for child in commandsGrid.get_children():
		commandsGrid.remove_child(child)
		
	selectedLabel.text = ""
	(selectedIcon as TextureRect).texture = null


func _on_CamControl_buildingSelected(objects):
	# subscribe to building ui event
	objects[0].connect("updateUI", self, "updateUI")
	
	# clear current labels
	for child in statsGrid.get_children():
		statsGrid.remove_child(child)
		
	for child in commandsGrid.get_children():
		commandsGrid.remove_child(child)
		
	# get all relevant properties
	for object in objects:
		if object.type == "building":
			selectedIcon.texture = buildingTexture
			selectedLabel.text = "Building"
			var label = Label.new()
			(label as Label).text = "Building: " + object.buildingType
			(statsGrid as GridContainer).add_child(label)
			label = Label.new()
			(label as Label).text = "Health: " + str(object.hp) + " / " + str(object.hpMax)
			(statsGrid as GridContainer).add_child(label)
			label = Label.new()
			(label as Label).text = "Workers: " + str(object.currentWorkers) + " / " + str(object.maxWorkers)
			(statsGrid as GridContainer).add_child(label)
			for worker in object.workers:
				var button = Button.new()
				(button as Button).text = worker.name
				button.connect("pressed", self, "buttonPressed", [button])
				commandsGrid.add_child(button)
				buttonWorkerMap[button] = [worker, object]
		if object.type == "EmptyPlot":
			selectedIcon.texture = plotTexture
			selectedLabel.text = "Empty Plot"
			
			# add plot command options
			var button = Button.new()
			button.text = "Buy Farm"
			button.connect("pressed", self, "plotButtonPressed", [button])
			commandsGrid.add_child(button)
			plotButtonMap[button] = [object, "Farm"]
			button = Button.new()
			button.text = "Buy Bank"
			button.connect("pressed", self, "plotButtonPressed", [button])
			commandsGrid.add_child(button)
			plotButtonMap[button] = [object, "Bank"]
			button = Button.new()
			button.text = "Buy Hospital"
			button.connect("pressed", self, "plotButtonPressed", [button])
			commandsGrid.add_child(button)
			plotButtonMap[button] = [object, "Hospital"]
			button = Button.new()
			button.text = "Buy Jail"
			button.connect("pressed", self, "plotButtonPressed", [button])
			commandsGrid.add_child(button)
			plotButtonMap[button] = [object, "Jail"]
			

func buttonPressed(button):
	buttonWorkerMap[button][1].leaveBuilding(buttonWorkerMap[button][0])
	buttonWorkerMap.erase(button)
	commandsGrid.remove_child(button)
	
func plotButtonPressed(button):
	plotButtonMap[button][0].purchaseBuilding(plotButtonMap[button][1])

func updateUI(object):
	print("Update UI signal called");

func _on_Control_mouse_entered():
	canDeselect = true

func _on_Control_mouse_exited():
	canDeselect = false
