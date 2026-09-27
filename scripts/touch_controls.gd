extends Control
@export var player_path: NodePath
var player
var touch_origin := Vector2.ZERO
var touch_position := Vector2.ZERO
var move_touch := -1
var sprint_button_down := false
var stick_sprinting := false

func _ready():
	player = get_node(player_path)
	queue_redraw()

func _draw():
	var base := Vector2(112.0, size.y - 116.0)
	var knob := base
	if move_touch != -1:
		knob = base + (touch_position - touch_origin).limit_length(43.0)
	draw_circle(base, 67.0, Color(0.04, 0.07, 0.09, 0.34))
	draw_arc(base, 65.0, 0.0, TAU, 48, Color(0.78, 0.83, 0.84, 0.46), 3.0)
	draw_circle(knob, 27.0, Color(0.75, 0.82, 0.83, 0.55))

func _unhandled_input(event):
    if event is InputEventScreenTouch:
        if event.pressed and event.position.x < size.x * 0.42 and event.position.y > size.y * 0.48 and move_touch == -1:
            move_touch = event.index
            touch_origin = Vector2(112.0, size.y - 116.0)
            touch_position = event.position
            stick_sprinting = false
            _update_sprint_action()
            queue_redraw()
        elif not event.pressed and event.index == move_touch:
            move_touch = -1
            stick_sprinting = false
            player.set_move_vector(Vector2.ZERO)
            _update_sprint_action()
            queue_redraw()
    elif event is InputEventScreenDrag and event.index == move_touch:
        touch_position = event.position
        var stick_delta: Vector2 = touch_position - touch_origin
        player.set_move_vector(stick_delta.limit_length(45.0) / 45.0)
        stick_sprinting = stick_delta.length() >= 36.0
        _update_sprint_action()
        queue_redraw()

func _update_sprint_action():
	if sprint_button_down or stick_sprinting:
		Input.action_press("sprint")
	else:
		Input.action_release("sprint")

func _on_attack_pressed():
	Input.action_press("attack")
	await get_tree().process_frame
	Input.action_release("attack")

func _on_dodge_pressed():
	Input.action_press("dodge")
	await get_tree().process_frame
	Input.action_release("dodge")

func _on_sprint_button_down():
	sprint_button_down = true
	_update_sprint_action()

func _on_sprint_button_up():
	sprint_button_down = false
	_update_sprint_action()
