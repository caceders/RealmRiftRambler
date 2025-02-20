class_name SequenceDecoder extends Node2D

const RANDOMIZE = false
const SPELL_SEQUENCE_LENGTH_MIN = 2
const SPELL_SEQUENCE_LENGTH_MAX = 5
const SEQUENCE_INPUTS = ["left", "right", "up", "down"]

## A Dictionart with the keycode as key and spell as value. {"left right" : DamageSpell}
@export var keycodes: Dictionary:
	get: return _keycodes
	set(value):
		_keycodes = value

static var _keycodes: Dictionary

func _ready():
	if RANDOMIZE:
		randomize_keycodes()

static func decode_keycode(keycode: String):
	if keycode in _keycodes:
		return _keycodes[keycode]
	else:
		return null

static func randomize_keycodes():
	var all_spells_to_re_keycode : Array[Spell] = []
	for keycode in _keycodes:
		var spell = _keycodes[keycode]
		all_spells_to_re_keycode.append(spell)
	_keycodes.clear()

	while not all_spells_to_re_keycode.is_empty():
		var spell = all_spells_to_re_keycode.pop_front()
		var keycode = get_random_keycode(spell.forced_keycode_length)

		while _keycodes.has(keycode):
			keycode = get_random_keycode(spell.forced_keycode_length)
		_keycodes[keycode] = spell
		

static func get_random_keycode(forced_length: int = 0):
	var keycode = ""
	var length = randi_range(SPELL_SEQUENCE_LENGTH_MIN, SPELL_SEQUENCE_LENGTH_MAX - 1)
	if forced_length != 0:
		length = forced_length
	for i in range(length):
		keycode += SEQUENCE_INPUTS.pick_random()
		if i != length - 1:
			keycode += " "
	return keycode
