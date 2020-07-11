extends Node

class_name PlayerHUD

var statsGrid: Node
var selectedLabel : Node
var selectedIcon : Node

var unitTexture

# Called when the node enters the scene tree for the first time.
func _ready():
	statsGrid = $HBoxContainer/VBoxStats/MarginStatsInfo/ScrollContainerInfo/GridStatsInfo
	selectedLabel = $HBoxContainer/VBoxSelectedItem/LabelSelectedItem
	selectedIcon = $HBoxContainer/VBoxSelectedItem/MarginContainer/TextureRect
	unitTexture = load("res://Resources/UnitIcon.JPG")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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
