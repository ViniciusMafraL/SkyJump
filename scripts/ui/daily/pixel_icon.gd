@tool
class_name PixelIcon
extends Control
## Ícone pixel-art desenhado por código (estrela, cadeado, check, chama...), sem texturas:
## escala nítida em qualquer resolução e combina com a identidade pixel-art do jogo.

enum Icon { STAR, LOCK, CHECK, FLAME, PLAY, ARROW_LEFT, ARROW_RIGHT, CLOSE }

const PATTERNS := {
	Icon.STAR: [
		".....#.....",
		"....###....",
		"....###....",
		"###########",
		".#########.",
		"..#######..",
		"..#######..",
		".####.####.",
		".###...###.",
		"##.......##",
	],
	Icon.LOCK: [
		"..#####..",
		".##...##.",
		".#.....#.",
		".#.....#.",
		"#########",
		"#########",
		"####.####",
		"####.####",
		"#########",
		"#########",
	],
	Icon.CHECK: [
		".........#",
		"........##",
		".......##.",
		"#.....##..",
		"##...##...",
		".##.##....",
		"..###.....",
		"...#......",
	],
	Icon.FLAME: [
		"...#....",
		"...##...",
		"..###...",
		"..####.#",
		".#######",
		".#######",
		"########",
		"########",
		".######.",
		"..####..",
	],
	Icon.PLAY: [
		"##.....",
		"####...",
		"######.",
		"#######",
		"#######",
		"######.",
		"####...",
		"##.....",
	],
	Icon.ARROW_LEFT: [
		"...#....",
		"..##....",
		".#######",
		"########",
		".#######",
		"..##....",
		"...#....",
	],
	Icon.ARROW_RIGHT: [
		"....#...",
		"....##..",
		"#######.",
		"########",
		"#######.",
		"....##..",
		"....#...",
	],
	Icon.CLOSE: [
		"##...##",
		"###.###",
		".#####.",
		"..###..",
		".#####.",
		"###.###",
		"##...##",
	],
}

@export var icon: Icon = Icon.STAR:
	set(value):
		icon = value
		queue_redraw()
@export var fill_color: Color = Color(1.0, 0.8, 0.15):
	set(value):
		fill_color = value
		queue_redraw()
## Transparente = sem contorno.
@export var outline_color: Color = Color(0.12, 0.1, 0.1):
	set(value):
		outline_color = value
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	draw_icon(self, icon, Rect2(Vector2.ZERO, size), fill_color, outline_color)


func set_colors(fill: Color, outline: Color) -> void:
	fill_color = fill
	outline_color = outline


## Desenha o padrão centralizado em `rect`, com contorno de um "pixel" ao redor.
static func draw_icon(canvas: CanvasItem, which: Icon, rect: Rect2, fill: Color, outline: Color) -> void:
	var rows: Array = PATTERNS[which]
	var columns := (rows[0] as String).length() + 2
	var lines := rows.size() + 2
	var pixel := floorf(minf(rect.size.x / columns, rect.size.y / lines))
	if pixel < 1.0:
		pixel = maxf(minf(rect.size.x / columns, rect.size.y / lines), 0.25)
	var origin := rect.position + (rect.size - Vector2(columns, lines) * pixel) * 0.5 + Vector2(pixel, pixel)
	if outline.a > 0.0:
		for y in rows.size():
			var row: String = rows[y]
			for x in row.length():
				if row[x] == "#":
					canvas.draw_rect(Rect2(origin + Vector2(x - 1, y - 1) * pixel, Vector2(3.0, 3.0) * pixel), outline)
	for y in rows.size():
		var row: String = rows[y]
		for x in row.length():
			if row[x] == "#":
				canvas.draw_rect(Rect2(origin + Vector2(x, y) * pixel, Vector2(pixel, pixel)), fill)
