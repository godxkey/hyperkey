extends Area2D
class_name BaseTarget, "res://icons/base_actor_icon.png"

var label_path:NodePath

func set_stats(text:TypistText):
  $Health.hit_points = text.merged_text().length()
  $FollowTarget.max_speed /= text.text_list.size()
  $FollowTarget.acceleration /= text.text_list.size()

func label():
  return get_node(label_path)

func on_hit():
  label().increment_cursor()

func text() -> TypistText:
  return label().display_text

func set_as_active_target():
  label().set_top_z()

func follow(other:Node2D):
  var ft = $FollowTarget
  ft.target = other
  ft.set_velocity(ft.max_speed * global_position.direction_to(other.global_position))
