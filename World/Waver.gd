extends Navigation


var time_between_waves:= 4;
var time_till_wave:= time_between_waves;
var wave_size:=20;

var list_o_spawner = [];

func _ready():
	VillageManager.connect("villageTick", self, "create_wave");

func create_wave(arg):
	time_till_wave-=1;
	if time_till_wave > 0:
		return;
	time_till_wave = time_between_waves;
	var points = get_tree().get_nodes_in_group("infected_spawn");
	if points.size() == 0:
		return;
	for i in range(20):
		var point = points[randi() % points.size() - 1];
		point.queue_spawn(self);
	wave_size += 10;
