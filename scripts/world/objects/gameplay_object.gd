class_name GameplayObject
extends Node3D
## Base de todo objeto de gameplay posicionado no cilindro (plataformas e objetos especiais).
## A lógica usa apenas dados cilíndricos (ângulo, altura, raio) e nunca depende do modelo visual.
## Objetos compostos (escada, vinhas) expõem suas plataformas por get_platforms().
## Objetos que reagem ao personagem sem pouso (parede, tubo, portal, canhão) retornam true em
## wants_player_updates() e recebem update_player() a cada frame de física do personagem.

enum Sound { ACTIVATION, LAUNCH, BREAK, TELEPORT, EXPLOSION }

## Configuração de movimento usada para desenhar trajetórias previstas no debug.
static var debug_movement: PlayerMovementConfig

## Tipo usado quando o objeto é criado sem PlatformData.
@export var object_type: PlatformType.Type = PlatformType.Type.NORMAL
## Espelha a direção local do objeto (direita <-> esquerda).
@export var flip: bool = false

@export_group("Audio")
## Pontos de integração de áudio. Vazio = silêncio.
@export var activation_sound: AudioStream
@export var launch_sound: AudioStream
@export var break_sound: AudioStream
@export var teleport_sound: AudioStream
@export var explosion_sound: AudioStream

@export_group("Debug")
## Desenha direções, trajetórias e raios (ferramenta de desenvolvimento).
@export var show_debug: bool = false:
	set(value):
		show_debug = value
		if _debug_draw and not value:
			_debug_draw.clear()
			_debug_draw.commit()

var data: PlatformData
## Estado atual (pode diferir de `data` em objetos que se movem).
var current_angle: float = 0.0
var current_radius: float = 0.0
var current_height: float = 0.0

var _theme: ThemeData
var _debug_draw: ObjectDebugDraw
var _audio_player: AudioStreamPlayer3D


## Posiciona o objeto no cilindro e o deixa no estado inicial.
func setup(platform_data: PlatformData, theme: ThemeData) -> void:
	data = platform_data
	_theme = theme
	current_angle = data.angle
	current_radius = data.radius
	current_height = data.height
	_sync_transform()
	_on_setup()
	reset()
	reset_physics_interpolation()


func get_object_type() -> PlatformType.Type:
	return data.platform_type if data else object_type


## Seção de configuração da sala de testes (ex.: &"moving"). Vazio = sem configuração editável.
func get_settings_section() -> StringName:
	return &""


## Troca a configuração (ex.: cópia ativa da sala de testes). Objetos com `config` a recebem aqui.
func set_config(value: Resource) -> void:
	if &"config" in self:
		set(&"config", value)


## Volta ao estado inicial (posição, contadores, estados temporários).
func reset() -> void:
	pass


func get_platforms() -> Array[Platform]:
	return []


func wants_player_updates() -> bool:
	return false


func update_player(_player: PlayerController, _delta: float) -> void:
	pass


## Objetos sólidos na lateral (paredes) limitam o movimento angular do personagem.
func blocks_player() -> bool:
	return false


func constrain_player_angle(_player: PlayerController, _from_angle: float, to_angle: float) -> float:
	return to_angle


## Ativação manual pela sala de testes.
func trigger_debug(_player: PlayerController) -> void:
	pass


## Estado legível para o overlay de debug.
func get_state_name() -> String:
	return ""


## 1 = direita do objeto é a direita da tela; -1 quando espelhado.
func get_object_sign() -> float:
	return -1.0 if flip else 1.0


## Direção 2D local (x = direita do objeto, y = cima) convertida para a convenção do personagem.
func local_direction(direction: Vector2) -> Vector2:
	return Vector2(direction.x * get_object_sign(), direction.y)


func play_sound(kind: Sound) -> void:
	var stream: AudioStream = [activation_sound, launch_sound, break_sound, teleport_sound, explosion_sound][kind]
	if stream == null:
		return
	if _audio_player == null:
		_audio_player = AudioStreamPlayer3D.new()
		add_child(_audio_player)
	_audio_player.stream = stream
	_audio_player.play()


func _physics_process(_delta: float) -> void:
	if show_debug:
		if _debug_draw == null:
			_debug_draw = ObjectDebugDraw.new()
			add_child(_debug_draw)
		_debug_draw.clear()
		_draw_debug(_debug_draw)
		_debug_draw.commit()


## Chamado no setup, após o posicionamento e antes do reset.
func _on_setup() -> void:
	pass


func _draw_debug(_draw: ObjectDebugDraw) -> void:
	pass


## Troca de tema depois do setup: reaplica materiais/cores sem recriar o objeto nem mudar estado.
func apply_theme(theme: ThemeData) -> void:
	_theme = theme
	if data:
		_on_theme_applied()


## Materiais que o tema ativo define para este tipo (plataformas ou objetos especiais).
func get_theme_materials() -> ThemeMaterialSettings:
	return _theme.get_material_settings(get_object_type()) if _theme else null


func theme_primary_color(fallback: Color) -> Color:
	var settings := get_theme_materials()
	return settings.primary_color if settings else fallback


func theme_secondary_color(fallback: Color) -> Color:
	var settings := get_theme_materials()
	return settings.secondary_color if settings else fallback


func theme_primary_material(fallback: Color) -> Material:
	var settings := get_theme_materials()
	return settings.get_primary_material() if settings else _fallback_material(fallback)


func theme_secondary_material(fallback: Color) -> Material:
	var settings := get_theme_materials()
	return settings.get_secondary_material() if settings else _fallback_material(fallback)


## Reaplica os visuais que dependem do tema. Objetos com visual próprio sobrescrevem.
func _on_theme_applied() -> void:
	pass


static var _fallback_materials: Dictionary = {}


static func _fallback_material(color: Color) -> StandardMaterial3D:
	if not _fallback_materials.has(color):
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		_fallback_materials[color] = material
	return _fallback_materials[color]


## Eixo local X aponta para fora do cilindro; eixo Z segue a tangente.
func _sync_transform() -> void:
	var target := CylinderSpace.transform_at(current_angle, current_height, current_radius)
	if is_inside_tree():
		global_transform = target
	else:
		transform = target


func _world_point(offset: Vector2, radial: float = 0.0) -> Vector3:
	return CylinderSpace.surface_point(current_angle, current_height, current_radius + radial, local_direction(offset))
