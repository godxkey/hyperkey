extends Area

class_name Target

export var label_offset:float = 20.0

# A weak reference is used because labels are not owned by the Target.
# Labels exist in a canvas layer since they are a UI element, and may
# be moved to another canvas layer if they become the active label.
# We apply manual tracking so the label appears to follow the Target.
var label_ref:WeakRef = WeakRef.new()

func _process(_delta):
  _track_label()

func set_stats(text:TypistText):
  $Health.reset_health(text.merged_text().length())
  _set_stats(text)

# Virtual
func _set_stats(_text:TypistText):
  pass

func hide_label():
  var l = label_ref.get_ref()
  if l:
    l.hide()

# Extended classes can override to apply custom behavior
func _on_damage_taken(_hit_points):
  pass

# Triggers when the target is hit with the correct letter.
func on_hit():
  var l = label_ref.get_ref()
  if l:
    l.increment_cursor()

func text() -> TypistText:
  var l = label_ref.get_ref()
  return l.display_text if l else null

# Update the label position so it tracks the target.
func _track_label():
  var label = label_ref.get_ref()
  if label:
    var camera = get_viewport().get_camera()
    if camera and label:
      label.rect_position = camera.unproject_position(global_transform.origin)
      label.rect_position.x -= label.rect_size.x / 2.0 # Center label
      label.rect_position.y += label_offset # Offset so it does not occlude target


# @tags - virtual
func set_attack_target(_target):
  pass

# @tags - virtual
func _on_killed():
  # Override in extended classes.
  pass
