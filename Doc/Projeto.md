Quero desenvolver um jogo 3D mobile na Godot Engine 4.x baseado em escalada vertical infinita em torno de um grande pilar/cilindro central.

O objetivo deste prompt é orientar o desenvolvimento de um primeiro protótipo jogável

IMPORTANTE:

- O foco inicial é exclusivamente o SINGLEPLAYER.
- Não implementar arte definitiva.
- Todos os modelos, materiais, efeitos e elementos visuais criados durante o protótipo devem ser considerados PLACEHOLDERS.
- No futuro, todos os assets serão substituídos manualmente por assets definitivos sem que a lógica do jogo precise ser reescrita.
- A arquitetura deve separar claramente lógica de gameplay, geração de mapa, câmera, jogador, plataformas e apresentação visual.
- O mapa deve ser procedural, mas controlável através de Resources `.tres`.
- O jogo deve ser pensado desde o início para funcionar em dispositivos mobile.
- Priorizar código simples, modular, legível e fácil de expandir.

==================================================
1. CONCEITO GERAL
==================================================

O jogo é um platformer vertical 3D.

Existe um grande pilar/cilindro vertical no centro do mundo.

O personagem começa em uma plataforma na parte inferior do pilar e precisa subir através de uma sequência de plataformas.

O pilar pode ser considerado verticalmente infinito.

As plataformas são distribuídas ao redor da superfície externa do cilindro.

O jogador consegue se movimentar ao redor do cilindro, podendo completar uma volta de 360 graus.

A experiência principal consiste em:

1. Observar as plataformas próximas.
2. Escolher onde pousar.
3. Movimentar o personagem ao redor do cilindro.
4. Pular.
5. Controlar a trajetória do salto.
6. Aterrissar em outra plataforma.
7. Continuar subindo.
8. Ganhar pontuação conforme aumenta sua altura.
9. Encontrar desafios progressivamente maiores.



==================================================
2. ESTRUTURA DO MUNDO
==================================================

O mundo possui um eixo vertical Y.

O pilar central possui um eixo vertical infinito.

O cilindro deve possuir:

- posição central;
- raio configurável;
- altura virtualmente infinita;
- quantidade de plataformas variável;
- possibilidade de diferentes temas visuais por regiões.

O personagem nunca precisa caminhar sobre uma superfície plana tradicional.

Ele está sempre se movimentando em relação à superfície cilíndrica.

A posição horizontal do personagem pode ser representada por um ângulo:

angle

Esse ângulo representa a posição do personagem ao redor do cilindro.

Exemplo:

0 graus   = frente
90 graus  = lateral
180 graus = parte traseira
270 graus = lateral oposta
360 graus = mesma posição inicial

O personagem pode realizar uma volta completa de 360 graus.

A distância do personagem em relação ao centro do cilindro deve permanecer dentro de um raio configurado.

==================================================
3. MOVIMENTO AO REDOR DO CILINDRO
==================================================

O jogador deve possuir movimento horizontal angular.

Em vez de simplesmente mover o personagem nos eixos X/Z tradicionais, o sistema deve considerar:

- ângulo ao redor do cilindro;
- velocidade angular;
- raio do cilindro;
- posição vertical.

A posição do personagem deve ser calculada aproximadamente através de:

x = cos(angle) * radius
z = sin(angle) * radius
y = altura do personagem

O personagem deve permanecer orientado de maneira coerente com a superfície do cilindro.

O movimento deve ser suave.

O jogador deve conseguir:

- mover para esquerda;
- mover para direita;
- parar;
- controlar a direção durante o salto, caso essa mecânica seja permitida;
- completar uma volta de 360 graus.

A velocidade angular deve ser configurável.

==================================================
4. CONTROLE MOBILE
==================================================

O jogo deve ser pensado prioritariamente para touchscreen.

Criar inicialmente uma interface simples.

O controle principal deve permitir ao jogador controlar o movimento horizontal ao redor do cilindro.

Pode ser utilizado inicialmente:

- joystick virtual;
OU
- arrastar horizontalmente;
OU
- botões esquerda/direita.

A arquitetura deve permitir trocar o sistema de input futuramente sem alterar a lógica do personagem.

Criar uma camada de input abstrata.

Exemplo conceitual:

InputController
    ↓
PlayerController
    ↓
Movement System

O salto deve possuir um controle simples e responsivo.

O objetivo é evitar controles excessivamente complexos.

==================================================
5. SISTEMA DE PULO
==================================================

O pulo é a principal mecânica do jogo.

O personagem possui:

- velocidade vertical;
- gravidade;
- força de pulo;
- estado no chão;
- estado no ar;
- estado de queda.

Ao iniciar um salto:

vertical_velocity = jump_force

Durante o voo:

vertical_velocity -= gravity * delta

A posição vertical é atualizada de acordo com essa velocidade.

O salto deve possuir comportamento arcade.

Não é necessário simular física realista.

O objetivo é proporcionar:

- previsibilidade;
- controle;
- resposta rápida;
- sensação de progressão;
- facilidade para aprender.

Os parâmetros devem ser configuráveis:

jump_force
gravity
fall_speed_limit
air_control
horizontal_speed
jump_cooldown

==================================================
6. DETECÇÃO DE PLATAFORMAS
==================================================

O personagem deve detectar quando está sobre uma plataforma.

Uma plataforma possui:

- posição;
- tamanho;
- altura;
- ângulo;
- tipo;
- propriedades de gameplay.

A colisão deve permitir que o personagem:

- pouse;
- permaneça sobre a plataforma;
- pule novamente;
- caia caso erre.

Evitar depender de lógica visual.

A plataforma deve possuir uma camada de gameplay independente do modelo 3D.

Exemplo:

Platform
    ├── Collision
    ├── Visual
    └── GameplayData

Isso permitirá substituir posteriormente o modelo visual sem alterar o funcionamento.

==================================================
7. TIPOS DE PLATAFORMA
==================================================

Criar inicialmente uma arquitetura que permita diferentes tipos.

Começar com:

1. NORMAL

Plataforma básica.

- fixa;
- sem comportamento especial;
- tamanho médio.

2. PEQUENA

Plataforma menor.

Exige maior precisão.

3. GRANDE

Plataforma mais fácil.

Pode ser utilizada no início de cada região ou como descanso.

4. MOVEL

Move-se verticalmente ou ao redor do cilindro.

5. IMPULSORA

Ao aterrissar nela, o personagem recebe uma força vertical adicional.

6. TEMPORARIA

Pode desaparecer depois de ser utilizada.

7. PERIGOSA

Caso o personagem toque nela, perde a vida ou reinicia.

A arquitetura deve permitir adicionar novos tipos futuramente sem modificar o gerador procedural inteiro.

==================================================
8. CÂMERA
==================================================

A câmera é uma parte fundamental do jogo.

A câmera deve ficar FORA do cilindro central.

Ela deve acompanhar o personagem enquanto ele sobe.

O jogador deve possuir a sensação de estar observando o personagem e o pilar externamente.

A câmera deve conseguir girar ao redor do cilindro.

O conceito visual é:

        CÂMERA
           \
            \
             O ← personagem
            /|
           / |
          /  |
       [ PILAR ]
          |
          |
          |
          ↓
       infinito

A câmera não deve ficar presa simplesmente atrás do personagem como em um platformer tradicional.

Ela deve possuir uma relação orbital com o centro do cilindro.

Parâmetros:

camera_distance
camera_height
camera_angle
camera_smoothing
camera_rotation_speed
camera_vertical_offset
camera_fov

==================================================
9. ROTAÇÃO 360º DA CÂMERA
==================================================

O jogador deve poder visualizar diferentes lados do cilindro.

A câmera deve conseguir realizar uma rotação completa de 360 graus ao redor do pilar.

A rotação deve utilizar o centro do cilindro como ponto de referência.

Criar um sistema semelhante a uma câmera orbital:

CameraRig
    └── CameraPivot
          └── Camera

O CameraPivot gira ao redor do centro do cilindro.

A câmera permanece a uma distância configurável do centro.

O jogador pode controlar a rotação horizontal da câmera.

A rotação deve ser suave e interpolada.

Não deve haver movimentos bruscos.

A câmera deve evitar:

- atravessar o cilindro;
- atravessar plataformas;
- ficar dentro do personagem;
- ficar em ângulos desconfortáveis.

==================================================
10. RELAÇÃO ENTRE CÂMERA E PERSONAGEM
==================================================

A câmera deve acompanhar a altura do personagem.

Conforme o jogador sobe:

- a câmera sobe;
- novas plataformas entram na área visível;
- plataformas antigas podem sair da área inferior.

A câmera não precisa acompanhar imediatamente todas as pequenas mudanças verticais.

Usar smoothing.

O personagem deve permanecer em uma posição confortável da tela.

A câmera pode antecipar levemente a direção do movimento ou a região que o jogador precisa observar.

Exemplo:

Se o jogador estiver subindo rapidamente, a câmera deve priorizar mostrar plataformas acima do personagem.

A câmera deve fornecer ao jogador informação suficiente para planejar o próximo salto.

==================================================
11. VISIBILIDADE DAS PLATAFORMAS
==================================================

O jogador deve conseguir enxergar:

- plataforma atual;
- próximas plataformas;
- parte da região acima;
- parte da região abaixo.

O sistema de câmera deve favorecer a leitura do percurso.

Não gerar plataformas em posições que fiquem completamente impossíveis de visualizar antes do salto.

O gerador procedural deve considerar a câmera.

Isso significa que a geração não deve apenas perguntar:

"Essa plataforma é fisicamente possível?"

Também deve considerar:

"Essa plataforma é visualmente identificável pelo jogador?"

==================================================
12. ALTURA E PONTUAÇÃO
==================================================

A principal pontuação do jogador é sua altura máxima alcançada.

O jogo deve possuir um contador de metros.

Exemplo:

ALTURA
1.250 m

A pontuação deve ser baseada na maior posição vertical alcançada pelo personagem.

Não utilizar simplesmente o tempo jogado.

Exemplo:

score = max_height_reached

Se o jogador cair e voltar para uma altura menor, sua pontuação máxima não deve diminuir.

Registrar:

current_height
max_height
best_height
run_height

A unidade visual deve ser "metros".

A conversão entre unidades internas da Godot e metros deve ser configurável.

Exemplo:

meters_per_world_unit

==================================================
13. RECORDES
==================================================

Criar inicialmente:

Current Height
Best Height
Run Height

O jogador deve possuir um recorde local.

Exemplo:

Melhor altura:
3.452 m

Quando superar o recorde:

Best Height = Current Height

Salvar localmente.

Posteriormente esse sistema poderá ser conectado a ranking online.

Não implementar ranking online agora.

==================================================
14. MORTE / QUEDA
==================================================

Se o jogador cair abaixo de determinada altura de segurança:

death_height_threshold

a tentativa termina.

O sistema deve:

1. detectar queda;
2. interromper o movimento;
3. mostrar uma pequena animação/efeito;
4. apresentar a altura alcançada;
5. apresentar o recorde;
6. permitir reiniciar.

Inicialmente não é necessário possuir vidas complexas.

A experiência pode simplesmente ser:

COMEÇAR
↓
SUBIR
↓
CAIR
↓
RESULTADO
↓
TENTAR NOVAMENTE

==================================================
15. CHECKPOINTS
==================================================

A arquitetura deve permitir checkpoints futuramente.

Um checkpoint pode salvar:

- altura;
- posição angular;
- progresso;
- estado necessário para reinício.

Inicialmente pode ser opcional ou desativado.

O sistema deve existir de maneira modular para não precisar ser refeito posteriormente.

==================================================
16. MAPA PROCEDURAL
==================================================

O mapa deve ser gerado proceduralmente.

O pilar é verticalmente infinito.

Não criar toda a torre de uma vez.

Utilizar geração por CHUNKS.

Exemplo:

Chunk 0
0m - 50m

Chunk 1
50m - 100m

Chunk 2
100m - 150m

Chunk 3
150m - 200m

E assim por diante.

Conforme o jogador sobe:

- gerar novos chunks acima;
- manter alguns chunks próximos;
- remover chunks muito distantes quando necessário.

Isso reduz consumo de memória e permite uma torre teoricamente infinita.

==================================================
17. SISTEMA DE CHUNKS
==================================================

Criar um:

LevelChunk

Cada chunk deve possuir:

- altura inicial;
- altura final;
- seed;
- lista de plataformas;
- dificuldade;
- tema;
- configuração procedural.

Exemplo:

LevelChunk
    ├── PlatformData
    ├── ThemeData
    ├── DifficultyData
    └── GenerationData

O chunk não deve depender diretamente de assets visuais específicos.

==================================================
19. GERAÇÃO DE PLATAFORMAS
==================================================

Cada chunk deve gerar uma sequência de plataformas.

Cada plataforma deve possuir pelo menos:

height
angle
radius
width
depth
platform_type

Exemplo:

PlatformData:

height = 15.0
angle = 1.45
radius = 10.0
width = 2.5
depth = 2.0
type = NORMAL

O gerador deve controlar:

- distância vertical;
- distância angular;
- tamanho;
- quantidade;
- dificuldade;
- variedade.

==================================================
20. DISTÂNCIA ENTRE PLATAFORMAS
==================================================

A geração procedural deve respeitar limites configuráveis.

Exemplo:

minimum_vertical_distance
maximum_vertical_distance

minimum_angular_distance
maximum_angular_distance

minimum_jump_height
maximum_jump_height

maximum_horizontal_jump_distance

Nunca criar uma plataforma que o jogador não consiga alcançar.

A dificuldade deve aumentar progressivamente.

==================================================
21. CURVA DE DIFICULDADE
==================================================

A dificuldade deve aumentar conforme a altura.

Exemplo:

0m - 100m
Fácil

100m - 300m
Fácil/Médio

300m - 600m
Médio

600m - 1000m
Difícil

1000m+
Muito difícil

A dificuldade deve controlar:

- tamanho das plataformas;
- distância vertical;
- distância angular;
- plataformas móveis;
- plataformas temporárias;
- frequência de plataformas especiais.

Não simplesmente aumentar tudo ao mesmo tempo.

A curva deve ser configurável.

==================================================
22. RESOURCES .TRES
==================================================

O mapa procedural NÃO deve possuir todos os parâmetros fixos dentro do código.

Utilizar Godot Resources personalizados.

Criar arquivos `.tres` para controlar a geração.

Exemplos:

PlatformConfig.tres
ChunkConfig.tres
DifficultyConfig.tres
WorldGenerationConfig.tres
ThemeConfig.tres

Criar scripts Resource correspondentes.

Exemplo conceitual:

class_name PlatformConfig
extends Resource

@export var platform_type
@export var width
@export var depth
@export var weight
@export var minimum_height
@export var maximum_height

==================================================
23. CONFIGURAÇÃO DO WORLD GENERATOR
==================================================

Criar:

WorldGenerationConfig.tres

Esse arquivo deve permitir controlar:

- seed;
- raio do cilindro;
- altura dos chunks;
- quantidade de plataformas;
- distância mínima;
- distância máxima;
- dificuldade inicial;
- progressão da dificuldade;
- tipos de plataforma permitidos;
- pesos de geração;
- distância de pré-geração;
- quantidade de chunks mantidos em memória.

O objetivo é poder alterar o comportamento do jogo pelo Inspector da Godot sem precisar alterar código.

==================================================
24. CONFIGURAÇÃO DE DIFICULDADE
==================================================

Criar:

DifficultyConfig.tres

Cada configuração pode definir:

easy
normal
hard
extreme

Ou utilizar uma curva contínua.

Parâmetros possíveis:

platform_size_multiplier
vertical_distance_multiplier
angular_distance_multiplier
moving_platform_chance
temporary_platform_chance
danger_platform_chance

A dificuldade deve ser calculada através da altura.

==================================================
25. CONFIGURAÇÃO DOS TIPOS DE PLATAFORMA
==================================================

Criar Resources individuais ou uma coleção de Resources para os tipos de plataforma.

Exemplo:

NormalPlatform.tres
SmallPlatform.tres
LargePlatform.tres
MovingPlatform.tres
BoostPlatform.tres
TemporaryPlatform.tres
DangerPlatform.tres

Esses arquivos devem definir os parâmetros de gameplay.

O visual deve permanecer separado.

==================================================
26. THEMES
==================================================

O pilar pode mudar de tema conforme a altura.

Exemplo:

0m - 500m
Tema inicial

500m - 1000m
Tema floresta

1000m - 1500m
Tema deserto

1500m - 2000m
Tema futurista

2000m+
Tema espacial

Os temas devem ser configuráveis através de:

ThemeConfig.tres

Cada tema pode definir futuramente:

- material do pilar;
- céu;
- iluminação;
- partículas;
- música;
- decoração;
- modelos das plataformas;
- efeitos.

No protótipo, utilizar apenas placeholders simples.

==================================================
27. ASSETS PLACEHOLDER
==================================================

Não criar arte definitiva.

Utilizar primitivas da Godot:

- CylinderMesh;
- BoxMesh;
- SphereMesh;
- CapsuleMesh;
- materiais simples;
- formas geométricas.

Exemplo:

Player = CapsuleMesh

Pillar = CylinderMesh

Platform = BoxMesh

MovingPlatform = BoxMesh

Esses elementos servem apenas para validar:

- gameplay;
- câmera;
- escala;
- física;
- geração procedural;
- dificuldade;
- controle.

No futuro, os objetos serão substituídos manualmente por assets reais.

A lógica NÃO deve depender do mesh utilizado.

==================================================
28. ARQUITETURA DE CENAS
==================================================

Organizar o projeto aproximadamente assim:

Main
├── World
│   ├── Pillar
│   ├── LevelGenerator
│   └── ChunkContainer
│
├── Player
│
├── CameraRig
│
├── UI
│   ├── HeightLabel
│   ├── BestHeightLabel
│   └── RestartButton
│
└── Systems
    ├── ScoreManager
    ├── GameManager
    └── InputController

As cenas devem ser modularizadas.

==================================================
29. PLAYER
==================================================

Criar uma cena:

Player.tscn

Com estrutura aproximada:

Player
├── CollisionShape3D
├── Visual
├── GroundDetector
└── OptionalEffects

O script do jogador deve cuidar apenas de:

- movimento;
- pulo;
- gravidade;
- estado;
- interação básica com plataformas.

Não colocar geração procedural dentro do Player.

==================================================
30. CAMERA RIG
==================================================

Criar uma cena separada:

CameraRig.tscn

Estrutura:

CameraRig
└── CameraPivot
    └── Camera3D

O CameraRig deve receber informações do:

- Player;
- centro do cilindro;
- altura;
- ângulo.

A câmera deve ser desacoplada do Player.

Isso permitirá alterar o comportamento da câmera sem modificar o movimento do personagem.

==================================================
31. GAME MANAGER
==================================================

Criar um GameManager responsável pelo estado geral da partida.

Estados:

MENU
PLAYING
PAUSED
FALLING
GAME_OVER
RESTARTING

O GameManager deve controlar o fluxo geral.

Não colocar toda a lógica do jogo em um único script.

==================================================
32. SCORE MANAGER
==================================================

Criar um ScoreManager independente.

Responsabilidades:

- ler altura do Player;
- converter para metros;
- atualizar altura atual;
- registrar maior altura da partida;
- registrar recorde local;
- informar a UI.

==================================================
33. UI
==================================================

A interface inicial deve ser extremamente simples.

Durante o jogo:

----------------------------

         1.254 m

----------------------------

No canto superior:

Best: 4.521 m

No final:

ALTURA ALCANÇADA
1.254 m

NOVO RECORDE!

[ TENTAR NOVAMENTE ]

A UI deve ser separada da lógica de gameplay.

==================================================
34. PERFORMANCE MOBILE
==================================================

O projeto deve ser pensado para dispositivos móveis.

Evitar:

- milhares de Nodes simultaneamente;
- geração excessiva;
- física desnecessária;
- meshes complexos;
- scripts executados desnecessariamente a cada frame.

Utilizar chunks para controlar memória.

Manter apenas uma quantidade limitada de chunks próximos ao jogador.

O sistema deve ser preparado para object pooling futuramente.

==================================================
35. SEPARAÇÃO ENTRE GAMEPLAY E VISUAL
==================================================

Essa regra é extremamente importante.

Gameplay:

PlatformData
PlayerController
WorldGenerator
Collision
Physics
Score

Visual:

PlatformVisual
PlayerVisual
Materials
Particles
Models
Animations

A substituição dos assets futuros não deve exigir alterações no sistema procedural.

==================================================
36. PRIMEIRA VERSÃO DO PROTÓTIPO
==================================================

Não tentar desenvolver todas as funcionalidades simultaneamente.

A primeira versão jogável deve conter apenas:

1. Pilar cilíndrico.

2. Player.

3. Gravidade.

4. Pulo.

5. Movimento ao redor do cilindro.

6. Câmera orbital externa.

7. Rotação de câmera 360 graus.

8. Plataformas normais.

9. Geração procedural simples.

10. Sistema de chunks.

11. Altura em metros.

12. Recorde local.

13. Queda/morte.

14. Reinício.

15. Configuração através de `.tres`.

Somente depois disso adicionar:

- plataformas móveis;
- plataformas especiais;
- temas;
- efeitos;
- animações;
- progressão avançada;
- sons;
- partículas;

==================================================
37. ORDEM DE IMPLEMENTAÇÃO
==================================================

Implementar na seguinte ordem:

FASE 1
Criar projeto Godot 3D.

FASE 2
Criar Player placeholder.

FASE 3
Implementar gravidade.

FASE 4
Implementar pulo.

FASE 5
Criar cilindro central.

FASE 6
Implementar movimento angular ao redor do cilindro.

FASE 7
Criar uma plataforma manual.

FASE 8
Implementar colisão e aterrissagem.

FASE 9
Criar CameraRig orbital.

FASE 10
Implementar rotação 360 graus da câmera.

FASE 11
Criar sistema básico de geração procedural.

FASE 12
Criar sistema de chunks.

FASE 13
Criar Resources `.tres`.

FASE 14
Transferir parâmetros de gameplay para os `.tres`.

FASE 15
Implementar progressão de dificuldade.

FASE 16
Implementar score por altura.

FASE 17
Implementar recorde local.

FASE 18
Implementar queda e game over.

FASE 19
Implementar UI.

FASE 20
Otimizar para mobile.

==================================================
38. REGRAS IMPORTANTES PARA A IA DE DESENVOLVIMENTO
==================================================

Ao escrever código:

- utilizar Godot 4.x;
- utilizar GDScript;
- evitar scripts gigantes;
- criar componentes independentes;
- utilizar Resources sempre que houver dados configuráveis;
- evitar valores mágicos espalhados pelo código;
- utilizar @export para parâmetros apropriados;
- comentar apenas onde houver lógica importante;
- utilizar nomes claros;
- manter responsabilidades separadas.

Antes de criar sistemas complexos, priorizar uma versão mínima funcional.

Não criar backend neste momento.

Não criar sistema de contas.

Não criar inventário.

Não criar loja.

Não criar monetização.

Não criar assets definitivos.

==================================================
39. OBJETIVO FINAL DO PROTÓTIPO
==================================================

Ao executar o projeto, o jogador deve entrar diretamente em uma pequena seção da torre.

Ele deve visualizar:

- o enorme cilindro central;
- seu personagem;
- algumas plataformas ao redor;
- plataformas acima;
- a câmera posicionada externamente.

O jogador deve conseguir:

1. movimentar-se ao redor do cilindro;
2. olhar ao redor;
3. realizar uma volta de 360 graus;
4. identificar plataformas;
5. pular;
6. aterrissar;
7. continuar subindo;
8. visualizar sua altura em metros;
9. encontrar plataformas diferentes conforme sobe;
10. continuar indefinidamente enquanto conseguir sobreviver.

A sensação desejada é de uma escalada vertical arcade em um mundo cilíndrico.

O jogo deve ser fácil de entender:

"Mova-se ao redor do pilar, escolha onde pousar e suba o máximo que conseguir."
----------
Não pule etapas importantes.

Sempre priorize uma implementação funcional antes de adicionar complexidade.

O resultado final dessa primeira etapa deve ser um protótipo 3D mobile funcional de escalada vertical procedural em torno de um cilindro, com câmera orbital externa, movimento de 360 graus, gravidade, pulo, plataformas, geração procedural por chunks, pontuação por metros e configuração através de Resources `.tres`.