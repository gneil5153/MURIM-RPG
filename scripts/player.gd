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
var facing := Vector3.FORWARD
var dodge_direction := Vector3.FORWARD
var dodge_cooldown := 0.0
var attack_visual: Node3D
var attack_tween: Tween
@onready var camera_pivot: Node3D = $CameraPivot

func _ready():
    qi = max_qi
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
    dodge_cooldown = maxf(0.0, dodge_cooldown - delta)
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    if touch_move.length() > 0.12:
        input = touch_move
    var forward := -camera_pivot.global_transform.basis.z; forward.y = 0; forward = forward.normalized()
    var right := camera_pivot.global_transform.basis.x; right.y = 0; right = right.normalized()
    # Input.get_vector returns negative Y for the "move_forward" action.
    var dir := (right * input.x - forward * input.y).normalized()
    if dir.length() > 0.1 and dodge_time <= 0.0:
        facing = dir
    if Input.is_action_just_pressed("dodge"): dodge()
    if Input.is_action_just_pressed("attack"): attack()
    var running := (touch_sprinting or Input.is_action_pressed("sprint")) and qi > 1.0 and input.length() > 0.12
    var base_speed := sprint_speed if running else speed * input.length()
    if running:
        qi = maxf(0.0, qi - 6.0 * delta)
    else:
        qi = minf(max_qi, qi + 10.0 * delta)
    if dodge_time > 0.0:
        velocity.x = dodge_direction.x * dodge_speed
        velocity.z = dodge_direction.z * dodge_speed
        dodge_time = maxf(0.0, dodge_time - delta)
    else:
        velocity.x = move_toward(velocity.x, dir.x * base_speed, acceleration * delta)
        velocity.z = move_toward(velocity.z, dir.z * base_speed, acceleration * delta)
    $Mesh.rotation.z = -0.35 if dodge_time > 0.0 else 0.0
    # Keep camera yaw independent of the moving body.
    if dir.length() > 0.1:
        $Mesh.rotation.y = lerp_angle($Mesh.rotation.y, atan2(-dir.x, -dir.z), 12.0 * delta)
    if not is_on_floor(): velocity.y -= 24.0 * delta
    move_and_slide()

func attack():
    if attack_cooldown > 0.0: return
    attack_cooldown = 0.32
    combo_step = (combo_step % 3) + 1
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
    if touch_move.length() < 0.12:
        touch_move = Vector2.ZERO
    else:
        var forward := -camera_pivot.global_transform.basis.z
        forward.y = 0.0
        forward = forward.normalized()
        var right := camera_pivot.global_transform.basis.x
        right.y = 0.0
        right = right.normalized()
        facing = (right * touch_move.x - forward * touch_move.y).normalized()
        $Mesh.rotation.y = atan2(-facing.x, -facing.z)

func dodge() -> void:
    if qi >= 15.0 and dodge_cooldown <= 0.0:
        qi -= 15.0
        dodge_time = 0.22
        dodge_cooldown = 0.55
        dodge_direction = facing
        dodge_direction = facing
