extends Node

export(String, FILE, "*.txt") var words_file
export(NodePath) var projectile_manager_path
export(NodePath) var player_path

const ENEMEY_RESOURCE = preload("res://actor/enemy/Enemy.tscn")
const BULLET_RESOURCE = preload("res://actor/projectile/Bullet.tscn")

onready var projectile_manager = get_tree().get_root().find_node("ProjectileManager", true, false)
onready var spawn_timer = $SpawnTimer as Timer

var rng = RandomNumberGenerator.new()

# Contains a mapping between a text and an enemy target.
var text_targets = {}

# Contains a mappings between first letter and active text for targets.
var active_words = {}

# Organizes words by letter.
var alpha_map = {}

var _current_target = null
onready var _player = get_node(player_path)

# Called when the node enters the scene tree for the first time.
func _ready():
  read_dictionary()
  rng.randomize()
  spawn_timer.connect("timeout", self, "spawn_enemy")
  spawn_timer.start()
  _player.connect("engage_shot_event", self, "process_engage_event")

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
  var index = rng.randi_range(0, words.size() - 1)
  return words[index]

func available_first_letter() -> String:
  var max_tries = 100
  for _try in range(max_tries):
    var letter = char(rng.randi_range(ord("a"), ord("z")))
    if not active_words.has(letter):
      return letter
  print("Could not find available first letter")
  return ""

func process_engage_event(event):
  if event as InputEventKey and event.is_pressed() and not event.echo:
    if event.scancode >= KEY_A and event.scancode <= KEY_Z:
      var event_letter = char(event.scancode).to_lower()
      if _current_target == null:
        var word = active_words.get(event_letter)
        if word != null:
          handle_acquire_target(word)
      else:
        handle_continue_hit_target(event_letter)

func handle_acquire_target(word:String):
  assert(_current_target == null)
  _current_target = text_targets[word]
  _player.aimed_target = _current_target
  if _current_target.hit(word[0]) == Enemy.HIT:
    spawn_bullet(_current_target)

func handle_continue_hit_target(letter:String):
  assert(_current_target != null)
  var hit_result = _current_target.hit(letter)
  if hit_result == Enemy.HIT or hit_result == Enemy.COMPLETED:
      spawn_bullet(_current_target)
  if hit_result == Enemy.COMPLETED:
      remove_enemy(_current_target.text())
      _current_target = null
      _player.aimed_target = null

func spawn_bullet(target):
  var to_target = _player.get_angle_to(target.position)
  projectile_manager.spawn_projectile(BULLET_RESOURCE, _player.position, to_target)

func random_point_in_view():
  var view_rect = get_viewport().get_visible_rect()
  var random_x = rng.randf_range(view_rect.position.x, view_rect.end.x)
  var random_y = rng.randf_range(view_rect.position.y, view_rect.end.y)
  return Vector2(random_x, random_y)

func create_enemy(word:String) -> Node2D:
  var enemy = ENEMEY_RESOURCE.instance()
  add_child(enemy)
  enemy.set_text(word)
  enemy.position = random_point_in_view()
  return enemy

func spawn_enemy():
  var letter = available_first_letter()
  if not letter.empty():
    var word = random_word(letter)
    active_words[letter] = word
    text_targets[word] = create_enemy(word)

func remove_enemy(word):
  var enemy = text_targets.get(word)
  if enemy != null:
    active_words.erase(word[0])
    text_targets.erase(word)
    enemy.queue_free()
