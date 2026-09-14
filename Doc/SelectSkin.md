Quero implementar um SISTEMA DE SKINS DO PLAYER no meu jogo 3D mobile desenvolvido em Godot 4.x.

Atualmente o personagem do jogador é apenas uma esfera/bola 3D.

Quero criar uma arquitetura de skins configurável dentro da Godot Engine, permitindo adicionar diferentes aparências para o personagem sem precisar alterar o código principal do PlayerController.

A primeira versão das skins será simples, baseada principalmente em:

- cores;
- materiais;

Porém, a arquitetura deve ser preparada para futuramente suportar:

- modelos 3D diferentes;
- acessórios;
- efeitos;
- materiais especiais;
- animações;
- skins raras;
- skins desbloqueáveis;
- customização mais avançada.

O sistema deve separar completamente:

GAMEPLAY DO PLAYER

de:

APARÊNCIA DO PLAYER.

==================================================
1. OBJETIVO
==================================================

Adicionar ao MENU PRINCIPAL uma seção de seleção de personagem/skin.

A tela inicial deve possuir aproximadamente esta estrutura:

					ESPAÇO LIVRE

			  <    [ PERSONAGEM 3D ]    >

					   JOGAR

					CONTROLES

				 SALA DE TESTE

			 TESTE DE TRANSIÇÕES

O personagem 3D será exibido em uma área própria do menu.

O jogador poderá utilizar:

<

e

>

para navegar entre as skins disponíveis.

Quando uma seta for pressionada:

1. selecionar próxima/anterior skin;
2. atualizar imediatamente o personagem 3D;
3. mostrar visualmente a nova skin;
4. manter a seleção enquanto o jogador estiver no menu.

Quando o jogador clicar em:

JOGAR

a skin atualmente selecionada deverá ser aplicada ao Player da partida.

==================================================
2. PRINCÍPIO IMPORTANTE
==================================================

A skin NÃO deve controlar gameplay.

A skin deve controlar somente aparência.

Exemplo:

PlayerController
	↓
Movimento
Pulo
Gravidade
Colisão
Gameplay

PlayerVisual
	↓
Skin
Material
Modelo
Efeitos
Aparência

Esses sistemas devem permanecer separados.

Trocar a skin nunca deve alterar:

- velocidade;
- pulo;
- gravidade;
- colisão;
- tamanho físico do personagem;
- movimentação;
- gameplay.

==================================================
3. SISTEMA CONFIGURÁVEL DE SKINS
==================================================

Criar um sistema baseado em Godot Resources.

Cada skin deverá ser um Resource.

Criar:

PlayerSkin.gd

extends Resource

Cada Skin deverá possuir informações como:

id
display_name
icon
material
model
preview_rotation
preview_scale
unlocked

A estrutura pode ser adaptada conforme necessário.

==================================================
4. PLAYER SKIN RESOURCE
==================================================

Criar um Resource semelhante a:

PlayerSkin

Propriedades iniciais:

skin_id
display_name
preview_icon
base_color
material
model
is_unlocked

Inicialmente não é necessário utilizar modelos diferentes.

O personagem continuará sendo uma esfera.

A diferença entre as skins poderá ser principalmente:

base_color
material
roughness
metallic
emission

Isso deve permitir criar diferentes aparências rapidamente.

==================================================
5. ARQUIVOS .TRES
==================================================

Criar os Resources como arquivos `.tres`.

Exemplo:

resources/
└── skins/
	├── Skin_Default.tres
	├── Skin_Blue.tres
	├── Skin_Red.tres
	├── Skin_Green.tres
	└── Skin_Yellow.tres

Cada arquivo representa uma skin.

Isso permitirá adicionar novas skins sem alterar o código.

==================================================
6. EXEMPLOS DE SKINS INICIAIS
==================================================

Criar algumas skins de teste.

Exemplo:

DEFAULT

Nome:
Classic

Cor:
branca

Material:
simples

BLUE

Nome:
Ocean

Cor:
azul

RED

Nome:
Ruby

Cor:
vermelha

GREEN

Nome:
Nature

Cor:
verde

YELLOW

Nome:
Sun

Cor:
amarela

Essas cores são apenas exemplos para validar o sistema.

==================================================
7. SKIN DATABASE
==================================================

Criar um sistema que mantenha a lista de skins disponíveis.

Exemplo:

SkinDatabase

ou:

SkinManager

Responsabilidades:

- carregar skins;
- manter lista;
- encontrar skin pelo ID;
- verificar skins desbloqueadas;
- retornar skin selecionada.

Evitar deixar os nomes das skins hardcoded no Menu.

==================================================
8. SKIN MANAGER
==================================================

Criar:

SkinManager.gd

Responsabilidades:

- skin atual;
- seleção;
- aplicação;
- carregamento;
- salvamento;
- consulta das skins disponíveis.

Exemplo de API:

SkinManager.get_current_skin()

SkinManager.set_skin(skin_id)

SkinManager.get_skin(index)

SkinManager.get_skin_count()

SkinManager.next_skin()

SkinManager.previous_skin()

==================================================
9. SKIN SELECTION NO MENU
==================================================

Criar um componente:

SkinSelector

Esse componente deve controlar a interface de seleção.

Estrutura:

SkinSelector
├── PreviousButton
├── CharacterPreview
├── NextButton
└── SkinName

O jogador deve conseguir navegar.

Exemplo:

<

Classic

>

Pressionar:

>

↓

Ocean

Pressionar:

>

↓

Ruby

Pressionar:

>

↓

Nature

==================================================
10. NAVEGAÇÃO CIRCULAR
==================================================

A lista deve ser circular.

Se o jogador estiver na última skin:

>

deve voltar para a primeira.

Exemplo:

Classic
Ocean
Ruby
Nature

Nature + >

→ Classic

Da mesma forma:

Classic + <

→ Nature

Isso evita que o jogador chegue a um estado sem opção.

==================================================
11. PREVIEW 3D
==================================================

A seleção deve utilizar um personagem 3D real.

Não utilizar apenas uma imagem.

Criar uma área de preview no Menu.

Exemplo conceitual:

Menu
└── CharacterPreview
	├── Camera3D
	├── Light
	├── PreviewEnvironment
	└── PlayerPreview

O personagem deve aparecer em 3D.

==================================================
12. PREVIEW ISOLADO
==================================================

O personagem utilizado no menu deve ser uma instância de PREVIEW.

Ele não deve ser o Player real da partida.

O preview existe apenas para mostrar a skin.

Isso evita problemas como:

- física;
- gravidade;
- colisão;
- movimento;
- gameplay.

O preview deve ficar parado.

==================================================
13. CÂMERA DO PREVIEW
==================================================

Criar uma câmera dedicada ao personagem.

A câmera deve mostrar a bola/personagem de maneira centralizada.

Parâmetros configuráveis:

preview_camera_distance
preview_camera_height
preview_fov

O personagem pode possuir uma rotação lenta automática.

Exemplo:

CharacterPreview
	  ↓
rotação suave

Isso deixa o menu mais vivo.

A rotação deve ser opcional.

==================================================
14. ILUMINAÇÃO DO PREVIEW
==================================================

Criar iluminação própria para o preview.

Exemplo:

PreviewEnvironment
├── WorldEnvironment
├── KeyLight
└── FillLight

O objetivo é permitir visualizar corretamente:

- cores;
- materiais;
- brilho;
- efeitos.

A iluminação do menu não deve depender da iluminação do gameplay.

==================================================
15. APLICAÇÃO DA SKIN
==================================================

Criar um componente responsável pela aparência:

PlayerVisual

ou:

PlayerAppearance

Responsabilidades:

- receber uma PlayerSkin;
- aplicar material;
- aplicar modelo;
- aplicar efeitos;
- atualizar visual.

Exemplo:

PlayerAppearance.apply_skin(skin)

O PlayerController não deve realizar essa operação.

==================================================
16. APLICAÇÃO NO GAMEPLAY
==================================================

Quando o jogador selecionar uma skin:

a seleção deve ser armazenada.

Ao clicar:

JOGAR

o Gameplay deve obter:

SkinManager.get_current_skin()

e aplicar a skin ao Player real.

Fluxo:

MENU

SkinSelector
	  ↓
SkinManager
	  ↓
Selected Skin
	  ↓
JOGAR
	  ↓
Gameplay
	  ↓
Player
	  ↓
PlayerAppearance
	  ↓
Skin aplicada

==================================================
17. MOMENTO DE APLICAÇÃO
==================================================

A skin deve ser aplicada antes do jogador começar a controlar o personagem.

Fluxo:

Carregar Gameplay
		↓
Criar Player
		↓
Obter Skin selecionada
		↓
Aplicar Skin
		↓
Inicializar gameplay
		↓
Liberar controle

Isso evita mostrar o personagem padrão por alguns frames antes da skin aparecer.

==================================================
18. PERSISTÊNCIA
==================================================

A skin selecionada deve ser salva localmente.

Se o jogador selecionar:

Ruby

e fechar o jogo:

ao abrir novamente:

Ruby

deve continuar selecionada.

Inicialmente utilizar armazenamento local.

Não implementar conta online.

Não implementar Steam Cloud.

Isso poderá ser adicionado futuramente.

==================================================
19. SKINS DESBLOQUEADAS
==================================================

Preparar o sistema para diferenciar:

UNLOCKED

e:

LOCKED.

Inicialmente todas podem estar desbloqueadas.

Futuramente:

Skin A
✓ desbloqueada

Skin B
🔒 bloqueada

Skin C
🔒 bloqueada

A arquitetura deve permitir que a lógica de desbloqueio seja adicionada depois.

==================================================
20. SKINS BLOQUEADAS
==================================================

Quando futuramente houver skins bloqueadas:

o jogador poderá visualizar a skin, mas não selecioná-la.

A interface pode mostrar:

🔒

ou:

LOCKED

Não implementar sistema de aquisição agora.

==================================================
21. NOME DA SKIN
==================================================

Mostrar o nome da skin abaixo ou acima do personagem.

Exemplo:

<

		  [ BOLA 3D ]

>

		  OCEAN

O nome deve vir do PlayerSkin Resource.

Não deixar os nomes hardcoded no Menu.

==================================================
22. BOTÕES
==================================================

As setas devem ser grandes e fáceis de tocar.

Exemplo:

	   <                         >

			  PLAYER

O botão esquerdo:

previous_skin()

O botão direito:

next_skin()

As setas devem possuir feedback visual quando pressionadas.

==================================================
23. ANIMAÇÃO DE TROCA DE SKIN
==================================================

Quando o jogador mudar de skin:

não realizar uma troca visual completamente instantânea se isso ficar estranho.

Criar uma pequena animação opcional.

Exemplo:

Skin A
 ↓
scale down
 ↓
troca material
 ↓
scale up
 ↓
Skin B

A duração deve ser curta.

Exemplo:

0.15–0.25 segundos.

A animação deve ser opcional/configurável.

Não bloquear o Menu durante a troca.

==================================================
24. EFEITO DE TROCA
==================================================

Opcionalmente permitir:

- pequeno scale;
- rotação;
- brilho;
- partículas;
- fade.

Não criar efeitos complexos inicialmente.

O objetivo é validar a funcionalidade.

==================================================
25. MENU PRINCIPAL
==================================================

Organizar o menu aproximadamente assim:

MAIN MENU

				[ ESPAÇO ]

		  <    CHARACTER    >

				SKIN NAME


				  JOGAR

				CONTROLES

			 SALA DE TESTES

		   TESTE DE TRANSIÇÕES


O menu deve permanecer visualmente limpo.

O personagem 3D deve ser o elemento visual principal.

==================================================
26. ESPAÇO LIVRE
==================================================

A parte superior do menu deve permanecer relativamente livre.

Não preencher a tela com elementos desnecessários.

O personagem deve possuir destaque.

Isso permitirá futuramente adicionar:

- nome;
- raridade;
- descrição;
- efeitos;
- partículas;
- informações da skin.

==================================================
27. RELAÇÃO COM O SISTEMA DE TRANSIÇÕES
==================================================

Ao clicar:

JOGAR

utilizar o TransitionManager já implementado.

Fluxo:

JOGAR
 ↓
TransitionManager
 ↓
Transition OUT
 ↓
Carregar Gameplay
 ↓
Aplicar Skin
 ↓
Transition IN
 ↓
Gameplay

A seleção da skin deve sobreviver à transição.

Não criar um sistema separado de transição.

==================================================
28. RELAÇÃO COM A SALA DE TESTES
==================================================

A Sala de Testes também deve utilizar a skin selecionada.

Fluxo:

Menu
 ↓
Skin selecionada
 ↓
Sala de Testes
 ↓
Player recebe mesma skin

Isso permitirá testar visualmente a skin durante o desenvolvimento.

==================================================
29. RELAÇÃO COM O PLAYER REAL
==================================================

Criar:

PlayerAppearance.gd

O Player real deve possuir:

Player
├── CollisionShape3D
├── PlayerAppearance
│   └── Visual
└── Gameplay Components

A Skin altera apenas:

PlayerAppearance

Nunca:

CollisionShape3D

ou:

PlayerController.

==================================================
30. PREPARAÇÃO PARA MODELOS 3D FUTUROS
==================================================

Embora inicialmente o personagem seja uma esfera, a arquitetura deve suportar futuramente:

Skin A
	└── Sphere

Skin B
	└── Robot

Skin C
	└── Creature

Skin D
	└── Human

O PlayerController deve continuar funcionando.

A skin poderá futuramente definir:

visual_scene

ou:

model_scene

O sistema deverá instanciar o modelo dentro do PlayerAppearance.

==================================================
31. PREPARAÇÃO PARA MATERIAIS
==================================================

Uma skin poderá possuir:

- material;
- textura;
- cor;
- emissão;
- metallic;
- roughness.

Inicialmente utilizar StandardMaterial3D.

Futuramente permitir ShaderMaterials.

==================================================
32. PREPARAÇÃO PARA EFEITOS
==================================================

O Resource de Skin deve permitir futuramente:

particle_effect
trail_effect
aura_effect
spawn_effect

Não é necessário implementar esses efeitos agora.

Apenas estruturar o sistema para receber essas propriedades futuramente.

==================================================
33. PREPARAÇÃO PARA RARIDADE
==================================================

Não implementar sistema de raridade agora.

Porém, deixar o Resource preparado para futuramente possuir:

rarity

Exemplo:

COMMON
UNCOMMON
RARE
EPIC
LEGENDARY

Isso poderá ser utilizado futuramente caso o jogo tenha desbloqueios ou sistemas de coleção.

==================================================
34. CONFIGURAÇÃO .TRES
==================================================

Todos os dados da aparência devem preferencialmente estar nos Resources.

Exemplo:

Skin_Ocean.tres

skin_id:
ocean

display_name:
Ocean

base_color:
blue

material:
StandardMaterial3D

model:
PlayerBall.tscn

unlocked:
true

Isso permitirá criar uma nova skin simplesmente duplicando um `.tres` e alterando seus parâmetros.

==================================================
35. SKIN DATABASE
==================================================

O banco de skins pode utilizar uma lista de Resources.

Exemplo:

SkinDatabase.tres

skins:
[
	Skin_Default.tres,
	Skin_Ocean.tres,
	Skin_Ruby.tres,
	Skin_Nature.tres
]

O sistema deve carregar essa lista.

Adicionar uma nova skin deve ser possível através do Inspector.

Evitar modificar código para adicionar uma nova skin.

==================================================
36. ORGANIZAÇÃO DE ARQUIVOS
==================================================

Estrutura sugerida:

player/
├── Player.tscn
├── PlayerController.gd
└── PlayerAppearance.gd

skins/
├── PlayerSkin.gd
├── SkinManager.gd
└── SkinDatabase.tres

skins/resources/
├── Skin_Default.tres
├── Skin_Ocean.tres
├── Skin_Ruby.tres
├── Skin_Nature.tres
└── Skin_Sun.tres

menu/
├── MainMenu.tscn
├── SkinSelector.tscn
└── SkinSelector.gd

preview/
├── CharacterPreview.tscn
└── CharacterPreview.gd

==================================================
37. RESPONSABILIDADES
==================================================

SkinManager:

Gerencia qual skin está selecionada.

SkinDatabase:

Mantém a lista de skins.

PlayerSkin:

Armazena os dados da skin.

SkinSelector:

Controla a interface.

CharacterPreview:

Mostra o personagem no Menu.

PlayerAppearance:

Aplica a aparência ao Player real.

PlayerController:

Controla somente gameplay.

Essas responsabilidades não devem ser misturadas.
