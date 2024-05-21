extends RigidBody2D

enum ANIMAL_STATE {READY, DRAG, RELEASE}


const DRAG_LIMIT_MAX: Vector2 = Vector2(0, 60)
const DRAG_LIMIT_MIN: Vector2 = Vector2(-60, 0)
const IMPULSE_MULT: float = 20.0
const IMPULSE_MAX: float = 1200


var _start: Vector2 = Vector2.ZERO
var _drag_start: Vector2 = Vector2.ZERO
var _dragged_vector: Vector2 = Vector2.ZERO
var _last_dragged_vector: Vector2 = Vector2.ZERO
var _arrow_scale_x: float = 0.0

var _state: ANIMAL_STATE = ANIMAL_STATE.READY

@onready var label = $Label
@onready var strecth_sound = $StrecthSound
@onready var arrow = $Arrow
@onready var launch_sound = $LaunchSound
@onready var animation_player = $AnimationPlayer

func _ready():
	_arrow_scale_x = arrow.scale.x
	arrow.hide()
	_start = position

func _physics_process(delta):
	
	label.text = "%s" % ANIMAL_STATE.keys()[_state]
	label.text += "%.1f,%.1f" % [_dragged_vector.x, _dragged_vector.y]
	
	update(delta)
	pass

func get_impulse() -> Vector2:
	return _dragged_vector * -1 * IMPULSE_MULT

func _on_screen_exited():
	_die()
	pass
	
func _die():
	SignalManager.on_animal_died.emit()
	set_physics_process(false)
	queue_free()

func set_drag():
	_drag_start = get_global_mouse_position()
	arrow.show()

func start_rotation(imp: Vector2):
	var perc = imp.length() / IMPULSE_MULT
	animation_player.speed_scale = perc * 0.1
	animation_player.play("rotation")

func set_release():
	arrow.hide()
	freeze = false
	var imp = get_impulse()
	start_rotation(imp)
	apply_central_impulse(imp)
	
	launch_sound.play()
	
func set_new_state(new_state: ANIMAL_STATE) -> void:
	_state = new_state
	if _state == ANIMAL_STATE.RELEASE:
		set_release()
	elif _state == ANIMAL_STATE.DRAG:
		set_drag()
	
func detect_release() -> bool:
	if _state == ANIMAL_STATE.DRAG:
		if Input.is_action_just_released("drag") == true:
			set_new_state(ANIMAL_STATE.RELEASE)
			return true
	return false
	
func get_dragged_vector(gmp: Vector2) -> Vector2:
	return gmp - _drag_start

func scale_arrow() -> void:
	var imp_len = get_impulse().length()
	var perc = imp_len / IMPULSE_MAX
	
	arrow.scale.x = (_arrow_scale_x * perc) + _arrow_scale_x
	
	arrow.rotation = (_start - position).angle()
	
func play_stretched_sound() -> void:
	if (_last_dragged_vector - _dragged_vector).length() > 0:
		if !strecth_sound.playing:
			strecth_sound.play()

func drag_in_limits():
	_last_dragged_vector = _dragged_vector
	
	_dragged_vector.x = clampf(
		_dragged_vector.x,
		 DRAG_LIMIT_MIN.x, 
		DRAG_LIMIT_MAX.x
	)
	
	_dragged_vector.y = clampf(
		_dragged_vector.y,
		 DRAG_LIMIT_MIN.y, 
		DRAG_LIMIT_MAX.y
	)
	
	position = _start + _dragged_vector

func update_drag():
	if detect_release():
		return
	
	var gmp = get_global_mouse_position()
	_dragged_vector = get_dragged_vector(gmp)
	play_stretched_sound()
	drag_in_limits()
	scale_arrow()
	
func update(delta: float) -> void:
	match  _state:
		ANIMAL_STATE.DRAG:
			update_drag()
		


func _on_input_event(viewport, event: InputEvent, shape_idx):
	if _state == ANIMAL_STATE.READY and event.is_action_pressed("drag"):
			set_new_state(ANIMAL_STATE.DRAG)
		
		
	
