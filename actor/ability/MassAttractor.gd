extends Area2D

export var attraction_strength:float = 1000.0
export var duration:float = 5.0
export var tangent_strength:float = 10.0
var targets_to_attract := []

func _ready():
  var timer = $Timer
  timer.wait_time = duration
  timer.one_shot = true

  $Tween.interpolate_property(
    $Center,
    "scale",
    Vector2.ONE,
    Vector2.ZERO,
    duration,
    Tween.TRANS_ELASTIC,
    Tween.EASE_OUT_IN)

  $Tween.interpolate_property(
    $Ring,
    "scale",
    Vector2.ONE,
    Vector2.ZERO,
    duration,
    Tween.TRANS_ELASTIC,
    Tween.EASE_OUT_IN)

func _process(_delta):
  for target in targets_to_attract:
    var attraction = attraction_force(target)
    target.motion.apply_force(attraction)
    target.motion.apply_force(tangent_force(attraction, target))

# Calculates the tangential force on the target object.
# Ensures that the tangential force is aligned with the incoming velocity.
func tangent_force(attraction:Vector2, other) -> Vector2:
  var tangent = tangent_strength * attraction.tangent()
  var dot = tangent.dot(other.motion.get_velocity())
  var direction = 1.0 if dot > 0 else -1.0
  return tangent * direction

func attraction_force(other) -> Vector2:
  var to_center = other.position.direction_to(position)
  var distance = other.position.distance_to(position)
  return to_center * attraction_strength / max(1.0, distance * 0.05)

func _on_MassAttractor_area_entered(other):
  if other.is_in_group("BaseActor"):
    if not is_under_attraction(other):
      targets_to_attract.append(other)
      # If the target dies inside the ability, then remove from processing list.
      other.connect("tree_exiting", self, "_remove_target", [other], CONNECT_ONESHOT)

# Once attracted, do not let go.
func _on_MassAttractor_area_exited(_other):
  pass
  # _remove_target(other)

func _remove_target(target):
  targets_to_attract.erase(target)

func is_under_attraction(target):
  return targets_to_attract.has(target)

func _on_Timer_timeout():
  queue_free()
