extends Area2D

export(int) var damage = 1
export(float) var rotation_speed = 1.0
onready var health = $Health as Health

onready var _cluster_root = $ClusterRoot

func _ready():
  health.connect("no_health", self, "queue_free")
  health.connect("critical_hit", self, "kill_random_subasteroid")
  connect("body_entered", self, "on_hit_body")

func _process(delta):
  _cluster_root.rotate(rotation_speed * delta)

func kill_random_subasteroid():
  var pick = randi() % _cluster_root.get_child_count()
  var child = _cluster_root.get_child(pick)
  GameEvent.play_impact_camera_shake()
  Sound.play("Break")
  Effect.play_explode_break(child.global_position)
  child.queue_free()

func on_hit_body(body):
  if body.is_in_group("planet"):
    body.health.apply_damage(damage)
    Effect.play_ground_explosion(global_position)
    GameEvent.play_strong_impact_camera_shake()
    queue_free()
