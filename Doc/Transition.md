Quero implementar um SISTEMA GLOBAL DE TRANSIÇÕES DE TELA para meu jogo 3D mobile desenvolvido em Godot 4.x.

O jogo possui diferentes telas, cenas e estados, e quero utilizar um sistema único de transição visual baseado em Shader para criar mudanças suaves e estilizadas entre elas.

A implementação deve ser modular, reutilizável e preparada para receber diferentes padrões de transição no futuro.

==================================================
1. REFERÊNCIAS
==================================================

Utilizar como referência os seguintes projetos:

1. Transition Shader With Patterns
Godot Shaders:
https://godotshaders.com/shader/transition-shader-with-patterns/

2. Godot Modular Transitions
Binbun:
https://binbun3d.itch.io/godot-modular-transitions

O primeiro utiliza uma abordagem baseada em gradient textures e shape textures, permitindo criar diferentes formas de transição através das texturas e parâmetros do shader.

O segundo demonstra uma abordagem modular de transições para Godot 4.x.

IMPORTANTE:

Não quero simplesmente espalhar o shader pelas cenas.

Quero criar uma arquitetura própria de TRANSITION MANAGER.

O shader será o componente visual.

O TransitionManager será responsável pelo fluxo da transição.

==================================================
2. OBJETIVO
==================================================

Criar um sistema que permita executar:

TRANSIÇÃO DE SAÍDA
        ↓
TELA COBERTA
        ↓
TROCA DE CENA/TELA
        ↓
TRANSIÇÃO DE ENTRADA

Visualmente:

Tela A
   ↓
shader começa
   ↓
tela desaparece
   ↓
tela completamente coberta
   ↓
troca de cena
   ↓
shader reverte
   ↓
Tela B aparece

A troca real da cena deve acontecer enquanto a tela está completamente coberta.

Isso evita mostrar a mudança de cena diretamente para o jogador.

==================================================
3. COMPONENTE GLOBAL
==================================================

Criar:

TransitionManager.gd

Ele deve funcionar como um sistema global/autoload.

Exemplo:

TransitionManager.play_transition(...)

ou:

TransitionManager.change_scene_with_transition(...)

O jogador e outras partes do jogo não devem precisar conhecer os detalhes do shader.

Exemplo:

Button
   ↓
TransitionManager
   ↓
Fade Out
   ↓
Scene Change
   ↓
Fade In

==================================================
4. ESTRUTURA
==================================================

Criar uma estrutura semelhante a:

autoload/
    TransitionManager.gd

transitions/
    TransitionOverlay.tscn
    TransitionShader.gdshader
    TransitionConfig.gd
    TransitionConfig.tres

resources/
    transitions/
        Fade.tres
        Circle.tres
        Radial.tres
        Pixel.tres
        Pattern.tres

O nome dos arquivos pode ser adaptado à arquitetura do projeto.

==================================================
5. TRANSITION OVERLAY
==================================================

Criar uma interface visual global utilizando:

CanvasLayer
    └── ColorRect / TextureRect

O overlay deve ocupar a tela inteira.

Exemplo:

TransitionLayer
    └── TransitionOverlay

O shader será aplicado nesse elemento.

O overlay deve ficar acima de:

- mundo 3D;
- UI;
- menus;
- HUD.

A transição deve cobrir toda a tela.

==================================================
6. SHADER
==================================================

Criar um CanvasItem Shader compatível com Godot 4.x.

O shader deve controlar a quantidade de tela coberta através de um parâmetro:

progress

ou:

factor

Variando de:

0.0 → transição não iniciada

até:

1.0 → tela completamente coberta

A arquitetura deve permitir controlar esse valor através de Tween.

Exemplo conceitual:

shader_material.set_shader_parameter("progress", value)

==================================================
7. REFERÊNCIA AO SHADER
==================================================

Utilizar como referência a estrutura do shader:

shader_type canvas_item;

uniform vec4 base_color : source_color;
uniform vec2 node_resolution;

uniform float factor;
uniform float width;

uniform sampler2D gradient_texture;
uniform sampler2D shape_texture;

e conceitos semelhantes aos apresentados no shader de referência.

Não é obrigatório copiar exatamente a implementação.

O objetivo é utilizar a mesma filosofia:

GRADIENTE
+
PADRÃO
+
PROGRESSO
=
TRANSIÇÃO

==================================================
8. OPÇÕES QUE O SHADER DEVE PROPORCIONAR
==================================================

O sistema deve permitir controlar pelo menos:

- cor da transição;
- progresso;
- velocidade;
- duração;
- largura da borda;
- feathering;
- intensidade;
- textura de gradiente;
- textura do padrão;
- escala do padrão;
- rotação do padrão;
- deslocamento do padrão;
- direção;
- modo de transição;
- easing;
- possibilidade de inverter a transição.

Esses parâmetros devem ser centralizados.

==================================================
9. TIPOS DE TRANSIÇÃO
==================================================

Criar suporte para diferentes tipos.

Inicialmente:

1. FADE

A tela simplesmente é coberta gradualmente.

2. RADIAL

A transição parte do centro e se espalha.

3. CIRCLE

Uma forma circular cresce ou diminui.

4. DIRECTIONAL

A transição entra de uma direção.

Exemplo:

LEFT
RIGHT
TOP
BOTTOM

5. PATTERN

Utiliza uma textura/padrão para revelar ou esconder a tela.

6. DISSOLVE

Utiliza noise/padrão para criar uma dissolução.

A arquitetura deve permitir adicionar novos tipos posteriormente.

==================================================
10. PATTERN TEXTURES
==================================================

O sistema deve permitir trocar a textura responsável pelo padrão.

Exemplos futuros:

- círculos;
- quadrados;
- triângulos;
- estrelas;
- pixels;
- ruído;
- formas orgânicas;
- padrões personalizados.

A textura não deve estar hardcoded no shader.

Ela deve ser um recurso configurável.

Exemplo:

uniform sampler2D shape_texture;

No Godot:

TransitionConfig
    ↓
shape_texture

==================================================
11. GRADIENT TEXTURE
==================================================

O sistema também deve permitir utilizar diferentes gradient textures.

Isso permitirá criar diferentes direções e comportamentos.

Exemplos:

horizontal gradient
vertical gradient
radial gradient
circular gradient
custom gradient

A arquitetura deve permitir trocar a textura sem alterar o código do shader.

==================================================
12. COR DA TRANSIÇÃO
==================================================

A cor deve ser configurável.

Exemplo:

transition_color

Padrão:

preto.

Mas permitir:

branco;
cor temática;
cor da região;
cor do menu;
ou qualquer outra cor.

A cor deve ser controlada pelo TransitionConfig.

==================================================
13. WIDTH
==================================================

Adicionar controle:

transition_width

Esse parâmetro controla a largura da região intermediária da transição.

Isso permite criar:

transição mais seca;
transição mais suave;
transição com borda mais larga.

==================================================
14. FEATHERING
==================================================

Adicionar:

feathering

Esse parâmetro controla a suavidade da borda do efeito.

Valores baixos:

borda mais definida.

Valores altos:

borda mais suave.

Esse parâmetro deve poder ser alterado pelo Inspector.

==================================================
15. PATTERN SCALE
==================================================

Adicionar:

pattern_scale

Isso controla o tamanho do padrão.

Exemplo:

escala baixa:
poucos elementos grandes.

escala alta:
muitos elementos pequenos.

==================================================
16. PATTERN ROTATION
==================================================

Adicionar:

pattern_rotation

Permitir rotacionar o padrão.

Exemplo:

0°
45°
90°
180°

==================================================
17. PATTERN MOVEMENT
==================================================

Preparar suporte para movimento do padrão.

Parâmetro:

pattern_scroll

Exemplo:

vec2(0.2, 0.0)

Isso permite que o padrão se mova durante a transição.

==================================================
18. IN/OUT
==================================================

O sistema deve suportar:

TRANSITION OUT

Tela atual desaparece.

E:

TRANSITION IN

Nova tela aparece.

A mesma configuração pode ser utilizada em sentido inverso.

Exemplo:

play_out()
play_in()

Ou:

play(reverse = false)
play(reverse = true)

==================================================
19. EASING
==================================================

Não utilizar apenas uma interpolação linear.

Permitir diferentes tipos de easing:

linear
ease_in
ease_out
ease_in_out

O TransitionManager deve utilizar Tween da Godot.

Exemplo conceitual:

var tween = create_tween()

tween.tween_method(
    set_transition_progress,
    0.0,
    1.0,
    duration
)

==================================================
20. DURAÇÃO
==================================================

Cada transição deve possuir duração configurável.

Exemplo:

0.25 segundos
0.5 segundos
0.75 segundos
1.0 segundo

Não utilizar duração fixa no código.

==================================================
21. TRANSITION CONFIG RESOURCE
==================================================

Criar:

TransitionConfig.gd

extends Resource

O Resource deve conter parâmetros como:

transition_type
base_color
duration
width
feathering
pattern_scale
pattern_rotation
pattern_scroll
gradient_texture
shape_texture
ease_type

Isso permitirá criar:

Fade.tres
Circle.tres
Radial.tres
Pattern.tres

sem duplicar lógica.

==================================================
22. TRANSITION PRESETS
==================================================

Criar presets.

Exemplo:

DefaultFade.tres

QuickFade.tres

CircleTransition.tres

RadialTransition.tres

PatternTransition.tres

DeathTransition.tres

MenuTransition.tres

Esses presets poderão ser utilizados pelos diferentes eventos do jogo.

==================================================
23. API DO TRANSITION MANAGER
==================================================

Criar funções simples.

Exemplo:

TransitionManager.play(config)

TransitionManager.play_out(config)

TransitionManager.play_in(config)

TransitionManager.change_scene(scene_path, config)

TransitionManager.change_scene_with_transition(scene_path, config)

Também permitir:

TransitionManager.is_transitioning()

==================================================
24. TROCA DE CENA
==================================================

Criar uma função central:

change_scene_with_transition()

Fluxo:

1. Verificar se já existe transição em andamento.

2. Iniciar TRANSITION OUT.

3. Aguardar chegar a 100%.

4. Trocar a cena.

5. Aguardar a nova cena estar pronta.

6. Executar TRANSITION IN.

7. Liberar o jogador.

Fluxo:

PLAYER
 ↓
REQUEST SCENE CHANGE
 ↓
TRANSITION OUT
 ↓
SCREEN COVERED
 ↓
CHANGE SCENE
 ↓
NEW SCENE READY
 ↓
TRANSITION IN
 ↓
GAMEPLAY

==================================================
25. BLOQUEIO DURANTE TRANSIÇÃO
==================================================

Enquanto a transição estiver acontecendo:

bloquear temporariamente:

- input do jogador;
- botões de gameplay;
- ações duplicadas;
- chamadas simultâneas de mudança de cena.

Criar:

transition_locked

Isso evita:

- clicar duas vezes;
- iniciar duas cenas;
- executar duas transições simultaneamente.

==================================================
26. MOMENTOS EM QUE A TRANSIÇÃO SERÁ CHAMADA
==================================================

Criar uma lista centralizada de eventos.

A transição deve ser utilizada nos seguintes momentos:

------------------------------------------
EVENTO 1 — ABRIR O JOGO
------------------------------------------

Ao iniciar o jogo:

Tela preta/overlay
        ↓
TRANSITION IN
        ↓
MENU PRINCIPAL

Objetivo:

evitar que o jogador veja a cena sendo carregada abruptamente.

------------------------------------------
EVENTO 2 — TROCA DE TELA
------------------------------------------

Exemplo:

MENU PRINCIPAL
        ↓
CONFIGURAÇÕES

Executar:

TRANSITION OUT
        ↓
troca de tela
        ↓
TRANSITION IN

------------------------------------------
EVENTO 3 — CLICAR EM "JOGAR"
------------------------------------------

Fluxo:

MENU
 ↓
JOGAR
 ↓
TRANSITION OUT
 ↓
carregar gameplay
 ↓
TRANSITION IN
 ↓
GAMEPLAY

------------------------------------------
EVENTO 4 — ENTRAR NA SALA DE TESTES
------------------------------------------

MENU
 ↓
SALA DE TESTES
 ↓
TRANSITION OUT
 ↓
TEST ROOM
 ↓
TRANSITION IN

------------------------------------------
EVENTO 5 — SAIR DA SALA DE TESTES
------------------------------------------

TEST ROOM
 ↓
SAIR
 ↓
TRANSITION OUT
 ↓
MENU
 ↓
TRANSITION IN

------------------------------------------
EVENTO 6 — MORTE
------------------------------------------

Quando o jogador morrer:

GAMEPLAY
 ↓
DEATH
 ↓
DEATH TRANSITION
 ↓
GAME OVER / RESULTADO

A transição de morte pode possuir um preset próprio.

------------------------------------------
EVENTO 7 — REINICIAR PARTIDA
------------------------------------------

GAME OVER
 ↓
REINICIAR
 ↓
TRANSITION OUT
 ↓
NOVA RUN
 ↓
TRANSITION IN

------------------------------------------
EVENTO 8 — VOLTAR AO MENU
------------------------------------------

GAMEPLAY
 ↓
MENU
 ↓
TRANSITION OUT
 ↓
MAIN MENU
 ↓
TRANSITION IN

------------------------------------------
EVENTO 9 — ABRIR CONFIGURAÇÕES
------------------------------------------

Se configurações forem uma tela independente:

CURRENT SCREEN
 ↓
TRANSITION
 ↓
SETTINGS
 ↓
TRANSITION IN

Se for apenas um painel sobre a mesma cena:

NÃO utilizar transição de cena.

Esse comportamento deve ser decidido de acordo com a arquitetura da UI.

------------------------------------------
EVENTO 10 — ENTRAR EM UMA NOVA REGIÃO
------------------------------------------

No futuro, quando o jogador atingir uma nova região temática:

REGION A
 ↓
TRANSITION
 ↓
REGION B

Isso poderá ser utilizado para mudanças importantes de ambiente.

------------------------------------------
EVENTO 11 — CHECKPOINT
------------------------------------------

Opcional.

Caso o design futuramente tenha checkpoints:

CHECKPOINT
 ↓
TRANSITION CURTA
 ↓
novo estado salvo

Não implementar necessariamente na primeira versão.

------------------------------------------
EVENTO 12 — TELEPORT
------------------------------------------

Caso o jogo futuramente possua teleporte:

PLAYER
 ↓
TRANSITION OUT
 ↓
TELEPORT
 ↓
TRANSITION IN

------------------------------------------
EVENTO 13 — EVENTOS ESPECIAIS
------------------------------------------

Preparar o sistema para:

- entrada em evento;
- saída de evento;
- mudança de modo;
- cutscene;
- introdução;
- tutorial;
- encerramento;
- retorno ao gameplay.

==================================================
27. TABELA DE PRESETS
==================================================

Criar inicialmente:

---------------------------------------------
EVENTO              | PRESET
---------------------------------------------
Abrir jogo          | FadeIn
Troca de tela       | DefaultFade
Jogar               | GameplayTransition
Sala de testes      | DefaultFade
Sair                | DefaultFade
Morte               | DeathTransition
Game Over → Jogar   | GameplayTransition
Voltar ao menu      | MenuTransition
Região nova         | RegionTransition
Teleport            | TeleportTransition
---------------------------------------------

Os nomes podem ser alterados.

O importante é que o evento não precise conhecer os detalhes do shader.

==================================================
28. TRANSIÇÃO DE MORTE
==================================================

Criar um preset específico para morte.

A ideia inicial pode ser:

- escurecimento rápido;
- padrão radial;
- fechamento para o centro;
- ou outro efeito estilizado.

A morte não precisa utilizar exatamente a mesma transição das trocas de tela.

Exemplo:

DeathTransition.tres

duration = 0.4

color = preto

pattern = radial

Depois:

GAME OVER

==================================================
29. TRANSIÇÃO DO MENU
==================================================

Criar uma transição um pouco mais suave para navegação entre menus.

Exemplo:

duration = 0.35

feathering = alto

pattern = simples

==================================================
30. TRANSIÇÃO DE GAMEPLAY
==================================================

Ao iniciar uma partida:

utilizar uma transição simples e rápida.

Exemplo:

MENU
 ↓
fade/pattern
 ↓
GAMEPLAY

Evitar uma animação longa.

O jogador deve começar rapidamente.

==================================================
31. TRANSIÇÃO DE REGIÃO
==================================================

Preparar um preset mais elaborado para mudanças importantes do mundo.

Exemplo:

PatternTransition

O padrão pode possuir:

- movimento;
- escala;
- rotação;
- cor temática.

Essa transição será utilizada futuramente quando o pilar mudar de tema.

==================================================
32. SHADER MOBILE
==================================================

O jogo é mobile.

O shader deve ser pensado para performance.

Evitar operações desnecessariamente complexas.

Priorizar:

- poucas amostras de textura;
- operações simples;
- resolução adequada;
- ausência de loops pesados.

A transição dura apenas alguns décimos de segundo, mas ainda assim deve ser eficiente.

==================================================
33. RESOLUÇÃO
==================================================

O overlay deve funcionar corretamente em diferentes resoluções e proporções de tela.

Utilizar:

node_resolution

ou equivalente.

Considerar:

- 16:9;
- 18:9;
- 19.5:9;
- tablets.

Evitar padrões distorcidos.

==================================================
34. CANCELAMENTO
==================================================

Criar proteção contra chamadas duplicadas.

Se uma transição estiver acontecendo:

não iniciar outra automaticamente.

Opcionalmente permitir:

force_transition()

para situações específicas de desenvolvimento.

==================================================
35. DEBUG
==================================================

Criar opção:

debug_transitions

Quando ativada:

mostrar:

Current Transition:
DeathTransition

Progress:
0.63

State:
TRANSITION_OUT

Isso facilitará o desenvolvimento.

==================================================
36. TESTE DO SISTEMA
==================================================

Criar uma cena:

TransitionTest.tscn

Essa cena deve permitir testar todos os presets.

Interface:

-----------------------------------
       TRANSITION TEST
-----------------------------------

[ Fade ]

[ Circle ]

[ Radial ]

[ Pattern ]

[ Death ]

[ Region ]

[ Directional ]

-----------------------------------

[ OUT ]

[ IN ]

-----------------------------------

Também mostrar:

Progress
Duration
Current Preset

Essa cena será apenas uma ferramenta de desenvolvimento.

==================================================
37. ORGANIZAÇÃO DO CÓDIGO
==================================================

Não colocar lógica de transição dentro de:

PlayerController
MainMenu
GameManager
UI
GameOver

Esses sistemas apenas devem chamar:

TransitionManager

Exemplo:

func _on_play_pressed():
    TransitionManager.change_scene_with_transition(
        gameplay_scene,
        gameplay_transition
    )

==================================================
38. FLUXO FINAL DO SISTEMA
==================================================

Qualquer sistema:

MENU
PLAYER
GAME OVER
REGION SYSTEM
TEST ROOM
TELEPORT
TUTORIAL

pode solicitar:

TransitionManager

↓

TransitionManager escolhe/configura:

TransitionConfig

↓

TransitionOverlay

↓

Shader

↓

Tween

↓

Tela coberta

↓

Evento de troca

↓

Tween reverso

↓

Tela revelada

==================================================
39. PRIMEIRA IMPLEMENTAÇÃO
==================================================

Implementar nesta ordem:

FASE 1
Criar TransitionOverlay.

FASE 2
Criar shader básico.

FASE 3
Criar parâmetro progress.

FASE 4
Criar fade simples.

FASE 5
Criar TransitionManager como Autoload.

FASE 6
Criar função play_out().

FASE 7
Criar função play_in().

FASE 8
Criar change_scene_with_transition().

FASE 9
Criar TransitionConfig Resource.

FASE 10
Criar presets.

FASE 11
Adicionar pattern textures.

FASE 12
Adicionar gradient textures.

FASE 13
Adicionar controle de width.

FASE 14
Adicionar feathering.

FASE 15
Adicionar scale/rotation/scroll.

FASE 16
Adicionar easing.

FASE 17
Criar DeathTransition.

FASE 18
Criar TransitionTest.tscn.

FASE 19
Integrar Menu.

FASE 20
Integrar Gameplay.

FASE 21
Integrar Game Over.

==================================================
40. CRITÉRIO DE SUCESSO
==================================================

O sistema estará concluído quando:

- existir um TransitionManager global;
- existir um overlay global;
- o overlay utilizar shader;
- a transição possuir progress controlável;
- existir entrada e saída;
- for possível trocar cenas através do sistema;
- existirem presets;
- for possível trocar padrões;
- for possível alterar cor;
- for possível alterar duração;
- for possível alterar width;
- for possível alterar feathering;
- for possível alterar escala;
- for possível alterar rotação;
- for possível movimentar o padrão;
- existir easing;
- existir proteção contra chamadas duplicadas;
- o input puder ser bloqueado durante a transição;
- a transição funcionar em diferentes resoluções;
- o sistema estiver otimizado para mobile.

==================================================
41. REGRA PRINCIPAL
==================================================

O shader é responsável pela APARÊNCIA.

O TransitionManager é responsável pelo FLUXO.

O TransitionConfig é responsável pelos DADOS.

As cenas são responsáveis por solicitar a TRANSIÇÃO.

Não misturar essas responsabilidades.

Arquitetura:

Scene
   ↓
TransitionManager
   ↓
TransitionConfig
   ↓
TransitionOverlay
   ↓
Shader