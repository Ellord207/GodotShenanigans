extends KinematicBody

const SPEED = 20;

var target: Spatial;

var speed: int = SPEED;

func _ready() -> void:
	pass;

func _physics_process(delta: float) -> void:
	if not target:
		self.queue_free();
		return;
	var vector = (target.global_transform.origin - self.global_transform.origin).normalized();
	look_at(target.transform.origin, Vector3.UP);
	var collision = self.move_and_collide(vector * SPEED * delta);
	if collision and collision.collider_id == target.get_instance_id():
		self.queue_free();
