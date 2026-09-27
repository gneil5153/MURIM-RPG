extends Control
@export var player_path: NodePath
var player
var touch_origin := Vector2.ZERO
var touch_position := Vector2.ZERO
var move_touch := -1

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
            queue_redraw()
        elif not event.pressed and event.index == move_touch:
            move_touch = -1
            player.set_move_vector(Vector2.ZERO)
            queue_redraw()
    elif event is InputEventScreenDrag and event.index == move_touch:
        touch_position = event.position
        player.set_move_vector((touch_position - touch_origin).limit_length(65.0) / 65.0)
        queue_redraw()

func _on_attack_pressed(): Input.action_press("attack"); await get_tree().process_frame; Input.action_release("attack")
func _on_dodge_pressed(): Input.action_press("dodge"); await get_tree().process_frame; Input.action_release("dodge")
func _on_sprint_button_down(): Input.action_press("sprint")
func _on_sprint_button_up(): Input.action_release("sprint")
