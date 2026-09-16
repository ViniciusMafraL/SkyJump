class_name SkyJumpColors
extends RefCounted
## Paleta oficial da UI do Sky Jump (Doc/implementaçãoArt.md). Único lugar com valores de cor da
## interface: cenas usam as variações do tema (SkyJumpThemeBuilder) e scripts usam estas constantes.

const BLACK := Color("#000000")
const GREEN := Color("#0ACF83")
const BLUE := Color("#3759FF")
const DARK_RED := Color("#CC1919")
const PURPLE := Color("#CC9EFF")
const RED := Color("#CF0000")
const CORAL := Color("#FA5F45")
const YELLOW := Color("#FFC100")
const WHITE := Color("#FFFFFF")

# Tons derivados da paleta (não são cores novas).
## Papel da agenda.
static var PAPER: Color = WHITE.lerp(BLACK, 0.04)
## Linhas da grade do calendário.
static var GRID_LINE: Color = WHITE.lerp(BLUE, 0.12).lerp(BLACK, 0.12)
## Números e textos "de caneta" sobre o papel.
static var INK: Color = WHITE.lerp(BLACK, 0.55)
static var INK_FADED: Color = WHITE.lerp(BLACK, 0.2)
## Botões e ícones indisponíveis.
static var DISABLED: Color = WHITE.lerp(BLACK, 0.42)
## Escurecimento atrás de painéis.
static var DIM: Color = Color(BLACK, 0.6)
## Cartão escuro (painéis sobre o jogo).
static var CARD: Color = BLUE.lerp(BLACK, 0.62)
## Medalhas (xadrez das plataformas de checkpoint): bronze e prata; a estrela usa RED.
static var BRONZE: Color = CORAL.lerp(BLACK, 0.3).lerp(YELLOW, 0.15)
static var SILVER: Color = WHITE.lerp(BLACK, 0.42)


## Tom mais escuro da cor (borda inferior dos botões, sombras).
static func shade(color: Color, amount: float = 0.24) -> Color:
	return color.darkened(amount)


## Tom mais claro da cor (hover).
static func light(color: Color, amount: float = 0.12) -> Color:
	return color.lightened(amount)
