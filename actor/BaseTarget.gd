extends Area2D
class_name BaseTarget, "res://icons/base_actor_icon.png"

onready var health = $Health as Health
onready var sprite = $Sprite as Sprite
onready var motion = $FollowTarget as FollowTarget

func set_text(text:TypistText):
  $TypistLabel/Label.display_text = text
  $Health.hit_points = text.merged_text().length()
  $FollowTarget.max_speed /= text.text_list.size()
  $FollowTarget.acceleration /= text.text_list.size()
  _on_text_set(text)

# Extended classes implement this to apply custom behavior based on the text.
func _on_text_set(_text:TypistText):
  pass

func label_location():
  return $TypistLabel
