extends CharacterBody2D

@onready var _animated_sprite = $"AnimatedSprite2D"
@onready var _tilemap = $"../BaseInicial"

const vel = 40.0

var ultima_direcao = Vector2.DOWN

func _physics_process(_delta: float) -> void:
	var direcao = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direcao:
		velocity = direcao * vel
		ultima_direcao = direcao
		
		if direcao.y > 0:
			_animated_sprite.play("walk_down")
		elif direcao.y < 0:
			_animated_sprite.play("walk_up")
		elif direcao.x != 0:
			_animated_sprite.play("walk_side")
			_animated_sprite.flip_h = direcao.x < 0
	else:
		velocity = velocity.move_toward(Vector2.ZERO, vel)
		
		if ultima_direcao.y > 0:
			_animated_sprite.play("idle_down")
		elif ultima_direcao.y < 0:
			_animated_sprite.play("idle_up")
		elif ultima_direcao.x != 0:
			_animated_sprite.play("idle_side")
			_animated_sprite.flip_h = ultima_direcao.x < 0


	move_and_slide()
