class_name ProgressBarConfig
extends Resource
## Aparência da barra lateral de progressão. Placeholders desenhados por código; qualquer
## textura abaixo substitui a forma padrão sem mudar a lógica.

@export_group("Layout")
## Largura da coluna de fundo (a linha fica no centro dela).
@export var bar_width: float = 72.0
## Altura da barra em fração da altura da tela.
@export_range(0.2, 0.9, 0.01) var bar_height_ratio: float = 0.55
## Distância do topo da área segura até o topo da barra (abaixo do botão de pausa e do aviso de meta).
@export var bar_top_offset: float = 215.0
## Distância da borda esquerda da área segura.
@export var bar_margin: float = 16.0
## Faixa inferior da tela reservada aos botões de controle: a barra nunca desce até ela.
@export var bottom_reserved_height: float = 300.0
@export_range(0.0, 0.5, 0.01) var max_safe_margin_ratio: float = 0.25
## Fração inferior da barra usada pelas metas já alcançadas (linha do tempo comprimida).
@export_range(0.0, 0.6, 0.01) var past_zone_fraction: float = 0.3
## Quantas metas alcançadas aparecem abaixo da faixa atual.
@export_range(1, 10) var max_past_milestones_shown: int = 3

@export_group("Cores")
@export var background_color: Color = SkyJumpColors.BLACK
@export_range(0.0, 1.0, 0.01) var background_opacity: float = 0.35
@export var line_color: Color = Color(SkyJumpColors.WHITE, 0.35)
@export var progress_color: Color = SkyJumpColors.YELLOW
@export var milestone_color: Color = SkyJumpColors.YELLOW
@export var reached_color: Color = Color(SkyJumpColors.WHITE, 0.85)
@export var check_color: Color = SkyJumpColors.GREEN
@export var record_color: Color = SkyJumpColors.CORAL

@export_group("Tamanhos")
@export var progress_width: float = 8.0
@export var player_icon_size: float = 30.0
@export var milestone_icon_size: float = 30.0
@export_range(0.3, 1.0, 0.01) var reached_milestone_scale: float = 0.7
@export var record_marker_size: float = 16.0

@export_group("Texto")
## Vazio = fonte do tema do projeto (Outfit ExtraBold).
@export var font: Font
@export var font_size: int = 22
@export var small_font_size: int = 18
@export var feedback_font_size: int = 44
## Distância do topo da área segura até o aviso de meta/recorde (abaixo dos botões de pausa e ALT).
@export var feedback_top_offset: float = 118.0
@export var text_color: Color = SkyJumpColors.WHITE
@export var outline_color: Color = SkyJumpColors.BLACK
@export var outline_size: int = 8

@export_group("Ícones")
## Substitui o círculo com a cor da skin.
@export var player_icon_texture: Texture2D
## Substitui a estrela desenhada.
@export var milestone_icon_texture: Texture2D
## Substitui a seta do recorde.
@export var record_icon_texture: Texture2D

@export_group("Animação")
## Velocidade da suavização dos marcadores (maior = mais rápido).
@export var animation_speed: float = 8.0
@export var pulse_speed: float = 3.0
@export_range(0.0, 0.5, 0.01) var pulse_amount: float = 0.12
@export var celebrate_scale: float = 1.3
@export_range(0.1, 2.0, 0.01, "suffix:s") var celebrate_duration: float = 0.45
@export_range(0.2, 5.0, 0.1, "suffix:s") var feedback_duration: float = 1.6


func get_font() -> Font:
	if font:
		return font
	var project_theme := ThemeDB.get_project_theme()
	return project_theme.default_font if project_theme and project_theme.default_font else ThemeDB.fallback_font
