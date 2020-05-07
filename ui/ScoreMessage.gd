extends "res://ui/FadedMessage.gd"

export(Color) var positive_score_color
export(Color) var negative_score_color
export(Color) var bonus_color

export(String) var score_prefix = "+"
export(String) var bonus_prefix = "+"

func set_displayed_score(score:int, bonus:int):
  var score_label = $UI/Score
  score_label.modulate = positive_score_color if score > 0 else negative_score_color
  score_label.text = score_prefix + String(score) if score > 0 else String(score)

  var bonus_label = $UI/Bonus
  bonus_label.modulate = bonus_color
  bonus_label.text = bonus_prefix + String(bonus) if bonus > 0 else ""