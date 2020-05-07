extends Node

export(String, FILE, "*.txt") var words_file
export(NodePath) var projectile_manager_path
export(NodePath) var player_path

onready var _player = get_node(player_path)
onready var _projectile_manager = get_node(projectile_manager_path)
onready var _spawner = get_node("Spawner")
onready var _mistype_player = $MistypePlayer

var _text_targets := TextTargets.new()
var _text_generator := TextGenerator.new()
var _current_tracker:HitTracker = null

var _total_keypresses:int = 0
var _total_keyhits:int = 0
var _max_key_history:int = 100

var _active_stats = {}

signal keyhits_stat_changed(hits, total)
signal key_missed

func create_tracker(target) -> HitTracker:
  var label = target.find_node("TypistLabel", true, false)
  return HitTracker.new(target, label)

# Called when the node enters the scene tree for the first time.
func _ready():
  _text_generator.word_dictionary = WordDictionary.new(words_file)
  _spawner.timer.connect("timeout", self, "spawn_target")
  _spawner.timer.start()

func _process(delta):
  if _current_tracker:
    _current_tracker.process(delta)

func available_first_letter() -> String:
  var max_tries = 100
  for _try in max_tries:
    var letter = _text_generator.random_letter()
    if not _text_targets.has_letter(letter):
      return letter
  return ""

func _input(event):
  if event as InputEventKey and event.is_pressed() and not event.echo:
    if event.scancode >= KEY_A and event.scancode <= KEY_Z:
      var input_letter = char(event.scancode).to_lower()
      _attack_letter(input_letter)

func _attack_letter(letter:String):
  if _current_tracker == null:
    var text = _text_targets.text(letter)
    if text != null:
      acquire_target(text)
    else:
      _mistype_player.play()
  else:
    continue_hit_target(letter)

func acquire_target(text:String):
  assert(_current_tracker == null)
  var target = _text_targets.target(text)
  _player.aimed_target = target
  _current_tracker = create_tracker(target)

  # draw over other targets in scene
  target.z_index += 1

  _total_keypresses += 1

  var result = _current_tracker.hit(text[0])
  if result.is_hit:
    spawn_bullet(target)
    _total_keyhits += 1
  emit_signal("keyhits_stat_changed", _total_keyhits, _total_keypresses)
  shift_down_keyhit_stats()

func continue_hit_target(letter:String):
  assert(_current_tracker != null)
  _total_keypresses += 1
  var result = _current_tracker.hit(letter)
  if result.is_hit:
      var target = _current_tracker.get_target()
      spawn_bullet(target, result.hit_completed_word)
      _total_keyhits += 1
      if _current_tracker.is_done():
          _active_stats[target] = _current_tracker.stats()
          clear_tracked()
  else:
    _mistype_player.play()
    emit_signal("key_missed")
  emit_signal("keyhits_stat_changed", _total_keyhits, _total_keypresses)
  shift_down_keyhit_stats()

# Reduces key hit stats so players can regain higher accuracy.
# If we keep absolute stats, then after many, many key presses,
# it will would take an enternity to reach high accuracy again.
func shift_down_keyhit_stats():
  if _total_keyhits >= _max_key_history:
    _total_keyhits /= 2
    _total_keypresses /= 2

func spawn_bullet(target, is_critical:bool = false):
  var bullet = _projectile_manager.spawn_projectile(_player.position, target)
  bullet.critical_hit = is_critical
  target.connect("tree_exiting", bullet, "queue_free")

func create_target(text:TypistText) -> Node2D:
  var target = _spawner.spawn_text_target(text, _select_spawn_type(text))
  target.connect(
    "tree_exiting",
    self,
    "remove_exited_target",
    [text.merged_text(), weakref(target)],
    CONNECT_ONESHOT)
  target.get_node("Health").connect(
    "no_health",
    self,
    "show_target_score",
    [weakref(target)],
    CONNECT_ONESHOT)
  add_child(target)
  return target

func _select_spawn_type(text:TypistText) -> String:
  return "Asteroid" if text.text_list.size() == 1 else "AsteroidCluster"

func spawn_target():
  var letter = available_first_letter()
  if not letter.empty():
    var text:TypistText = _text_generator.random_text(letter)
    _text_targets.add_text_target(text.merged_text(), create_target(text))
  _spawner.randomize_spawn_timer()

func show_target_score(target_wref):
  var target = target_wref.get_ref()
  if target:
    var stats = _active_stats[target]
    _active_stats.erase(target)
    GameEvent.update_score(
      stats.text_length,
      stats.keypress_count,
      stats.time_to_complete,
      target.global_position)

func remove_target_word(text:String):
  _text_targets.remove_text_target(text)

func clear_tracked():
  assert(_current_tracker != null)
  remove_target_word(_current_tracker.text())
  _current_tracker.remove_label()
  _current_tracker = null
  _player.aimed_target = null

func remove_exited_target(text:String, target_wref):
  var target = target_wref.get_ref()
  if _text_targets.target(text) == target:
    if _current_tracker and _current_tracker.text() == text:
      clear_tracked()
      # Remove any tracked stats if found.
      _active_stats.erase(target)
    else:
      remove_target_word(text)
