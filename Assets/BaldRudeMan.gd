extends Spatial

func _ready():
	var firstAnimation;
	for cube in self.get_children():
		for animation in cube.get_children():
			firstAnimation=animation.get_animation_list()[0];
			animation.play(firstAnimation);
