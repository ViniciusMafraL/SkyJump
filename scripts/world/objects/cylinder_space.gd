class_name CylinderSpace
extends RefCounted
## Conversões entre o espaço "desenrolado" da superfície do cilindro e o mundo 3D.
## Offsets 2D de objetos seguem sempre a mesma convenção:
##   x = deslocamento ao longo da circunferência (positivo = direita da tela = ângulo decrescente)
##   y = altura (positivo = para cima)
## Assim direções de lançamento, trajetórias e tubos funcionam em qualquer posição angular.

## Altura do centro do corpo do personagem acima dos pés (usada em raios de detecção).
const PLAYER_CENTER_HEIGHT := 0.35


## Ângulo resultante de andar `tangent_offset` (positivo = direita da tela) a partir de `base_angle`.
static func angle_at(base_angle: float, tangent_offset: float, radius: float) -> float:
	return wrapf(base_angle - tangent_offset / maxf(radius, 0.001), 0.0, TAU)


## Distância ao longo da circunferência de `from_angle` até `to_angle` (positivo = `to` à direita).
static func tangent_offset(from_angle: float, to_angle: float, radius: float) -> float:
	return -angle_difference(from_angle, to_angle) * radius


static func to_world(angle: float, height: float, radius: float) -> Vector3:
	return Vector3(cos(angle) * radius, height, sin(angle) * radius)


## Orientação padrão de objetos: X local para fora do cilindro, Z local = esquerda da tela.
static func basis_at(angle: float) -> Basis:
	return Basis(Vector3.UP, -angle)


static func transform_at(angle: float, height: float, radius: float) -> Transform3D:
	return Transform3D(basis_at(angle), to_world(angle, height, radius))


## Ponto do mundo a partir de uma origem (ângulo/altura) e de um offset 2D na superfície.
static func surface_point(base_angle: float, base_height: float, radius: float, offset: Vector2) -> Vector3:
	return to_world(angle_at(base_angle, offset.x, radius), base_height + offset.y, radius)


## Posição do centro do personagem relativa a uma origem, no espaço desenrolado.
static func player_offset(origin_angle: float, origin_height: float, player: PlayerController) -> Vector2:
	return Vector2(
		tangent_offset(origin_angle, player.angle, player.orbit_radius),
		player.height + PLAYER_CENTER_HEIGHT - origin_height)


## Direção 2D a partir de graus: 0 = direita, 90 = para cima, 180 = esquerda.
static func direction_from_degrees(degrees: float) -> Vector2:
	return Vector2(cos(deg_to_rad(degrees)), sin(deg_to_rad(degrees)))


## Transform de uma malha unitária de eixo Y (CylinderMesh altura 1) esticada de `a` até `b`.
static func segment_transform(a: Vector3, b: Vector3, thickness: float) -> Transform3D:
	var length := a.distance_to(b)
	if length < 0.0001:
		return Transform3D(Basis.from_scale(Vector3.ONE * 0.0001), a)
	var y := (b - a) / length
	var reference := Vector3.RIGHT if absf(y.dot(Vector3.UP)) > 0.99 else Vector3.UP
	var x := y.cross(reference).normalized()
	var z := x.cross(y)
	return Transform3D(Basis(x * thickness, y * length, z * thickness), (a + b) * 0.5)
