extends Area

class_name Target

export var label_offset:float = 20.0

var label_path:NodePath

func _process(_delta):
  _track_label()

func set_stats(text:TypistText):
  $Health.hit_points = text.merged_text().length()

func label():
  return get_node(label_path)

func on_hit():
  label().increment_cursor()

func text() -> TypistText:
  return label().display_text

func set_attack_target_path(_path):
  pass

# Update the label position so it tracks the target.
func _track_label():
  if label_path:
    var camera = get_viewport().get_camera()
    if camera:
      var l = get_node(label_path)
      l.rect_position = camera.unproject_position(global_transform.origin)
      l.rect_position.x -= l.rect_size.x / 2.0 # Center label
      l.rect_position.y += label_offset # Offset so it does not occlude target

func _on_killed():
  # Override in extended classes.
  pass
