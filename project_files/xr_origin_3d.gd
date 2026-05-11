extends XROrigin3D

@export var move_speed: float = 2.5
@export var deadzone: float = 0.15
@onready var xr_camera: XRCamera3D = $XRCamera3D
@onready var left_ctrl: XRController3D = $LeftController
@onready var right_ctrl: XRController3D = $RightController

var can_snap_turn: bool = true

func _physics_process(delta: float) -> void:
	# --- PŁYNNA LOKOMOCJA (Lewy drążek) ---
	var v_left: Vector2 = left_ctrl.get_vector2("thumbstick")
	if v_left.length() > deadzone:
		# Projekcja kierunków na płaszczyznę poziomą (ignorujemy patrznie w górę/dół)
		var fwd := -xr_camera.global_transform.basis.z
		fwd.y = 0.0
		fwd = fwd.normalized()

		var right := xr_camera.global_transform.basis.x
		right.y = 0.0
		right = right.normalized()

		var dir = fwd * (-v_left.y) + right * (v_left.x)
		if dir.length() > 0.0:
			global_translate(dir.normalized() * move_speed * delta)

	# --- OBRÓT SKOKOWY (Prawy drążek) ---
	var v_right: Vector2 = right_ctrl.get_vector2("thumbstick")
	if abs(v_right.x) > 0.5 and can_snap_turn:
		can_snap_turn = false
		var turn_angle = deg_to_rad(-45.0 * sign(v_right.x))
		# Skokowy obrót bazy gracza o 45 stopni
		rotate_y(turn_angle)
	elif abs(v_right.x) < 0.2:
		# Wymóg z instrukcji: odblokowanie ponownego obrotu dopiero po puszczeniu drążka
		can_snap_turn = true
