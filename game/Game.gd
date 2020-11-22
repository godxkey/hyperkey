extends Node

export var main_dictionary:Resource

func _ready():
  randomize()
  main_dictionary.load_words()

func text_gen():
  return $TextGenerator
