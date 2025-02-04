class_name ResourcePool extends Node2D
## A class implementing a resourcepool, - health, stamina, mana, oxygen etc.

## To use add the resourcepool Node to an object. Name the pool something
## relevant.
## The resourcepool can be added to and removed of by any _amount through
## add_to and remove_from methods.
## It can be depleted and replenished by an _amount per second through
## the start/stop replenish/depletion methods.
## Additional settings for controll and dependencies are given in the inspector
## as exported variables

#region Variables
## Signal for ANY change in the _amount
signal resource_amount_changed
signal resource_amount_increased
signal resource_amount_decreased

signal resource_reached_max
signal resource_reached_min

## Signal from adding fixed amounts of resources
## Differs from the "_amount increased"- and "_amount decreased"
## signals by only being emited when a fixed _amount is added externally
signal resource_amount_added
## Signal from removing fixed amounts of resources
## Differs from the "_amount increased"- and "_amount decreased"
## signals by only being emited when a fixed _amount is added externally
signal resource_amount_removed

@export var has_max_amount: bool = true
@export var has_min_amount: bool = true
@export var max_amount: float = 100
@export var min_amount: float = 0
## Base growth in unit/seconds. Always applied unless other parameters tell it not to.
@export var base_growth: float = 10
## Base decay in unit/seconds. Always applied unless other parameters tell it not to.
@export var base_decay: float = 10

## ACTIVE
## If growth should be enabled
@export var enable_growth: bool = true
## If decay should be enabled	
@export var enable_decay: bool = false

@export var _amount: float = 100

var amount: float:
	get: return get_amount()
	set(value):
		if value > _amount:
			add_to_pool(value-_amount)
		elif value < _amount:
			remove_from_pool(_amount-value)
		else:
			return


var _pause_growth: bool = false
var _pause_decay: bool = false


var _pause_growth_timer : Timer
var _pause_decay_timer : Timer


#endregion

func _ready():

	_pause_growth_timer = Timer.new()
	_pause_growth_timer.one_shot = true
	add_child(_pause_growth_timer)

	_pause_decay_timer = Timer.new()
	_pause_decay_timer.one_shot = true
	add_child(_pause_decay_timer)

func _process(delta):
	_grow_and_decay(delta)


## Method for getting the _amount of resource in the pool
func get_amount() -> float:
	return _amount


## Method to be used externaly for adding to resourcepool
func add_to_pool(amount_to_add: float) -> void:
	_increase_amount(amount_to_add)
	resource_amount_added.emit()


## Method to be used externaly for removing from resourcepool
func remove_from_pool(amount_to_remove: float) -> void:
	_decrease_amount(amount_to_remove)
	resource_amount_removed.emit()


## Pauses the resource for the given time
func pause_for(time: float) -> void:
	pause_decay_for(time)
	pause_growth_for(time)


## Pauses the resource for the given time
func pause_growth_for(time: float) -> void:
	_pause_growth = true
	_pause_growth_timer.start(time)
	await _pause_growth_timer.timeout
	_pause_growth = false


## Pauses the resource for the given time
func pause_decay_for(time: float) -> void:
	_pause_decay = true
	_pause_decay_timer.start(time)
	await _pause_decay_timer.timeout
	_pause_decay = false


## Check if has amount
func has_amount(p_amount: float):
	return amount >= p_amount

## Internal method for increasing the _amount until reached max if given
func _increase_amount(amount_to_add: float) -> void:
	# If passed negative value raise error
	assert(amount_to_add >= 0)
	
	if amount_to_add == 0:
		return
	
	# If no max _amount add, emit signal and return
	if not has_max_amount:
		_amount += amount_to_add
		resource_amount_changed.emit()
		return
	
	# If _amount already at max do nothing
	if _amount == max_amount:
		return
	
	# Add _amount and emit signal
	_amount += amount_to_add
	resource_amount_changed.emit()
	
	# If _amount is maxed (or above) emit signal and reduce to max
	if _amount >= max_amount:
		_amount = max_amount
		resource_reached_max.emit()


## Internal method for decreasing the _amount until reached min if given
func _decrease_amount(amount_to_subtract: float) -> void:
	# If passed negative value raise error
	assert(amount_to_subtract >= 0)
	
	if amount_to_subtract == 0:
		return
	
	# If no min _amount subtract, emit signal and return
	if not has_min_amount:
		_amount -= amount_to_subtract
		resource_amount_changed.emit()
		return
	
	
	# If _amount already at min do nothing
	if _amount == min_amount:
		return
	# Decay
	
	# Subtract _amount and emit signal
	_amount -= amount_to_subtract
	resource_amount_changed.emit()
	
	# If _amount is at minimum (or below) emit signal and increase to min
	if _amount <= min_amount:
		_amount = min_amount
		resource_reached_min.emit()



## Process for growing and decaying resource pool
func _grow_and_decay(delta) -> void:
	# Growth
	if enable_growth and not _pause_growth:
		_increase_amount((base_growth) * delta)
	# Decay
	if enable_decay and not _pause_growth:
		_decrease_amount((base_decay) * delta)
