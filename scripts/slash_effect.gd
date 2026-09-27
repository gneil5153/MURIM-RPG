extends Node2D

var elapsed := 0.0
var current_style := 0
func restart(style: int = 0) -> void:
    current_style = style
    elapsed = 0.0
    set_process(true)
    queue_redraw()
func _process(delta: float) -> void:
    elapsed += delta
    if elapsed >= 0.19:
        visible = false
        set_process(false)
    else:
        queue_redraw()
func _draw() -> void:
    var alpha := 1.0 - elapsed / 0.19
    if current_style == 0:
        # Quick, tight forward cut.
        draw_arc(Vector2(0, -19), 35.0, -1.2, 1.12, 12, Color(0.29, 0.91, 0.87, alpha), 4.0, false)
        draw_arc(Vector2(0, -19), 41.0, -1.05, 0.82, 10, Color(0.88, 1.0, 0.88, alpha * 0.8), 2.0, false)
    elif current_style == 1:
        # Longer rising cut, highlighted with a second trail and pixel sparks.
        draw_arc(Vector2(0, -23), 44.0, -2.45, 0.18, 14, Color(1.0, 0.77, 0.34, alpha), 5.0, false)
        draw_arc(Vector2(0, -23), 51.0, -2.25, 0.0, 12, Color(1.0, 0.94, 0.68, alpha * 0.85), 2.0, false)
        draw_rect(Rect2(-27, -61, 5, 5), Color(1.0, 0.9, 0.57, alpha))
        draw_rect(Rect2(22, -49, 4, 4), Color(1.0, 0.9, 0.57, alpha))
    else:
        # Qi spin sweeps around the player and can hit targets on every side.
        draw_arc(Vector2.ZERO, 57.0, -0.25, TAU - 0.25, 20, Color(0.48, 0.78, 1.0, alpha), 5.0, false)
        draw_arc(Vector2.ZERO, 64.0, 0.1, TAU + 0.1, 20, Color(0.88, 0.97, 1.0, alpha * 0.8), 2.0, false)
