extends Node2D

var health := 100.0
var reset_time := 0.0
var flash_time := 0.0
var hits := 0
func _ready() -> void:
    add_to_group("damageable")
    z_index = 0
func take_damage(amount: float) -> void:
    if health <= 0.0:
        return
    hits += 1
    health = maxf(0.0, health - amount)
    flash_time = 0.17
    if health <= 0.0:
        reset_time = 2.0
    queue_redraw()
func _process(delta: float) -> void:
    flash_time = maxf(0.0, flash_time - delta)
    if reset_time > 0.0:
        reset_time = maxf(0.0, reset_time - delta)
        if reset_time == 0.0:
            health = 100.0
    queue_redraw()
func _draw() -> void:
    draw_set_transform(Vector2(0, 16), 0.0, Vector2(1.0, 0.38))
    draw_circle(Vector2.ZERO, 19.0, Color(0.05, 0.08, 0.08, 0.4))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    var cloth := Color("#f4e6bd") if flash_time > 0.0 else Color("#a95d42")
    draw_rect(Rect2(-5, -38, 10, 50), Color("#382920"))
    draw_rect(Rect2(-17, -34, 34, 14), Color("#463126"))
    draw_rect(Rect2(-14, -32, 28, 9), cloth)
    draw_rect(Rect2(-11, -48, 22, 14), Color("#593a2b"))
    draw_rect(Rect2(-9, -46, 18, 10), Color("#c68159"))
    draw_rect(Rect2(-15, -8, 30, 5), Color("#704f35"))
    draw_rect(Rect2(-11, 0, 22, 5), Color("#473328"))
    draw_rect(Rect2(-4, -52, 8, 7), Color("#d8b76e"))
    draw_string(ThemeDB.fallback_font, Vector2(-36, -58), "%d/100" % int(health), HORIZONTAL_ALIGNMENT_CENTER, 72, 12, Color("#f2e6c8"))
