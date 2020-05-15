extends Spawner
class_name TargetedSpawner, "res://icons/target_icon.png"

export(String) var target_key

func spawn(tick:SpawnTick) -> Node2D:
  var s = spawner.spawn(tick)
  var target = tick.blackboard.get(target_key).get_ref()
  if s and target:
    var follow = s.get_node("FollowTarget")
    if follow:
      follow.target = target
      var start_speed = rand_range(0.2 * follow.max_speed, 0.8 * follow.max_speed)
      follow.set_velocity(start_speed * s.position.direction_to(target.position))
  return s
