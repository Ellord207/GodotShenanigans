extends Spatial
var baldManLimbAnimations={};
func _start():
	for animation in baldManLimbAnimations.keys():
		baldManLimbAnimations.get(animation).play(animation);

func _stop():
	for animation in baldManLimbAnimations.keys():
		baldManLimbAnimations.get(animation).play_backwards(animation);

func _ready():
	for cube in self.get_children():
		for animation in cube.get_children():	
			baldManLimbAnimations[animation.get_animation_list()[0]]=animation;
