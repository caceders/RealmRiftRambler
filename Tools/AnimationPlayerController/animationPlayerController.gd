class_name AnimationPlayerController extends AnimationPlayer

## A node for controlling the AnimatedSpriteController easily. Can smoothly play base animations and sudden overlay animations.


# region private variables
var _base_animation: String

var _current_overlay_animation_priority: int = 0
var _is_playing_overlay_animation: bool = false
var _overlay_animation_queue: Array[OverlayAnimation]
# endregion


# region built-in virtual _ready method
func _ready():
    animation_finished.connect(_on_animation_finished)
# endregion


# region remaining built-in virtual methods
func _process(_add_constant_forcedelta):
    if not is_playing() and _base_animation != "":
        play(_base_animation)
# endregion


# region public methods
## Change the base animation to be playing.
func play_base_animation(base_animation_name: String):
    self._base_animation = base_animation_name
    if not _is_playing_overlay_animation:
        play(_base_animation)

## Play an overlay animation and return to the base animation when finish. Alternatively add the animation to queue. The queue will play
## in the order of priority until empty, then it will return tp the base animation.
func play_overlay_animation(overlay_animation: String, priority: int, join_queue: bool = false):
    if join_queue:
        if _overlay_animation_queue.is_empty() and not _is_playing_overlay_animation:
            play(overlay_animation)
            _is_playing_overlay_animation = true
        else:
            _overlay_animation_queue.append(OverlayAnimation.new(overlay_animation, priority))
            _overlay_animation_queue.sort_custom(_sort_animation_priority)
    
    else:
        if priority > _current_overlay_animation_priority:
            play(overlay_animation)
            _is_playing_overlay_animation = true
            _current_overlay_animation_priority = priority

# endregion


# region private methods
func _on_animation_finished(_param):
    if not _overlay_animation_queue.is_empty():
        var next_animation = _overlay_animation_queue.pop_front()
        _current_overlay_animation_priority = next_animation.priority
        play(next_animation)
    else:
        _is_playing_overlay_animation = false
        play(_base_animation)
        _current_overlay_animation_priority = 0


func _sort_animation_priority(a: OverlayAnimation, b: OverlayAnimation):
    if a.priority < b.priority: return true
    return false
# endregion


# region subclasses
class OverlayAnimation:
    var name: String
    var priority: int

    func _init(p_name, p_priority):
        self.name = p_name
        self.priority = p_priority
# endregion