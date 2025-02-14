class_name SequenceDecoder extends Node2D

const SPELL_SEQUENCE_LENGTH_MAX = 5
const SEQUENCE_INPUTS = ["left", "right", "up", "down"]

## A Dictionart with the keycode as key and spell as value. {"left right" : DamageSpell}
@export var keycodes: Dictionary:
	get: return _keycodes
	set(value):
		_keycodes = value

static var _keycodes: Dictionary

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
		var keycode = get_random_keycode()
		while _keycodes.has(keycode):
			keycode = get_random_keycode()
		_keycodes[keycode] = spell
		

static func get_random_keycode():
	var keycode = ""
	for i in range(randi_range(1, SPELL_SEQUENCE_LENGTH_MAX - 1)):
		keycode += SEQUENCE_INPUTS.pick_random()
		if i != SPELL_SEQUENCE_LENGTH_MAX - 2:
			keycode += ""
	return keycode
