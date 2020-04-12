class_name Enemy

extends KinematicBody2D

enum {HIT, NO_HIT, COMPLETED}

onready var label = find_node("TextLabel")
var _hit_cursor:int = 0

func set_text(text:String):
  label.raw_text = text

func text() -> String:
  return label.raw_text

func hit(letter:String) -> int:
  if _hit_cursor < text().length() and letter == text()[_hit_cursor]:
    label.increment_cursor()
    _hit_cursor += 1
    if _hit_cursor == text().length():
      return COMPLETED
    return HIT
  return NO_HIT
