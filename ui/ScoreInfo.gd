extends QuickInfo

export(Color) var positive_score_color = Color("00ffb7")
export(Color) var negative_score_color = Color("ff5252")
export(Color) var bonus_color = Color("60a5ff")

export(String) var score_prefix = "+"
export(String) var bonus_prefix = "+"

var score:int = 0 setget _set_score
var bonus_score:int = 0 setget _set_bonus_score

func _set_score(value:int):
  score = value
  var label = $Labels/Score
  label.modulate = positive_score_color if score > 0 else negative_score_color
  label.text = score_prefix + String(score) if score > 0 else String(score)

func _set_bonus_score(value:int):
  bonus_score = value
  var label = $Labels/Bonus
  label.modulate = bonus_color
  label.text = bonus_prefix + String(bonus_score) if bonus_score > 0 else ""