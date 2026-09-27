extends CharacterBody2D

@export var walk_speed := 205.0
@export var run_speed := 325.0
@export var acceleration := 1812.5
@export var braking := 2187.5
@export var max_qi := 100.0
const SPECIAL_QI_COST := 30.0
const SPECIAL_COOLDOWN_TIME := 5.0
const SPECIAL_DAMAGE := 45.0
var touch_move := Vector2.ZERO
var touch_sprinting := false
var qi := 100.0
var facing := Vector2.DOWN
var dodge_direction := Vector2.ZERO
var dodge_time := 0.0
var dodge_cooldown := 0.0
var attack_cooldown := 0.0
var attack_anim := 0.0
var special_anim := 0.0
var special_cooldown := 0.0
var combo_step := 0
var last_attack_time := -10.0
var walk_phase := 0.0
var jump_buffer := 0.0
var jump_held := false
var jump_anim := 0.0
var landing_impact := 0.0
var turn_lean := 0.0
var dodge_lean := Vector2.ZERO
var attack_visual: Node2D
var special_visual: Node2D
var ground_shadow: Node2D
@onready var camera: Camera2D = $Camera2D
@onready var sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
    qi = max_qi
    _setup_animations()
    ground_shadow = Node2D.new()
    ground_shadow.name = "GroundShadow"
    ground_shadow.z_index = -1
    ground_shadow.set_script(load("res://scripts/character_shadow.gd"))
    add_child(ground_shadow)
    attack_visual = Node2D.new()
    attack_visual.name = "Slash"
    attack_visual.z_index = 4
    attack_visual.set_script(load("res://scripts/slash_effect.gd"))
    add_child(attack_visual)
    attack_visual.visible = false
    special_visual = Node2D.new()
    special_visual.name = "RadiantBurst"
    special_visual.position = Vector2(0, -42)
    special_visual.z_index = 3
    special_visual.set_script(load("res://scripts/special_effect.gd"))
    add_child(special_visual)
    special_visual.visible = false

func _physics_process(delta: float) -> void:
    dodge_cooldown = maxf(0.0, dodge_cooldown - delta)
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    special_cooldown = maxf(0.0, special_cooldown - delta)
    attack_anim = maxf(0.0, attack_anim - delta * 3.0)
    special_anim = maxf(0.0, special_anim - delta)
    jump_buffer = maxf(0.0, jump_buffer - delta)
    jump_anim = maxf(0.0, jump_anim - delta)
    landing_impact = maxf(0.0, landing_impact - delta * 3.0)
    if Input.is_action_just_pressed("attack"):
        attack()
    if Input.is_action_just_pressed("special"):
        special_attack()
    if Input.is_action_just_pressed("dodge"):
        dodge()
    if Input.is_action_just_pressed("jump"):
        jump()
    if Input.is_action_just_released("jump"):
        jump_released()

    var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    if touch_move.length() > 0.08:
        input = touch_move
    var strength := minf(1.0, input.length())
    if strength > 0.08:
        facing = input.normalized()
    var sprinting := (touch_sprinting or Input.is_action_pressed("sprint")) and qi > 0.0 and strength > 0.1
    var target_speed := run_speed if sprinting else walk_speed
    if sprinting:
        qi = maxf(0.0, qi - 7.0 * delta)
    else:
        qi = minf(max_qi, qi + 11.0 * delta)
    if dodge_time > 0.0:
        velocity = dodge_direction * 650.0
        dodge_time = maxf(0.0, dodge_time - delta)
        dodge_lean = dodge_direction
    else:
        dodge_lean = Vector2.ZERO
        var target_velocity := input.normalized() * target_speed * strength if strength > 0.08 else Vector2.ZERO
        var rate := acceleration if strength > 0.08 else braking
        velocity = velocity.move_toward(target_velocity, rate * delta)
    move_and_slide()
    if jump_anim <= 0.0 and sprite.position.y < -1.0:
        landing_impact = 0.35
    _update_animation(delta)

func set_move_vector(value: Vector2) -> void:
    touch_move = value.limit_length(1.0)

func attack() -> void:
    if attack_cooldown > 0.0:
        return
    var now := float(Time.get_ticks_msec()) / 1000.0
    if now - last_attack_time > 0.95:
        combo_step = 0
    else:
        combo_step = (combo_step + 1) % 3
    last_attack_time = now
    attack_cooldown = 0.34
    attack_anim = 1.35
    _show_slash()
    if combo_step == 2:
        for candidate in get_tree().get_nodes_in_group("damageable"):
            if candidate is Node2D and candidate.global_position.distance_to(global_position) <= 76.0 and candidate.has_method("take_damage"):
                candidate.take_damage(32.0)
        return
    var best: Node2D
    var best_distance := 92.0 if combo_step == 0 else 112.0
    for candidate in get_tree().get_nodes_in_group("damageable"):
        if not candidate is Node2D:
            continue
        var offset: Vector2 = candidate.global_position - global_position
        var distance := offset.length()
        var in_attack_arc := distance < 1.0 or facing.dot(offset.normalized()) > (0.15 if combo_step == 0 else -0.2)
        if distance <= best_distance and in_attack_arc:
            best = candidate
            best_distance = distance
    if best and best.has_method("take_damage"):
        var damage := 18.0 if combo_step == 0 else 25.0
        best.take_damage(damage)

func special_attack() -> void:
    if special_cooldown > 0.0 or qi < SPECIAL_QI_COST:
        return
    qi -= SPECIAL_QI_COST
    special_cooldown = SPECIAL_COOLDOWN_TIME
    special_anim = 0.55
    var frame := sprite.sprite_frames.get_frame_texture("idle_down", 0)
    var radius := frame.get_size().y * sprite.scale.y * 3.0
    special_visual.visible = true
    special_visual.call("restart", radius)
    var center := special_visual.global_position
    for candidate in get_tree().get_nodes_in_group("damageable"):
        if candidate is Node2D and candidate.global_position.distance_to(center) <= radius and candidate.has_method("take_damage"):
            candidate.take_damage(SPECIAL_DAMAGE)

func _show_slash() -> void:
    attack_visual.rotation = facing.angle() + PI * 0.5
    attack_visual.visible = true
    attack_visual.call("restart", combo_step)
    if sprite.animation.begins_with("attack_"):
        sprite.set_frame_and_progress(0, 0.0)
        sprite.play()

func dodge() -> void:
    if dodge_cooldown > 0.0 or qi < 12.0:
        return
    qi -= 12.0
    dodge_cooldown = 0.62
    dodge_time = 0.22
    dodge_direction = touch_move.normalized() if touch_move.length() > 0.12 else -facing

func jump() -> void:
    if jump_anim > 0.05:
        return
    jump_anim = 0.48
    jump_buffer = 0.16
    jump_held = true

func jump_released() -> void:
    jump_held = false

func _setup_animations() -> void:
    var sheet: Texture2D = load("res://assets/pixel/hero_sheet.png")
    var frames := SpriteFrames.new()
    frames.clear_all()
    var names := ["idle", "walk", "attack", "dodge", "jump"]
    # The art rows are front, side, back and the opposite side.
    var dirs := ["down", "right", "up", "left"]
    for row in range(dirs.size()):
        for ai in range(names.size()):
            var animation_name: String = names[ai] + "_" + dirs[row]
            frames.add_animation(animation_name)
            frames.set_animation_speed(animation_name, 14.0 if names[ai] == "attack" else (10.5 if names[ai] == "walk" else 12.0))
            frames.set_animation_loop(animation_name, names[ai] in ["idle", "walk"])
            for frame_index in range(4):
                var atlas := AtlasTexture.new()
                atlas.atlas = sheet
                atlas.region = Rect2((ai * 4 + frame_index) * 64, row * 72, 64, 72)
                frames.add_frame(animation_name, atlas)
    sprite.sprite_frames = frames
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.animation = "idle_down"
    sprite.play()

func _update_animation(delta: float = 1.0 / 60.0) -> void:
    var direction_name := "up"
    sprite.flip_h = false
    if absf(facing.x) > absf(facing.y):
        direction_name = "right"
        sprite.flip_h = facing.x > 0.0
    elif facing.y < 0.0:
        direction_name = "down"
    var speed := velocity.length()
    var state := "idle"
    if jump_anim > 0.06:
        state = "jump"
    elif dodge_time > 0.0 or (dodge_cooldown > 0.39 and dodge_cooldown < 0.62):
        state = "dodge"
    elif attack_anim > 0.0:
        state = "attack"
        sprite.speed_scale = 1.0
    elif speed > run_speed * 0.72:
        state = "walk"
        sprite.speed_scale = 1.35
    elif speed > 12.0:
        state = "walk"
        sprite.speed_scale = 1.0
    else:
        sprite.speed_scale = 0.75
    var anim_name := state + "_" + direction_name
    if sprite.animation != anim_name:
        sprite.play(anim_name)
    if state == "walk":
        var gait_rate := 13.0 if speed > run_speed * 0.72 else 9.5
        walk_phase = fposmod(walk_phase + delta * gait_rate, TAU)
        var stride := sin(walk_phase)
        sprite.position.x = stride * 2.8
        sprite.rotation = stride * 0.075
    else:
        sprite.position.x = 0.0
        sprite.rotation = 0.0
    var lift := 0.0
    if jump_anim > 0.06:
        var progress := 1.0 - jump_anim / 0.48
        lift = sin(progress * PI) * 24.0
        sprite.position.y = -20.0 - lift
        sprite.z_index = 2
    elif state == "walk":
        sprite.position.y = -20.0 - absf(sin(walk_phase)) * 3.2
        sprite.z_index = 0
    else:
        sprite.position.y = -20.0
        sprite.z_index = 0
    if is_instance_valid(ground_shadow):
        ground_shadow.call("set_lift", lift)
