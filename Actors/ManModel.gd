extends Spatial


onready var model = $BaldRudeMan;
var is_running = false;

func animation_run():
	if not is_running:
		model._start();
		is_running = true;

func animation_stop():
	model._stop();
	is_running = false;
