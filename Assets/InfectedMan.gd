extends Spatial

var infectedManLimbAnimations={};

func _start():
	var limbAnim;
	for animation in infectedManLimbAnimations.keys():
		limbAnim=infectedManLimbAnimations.get(animation);
		limbAnim.get_animation(animation).set_loop(true);
		limbAnim.play(animation);

func _stop():
	for animation in infectedManLimbAnimations.keys():
		infectedManLimbAnimations.get(animation).stop();

func _ready():
	for cube in self.get_children():
		for animation in cube.get_children():	
			infectedManLimbAnimations[animation.get_animation_list()[0]]=animation;
