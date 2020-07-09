extends Spatial

onready var top = $Cone
onready var bottom = $Cone001

class_name UnitModel

func material_override(material: SpatialMaterial) -> void:
	top.material_override = material
	bottom.material_override = material
