extends CharacterBody3D

@export var speed := 7.0
@export var sprint_speed := 10.5
@export var acceleration := 34.0
@export var braking := 42.0
@export var air_control := 12.0
@export var turn_rate := 13.0
@export var dodge_speed := 16.0
@export var max_qi := 100.0
@export var attack_range := 2.6
@export var attack_damage := 20.0
var touch_move := Vector2.ZERO
var touch_sprinting := false
var stick_active := false
var stick_world_direction := Vector3.FORWARD
var dodge_lean := Vector3.ZERO
var qi := 100.0
var dodge_time := 0.0
var attack_cooldown := 0.0
var combo_step := 0
var facing := Vector3.FORWARD
var dodge_direction := Vector3.FORWARD
var dodge_cooldown := 0.0
var jump_buffer := 0.0
var coyote_time := 0.0
var jump_hold_time := 0.0
var jump_held := false
var attack_anim := 0.0
var landing_impact := 0.0
var turn_lean := 0.0
var checkpoint_position := Vector3.ZERO
@export var jump_velocity := 8.0
var attack_visual: Node3D
var attack_tween: Tween
@onready var camera_pivot: Node3D = $CameraPivot

func _ready():
    qi = max_qi
    checkpoint_position = global_position
    attack_visual = Node3D.new()
    add_child(attack_visual)
    var fist := MeshInstance3D.new()
    var shape := BoxMesh.new()
    shape.size = Vector3(0.38, 0.38, 1.15)
    fist.mesh = shape
    attack_visual.position = Vector3(0.0, 1.2, -0.85)
    fist.position = Vector3(0.35, 0.05, -0.55)
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(1.0, 0.75, 0.25)
    material.emission_enabled = true
    material.emission = Color(0.7, 0.35, 0.05)
    fist.material_override = material
    attack_visual.add_child(fist)
    attack_visual.visible = false

func _physics_process(delta):
    if global_position.y < -6.0:
        global_position = checkpoint_position
        velocity = Vector3.ZERO
        dodge_time = 0.0
    dodge_cooldown = maxf(0.0, dodge_cooldown - delta)
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    if touch_move.length() > 0.12:
        input = touch_move
    var forward := -camera_pivot.global_transform.basis.z; forward.y = 0; forward = forward.normalized()
    var right := camera_pivot.global_transform.basis.x; right.y = 0; right = right.normalized()
    # Input.get_vector returns negative Y for the "move_forward" action.
    var input_strength := clampf(input.length(), 0.0, 1.0)
    var dir := (right * input.x - forward * input.y).normalized() if input_strength > 0.01 else Vector3.ZERO
    if is_on_floor():
        coyote_time = 0.12
    else:
        coyote_time = maxf(0.0, coyote_time - delta)
    if Input.is_action_just_pressed("dodge"): dodge()
    if Input.is_action_just_pressed("attack"): attack()
    if Input.is_action_just_pressed("jump"):
        jump()
        jump_held = true
    if Input.is_action_just_released("jump"):
        jump_released()
    jump_buffer = maxf(0.0, jump_buffer - delta)
    attack_anim = maxf(0.0, attack_anim - delta * 4.0)
    landing_impact = maxf(0.0, landing_impact - delta * 3.0)
    if jump_buffer > 0.0 and (is_on_floor() or coyote_time > 0.0):
        velocity.y = jump_velocity
        jump_buffer = 0.0
        coyote_time = 0.0
        jump_hold_time = 0.0
    var sprint_button := Input.is_action_pressed("sprint") and qi > 1.0
    var stick_run := touch_move.length() > 0.12 and qi > 1.0
    var run_blend := clampf(inverse_lerp(0.58, 1.0, input_strength), 0.0, 1.0) if stick_run else (1.0 if sprint_button else 0.0)
    var base_speed := lerpf(speed, sprint_speed, run_blend) * input_strength
    var running := run_blend > 0.05 and input_strength > 0.12
    if running:
        qi = maxf(0.0, qi - lerpf(4.0, 8.0, run_blend) * delta)
    else:
        qi = minf(max_qi, qi + 10.0 * delta)
    var was_airborne := not is_on_floor()
    var previous_yaw := $Mesh.rotation.y
    if dodge_time > 0.0:
        velocity.x = dodge_direction.x * dodge_speed
        velocity.z = dodge_direction.z * dodge_speed
        var local_dodge: Vector3 = Basis(Vector3.UP, $Mesh.rotation.y).inverse() * dodge_direction
        dodge_lean = Vector3(clampf(local_dodge.z * 0.32, -0.32, 0.32), 0.0, clampf(-local_dodge.x * 0.3, -0.3, 0.3))
        dodge_time = maxf(0.0, dodge_time - delta)
    else:
        dodge_lean = Vector3.ZERO
        var horizontal := Vector3(velocity.x, 0.0, velocity.z)
        if dir.length_squared() > 0.0:
            var control := acceleration if not was_airborne else air_control
            var lateral := horizontal - dir * horizontal.dot(dir)
            horizontal -= lateral * minf(1.0, (14.0 if not was_airborne else 2.2) * delta)
            var target := dir * base_speed
            horizontal = horizontal.move_toward(target, control * delta)
        else:
            horizontal = horizontal.move_toward(Vector3.ZERO, (braking if not was_airborne else air_control * 0.6) * delta)
        velocity.x = horizontal.x
        velocity.z = horizontal.z
    # Keep camera yaw independent of the moving body.
    if dir.length_squared() > 0.0 and dodge_time <= 0.0:
        var target_yaw := atan2(-dir.x, -dir.z)
        $Mesh.rotation.y = rotate_toward($Mesh.rotation.y, target_yaw, turn_rate * delta)
        facing = Vector3(-sin($Mesh.rotation.y), 0.0, -cos($Mesh.rotation.y))
    turn_lean = clampf(wrapf($Mesh.rotation.y - previous_yaw, -PI, PI) * -1.8, -0.34, 0.34)
    if not is_on_floor():
        if jump_held and velocity.y > 0.0 and jump_hold_time < 0.16:
            jump_hold_time += delta
            velocity.y -= 9.0 * delta
        else:
            velocity.y -= 24.0 * delta
    move_and_slide()
    if was_airborne and is_on_floor():
        landing_impact = 1.0
        jump_held = false
    if is_on_floor() and global_position.y > -1.0:
        checkpoint_position = global_position

func attack():
    if attack_cooldown > 0.0: return
    attack_cooldown = 0.32
    combo_step = (combo_step % 3) + 1
    attack_anim = 1.0
    attack_visual.visible = true
    attack_visual.rotation.y = atan2(-facing.x, -facing.z) - 0.65
    if attack_tween:
        attack_tween.kill()
    attack_tween = create_tween()
    attack_tween.tween_property(attack_visual, "rotation:y", attack_visual.rotation.y + 1.3, 0.22)
    attack_tween.tween_callback(func(): attack_visual.visible = false)
    for body in get_tree().get_nodes_in_group("damageable"):
        var offset: Vector3 = body.global_position - global_position
        offset.y = 0.0
        if offset.length() <= attack_range and (offset.length() < 0.1 or facing.dot(offset.normalized()) >= 0.35):
            body.take_damage(attack_damage + (combo_step - 1) * 5.0)

func set_move_vector(v: Vector2) -> void:
    touch_move = v.limit_length(1.0)
    stick_active = touch_move.length() >= 0.12
    if not stick_active:
        touch_move = Vector2.ZERO
        return
    var forward := -camera_pivot.global_transform.basis.z
    forward.y = 0.0
    forward = forward.normalized()
    var right := camera_pivot.global_transform.basis.x
    right.y = 0.0
    right = right.normalized()
    stick_world_direction = (right * touch_move.x - forward * touch_move.y).normalized()
    facing = stick_world_direction

func jump() -> void:
    jump_buffer = 0.15
    jump_held = true

func jump_released() -> void:
    jump_held = false
    if velocity.y > jump_velocity * 0.48:
        velocity.y = jump_velocity * 0.48

func dodge() -> void:
    if qi >= 15.0 and dodge_cooldown <= 0.0:
        qi -= 15.0
        dodge_time = 0.22
        dodge_cooldown = 0.55
        var body_forward: Vector3 = -$Mesh.global_transform.basis.z
        body_forward.y = 0.0
        body_forward = body_forward.normalized()
        dodge_direction = stick_world_direction if stick_active else -body_forward
