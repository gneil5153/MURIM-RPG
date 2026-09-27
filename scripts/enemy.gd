extends CharacterBody3D
@export var health := 100.0
@export var speed := 3.2
@export var aggro_range := 12.0
var target: Node3D
func _physics_process(delta):
    if target and global_position.distance_to(target.global_position) < aggro_range:
        var d = target.global_position - global_position; d.y = 0
        velocity = d.normalized() * speed
        move_and_slide()
func hit(damage: float):
    health -= damage
    if health <= 0: queue_free()
