extends CharacterBody2D

@onready var _animated_sprite = $personagem
@onready var _tilemap = $"../Chao"

const SPEED = 40.0

var last_direction = Vector2.DOWN
var inventario = ["hoe", "water"]
var ferramenta_atual_index = 0
var esta_trabalhando = false

func _physics_process(_delta: float) -> void:
	if esta_trabalhando:
		return

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction:
		velocity = direction * SPEED
		last_direction = direction
		
		if direction.y > 0:
			_animated_sprite.play("walk_up")
		elif direction.y < 0:
			_animated_sprite.play("walk_down")
		elif direction.x != 0:
			_animated_sprite.play("walk_side")
			_animated_sprite.flip_h = direction.x < 0
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		
		if last_direction.y > 0:
			_animated_sprite.play("idle_up")
		elif last_direction.y < 0:
			_animated_sprite.play("idle_down")
		elif last_direction.x != 0:
			_animated_sprite.play("idle_side")
			_animated_sprite.flip_h = last_direction.x < 0

	move_and_slide()

	if Input.is_action_just_pressed("trocarItem"):
		trocar_ferramenta()

	if Input.is_action_just_pressed("usarItem"):
		usar_ferramenta()

func trocar_ferramenta():
	ferramenta_atual_index = (ferramenta_atual_index + 1) % inventario.size()

func usar_ferramenta():
	esta_trabalhando = true
	velocity = Vector2.ZERO
	
	var ferramenta = inventario[ferramenta_atual_index]
	var direcao_str = ""
	
	if last_direction.y > 0:
		direcao_str = "up"
	elif last_direction.y < 0:
		direcao_str = "down"
	else:
		direcao_str = "side"
		_animated_sprite.flip_h = last_direction.x < 0
		
	_animated_sprite.play("work_" + ferramenta + "_" + direcao_str)
	
	if ferramenta == "hoe":
		arar_chao()
	
	await _animated_sprite.animation_finished
	esta_trabalhando = false

func arar_chao():
	if not _tilemap: return
	
	var posicao_alvo = global_position + (last_direction * 16)
	var coords_tile = _tilemap.local_to_map(_tilemap.to_local(posicao_alvo))
	
	var posicao_final_local = _tilemap.map_to_local(coords_tile)
	
	var cena_canteiro = load("res://canteiro.tscn")
	if cena_canteiro:
		var instancia = cena_canteiro.instantiate()
		_tilemap.add_child(instancia)
		
		instancia.position = posicao_final_local
		print("Canteiro instanciado em: ", coords_tile)
	else:
		print("Erro: Arquivo canteiro.tscn não encontrado!")
	
