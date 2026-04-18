extends Node2D

@onready var _tilemap = %BaseInicial
#@onready var _player = %Player

var cena_arvore_5 = preload("res://arvore_5.tscn")
var cena_arvore_6 = preload("res://arvore_6.tscn")

var largura_mapa = 16
var altura_mapa = 13

var id_grama_pura = Vector2i(5, 3)
var id_sombra = Vector2i(4, 2)
var id_mato = Vector2i(3,3)

var max_tree_seeds = 4
var cur_tree_seeds = 0

func _ready():
	randomize()
	if _tilemap:
		gerar_chao_base()
		gerar_vegetacao_organica()
	#posicionar_player()

func gerar_chao_base():
	for x in range(-1 * largura_mapa, largura_mapa):
		for y in range(-1 * altura_mapa, altura_mapa):
			var coords = Vector2i(x, y)
			if _tilemap.get_cell_source_id(coords) == -1:
				_tilemap.set_cell(coords, 1, id_grama_pura)

func gerar_vegetacao_organica():
	for x in range(-1 * largura_mapa, largura_mapa, 2):
		for y in range(-1 * altura_mapa, altura_mapa, 2):
			var coords = Vector2i(x, y)
			if not tile_pode_ter_vegetacao(coords):
				continue
			
			var sorteio = randf()
			#if sorteio < 1 and max_tree_seeds >= cur_tree_seeds:
			if sorteio < 0.05:
				tenta_criar_grupo_arvore(coords)
				cur_tree_seeds += 1
			elif sorteio < 0.45:
				tenta_criar_grupo_mato(coords)

func tile_pode_ter_vegetacao(coords: Vector2i) -> bool:
	return _tilemap.get_cell_atlas_coords(coords) == id_grama_pura

func tenta_criar_grupo_arvore(coords: Vector2i):
	var tipo_escolhido = 5 if randf() < 0.5 else 6
	
	instanciar_arvore(coords, tipo_escolhido)
	
	if randf() < 0.4:
		var vizinho = coords + Vector2i(randi_range(-2, 2), randi_range(-2, 0))
		if tile_pode_ter_vegetacao(vizinho):
			instanciar_arvore(vizinho, tipo_escolhido)

func tenta_criar_grupo_mato(coords: Vector2i):
	if tile_tem_sombra_perto(coords):
		return
	
	_tilemap.set_cell(coords, 1, id_mato)
	
	if randf() < 0.40:
		var vizinho = coords + Vector2i(randi_range(-1, 1), randi_range(-1, 1))
		if tile_pode_ter_vegetacao(vizinho) and not tile_tem_sombra_perto(vizinho):
			_tilemap.set_cell(vizinho, 1, id_mato)

func tile_tem_sombra_perto(coords: Vector2i) -> bool:
	for x in range(-1, 2):
		for y in range(-1, 2):
			var data = _tilemap.get_cell_tile_data(coords + Vector2i(x, y))
			if data and data.get_custom_data("tipo_chao") == "sombra":
				return true
	return false

func instanciar_arvore(coords: Vector2i, tipo: int):
	var pos_global = _tilemap.to_global(_tilemap.map_to_local(coords))
	
	var arvore = (cena_arvore_5 if tipo == 5 else cena_arvore_6).instantiate()
	add_child(arvore)
	
	arvore.global_position = pos_global
	
	for x in range(-1, 2):
		for y in range(-1, 2):
			var sombra_coords = coords + Vector2i(x, y)
			var data = _tilemap.get_cell_tile_data(sombra_coords)
			if data:
				var tipo_c = data.get_custom_data("tipo_chao")
				if tipo_c == "grama" or tipo_c == "mato":
					_tilemap.set_cell(sombra_coords, 1, id_sombra)

#func posicionar_player():
#	var pos_valida = false

#	while not pos_valida:
#		var x = randi_range(-largura_mapa, largura_mapa)
#		var y = randi_range(-altura_mapa, altura_mapa)
#		var coords = Vector2i(x, y)
		
#		if _tilemap.get_cell_atlas_coords(coords) == id_grama_pura:
#			_player.global_position = _tilemap.to_global(_tilemap.map_to_local(coords))
#			pos_valida = true
#			print (pos_valida)
