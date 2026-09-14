class_name MilestoneMarker
extends ProgressBarMarker
## Estrela de uma meta: a próxima meta pulsa em destaque; metas alcançadas ficam menores, apagadas e com ✓.

var height_m: float = 0.0
var caption: String = ""
var reached: bool = false
var is_next: bool = false
var celebrate_scale: float = 1.0
var glow: float = 0.0
var appear_scale: float = 1.0

var _time: float = 0.0
var _celebrate_tween: Tween


func set_state(is_reached: bool, next: bool) -> void:
	reached = is_reached
	is_next = next


## Nova meta surgindo no topo.
func appear() -> void:
	appear_scale = 0.0
	create_tween().tween_property(self, "appear_scale", 1.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Meta atingida: 1.0 -> celebrate_scale -> 1.0 com brilho.
func celebrate() -> void:
	if _celebrate_tween and _celebrate_tween.is_valid():
		_celebrate_tween.kill()
	glow = 1.0
	_celebrate_tween = create_tween()
	_celebrate_tween.tween_property(self, "celebrate_scale", config.celebrate_scale, config.celebrate_duration * 0.35) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_celebrate_tween.parallel().tween_property(self, "glow", 0.0, config.celebrate_duration)
	_celebrate_tween.chain().tween_property(self, "celebrate_scale", 1.0, config.celebrate_duration * 0.65) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Meta saindo da faixa visível: some suavemente.
func dismiss() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var base_radius := config.milestone_icon_size * 0.5
	var radius := base_radius * (config.reached_milestone_scale if reached else 1.0) * celebrate_scale * appear_scale
	if is_next:
		radius *= 1.0 + config.pulse_amount * (0.5 + 0.5 * sin(_time * config.pulse_speed))
	var color := config.reached_color if reached else config.milestone_color
	if glow > 0.0:
		draw_circle(Vector2.ZERO, radius * 2.2, Color(config.milestone_color, 0.45 * glow))
	if is_next:
		draw_circle(Vector2.ZERO, radius * 1.5, Color(color, 0.18))
	if radius <= 0.5:
		return
	if config.milestone_icon_texture:
		draw_texture_rect(config.milestone_icon_texture, Rect2(-Vector2.ONE * radius, Vector2.ONE * radius * 2.0), false, color)
	else:
		var points := star_points(radius)
		draw_colored_polygon(points, color)
		points.append(points[0])
		draw_polyline(points, config.outline_color, 2.0, true)

	var text := HeightFormat.meters(height_m)
	if not caption.is_empty():
		text = "%s  %s" % [text, caption]
	var font_size := config.small_font_size if reached else config.font_size
	var text_position := Vector2(base_radius + 10.0, font_size * 0.35)
	_draw_text(text, text_position, font_size, Color(config.text_color, 0.75) if reached else config.text_color)
	if reached:
		var width := config.get_font().get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var origin := text_position + Vector2(width + 8.0, -font_size * 0.3)
		var check := PackedVector2Array([origin + Vector2(0, 0), origin + Vector2(5, 5), origin + Vector2(14, -6)])
		draw_polyline(check, config.outline_color, 6.0, true)
		draw_polyline(check, config.check_color, 3.0, true)


static func star_points(radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 10:
		var point_radius := radius if i % 2 == 0 else radius * 0.45
		var angle := -PI * 0.5 + float(i) * PI / 5.0
		points.append(Vector2(cos(angle), sin(angle)) * point_radius)
	return points
