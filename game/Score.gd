extends Node

# Stores the typing score result for completing a text target.
class TargetScore:
  var typing_score:int = 0
  var speed_bonus:int = 0
  var super_bonus:int = 0
  var position:Vector2 = Vector2.ZERO

export(int) var score_per_letter = 10
export(int) var score_miss_penalty = 20
export(int) var speed_score_multiplier = 3
export(float) var time_per_letter = 0.11
export(int) var min_length_super_bonus = 14
export(int) var super_bonus = 1000

export(int) var high_streak_limit = 200
export(int) var silver_streak_limit = 400
export(int) var gold_streak_limit = 800

var score:int = 0 setget _set_score

signal score_changed(score)
signal scored_target(target_score)

func _set_score(value):
  score = value
  emit_signal("score_changed", score)

func update_score(target_stats:HitTracker.TypingStats, message_position:Vector2):
  var typing_score = _typing_score(target_stats)
  var speed_bonus = _speed_bonus_score(target_stats)
  var extra_bonus = _super_bonus(target_stats)
  score += typing_score + speed_bonus + extra_bonus

  var target_score = TargetScore.new()
  target_score.typing_score = typing_score
  target_score.speed_bonus = speed_bonus
  target_score.super_bonus = extra_bonus
  target_score.position = message_position

  emit_signal("scored_target", target_score)
  emit_signal("score_changed", score)

func _typing_score(stats:HitTracker.TypingStats) -> int:
  var base_score = (pow(stats.text_length, 1.2) * score_per_letter) as int
  var miss_penalty = (stats.keypress_count - stats.text_length) * score_miss_penalty
  return base_score - miss_penalty

func _speed_bonus_score(stats:HitTracker.TypingStats) -> int:
  var min_time_required = pow(stats.text_length * time_per_letter, 1.2)
  var is_fast = stats.time_to_complete < min_time_required
  var requirements_met = is_fast and stats.text_length > 4
  return speed_score_multiplier * pow(stats.text_length, 1.2) if requirements_met else 0

func _super_bonus(stats:HitTracker.TypingStats) -> int:
  var is_fast = stats.time_to_complete < 1.4 * pow(stats.text_length * time_per_letter, 1.2)
  var is_perfect = stats.text_length == stats.keypress_count
  var is_impressive = stats.text_length > min_length_super_bonus and is_perfect and is_fast
  return super_bonus if is_impressive else 0
