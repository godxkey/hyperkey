extends Node

export(int) var score_per_letter = 10
export(int) var score_miss_penalty = 20
export(int) var speed_score_multiplier = 3
export(float) var time_per_letter = 0.11
export(int) var min_length_super_bonus = 14
export(int) var super_bonus = 1000

# A score message is displayed whenever a target is killed.
export(PackedScene) var score_message_scene

var _score = 0

signal score_changed(score)

# All levels should be under a node named World
func world_root():
  return get_node("/root/World")

func camera_shake():
  return world_root().get_node("Player/Camera2D/CameraShake")

func play_impact_camera_shake():
  camera_shake().shake(0.14, 24.0, 14.0, 1)

func play_strong_impact_camera_shake():
  camera_shake().shake(0.20, 24.0, 18.0, 2)

func view_center() -> Vector2:
  return world_root().get_node("Player/Camera2D").global_position

func update_score(text_length:int, total_keypress_count:int, time_to_complete:float, message_position:Vector2):
  var typing_score = _typing_score(text_length, total_keypress_count)
  var speed_bonus = _speed_bonus_score(text_length, time_to_complete)
  var extra_bonus = _super_bonus(text_length, total_keypress_count, time_to_complete)
  _score += typing_score + speed_bonus + extra_bonus
  _show_score_message(typing_score, speed_bonus, extra_bonus, message_position)
  emit_signal("score_changed", _score)

func _typing_score(text_length:int, total_keypress_count:int) -> int:
  var base_score = (pow(text_length, 1.2) * score_per_letter) as int
  var miss_penalty = (total_keypress_count - text_length) * score_miss_penalty
  return base_score - miss_penalty

func _speed_bonus_score(text_length:int, time_to_complete:float) -> int:
  var is_fast = time_to_complete < pow(text_length * time_per_letter, 1.2)
  return speed_score_multiplier * pow(text_length, 1.2) if is_fast and text_length > 4 else 0

func _super_bonus(text_length:int, total_keypress_count:int, time_to_complete:float) -> int:
  var is_fast = time_to_complete < 1.4 * pow(text_length * time_per_letter, 1.2)
  var is_impressive = text_length > min_length_super_bonus and text_length == total_keypress_count and is_fast
  return super_bonus if is_impressive else 0

func _show_score_message(typing_score:int, speed_bonus:int, extra_bonus:int, position:Vector2):
  var message = score_message_scene.instance()
  message.set_displayed_score(typing_score, speed_bonus)
  message.position = position
  message.move_angle = position.direction_to(view_center()).angle()
  # Add to self or another node? Could text still exist in AutoLoad if there is a scene transition mid score?
  add_child(message)
  _show_super_bonus(extra_bonus, position)

  if speed_bonus > 0:
    Sound.play("SpeedBonus")

func _show_super_bonus(extra_bonus:int, position:Vector2):
  if extra_bonus > 0:
    var super_message = score_message_scene.instance()
    super_message.positive_score_color = Color.gold
    super_message.position = position
    super_message.score_prefix = "+"
    super_message.move_angle = position.direction_to(view_center()).rotated(0.5).angle()
    super_message.move_offset = 140
    super_message.set_displayed_score(extra_bonus, 0)
    add_child(super_message)
    Sound.play("SuperBonus")
