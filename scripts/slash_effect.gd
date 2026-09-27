extends Node2D

var elapsed := 0.0
func restart() -> void:
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
    draw_arc(Vector2(0, -19), 37.0, -1.22, 1.15, 16, Color(0.29, 0.91, 0.87, alpha), 4.0, true)
    draw_arc(Vector2(0, -19), 43.0, -1.15, 0.93, 14, Color(0.88, 1.0, 0.88, alpha * 0.85), 2.0, true)
