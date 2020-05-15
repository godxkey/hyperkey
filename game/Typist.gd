extends Node

export(NodePath) var projectile_manager_path
export(NodePath) var planet_path
export(NodePath) var player_path

onready var _player = get_node(player_path)
onready var _projectile_manager = get_node(projectile_manager_path)
onready var _text_targets = $TextTargets
onready var _text_generator = $TextGenerator
onready var _spawner = $SpawnSystem

var _current_tracker:HitTracker = null
var spawn_tick := SpawnTick.new()

# Called when the node enters the scene tree for the first time.
func _ready():
  _text_generator.text_server.unused_letter_condition = funcref(self, "is_letter_unused")
  spawn_tick.blackboard["AttackTarget"] = weakref(get_node(planet_path))
  spawn_tick.blackboard["Typist"] = self

func _process(delta):
  if _current_tracker:
    _current_tracker.process(delta)
  var s = _spawner.spawn(spawn_tick)
  if s: add_child(s)

func _input(event):
  if event as InputEventKey and event.is_pressed() and not event.echo:
    if event.scancode >= KEY_A and event.scancode <= KEY_Z:
      var input_letter = char(event.scancode).to_lower()
      _attack_letter(input_letter)

func is_letter_unused(letter:String) -> bool:
  return not _text_targets.has_letter(letter)

func create_tracker(target) -> HitTracker:
  var label = target.find_node("TypistLabelRoot", true, false)
  # Current targeted label should render above others
  label.z_index += 1
  return HitTracker.new(target, label)

func _attack_letter(letter:String):
  if _current_tracker == null:
    var text = _text_targets.text(letter)
    if text != null:
      acquire_target(text)
    else:
      Stats.add_keypress()
      Stats.mistype()
  else:
    continue_hit_target(letter)

func acquire_target(text:String):
  assert(_current_tracker == null)
  var target = _text_targets.target(text)
  _player.aimed_target = target
  _current_tracker = create_tracker(target)
  Stats.add_keypress()
  var result = _current_tracker.hit(text[0])
  if result.is_hit:
    spawn_bullet(target)
    Stats.add_keyhit()

func continue_hit_target(letter:String):
  assert(_current_tracker != null)
  Stats.add_keypress()
  var result = _current_tracker.hit(letter)
  if result.is_hit:
      var target = _current_tracker.get_target()
      spawn_bullet(target, result.hit_completed_word)
      Stats.add_keyhit()
      if _current_tracker.is_done():
          Stats.set_stats(target, _current_tracker.stats())
          _clear_tracked()
  else:
    Stats.mistype_tracked(letter, _current_tracker.get_target())

func spawn_bullet(target, is_critical:bool = false):
  var bullet = _projectile_manager.spawn_projectile(_player.position, target)
  bullet.critical_hit = is_critical
  target.connect("tree_exiting", bullet, "queue_free")

# Generates any text that is not currently used in text targets.
# Beware that consecutive calls may generate the same word or with the same start letter.
# Client code should handle according to needs.
# It is recommended to use hand in hand with add_text_targets.
func generate_text() -> TypistText:
  return _text_generator.random_text()

# Add a text target. Text targets are game objects the player can type to shoot.
# Will fail if adding a text target with an already used starting letter.
# Empty text is not allowed and will fail.
func add_text_target(text:TypistText, target):
  var merged_text = text.merged_text()
  assert(not merged_text.empty())
  assert(not _text_targets.has_letter(merged_text[0]))
  target.connect(
    "tree_exiting",
    self,
    "_remove_exited_target",
    [merged_text, weakref(target)],
    CONNECT_ONESHOT)
  _text_targets.add_text_target(merged_text, target)

func _remove_target_word(text:String):
  _text_targets.remove_text_target(text)

func _clear_tracked():
  assert(_current_tracker != null)
  _remove_target_word(_current_tracker.text())
  _current_tracker.remove_label()
  _current_tracker = null
  _player.aimed_target = null

func _remove_exited_target(text:String, target_wref):
  var target = target_wref.get_ref()
  if _text_targets.target(text) == target:
    if _current_tracker and _current_tracker.text() == text:
      _clear_tracked()
    else:
      _remove_target_word(text)
