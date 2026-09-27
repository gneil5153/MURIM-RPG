extends CharacterBody3D

@export var speed := 7.0
@export var sprint_speed := 10.5
@export var acceleration := 24.0
@export var dodge_speed := 16.0
@export var max_qi := 100.0
@export var attack_range := 2.6
@export var attack_damage := 20.0
var touch_move := Vector2.ZERO
var touch_sprinting := false
var qi := 100.0
var dodge_time := 0.0
var attack_cooldown := 0.0
var combo_step := 0
@onready var camera_pivot: Node3D = $CameraPivot

func _ready():
    qi = max_qi

func _physics_process(delta):
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    if touch_move.length() > 0.12:
        input = touch_move
    var forward := -camera_pivot.global_transform.basis.z; forward.y = 0; forward = forward.normalized()
    var right := camera_pivot.global_transform.basis.x; right.y = 0; right = right.normalized()
    # Input.get_vector returns negative Y for the "move_forward" action.
    var dir := (right * input.x - forward * input.y).normalized()
    if Input.is_action_just_pressed("dodge"): dodge()
    if Input.is_action_just_pressed("attack"): attack()
    var running := (touch_sprinting or Input.is_action_pressed("sprint")) and qi > 1.0 and input.length() > 0.12
    var base_speed := sprint_speed if running else speed * input.length()
    if running:
        qi = maxf(0.0, qi - 6.0 * delta)
    else:
        qi = minf(max_qi, qi + 10.0 * delta)
    var target_speed := dodge_speed if dodge_time > 0.0 else base_speed
    dodge_time = maxf(0.0, dodge_time - delta)
    velocity.x = move_toward(velocity.x, dir.x * target_speed, acceleration * delta)
    velocity.z = move_toward(velocity.z, dir.z * target_speed, acceleration * delta)
    # Keep camera yaw independent of the moving body.
    if dir.length() > 0.1:
        $Mesh.rotation.y = lerp_angle($Mesh.rotation.y, atan2(-dir.x, -dir.z), 12.0 * delta)
    if not is_on_floor(): velocity.y -= 24.0 * delta
    move_and_slide()

func attack():
    if attack_cooldown > 0.0: return
    attack_cooldown = 0.32
    combo_step = (combo_step % 3) + 1
    for body in $AttackArea.get_overlapping_bodies():
        if body != self and body.has_method("take_damage"):
            body.take_damage(attack_damage + (combo_step - 1) * 5.0)

func set_move_vector(v: Vector2) -> void:
    touch_move = v.limit_length(1.0)
    if touch_move.length() < 0.12:
        touch_move = Vector2.ZERO

func dodge() -> void:
    if qi >= 15.0 and dodge_time <= 0.0:
        qi -= 15.0
        dodge_time = 0.22
