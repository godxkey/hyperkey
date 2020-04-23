extends Node

export(String, FILE, "*.txt") var words_file
export(NodePath) var projectile_manager_path
export(NodePath) var player_path

onready var _player = get_node(player_path)
onready var _projectile_manager = get_node(projectile_manager_path)
onready var _spawner = $Spawner as Spawner
onready var _mistype_player = $MistypePlayer

var _rng = RandomNumberGenerator.new()
var _text_targets := TextTargets.new()
var _word_dictionary := WordDictionary.new()
var _current_tracker:HitTracker = null

func create_tracker(target) -> HitTracker:
  var label = target.find_node("TypistLabel", true, false)
  return HitTracker.new(target, label)

# Called when the node enters the scene tree for the first time.
func _ready():
  _word_dictionary.read_dictionary(words_file)
  randomize() # Randomize the default generator as well
  _rng.randomize()
  _spawner.timer.connect("timeout", self, "spawn_target")
  _spawner.timer.start()

func random_text(first_letter:String) -> TypistText:
  var chance:float = _rng.randf() < 0.8
  var words:Array= [random_word(first_letter)] + ([] if chance else random_words())
  var t = TypistText.new()
  t.text_list = words
  return t

func random_word(first_letter:String) -> String:
  var words = _word_dictionary.words(first_letter)
  var index = _rng.randi_range(0, words.size() - 1)
  return words[index]

func random_words() -> Array:
  var words = []
  for _i in _rng.randi_range(1, 3):
    words.append(random_word(random_letter()))
  return words

func available_first_letter() -> String:
  var max_tries = 100
  for _try in max_tries:
    var letter = random_letter()
    if not _text_targets.has_letter(letter):
      return letter
  return ""

func random_letter() -> String:
  return char(_rng.randi_range(ord("a"), ord("z")))

func _input(event):
  if event as InputEventKey and event.is_pressed() and not event.echo:
    if event.scancode >= KEY_A and event.scancode <= KEY_Z:
      var input_letter = char(event.scancode).to_lower()
      if _current_tracker == null:
        var text = _text_targets.text(input_letter)
        if text != null:
          acquire_target(text)
        else:
          _mistype_player.play()
      else:
        continue_hit_target(input_letter)

func acquire_target(text:String):
  assert(_current_tracker == null)
  var target = _text_targets.target(text)
  _player.aimed_target = target
  _current_tracker = create_tracker(target)
  if _current_tracker.hit(text[0]):
    spawn_bullet(target)

func continue_hit_target(letter:String):
  assert(_current_tracker != null)
  if _current_tracker.hit(letter):
      spawn_bullet(_current_tracker.get_target())
      if _current_tracker.is_done():
          clear_tracked()
  else:
    _mistype_player.play()

func spawn_bullet(target):
  var bullet = _projectile_manager.spawn_projectile(_player.position, target)
  target.connect("tree_exiting", bullet, "queue_free")

func create_target(text:TypistText) -> Node2D:
  var target = _spawner.spawn_text_target(text)
  target.connect(
    "tree_exiting",
    self,
    "remove_exited_target",
    [text.merged_text(), weakref(target)],
    CONNECT_ONESHOT)
  add_child(target)
  return target

func spawn_target():
  var letter = available_first_letter()
  if not letter.empty():
    var text:TypistText = random_text(letter)
    _text_targets.add_text_target(text.merged_text(), create_target(text))

func remove_target_word(text:String):
  _text_targets.remove_text_target(text)

func clear_tracked():
  assert(_current_tracker != null)
  remove_target_word(_current_tracker.text())
  _current_tracker.remove_label()
  _current_tracker = null
  _player.aimed_target = null

func remove_exited_target(text:String, target_wref):
  if _text_targets.target(text) == target_wref.get_ref():
    if _current_tracker and _current_tracker.text() == text:
      clear_tracked()
    else:
      remove_target_word(text)
