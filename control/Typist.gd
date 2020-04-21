extends Node

export(String, FILE, "*.txt") var words_file
export(NodePath) var projectile_manager_path
export(NodePath) var player_path
export(NodePath) var planet_path

onready var _planet = get_node(planet_path)
onready var _player = get_node(player_path)
onready var _projectile_manager = get_node(projectile_manager_path)
onready var _spawner = $Spawner as Spawner
onready var _mistype_player = $MistypePlayer

const LABEL_SCENE = preload("res://ui/TypistLabel.tscn")

var _rng = RandomNumberGenerator.new()

# Contains a mapping between a text and an enemy target.
var text_targets = {}

# Contains a mappings between first letter and active text for targets.
var active_words = {}

# Organizes words by letter.
var alpha_map = {}

var _current_tracker:HitTracker = null

class HitTracker:
  var _target = null setget ,get_target
  var _label = null
  var _hit_cursor:int = 0

  func _init(target, label):
    _target = target
    _label = label

  func get_target():
    return _target

  func text() -> String:
    return _label.word_text

  func is_done() -> bool:
    return _hit_cursor == text().length()

  func remove_label():
    _label.queue_free()

  func get_cursor() -> int:
    return _hit_cursor

  func hit(letter:String) -> bool:
    if _hit_cursor < text().length() and letter == text()[_hit_cursor]:
      _label.increment_cursor()
      _hit_cursor += 1
      return true
    return false

func create_tracker(target) -> HitTracker:
  var label = target.find_node("TypistLabel", true, false)
  return HitTracker.new(target, label)

# Called when the node enters the scene tree for the first time.
func _ready():
  read_dictionary()
  _rng.randomize()
  _spawner.timer.connect("timeout", self, "spawn_target")
  _spawner.timer.start()

func read_dictionary():
  var file = File.new()
  file.open(words_file, File.READ)
  assert(file.is_open())
  alpha_map.clear()

  var min_word_length = 4
  while not file.eof_reached():
    var line = file.get_line()
    if line.length() >= min_word_length:
      _add_to_alpha_map(line)
  file.close()

func _add_to_alpha_map(word:String):
  var first_letter = word[0]
  var word_list = alpha_map.get(first_letter)
  if word_list == null:
    alpha_map[first_letter] = [word]
  else:
    word_list.append(word)

func random_word(first_letter) -> String:
  var words = alpha_map[first_letter]
  var index = _rng.randi_range(0, words.size() - 1)
  return words[index]

func available_first_letter() -> String:
  var max_tries = 100
  for _try in range(max_tries):
    var letter = char(_rng.randi_range(ord("a"), ord("z")))
    if not active_words.has(letter):
      return letter
  print("Could not find available first letter")
  return ""

func _input(event):
  if event as InputEventKey and event.is_pressed() and not event.echo:
    if event.scancode >= KEY_A and event.scancode <= KEY_Z:
      var event_letter = char(event.scancode).to_lower()
      if _current_tracker == null:
        var word = active_words.get(event_letter)
        if word != null:
          acquire_target(word)
        else:
          _mistype_player.play()
      else:
        continue_hit_target(event_letter)

func acquire_target(word:String):
  assert(_current_tracker == null)
  var target = text_targets[word]
  _player.aimed_target = target
  _current_tracker = create_tracker(target)
  if _current_tracker.hit(word[0]):
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

func create_target(word:String) -> Node2D:
  var target = _spawner.spawn()
  var label = LABEL_SCENE.instance()
  var zcontrol = Node2D.new()

  zcontrol.add_child(label)
  target.add_child(zcontrol)
  add_child(target)

  zcontrol.name = "ZControl"
  zcontrol.z_index = 1000
  zcontrol.position.y = 30.0
  label.word_text = word
  target.health.hit_points = word.length()
  target.motion.start_moving_towards(_player.position)

  var max_speed = target.motion.max_speed
  var starting_speed = _rng.randf_range(0.2 * max_speed, 0.8 * max_speed)
  target.motion.set_speed(starting_speed)

  target.motion.target = _player
  target.connect("tree_exiting", self, "remove_exited_target_word", [word], CONNECT_ONESHOT)
  return target

func spawn_target():
  var letter = available_first_letter()
  if not letter.empty():
    var word = random_word(letter)
    active_words[letter] = word
    text_targets[word] = create_target(word)

func remove_target_word(word:String):
  active_words.erase(word[0])
  text_targets.erase(word)

func clear_tracked():
  assert(_current_tracker != null)
  remove_target_word(_current_tracker.text())
  _current_tracker.remove_label()
  _current_tracker = null
  _player.aimed_target = null

func remove_exited_target_word(word:String):
  if _current_tracker and _current_tracker.text() == word:
    clear_tracked()
  else:
    remove_target_word(word)
