extends Node2D

var elapsed := 0.0
var duration := 0.55
var max_radius := 0.0

func _ready() -> void:
    set_process(false)

func restart(radius: float) -> void:
    max_radius = radius
    elapsed = 0.0
    visible = true
    set_process(true)
    queue_redraw()

func _process(delta: float) -> void:
    elapsed += delta
    if elapsed >= duration:
        visible = false
        set_process(false)
    else:
        queue_redraw()

func _draw() -> void:
    var progress := clampf(elapsed / duration, 0.0, 1.0)
    var radius := lerpf(18.0, max_radius, progress)
    var alpha := 1.0 - progress
    draw_circle(Vector2.ZERO, radius * 0.72, Color(1.0, 0.82, 0.34, alpha * 0.10))
    draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, Color(1.0, 0.91, 0.56, alpha), 6.0, false)
    draw_arc(Vector2.ZERO, radius * 0.91, 0.0, TAU, 36, Color(0.57, 0.91, 1.0, alpha * 0.85), 3.0, false)
    for ray in range(16):
        var angle := TAU * float(ray) / 16.0
        var direction := Vector2(cos(angle), sin(angle))
        draw_line(direction * radius * 0.66, direction * radius, Color(1.0, 0.96, 0.75, alpha * 0.82), 3.0, false)
    draw_circle(Vector2.ZERO, 24.0 * alpha, Color(1.0, 0.98, 0.82, alpha * 0.7))
