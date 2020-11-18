extends Timer

# Kills parent when time is up.
# Life time is decided by parent or by MainEffect tag override.

# Optional override to select the main effect.
# If no child is in this group, then the parent is selected.
export var main_effect_group_tag := "MainEffect"

func _ready():
  var res = connect("timeout", get_parent(), "queue_free")
  assert(res == OK)
  var main_effect = _get_main_effect_child()
  wait_time = main_effect.lifetime if main_effect else get_parent().lifetime
  one_shot = true
  start()

func _get_main_effect_child():
  for child in get_parent().get_children():
    if child.is_in_group(main_effect_group_tag):
      return child
  return null

