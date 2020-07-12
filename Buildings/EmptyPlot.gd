extends Spatial

var type = "EmptyPlot"

var building = preload("building.gd") # Relative path

# Called when the node enters the scene tree for the first time.
func _ready():
	$BuildingOrigin/Building.allBuildingVisibility(false)
	pass # Replace with function body.

func select() -> void:
	if $SelectionRing == null:
		$BuildingForSaleSign/SelectionRing.show()
	else:
		$SelectionRing.show()
	
func deselect() -> void:
	if $SelectionRing == null:
		$BuildingForSaleSign/SelectionRing.hide()
	else:
		$SelectionRing.hide()

func purchaseBuilding(type):
	$BuildingOrigin/Building.setBuildingType(type)
	$Wall1.visible = false
	$Wall2.visible = false
	$Wall3.visible = false
	$Wall4.visible = false
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
