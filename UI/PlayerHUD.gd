extends Node

class_name PlayerHUD

var statsGrid: Node
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

# Called when the node enters the scene tree for the first time.
func _ready():
	statsGrid = $HBoxContainer/VBoxStats/MarginStatsInfo/ScrollContainerInfo/GridStatsInfo
	selectedLabel = $HBoxContainer/VBoxSelectedItem/LabelSelectedItem
	selectedIcon = $HBoxContainer/VBoxSelectedItem/MarginContainer/TextureRect
	timeLabel = $VBoxContainer/TimeLabel
	villagerLabel = $VBoxContainer/VillagerLabel
	foodLabel = $VBoxContainer/FoodLabel
	medicineLabel = $VBoxContainer/MedicineLabel
	moneyLabel = $VBoxContainer/MoneyLabel
	unitTexture = load("res://Resources/UnitIcon.JPG")
	buildingTexture = load("res://Resources/BuildingIcon.JPG")
	
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
	#var statsGrid = get_node("/root/TestWorld/Control/HBoxContainer/VBoxStats/MarginStatsInfo/GridStatsInfo")
	
	# clear current labels
	for child in statsGrid.get_children():
		statsGrid.remove_child(child)
	
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
		
	selectedLabel.text = ""
	(selectedIcon as TextureRect).texture = null


func _on_CamControl_buildingSelected(objects):
	# clear current labels
	for child in statsGrid.get_children():
		statsGrid.remove_child(child)
		
	# get all relevant properties
	selectedIcon.texture = buildingTexture
	selectedLabel.text = "Building"
	for object in objects:
		var label = Label.new()
		(label as Label).text = "Building: " + object.buildingType
		(statsGrid as GridContainer).add_child(label)
		label = Label.new()
		(label as Label).text = "Health: " + str(object.hp) + " / " + str(object.hpMax)
		(statsGrid as GridContainer).add_child(label)
		label = Label.new()
		(label as Label).text = "Workers: " + str(object.currentWorkers) + " / " + str(object.maxWorkers)
		(statsGrid as GridContainer).add_child(label)
