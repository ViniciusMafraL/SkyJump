Quero implementar uma SALA DE TESTES no meu jogo 3D desenvolvido em Godot 4.x.

Essa sala será utilizada exclusivamente durante o desenvolvimento para testar, ajustar e balancear as principais mecânicas do jogo.

O jogo é um platformer vertical em torno de um cilindro central. O jogador se movimenta ao redor do cilindro, pula entre plataformas e sobe verticalmente.

A sala de testes NÃO deve representar uma fase normal do jogo.

Ela deve ser uma área pequena, controlada e prática para testar rapidamente diferentes valores de gameplay.

==================================================
1. OBJETIVO DA SALA
==================================================

Criar uma pequena área de testes contendo:

- um cilindro menor;
- poucas plataformas;
- personagem;
- sistema de movimento;
- sistema de pulo;
- gravidade;
- plataformas especiais;
- possíveis habilidades futuras;
- botão para abrir as configurações da sala.

A sala deve permitir alterar parâmetros de gameplay em tempo real.

O objetivo é conseguir testar uma mecânica sem precisar alterar o código, reiniciar o projeto ou gerar uma fase inteira.

Fluxo:

Entrar na Sala de Testes
		↓
Escolher parâmetros
		↓
Fechar configurações
		↓
Testar mecânica
		↓
Alterar parâmetros
		↓
Testar novamente

==================================================
2. ESTRUTURA DA SALA
==================================================

A sala deve possuir um cilindro menor do que o cilindro utilizado no jogo principal.

Ela deve possuir poucas plataformas distribuídas ao redor do cilindro.

A distribuição das plataformas deve ser propositalmente simples.

Não é necessário utilizar geração procedural infinita nessa sala.

O objetivo é facilitar testes.

Exemplo:

			  Plataforma
				   ■

		■                   ■


			  ║       ║
			  ║ PILAR ║
			  ║       ║
		■                   ■

				   ●
				 PLAYER

O jogador deve conseguir testar:

- pulo vertical;
- distância de salto;
- movimento angular;
- aterrissagem;
- trampolins;
- gravidade;
- diferentes configurações de plataforma.

==================================================
3. BOTÃO DE CONFIGURAÇÕES
==================================================

Adicionar um botão visível na interface:

CONFIGURAÇÕES DA SALA

Esse botão abre uma janela/painel de configuração.

A janela deve ser criada de maneira modular para futuramente receber novos parâmetros.

Exemplo:

------------------------------------
	   CONFIGURAÇÕES DA SALA
------------------------------------

MOVIMENTO

Velocidade:
[------●----------]

CONTROLES DE PULO

Força do pulo:
[---------●-------]

Gravidade:
[------●----------]

TRAMPOLIM

Força:
[-----------●-----]

ITENS

[✓] Permitir itens

HABILIDADES

[✓] Permitir habilidades

------------------------------------

	   [ APLICAR ]

	   [ RESETAR ]

------------------------------------

==================================================
4. CONFIGURAÇÃO DO PULO
==================================================

Criar parâmetros editáveis para o sistema de pulo.

No mínimo:

jump_force
jump_height
jump_cooldown
air_control

A interface deve permitir modificar esses valores.

IMPORTANTE:

Sempre que possível, não utilizar valores mágicos diretamente no PlayerController.

O Player deve receber suas configurações através de um objeto de configuração.

Exemplo conceitual:

Player
   ↓
PlayerMovementConfig
   ↓
jump_force
gravity
air_control

==================================================
5. TAMANHO / ALTURA DO PULO
==================================================

Quero poder testar diferentes alturas de salto.

A configuração deve permitir controlar o comportamento do pulo de forma intuitiva.

Idealmente, disponibilizar:

Altura do Pulo

e/ou

Força do Pulo

Se for necessário, implementar uma relação entre os parâmetros físicos.

Exemplo:

jump_force = X
gravity = Y

resultando em:

jump_height ≈ X² / (2Y)

O sistema deve manter consistência entre os valores.

A interface deve deixar claro qual parâmetro está sendo alterado.

==================================================
6. GRAVIDADE
==================================================

Adicionar controles para os parâmetros de gravidade.

No mínimo:

gravity
fall_speed_limit

Permitir testar:

- gravidade baixa;
- gravidade normal;
- gravidade alta.

Exemplo de comportamento:

Gravidade baixa:
pulo mais longo e flutuante.

Gravidade normal:
pulo padrão.

Gravidade alta:
queda rápida.

A alteração deve poder ser aplicada sem reiniciar o jogo.

==================================================
7. TRAMPOLINS
==================================================

A sala deve possuir pelo menos uma plataforma do tipo TRAMPOLIM.

O trampolim será utilizado para testar saltos especiais.

Criar configuração:

trampoline_force

Opcionalmente:

trampoline_horizontal_force
trampoline_cooldown
trampoline_bounce_multiplier

Quando o personagem pousar no trampolim:

vertical_velocity = trampoline_force

ou utilizar uma função equivalente que produza o comportamento esperado.

A força deve poder ser alterada na janela de configuração.

Exemplo:

Força do Trampolim:
[---------●-------]

Valor atual:
18.0

Ao alterar para 25.0:

O próximo salto produzido pelo trampolim deve utilizar 25.0.

==================================================
8. APLICAÇÃO DAS CONFIGURAÇÕES EM TEMPO REAL
==================================================

As configurações da sala devem poder ser aplicadas durante a execução.

Ao clicar:

APLICAR

o sistema deve atualizar os componentes relevantes.

Exemplo:

Configuração
	  ↓
SettingsManager
	  ↓
PlayerController
	  ↓
Trampoline
	  ↓
Gameplay Systems

Evitar reiniciar a cena inteira sempre que uma configuração for alterada.

Se uma propriedade não puder ser aplicada imediatamente por razões técnicas, aplicar no próximo estado seguro, como o próximo salto.

==================================================
9. RESET DAS CONFIGURAÇÕES
==================================================

Adicionar botão:

RESETAR

Esse botão deve restaurar os valores padrão.

Exemplo:

Pulo:
10

Gravidade:
20

Trampolim:
20

Os valores reais devem ficar centralizados em uma configuração padrão.

Não duplicar os valores padrão em vários scripts.

==================================================
10. RESOURCES .TRES
==================================================

As configurações da sala devem utilizar Godot Resources.

Criar Resources específicos.

Exemplo:

PlayerMovementConfig.gd
PlayerMovementConfig.tres

PhysicsConfig.gd
PhysicsConfig.tres

TrampolineConfig.gd
TrampolineConfig.tres

TestRoomConfig.gd
TestRoomConfig.tres

O TestRoomConfig deve poder reunir as principais configurações.

Exemplo:

TestRoomConfig
├── movement_config
├── physics_config
├── trampoline_config
├── item_config
└── ability_config

Os arquivos `.tres` devem permitir editar os valores diretamente pelo Inspector.

==================================================
11. ITENS FUTUROS
==================================================

A sala deve possuir uma seção:

ITENS

Essa seção NÃO precisa implementar os itens ainda.

Ela deve preparar a arquitetura para futuras mecânicas.

Criar opções como:

[ ] Itens habilitados

[ ] Itens de movimento

[ ] Itens defensivos

[ ] Itens de mobilidade

[ ] Itens especiais

Ou utilizar uma estrutura mais apropriada para o projeto.

IMPORTANTE:

Não implementar itens fictícios apenas para preencher a interface.

Criar a infraestrutura de configuração para que os itens possam ser adicionados futuramente.

==================================================
12. HABILIDADES FUTURAS
==================================================

Criar também uma seção:

HABILIDADES

Inicialmente:

[ ] Habilidades habilitadas

Depois permitir futuramente selecionar quais habilidades estarão disponíveis.

Exemplo conceitual:

[ ] Dash
[ ] Double Jump
[ ] Air Dash
[ ] Wall Jump
[ ] Grappling Hook
[ ] Shield

Essas habilidades NÃO precisam ser implementadas agora.

A arquitetura deve apenas preparar o sistema para elas.

Não criar funcionalidades falsas.

==================================================
13. SISTEMA DE FEATURE FLAGS
==================================================

Utilizar uma estrutura de configuração que permita ativar/desativar sistemas.

Exemplo:

features.enable_items
features.enable_abilities
features.enable_double_jump
features.enable_dash

Isso será útil durante o desenvolvimento.

A sala de testes deve funcionar como um laboratório de gameplay.

==================================================
14. CONFIGURAÇÃO POR PRESETS
==================================================

Além dos valores individuais, criar futuramente suporte a presets.

Exemplo:

DEFAULT
LOW_GRAVITY
HIGH_GRAVITY
HIGH_JUMP
LOW_JUMP
TRAMPOLINE_TEST

A interface pode possuir:

PRESET:
[ Default ▼ ]

[ APLICAR ]

Isso permitirá testar rapidamente diferentes sensações.

Não é obrigatório implementar todos os presets na primeira versão, mas a arquitetura deve permitir adicioná-los.

==================================================
15. VISUAL DA SALA
==================================================

Utilizar apenas placeholders.

O cilindro pode ser um CylinderMesh simples.

As plataformas podem ser BoxMesh.

O jogador pode ser uma CapsuleMesh ou outro objeto simples.

Não investir em arte.

O objetivo é validar gameplay.

Todos os objetos visuais deverão poder ser substituídos futuramente sem alterar a lógica.

==================================================
16. SEPARAÇÃO ENTRE DADOS E LÓGICA
==================================================

Não colocar configurações diretamente nos scripts.

Evitar:

const GRAVITY = 20
const JUMP_FORCE = 10

quando esses valores precisarem ser alterados durante os testes.

Preferir:

PhysicsConfig
PlayerMovementConfig
TrampolineConfig

Os scripts devem consumir esses Resources.

Isso permitirá posteriormente utilizar configurações diferentes para:

- sala de testes;
- jogo normal;
- fases específicas;
- eventos;
- modos de jogo.

==================================================
18. TEST ROOM MANAGER
==================================================

Criar um TestRoomManager responsável por:

- iniciar a sala;
- carregar configurações;
- aplicar configurações;
- resetar configurações;
- controlar presets;
- informar os sistemas sobre alterações.

Não colocar toda a lógica no painel de UI.

A UI apenas modifica dados.

Exemplo:

TestSettingsPanel
	   ↓
SettingsManager
	   ↓
TestRoomManager
	   ↓
Gameplay Systems

==================================================
19. PAINEL DE CONFIGURAÇÕES
==================================================

O painel deve utilizar controles apropriados da Godot:

- Slider;
- SpinBox;
- CheckButton;
- CheckBox;
- OptionButton.

Para valores numéricos, mostrar o valor atual.

Exemplo:

Força do Pulo
[----------●-----]
10.0

Gravidade
[------●---------]
20.0

Força do Trampolim
[-------------●--]
25.0

Isso facilita o ajuste fino.

==================================================
20. ATUALIZAÇÃO VISUAL
==================================================

Sempre que possível, mostrar os valores atuais no painel.

Exemplo:

GRAVIDADE
20.0

PULO
12.0

TRAMPOLIM
25.0

O desenvolvedor deve conseguir testar diferentes valores rapidamente.

==================================================
21. REINICIAR O TESTE
==================================================

Adicionar também:

[ REINICIAR TESTE ]

Esse botão deve:

- reposicionar o jogador;
- restaurar o estado das plataformas;
- manter ou não as configurações atuais dependendo da escolha.

Idealmente:

REINICIAR TESTE

mantém as configurações atuais.

Enquanto:

RESETAR CONFIGURAÇÕES

restaura os valores padrão.

Essas duas ações devem ser independentes.

==================================================
23. TESTES DE GAMEPLAY
==================================================

A sala deve permitir testar rapidamente perguntas como:

- O pulo está alto demais?
- O personagem cai rápido demais?
- É possível alcançar a próxima plataforma?
- O trampolim lança o personagem suficientemente alto?
- O controle no ar está bom?
- A distância angular está adequada?
- A câmera mostra a próxima plataforma?
- O jogador consegue completar uma volta no cilindro?
- A gravidade proporciona uma sensação agradável?

A sala deve ser construída para responder essas perguntas rapidamente.

==================================================
24. PREPARAÇÃO PARA O JOGO PRINCIPAL
==================================================

A sala de testes não deve possuir uma lógica completamente separada da lógica do jogo.

Ela deve utilizar os mesmos sistemas principais do jogo:

- PlayerController;
- Physics;
- Platform;
- Trampoline;
- CameraRig;
- InputController.

A diferença é que a sala fornece configurações controláveis.

Isso é importante porque qualquer melhoria feita durante o teste deve continuar funcionando no jogo principal.

==================================================
25. PRIMEIRA VERSÃO
==================================================

Implementar inicialmente somente:

1. Sala de testes.

2. Cilindro pequeno.

3. Poucas plataformas.

4. Player.

5. Gravidade.

6. Pulo.

7. Movimento ao redor do cilindro.

8. Câmera orbital.

9. Uma plataforma normal.

10. Uma plataforma trampolim.

11. Painel de configurações.

12. Configuração da força do pulo.

13. Configuração da gravidade.

14. Configuração da força do trampolim.

15. Botão Aplicar.

16. Botão Resetar Configurações.

17. Botão Reiniciar Teste.

18. Estrutura `.tres`.

19. Debug Information.

20. Estrutura preparada para itens e habilidades futuras.


==================================================
27. CRITÉRIO DE SUCESSO
==================================================

A implementação será considerada funcional quando for possível:

1. Entrar na sala de testes.

2. Controlar o personagem.

3. Pular entre plataformas.

4. Dar a volta no cilindro.

5. Utilizar um trampolim.

6. Abrir o painel de configurações.

7. Alterar a força do pulo.

8. Alterar a gravidade.

9. Alterar a força do trampolim.

10. Aplicar as alterações.

11. Testar imediatamente o novo comportamento.

12. Resetar os valores.

13. Reiniciar a tentativa.

14. Visualizar informações de debug.

15. Ativar/desativar opções futuras de itens e habilidades.

16. Alterar os valores através de Resources `.tres`.

O resultado deve funcionar como um "laboratório de física e gameplay" do projeto.
