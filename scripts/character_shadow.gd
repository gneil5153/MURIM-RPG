extends Node2D

var lift := 0.0

func set_lift(value: float) -> void:
    lift = maxf(0.0, value)
    queue_redraw()

func _draw() -> void:
    var height := clampf(lift / 46.0, 0.0, 1.0)
    var opacity := 1.0 - height * 0.58
    var scale_x := lerpf(1.0, 0.73, height)
    draw_set_transform(Vector2(0, 5), 0.0, Vector2(scale_x, 0.56))
    draw_circle(Vector2.ZERO, 21.0, Color(0.035, 0.055, 0.10, 0.12 * opacity))
    draw_circle(Vector2.ZERO, 15.0, Color(0.025, 0.04, 0.075, 0.17 * opacity))
    draw_circle(Vector2.ZERO, 9.0, Color(0.015, 0.025, 0.05, 0.16 * opacity))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
