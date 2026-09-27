extends Control
@export var player_path: NodePath
var player
var touch_origin := Vector2.ZERO
var move_touch := -1

func _ready(): player = get_node(player_path)
func _unhandled_input(event):
    if event is InputEventScreenTouch:
        if event.pressed and event.position.x < size.x * 0.5 and move_touch == -1:
            move_touch = event.index; touch_origin = event.position
        elif not event.pressed and event.index == move_touch:
            move_touch = -1; player.set_move_vector(Vector2.ZERO)
    elif event is InputEventScreenDrag and event.index == move_touch:
        player.set_move_vector((event.position - touch_origin).limit_length(110.0) / 110.0)
func _on_attack_pressed(): Input.action_press("attack"); await get_tree().process_frame; Input.action_release("attack")
func _on_dodge_pressed(): Input.action_press("dodge"); await get_tree().process_frame; Input.action_release("dodge")
func _on_sprint_button_down(): Input.action_press("sprint")
func _on_sprint_button_up(): Input.action_release("sprint")
