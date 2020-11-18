extends Area2D
class_name Bullet

signal target_hit

onready var follow = $FollowTarget

export var hit_effect:PackedScene

var _is_near := false

func _ready():
  # Prevent repetitive trails by preprocessing the particles.
  $Trail.preprocess = rand_range(1, 10)

func _on_hit(object_hit):
  var target = follow.target
  if object_hit and object_hit == target:
    emit_signal("target_hit", target)
    Sound.play("Hit")
    Effect.play_impact_effect(hit_effect, global_position, follow.get_velocity().angle())
    $Damage.apply_damage(target)
    queue_free()

func _on_near(near_object):
  if not _is_near:
    var target = follow.target
    if near_object and near_object == target:
      # Increase homing acceleration so bullet does not miss target.
      follow.acceleration *= 20.0
      _is_near = false

func _process(_delta):
  set_rotation(follow.get_velocity().angle())

func _exit_tree():
  Effect.release_effect($Trail)
