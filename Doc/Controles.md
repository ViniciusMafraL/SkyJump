Quero implementar um SISTEMA DE CONTROLES CONFIGURÁVEIS para o meu jogo 3D mobile desenvolvido em Godot 4.x.

O jogo é um platformer vertical em torno de um cilindro central.

O personagem se movimenta ao redor do cilindro, podendo realizar uma volta completa de 360 graus, e utiliza o salto para alcançar plataformas cada vez mais altas.

Embora o jogo seja desenvolvido e testado inicialmente em computador, o objetivo principal é MOBILE/TOUCHSCREEN.

Quero que o jogador possa escolher diferentes formas de controle.

IMPORTANTE:

- O sistema de controles deve ser modular.
- O PlayerController NÃO deve depender diretamente dos botões da interface.
- Todos os métodos de controle devem enviar comandos para uma mesma camada de input.
- A física, gravidade, salto e movimento do personagem devem permanecer independentes do método utilizado.
- O jogador deve poder trocar o método de controle pelas configurações.
- O sistema deve ser preparado para adicionar novos métodos de controle no futuro.
- Inicialmente implementar três métodos.
- O jogo possui PULO AUTOMÁTICO nos modos que não possuem botão de pulo.
- O terceiro modo possui botão manual de pulo.

==================================================
1. CONCEITO DO SISTEMA
==================================================

Criar um sistema central de input.

Arquitetura:

Touch / Gyroscope / Buttons
          ↓
   Control Scheme
          ↓
   Input Controller
          ↓
   Player Controller
          ↓
Movement + Jump
          ↓
Physics

O PlayerController não deve saber se o jogador está utilizando:

- botão;
- touchscreen;
- giroscópio;
- teclado;
- controle físico.

Ele deve receber apenas comandos abstratos.

Exemplo:

move_direction = -1
move_direction = 0
move_direction = 1

jump_pressed = true

==================================================
2. MÉTODOS DE CONTROLE
==================================================

Implementar inicialmente três opções:

CONTROL SCHEME 1
Botões invisíveis + Pulo automático

CONTROL SCHEME 2
Giroscópio + Pulo automático

CONTROL SCHEME 3
Botões esquerda/direita + botão de pulo

O jogador poderá selecionar o método nas configurações.

==================================================
3. OPÇÃO 1 — BOTÕES INVISÍVEIS
==================================================

Esse será um dos métodos principais.

A tela será dividida verticalmente em duas grandes áreas:

┌─────────────────────────────────┐
│               │                 │
│               │                 │
│               │                 │
│               │                 │
│               │                 │
│ ÁREA ESQUERDA │ ÁREA DIREITA    │
│               │                 │
│               │                 │
│               │                 │
│               │                 │
└─────────────────────────────────┘

Na prática, a tela deve ser dividida em:

50% esquerda
50% direita

Quando o jogador tocar na metade esquerda:

move_direction = LEFT

Quando tocar na metade direita:

move_direction = RIGHT

O jogador não precisa visualizar botões permanentes.

As áreas de toque devem ser praticamente invisíveis.

==================================================
4. INDICAÇÃO VISUAL DOS BOTÕES INVISÍVEIS
==================================================

Como os botões são invisíveis, o jogo deve ensinar ao jogador como utilizá-los.

Quando o jogador NÃO estiver pressionando nenhuma das áreas:

mostrar temporariamente no centro da tela:

< >

Essas setas servem como indicação visual de que:

← lado esquerdo = movimenta para esquerda

→ lado direito = movimenta para direita

As setas devem aparecer principalmente:

- no primeiro uso;
- quando o jogador entra na sala;
- quando o jogador não está tocando na tela;
- durante um pequeno período de orientação.

Quando o jogador tocar em qualquer uma das áreas:

as setas devem desaparecer.

==================================================
5. COMPORTAMENTO DAS SETAS
==================================================

As setas não devem permanecer visíveis permanentemente.

Fluxo:

Jogador entra
    ↓
Mostra < >
    ↓
Jogador toca
    ↓
Setas desaparecem
    ↓
Controle fica invisível

Se o jogador permanecer sem tocar por um determinado período:

opcionalmente:

mostrar < >

novamente de forma temporária.

Criar um parâmetro:

control_hint_timeout

E outro:

control_hint_repeat_delay

Esses valores devem ser configuráveis.

==================================================
6. PULO AUTOMÁTICO — OPÇÃO 1
==================================================

Nesse método não existe botão de pulo.

O personagem possui salto automático.

Quando estiver sobre uma plataforma válida:

o personagem automaticamente inicia um novo salto.

Fluxo:

Pousou
 ↓
Pequeno intervalo opcional
 ↓
Pulo automático
 ↓
Movimento no ar
 ↓
Queda
 ↓
Aterrissagem
 ↓
Novo pulo

O jogador controla principalmente:

"Para qual lado eu quero ir?"

O objetivo desse sistema é criar uma experiência simples:

ESCOLHER DIREÇÃO → PULAR → ATERRISSAR

==================================================
7. OPÇÃO 2 — GIROSCÓPIO
==================================================

O segundo método utiliza o giroscópio/sensores de movimento do celular.

O jogador inclina ou movimenta o aparelho para controlar o personagem ao redor do cilindro.

Exemplo conceitual:

Celular inclinado para esquerda
        ↓
Personagem gira para esquerda

Celular inclinado para direita
        ↓
Personagem gira para direita

O movimento deve ser convertido para:

move_direction

O sistema deve evitar utilizar diretamente valores brutos do sensor.

Criar uma camada de processamento.

Gyroscope
   ↓
Calibration
   ↓
Sensitivity
   ↓
Dead Zone
   ↓
Smoothing
   ↓
move_direction
   ↓
Player

==================================================
8. CALIBRAÇÃO DO GIROSCÓPIO
==================================================

O jogador deve poder calibrar a posição neutra.

Criar uma opção:

CALIBRAR CONTROLE

Ao pressionar:

"Segure o celular na posição desejada."

O sistema registra essa posição como:

neutral_orientation

A partir dela, o movimento será calculado.

Isso evita que o jogador precise manter o celular em uma posição desconfortável.

==================================================
9. SENSIBILIDADE DO GIROSCÓPIO
==================================================

Criar uma configuração:

Sensibilidade

Exemplo:

[------●---------]

Valores baixos:

movimento mais lento.

Valores altos:

movimento mais rápido.

Criar também:

dead_zone

para evitar pequenos movimentos involuntários.

==================================================
10. SUAVIZAÇÃO DO GIROSCÓPIO
==================================================

O sensor pode produzir pequenas oscilações.

Não transmitir diretamente essas oscilações para o personagem.

Utilizar smoothing.

Parâmetro:

gyro_smoothing

Também utilizar uma zona morta:

gyro_dead_zone

O objetivo é fazer com que:

pequenas oscilações = nenhuma movimentação

inclinação real = movimentação

==================================================
11. PULO AUTOMÁTICO — GIROSCÓPIO
==================================================

Assim como no primeiro método, o jogador NÃO possui botão de pulo.

O salto é automático.

O giroscópio controla somente:

movimentação horizontal/angular.

O jogador deve se concentrar em:

inclinar o aparelho
        ↓
escolher direção
        ↓
personagem se movimenta
        ↓
pulo automático
        ↓
aterrissagem

==================================================
12. OPÇÃO 3 — BOTÕES + PULO MANUAL
==================================================

O terceiro método utiliza controles tradicionais.

Interface:

┌─────────────────────────────────┐
│                                 │
│                                 │
│                                 │
│                                 │
│                                 │
│                                 │
│                                 │
│                                 │
│                                 │
│   [ ← ]     [ JUMP ]    [ → ]  │
└─────────────────────────────────┘

Criar:

Botão esquerda
Botão direita
Botão pulo

O jogador controla diretamente:

← movimentar esquerda

→ movimentar direita

JUMP = realizar salto

==================================================
13. BOTÕES DE MOVIMENTO
==================================================

Os botões esquerda/direita devem suportar:

- toque;
- pressionamento contínuo;
- liberação.

Enquanto o botão estiver pressionado:

move_direction = -1 ou +1

Ao liberar:

move_direction = 0

O movimento deve ser contínuo.

Não implementar o botão como apenas um comando único.

==================================================
14. BOTÃO DE PULO
==================================================

No terceiro modo, o pulo será manual.

Ao tocar no botão:

jump_pressed = true

O PlayerController decidirá se o salto pode acontecer.

O sistema deve impedir:

- múltiplos saltos acidentais;
- spam de comandos;
- pulo durante estados inválidos.

Futuramente, habilidades como Double Jump poderão alterar essas regras.

==================================================
15. DIFERENÇA ENTRE OS MODOS
==================================================

Modo 1:

TOUCH INVISÍVEL

Esquerda/direita:
movimentação

Pulo:
automático

Modo 2:

GIROSCÓPIO

Inclinação:
movimentação

Pulo:
automático

Modo 3:

BOTÕES

Esquerda/direita:
movimentação

Pulo:
manual

Os três métodos devem utilizar o mesmo PlayerController.

==================================================
16. INPUT ABSTRATO
==================================================

Criar uma estrutura comum.

Exemplo:

PlayerInputState

Deve conter informações como:

move_axis
jump_pressed
jump_held
control_scheme

Opcionalmente:

camera_input
ability_pressed
item_pressed

O PlayerController recebe esse estado.

Assim:

Input Scheme 1 ──┐
Input Scheme 2 ──┼──> PlayerInputState ──> Player
Input Scheme 3 ──┘

==================================================
17. CONTROL MANAGER
==================================================

Criar:

ControlManager.gd

Responsabilidades:

- saber qual método está selecionado;
- ativar/desativar o sistema correspondente;
- coletar input;
- gerar PlayerInputState;
- atualizar a interface necessária;
- gerenciar calibração do giroscópio;
- aplicar configurações de sensibilidade.

Não colocar lógica de física nesse sistema.

==================================================
18. INTERFACES DE CONTROLE
==================================================

Cada método deve possuir seu próprio componente.

Exemplo:

controls/
├── ControlManager.gd
├── TouchInvisibleControl.gd
├── GyroscopeControl.gd
└── ButtonControl.gd

Isso permitirá adicionar futuramente:

KeyboardControl.gd
GamepadControl.gd
SwipeControl.gd
JoystickControl.gd

sem modificar o PlayerController.

==================================================
19. CONFIGURAÇÃO DOS CONTROLES
==================================================

Criar:

ControlConfig.gd

e:

ControlConfig.tres

Parâmetros possíveis:

selected_control_scheme

touch_sensitivity

gyro_sensitivity

gyro_dead_zone

gyro_smoothing

auto_jump_enabled

control_hint_enabled

control_hint_timeout

button_size

jump_button_size

button_opacity

camera_control_enabled

Os valores devem poder ser configurados através do Inspector.

==================================================
20. CONFIGURAÇÃO POR JOGADOR
==================================================

A escolha do método de controle deve ser salva localmente.

Exemplo:

control_scheme = "touch_invisible"

Ao abrir o jogo novamente:

carregar a última configuração.

Inicialmente utilizar armazenamento local.

Não implementar conta online para isso.

==================================================
21. MENU DE CONTROLES
==================================================

Criar uma seção:

CONTROLES

Exemplo:

------------------------------------
             CONTROLES
------------------------------------

Método de controle:

( ) Toque + Pulo Automático

( ) Giroscópio + Pulo Automático

( ) Botões + Pulo Manual

------------------------------------

Quando GIROSCÓPIO estiver selecionado:

Sensibilidade
[-------●--------]

Zona Morta
[---●------------]

[ CALIBRAR ]

------------------------------------

Quando BOTÕES estiver selecionado:

Tamanho dos botões
[-------●--------]

Opacidade
[---●------------]

------------------------------------

[ APLICAR ]
------------------------------------

A interface deve mostrar apenas as configurações relevantes para o método selecionado.

==================================================
22. COMPATIBILIDADE COM COMPUTADOR
==================================================

Embora o jogo seja mobile, durante o desenvolvimento será utilizado um computador.

Criar uma camada de fallback para testes.

Quando estiver rodando no PC:

- o teclado pode simular esquerda/direita;
- uma tecla pode simular pulo;
- o mouse pode simular touchscreen.

Isso permitirá testar os três métodos sem necessariamente possuir um celular conectado.

Exemplo:

A = esquerda
D = direita
Space = pulo

Para o modo giroscópio, criar uma forma de simular o sensor no PC ou permitir utilizar teclado para representar a inclinação.

IMPORTANTE:

Esse fallback existe apenas para desenvolvimento.

==================================================
23. CÂMERA
==================================================

O sistema de controles deve permanecer separado da câmera.

O movimento do jogador é:

move_axis

A câmera continua utilizando seu próprio:

camera_orbit

Não assumir que movimentar para direita significa necessariamente rotacionar a câmera.

A lógica do jogo deve continuar funcionando independentemente do método de controle.

==================================================
24. RELAÇÃO COM O CILINDRO
==================================================

O controle horizontal representa movimentação ANGULAR ao redor do cilindro.

Exemplo:

move_axis = -1

→ diminuir angle

move_axis = +1

→ aumentar angle

O PlayerController converte isso para posição no cilindro.

Os controles não devem manipular diretamente:

position.x
position.z

O PlayerController deve ser responsável por transformar o comando abstrato em movimento cilíndrico.

==================================================
25. PULO AUTOMÁTICO COMO SISTEMA
==================================================

O Auto Jump deve ser um sistema independente.

Criar:

AutoJumpController

Ele deve verificar:

- personagem está em plataforma;
- plataforma permite salto;
- personagem está no estado correto;
- auto jump está habilitado.

Se todas as condições forem verdadeiras:

solicitar salto.

Isso permitirá futuramente:

auto_jump = true

ou:

auto_jump = false

sem modificar a física do personagem.

==================================================
26. PLATAFORMAS E AUTO JUMP
==================================================

Cada plataforma pode possuir uma propriedade:

auto_jump_enabled

Isso permitirá futuramente ter plataformas que:

- causam salto automático;
- não permitem salto automático;
- lançam o jogador;
- possuem comportamento especial.

O PlayerController não deve precisar saber detalhes específicos da plataforma.

==================================================
27. ACESSIBILIDADE E CONFORTO
==================================================

Os controles devem ser confortáveis para sessões longas.

Evitar:

- botões pequenos;
- necessidade de precisão excessiva;
- movimentos bruscos;
- giroscópio excessivamente sensível;
- comandos difíceis de entender.

Permitir futuramente configurar:

- sensibilidade;
- tamanho;
- posição;
- opacidade;
- vibração;
- feedback visual.

==================================================
28. FEEDBACK VISUAL
==================================================

Os controles devem fornecer feedback.

Modo invisível:

Ao tocar na esquerda:

mostrar brevemente uma indicação visual de esquerda.

Ao tocar na direita:

mostrar brevemente uma indicação visual de direita.

Modo botões:

botão deve mudar visualmente enquanto pressionado.

Modo giroscópio:

opcionalmente mostrar uma pequena indicação de direção.

O feedback não deve ocupar muito espaço da tela.

==================================================
29. VIBRAÇÃO
==================================================

Preparar suporte futuro para haptic feedback.

Exemplos:

- aterrissagem;
- trampolim;
- erro;
- novo recorde;
- habilidade.

Criar uma camada independente:

HapticManager

Não implementar vibração diretamente dentro dos botões.

==================================================
30. RESPONSIVIDADE DA INTERFACE
==================================================

A UI deve funcionar em diferentes proporções de tela.

Não assumir resolução específica.

Utilizar:

Control nodes
anchors
containers
safe areas

Considerar:

- celulares pequenos;
- celulares grandes;
- tablets;
- diferentes proporções;
- orientação suportada pelo jogo.

==================================================
31. ORIENTAÇÃO DA TELA
==================================================

O jogo deve ser desenvolvido considerando inicialmente orientação:

LANDSCAPE

A interface deve aproveitar a divisão horizontal da tela.

O modo de toque invisível deve funcionar independentemente da resolução.

==================================================
32. DEBUG
==================================================

Criar uma opção:

[✓] Mostrar Debug dos Controles

Quando ativada:

mostrar:

CONTROL: TOUCH
MOVE: LEFT
AUTO JUMP: ON

ou:

CONTROL: GYROSCOPE
GYRO VALUE: 0.35
MOVE: RIGHT

ou:

CONTROL: BUTTONS
MOVE: LEFT
JUMP: READY

Isso será extremamente útil durante o desenvolvimento.

==================================================
33. TROCA DE CONTROLE EM TEMPO DE EXECUÇÃO
==================================================

Sempre que possível permitir trocar o método sem reiniciar o jogo.

Ao selecionar outro método:

1. desativar controle atual;
2. limpar seu estado;
3. ativar novo controle;
4. inicializar configuração;
5. atualizar UI.

Exemplo:

Touch
 ↓
Gyroscope
 ↓
Buttons

O PlayerController permanece ativo durante todo o processo.

==================================================
34. RECURSOS .TRES
==================================================

Toda configuração importante deve poder ser controlada através de Resources.

Criar:

ControlConfig.gd
ControlConfig.tres

GyroscopeConfig.gd
GyroscopeConfig.tres

TouchControlConfig.gd
TouchControlConfig.tres

ButtonControlConfig.gd
ButtonControlConfig.tres

Isso permite ajustar o comportamento através do Inspector.

==================================================
35. ARQUITETURA
==================================================

Estrutura sugerida:

systems/
├── ControlManager.gd
├── AutoJumpController.gd
└── HapticManager.gd

controls/
├── TouchInvisibleControl.gd
├── GyroscopeControl.gd
└── ButtonControl.gd

player/
└── PlayerController.gd

ui/
├── ControlSettingsPanel.gd
├── TouchControlUI.gd
└── ButtonControlUI.gd

resources/
└── controls/
    ├── ControlConfig.tres
    ├── GyroscopeConfig.tres
    ├── TouchControlConfig.tres
    └── ButtonControlConfig.tres

==================================================
36. REGRAS IMPORTANTES
==================================================

NÃO colocar lógica de controle diretamente no PlayerController.

NÃO fazer o PlayerController saber qual botão foi pressionado.

NÃO fazer o PlayerController depender do touchscreen.

NÃO fazer o PlayerController depender do giroscópio.

NÃO colocar física dentro da UI.

NÃO colocar configuração diretamente espalhada pelos scripts.

Todos os métodos devem convergir para uma interface comum de input.

==================================================
37. PRIMEIRA IMPLEMENTAÇÃO
==================================================

Implementar inicialmente:

1. ControlManager.

2. PlayerInputState.

3. Touch Invisible Control.

4. Auto Jump.

5. Gyroscope Control.

6. Gyroscope Calibration.

7. Button Control.

8. Manual Jump.

9. Menu de seleção de controle.

10. ControlConfig.tres.

11. Configurações de sensibilidade.

12. Feedback visual.

13. Debug.

14. Salvamento da preferência do jogador.

==================================================
38. TESTES
==================================================

Testar individualmente:

TESTE 1

Toque esquerdo.

Resultado:

personagem gira para esquerda.

TESTE 2

Toque direito.

Resultado:

personagem gira para direita.

TESTE 3

Nenhum toque.

Resultado:

personagem para de receber movimento.

TESTE 4

Auto Jump.

Resultado:

personagem pula automaticamente após aterrissar.

TESTE 5

Giroscópio.

Resultado:

inclinação esquerda/direita controla o movimento.

TESTE 6

Calibração.

Resultado:

posição atual se torna posição neutra.

TESTE 7

Botões.

Resultado:

esquerda/direita movimentam continuamente.

TESTE 8

Botão Jump.

Resultado:

personagem pula quando pressionado.

TESTE 9

Troca de controle.

Resultado:

trocar método não quebra o PlayerController.

==================================================
39. CRITÉRIO DE SUCESSO
==================================================

A implementação será considerada concluída quando:

- o jogador puder escolher entre três métodos;
- cada método controlar o mesmo personagem;
- o movimento ao redor do cilindro funcionar;
- os modos 1 e 2 utilizarem pulo automático;
- o modo 3 utilizar pulo manual;
- o giroscópio possuir calibração;
- a sensibilidade puder ser alterada;
- os botões puderem ser configurados;
- o modo invisível mostrar dicas temporárias;
- os controles puderem ser trocados;
- as configurações puderem ser salvas;
- os parâmetros puderem ser configurados através de `.tres`;
- o PlayerController permanecer independente do método de controle.

O objetivo é criar um sistema de input flexível e preparado para expansão.

No futuro será possível adicionar:

- joystick virtual;
- swipe;
- controle Bluetooth;
- teclado;
- gamepad;
- controle por movimento;
- novos esquemas de acessibilidade.

Todos eles deverão utilizar a mesma interface de input.