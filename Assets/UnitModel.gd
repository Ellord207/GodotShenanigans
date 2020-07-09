extends Spatial

onready var top = $Cone
onready var bottom = $Cone001
onready var animationTop = $Cone/AnimationPlayer;
onready var animationBottom = $Cone001/AnimationPlayer;
class_name UnitModel

func _ready() -> void:
	animationBottom.get_animation("Cone.001Action.002").set_loop(true);
	animationTop.get_animation("ConeAction.002").set_loop(true);
	randomize()
	var offset : float = rand_range(0, animationBottom.get_animation("Cone.001Action.002").length)
	animationBottom.advance(offset);
	animationTop.advance(offset);

func material_override(material: SpatialMaterial) -> void:
	top.material_override = material
	bottom.material_override = material

func animation_start() -> void:
	animationBottom.play("Cone.001Action.002");
	animationTop.play("ConeAction.002");

func animation_stop(reset: bool) -> void:
	animationBottom.stop(reset);
	animationTop.stop(reset);
	
