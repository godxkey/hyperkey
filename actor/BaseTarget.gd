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

func label_location():
  return $TypistLabel
