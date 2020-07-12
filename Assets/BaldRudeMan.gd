extends Spatial
var baldManLimbAnimations={};
func _start():
	var limbAnim;
	for animation in baldManLimbAnimations.keys():
		limbAnim=baldManLimbAnimations.get(animation);
		limbAnim.get_animation(animation).set_loop(true);
		limbAnim.play(animation);

func _stop():
	for animation in baldManLimbAnimations.keys():
		baldManLimbAnimations.get(animation).stop();

func _ready():
	for cube in self.get_children():
		for animation in cube.get_children():	
			baldManLimbAnimations[animation.get_animation_list()[0]]=animation;
