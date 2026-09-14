

# PROMPT — HUD DE PROGRESSÃO VERTICAL POR ALTITUDE

```text
Quero implementar uma nova funcionalidade na HUD do meu jogo 3D mobile desenvolvido em Godot 4.x.

A funcionalidade será uma BARRA LATERAL VERTICAL DE PROGRESSÃO.

Ela deverá substituir o indicador simples de altura que existe atualmente no jogo.

O objetivo é transformar a altura do jogador em um objetivo visual contínuo.

O jogador estará escalando um pilar/cilindro vertical potencialmente infinito.

Quanto maior a altura alcançada:

- maior será sua progressão;
- novas metas serão desbloqueadas;
- novos biomas poderão aparecer;
- o jogador terá novos objetivos de altitude.

A barra deve mostrar visualmente:

- altura atual;
- posição atual do jogador;
- próxima meta;
- metas anteriores;
- recorde pessoal.

==================================================
1. OBJETIVO DA FUNCIONALIDADE
==================================================

Criar uma barra vertical fixa na lateral da HUD.

A barra representa a progressão vertical do jogador.

Conceito: Barra lateral vertical na parte esquerda da tela, 

                 ⭐ 2.000 m
                 │
                 │
                 │
                 ● ← jogador
                 │
                 │
                 │
                 ⭐ 1.000 m
                 │
                 │
                 │
                 0 m

O personagem do jogador será representado por um pequeno ícone na barra.

Uma seta/indicador deverá apontar para a posição exata correspondente à altura atual.

==================================================
2. POSIÇÃO NA HUD
==================================================

A barra deve ficar fixa na lateral da tela.

Preferencialmente:

lado esquerdo ou direito da HUD.

Ela NÃO deve acompanhar a câmera do mundo 3D.

Ela pertence à interface 2D.

A posição deve permanecer fixa independentemente de:

- câmera;
- rotação do cilindro;
- movimento do player;
- bioma;
- resolução.

==================================================
3. ESTRUTURA VISUAL
==================================================

Criar aproximadamente:

┌──────────────────────┐
│                      │
│      ⭐ 2.000 m      │
│          │           │
│          │           │
│          ● ← PLAYER  │
│          │           │
│          │           │
│      ⭐ 1.000 m      │
│          │           │
│          │           │
│          0           │
│                      │
│  RECORDE             │
│  1.387 m             │
└──────────────────────┘

A aparência exata poderá ser refinada posteriormente.

O importante é estabelecer a funcionalidade.

==================================================
4. ESCALA DA BARRA
==================================================

A barra NÃO representa todo o mundo infinito.

Ela representa a próxima etapa de progressão.

Inicialmente:

0 → 1.000 metros

Quando o jogador atingir:

1.000 m

a próxima meta será:

2.000 m

Quando atingir:

2.000 m

a próxima meta será:

3.000 m

E assim sucessivamente.

Exemplo:

0 → 1.000
1.000 → 2.000
2.000 → 3.000
3.000 → 4.000
...

Porém, o sistema deve manter a sensação de progressão contínua.

==================================================
5. META ATUAL
==================================================

Criar uma variável:

current_milestone

Inicialmente:

1000

Depois:

2000

Depois:

3000

etc.

A próxima estrela exibida deverá representar:

current_milestone

==================================================
6. CÁLCULO DA POSIÇÃO
==================================================

A posição do jogador na barra deverá ser calculada através da altura real do player.

Exemplo:

current_height = 350

current_milestone = 1000

progress:

350 / 1000 = 0.35

Então o marcador do jogador deverá estar aproximadamente em:

35% da barra.

Exemplo:

0m
│
│
● 350m
│
│
│
│
⭐ 1000m

==================================================
7. QUANDO O PLAYER ATINGIR A META
==================================================

Quando:

current_height >= current_milestone

executar:

1. registrar a meta como alcançada;
2. atualizar a estrela;
3. criar a próxima meta;
4. atualizar a escala da barra;
5. gerar feedback visual;
6. definir nova meta.

Exemplo:

PLAYER:

999m
 ↓
1000m
 ↓
META ALCANÇADA
 ↓
⭐ 1000m
 ↓
NOVA META
 ↓
⭐ 2000m

==================================================
8. COMPORTAMENTO APÓS 1.000m
==================================================

Quando atingir 1.000m:

A barra deve passar a representar:

1.000 → 2.000m

ou utilizar uma janela equivalente de progressão.

A implementação deve evitar que o marcador simplesmente fique parado no topo.

O jogador deve continuar tendo uma meta visível.

Exemplo:

                 ⭐ 2.000
                 │
                 │
                 ● 1.500m
                 │
                 │
                 ⭐ 1.000
```

Continue a implementação considerando a progressão como uma linha do tempo vertical, e não como uma barra que precisa representar simultaneamente toda a altura infinita.

==================================================
9. MARCOS ANTERIORES
====================

As metas já alcançadas devem permanecer visualmente identificáveis.

Exemplo:

⭐ 3.000 m ← meta atual

│

⭐ 2.000 m ← alcançada

│

⭐ 1.000 m ← alcançada

│

0 m

As estrelas anteriores podem ficar:

* menores;
* parcialmente preenchidas;
* com aparência de concluídas;
* com brilho reduzido.

Não remover completamente os marcos alcançados.

==================================================
10. META ATUAL
==============

A próxima meta deve possuir maior destaque.

Exemplo:

⭐ 2.000 m

A estrela pode:

* pulsar suavemente;
* possuir brilho;
* possuir pequena animação;
* possuir efeito quando a meta é atingida.

Evitar animações exageradas.

==================================================
11. ÍCONE DO PLAYER
===================

Criar um indicador visual representando o jogador.

Esse indicador pode ser:

* pequeno retrato;
* ícone da skin;
* miniatura do personagem;
* círculo contendo a cor da skin.

IMPORTANTE:

O indicador deve utilizar a SKIN atualmente selecionada pelo jogador.

Assim:

Skin vermelha
→ marcador vermelho

Skin azul
→ marcador azul

Futuramente, quando houver personagens mais complexos:

→ utilizar uma miniatura correspondente.

==================================================
12. SETA DO PLAYER
==================

Além do ícone, utilizar uma seta indicando a posição.

Exemplo:

```
  ───► ●
       PLAYER
```

ou:

```
      ▼
      ●
```

A seta deve deixar claro que aquele ponto representa a posição atual do jogador.

A seta pode ser integrada ao ícone.

==================================================
13. MOVIMENTO DO INDICADOR
==========================

O indicador do jogador deve acompanhar a altura em tempo real.

Se o jogador estiver subindo:

o marcador sobe.

Se o jogador cair:

o marcador desce.

Se o jogador morrer:

o marcador permanece na última posição até a transição para Game Over.

A atualização deve ser suave.

Não mover o marcador apenas em saltos inteiros.

==================================================
14. SMOOTHING
=============

A posição visual do marcador deve utilizar interpolação suave.

Não fazer:

position = target_position

diretamente.

Utilizar:

lerp

ou:

Tween

ou:

interpolação equivalente.

Isso evita que o marcador fique tremendo.

==================================================
15. ALTURA REAL
===============

A HUD deve obter a altura através de uma fonte central de dados.

Não calcular a altura independentemente na HUD.

Criar ou utilizar um sistema central:

HeightManager

ou:

ProgressManager

Exemplo:

Player
↓
HeightTracker
↓
Current Height
↓
Progression HUD

==================================================
16. ALTURA ATUAL
================

A altura deve continuar existindo como dado numérico.

Exemplo:

current_height = 734.25

A HUD poderá futuramente mostrar:

734 m

ou:

734.2 m

Porém, o foco principal da HUD será a representação visual.

==================================================
17. SUBSTITUIÇÃO DO INDICADOR ANTIGO
====================================

O indicador de altura atual existente no jogo deve ser substituído pela nova barra.

Não manter dois sistemas concorrentes sem necessidade.

O número de metros pode continuar disponível em outra parte da HUD caso seja útil.

Mas a barra deve se tornar o principal indicador de progressão.

==================================================
18. RECORD
==========

A barra também deverá mostrar o recorde pessoal do jogador.

Criar:

personal_best_height

Exemplo:

RECORDE

1.827 m

O recorde deve ser independente da altura atual.

Exemplo:

altura atual:
730m

recorde:
1.827m

==================================================
19. MARCADOR DE RECORDE
=======================

Além do texto, preparar um indicador visual na barra.

Exemplo:

```
      ⭐ 2.000m
         │
         │
```

RECORDE ────►●
│
│
● PLAYER
│
│
⭐ 1.000m

O recorde deve representar a maior altura alcançada pelo jogador.

Caso o recorde esteja fora da faixa visual atual da barra:

adaptar a visualização.

Não deixar o marcador desaparecer sem explicação.

==================================================
20. NOVO RECORDE
================

Quando:

current_height > personal_best_height

atualizar:

personal_best_height

e executar feedback.

Exemplo:

⭐ NOVO RECORDE!

O marcador de recorde acompanha a posição atual.

Depois da partida:

salvar o novo recorde.

==================================================
21. PERSISTÊNCIA DO RECORDE
===========================

Inicialmente salvar localmente.

Exemplo:

user://save_data.dat

ou sistema equivalente.

Salvar:

personal_best_height

Não depender de servidor para essa primeira implementação.

No futuro, o recorde poderá ser sincronizado com:

* Steam;
* servidor;
* perfil online;
* ranking.

==================================================
22. MILESTONES
==============

Não hardcodar apenas:

1000
2000
3000

Criar um sistema configurável.

Exemplo:

MilestoneConfig

ou:

ProgressionConfig.tres

Parâmetros:

milestone_interval = 1000

Ou permitir uma lista:

[
1000,
2000,
3000,
5000,
10000
]

Isso permitirá futuramente criar progressões diferentes.

==================================================
23. PROGRESSÃO CONFIGURÁVEL
===========================

Preparar o sistema para diferentes intervalos.

Exemplo:

0
100
250
500
1000
2000
5000
10000

O jogo poderá futuramente utilizar metas não lineares.

Por isso:

não assumir que toda meta obrigatoriamente é +1000m.

==================================================
24. BIOMES
==========

A barra de progressão deve ser preparada para integração com o sistema de BIOMES.

Cada região de altitude poderá possuir:

BiomeConfig.tres

Exemplo:

0–1000
FOREST

1000–2000
MOUNTAIN

2000–3000
SNOW

3000–4000
CLOUDS

4000–5000
STORM

etc.

A HUD poderá futuramente mostrar:

ícone;
nome;
cor;
tema;
ou pequena indicação do próximo bioma.

NÃO implementar necessariamente essa parte agora.

A arquitetura deve apenas permitir a integração.

==================================================
25. RELAÇÃO ENTRE META E BIOMA
==============================

Preparar para que uma milestone possa representar também:

uma mudança de bioma.

Exemplo:

1000m
⭐
Floresta → Montanha

2000m
⭐
Montanha → Neve

3000m
⭐
Neve → Nuvens

Isso fará com que:

META
+
PROGRESSÃO
+
BIOMA

funcionem juntos.

==================================================
26. FEEDBACK AO ATINGIR MARCO
=============================

Quando o jogador atingir uma estrela:

executar uma pequena sequência:

PLAYER
↓
ATINGE 1000m
↓
⭐ animação
↓
feedback visual
↓
META COMPLETADA
↓
NOVA META
↓
2000m

O feedback pode incluir:

* brilho;
* escala;
* pequena explosão de partículas;
* som;
* vibração mobile;
* texto curto.

Não bloquear o gameplay.

==================================================
27. FEEDBACK VISUAL DA ESTRELA
==============================

Ao atingir:

1000m

a estrela pode:

scale 1.0
→
scale 1.3
→
scale 1.0

e emitir brilho.

Depois:

1000m = concluído

2000m = nova meta.

==================================================
28. ANIMAÇÃO DA BARRA
=====================

Quando uma nova meta for estabelecida:

a barra deve atualizar suavemente.

Evitar:

"teleportar" todos os elementos da HUD instantaneamente.

Utilizar:

Tween

ou animação equivalente.

==================================================
29. INTERFACE RESPONSIVA
========================

A barra deve funcionar em diferentes resoluções.

Considerar:

* celulares;
* tablets;
* diferentes proporções;
* diferentes tamanhos de tela.

Utilizar:

Control
Anchors
Containers

A barra deve permanecer presa à lateral.

==================================================
30. SAFE AREA
=============

Considerar safe areas de dispositivos móveis.

A barra não deve ficar:

* atrás de notch;
* atrás de câmera;
* próxima demais às bordas;
* escondida por elementos do sistema.

==================================================
31. CONFIGURAÇÃO VISUAL
=======================

Criar parâmetros configuráveis.

Exemplo:

ProgressBarConfig.tres

Parâmetros:

bar_width
bar_height
bar_margin
background_opacity
progress_width
player_icon_size
milestone_icon_size
record_marker_size
animation_speed

Também permitir configurar:

font;
font_size;
text_color;
icon_texture.

==================================================
32. CÓDIGO NÃO DEVE DEPENDER DE ASSETS FINAIS
=============================================

Inicialmente utilizar placeholders.

Exemplo:

* círculo para player;
* estrela simples;
* linha para barra;
* texto padrão.

Todos os assets deverão ser substituíveis posteriormente.

Não criar lógica dependente de uma textura específica.

==================================================
33. SKIN DO PLAYER
==================

O ícone do jogador deve estar preparado para receber a skin atual.

Fluxo:

SkinManager
↓
Current Skin
↓
ProgressHUD
↓
PlayerMarker

Se o sistema de skins ainda estiver utilizando uma bola:

utilizar a cor/material da bola.

No futuro:

utilizar ícone/modelo/thumbnail da skin.

==================================================
34. ARQUITETURA
===============

Estrutura sugerida:

HUD/
├── ProgressHUD.tscn
├── ProgressHUD.gd
├── VerticalProgressBar.gd
├── PlayerProgressMarker.gd
├── MilestoneMarker.gd
└── RecordMarker.gd

Systems/
├── HeightTracker.gd
├── ProgressionManager.gd
└── SaveManager.gd

Resources/
└── progression/
└── ProgressionConfig.tres

==================================================
35. RESPONSABILIDADES
=====================

HeightTracker:

Responsável por saber a altura atual.

ProgressionManager:

Responsável por:

* milestone atual;
* próxima milestone;
* milestones alcançadas;
* progresso;
* recorde.

ProgressHUD:

Responsável pela interface.

PlayerProgressMarker:

Responsável pelo marcador do jogador.

MilestoneMarker:

Responsável pelas estrelas.

RecordMarker:

Responsável pelo indicador do recorde.

SaveManager:

Responsável pela persistência.

Não misturar essas responsabilidades.

==================================================
36. DADOS CENTRAIS
==================

Criar estrutura semelhante a:

current_height

personal_best_height

current_milestone

previous_milestone

progress_to_next_milestone

milestones_reached

Esses dados devem estar disponíveis para a HUD.

==================================================
37. EXEMPLO
===========

Jogador começa:

HEIGHT = 0

RECORD = 0

MILESTONE = 1000

HUD:

⭐ 1000m

│

│

● PLAYER

│

│

0m

Jogador chega a:

250m

HUD:

⭐ 1000m

│

│

│

●

│

│

0m

Jogador chega a:

750m

HUD:

⭐ 1000m

│

● PLAYER

│

│

│

0m

Jogador chega a:

1000m

HUD:

⭐ 1000m ✓

│

● PLAYER

│

0m

Evento:

NOVA META: 2000m

==================================================
38. EXEMPLO APÓS ALCANÇAR 2.000m
================================

O sistema passa a mostrar:

⭐ 3000m ← próxima meta

│

│

● PLAYER

│

⭐ 2000m ✓

│

│

⭐ 1000m ✓

│

0m

A posição do player deve sempre representar sua altura relativa à próxima meta.

==================================================
39. PROGRESSÃO INFINITA
=======================

O sistema deve suportar progressão indefinida.

Não criar:

if height > 10000

como limite final.

A próxima milestone deve ser calculada dinamicamente.

Exemplo:

current_milestone = ceil(current_height / interval) * interval

ou utilizar uma lista/configuração de milestones.

O sistema deve funcionar para:

1.000m
10.000m
100.000m
1.000.000m

sem alterar o código principal.

==================================================
40. ALTURA NEGATIVA
===================

Inicialmente assumir:

altura mínima = 0.

O jogador não deve possuir progressão negativa.

Se o player cair:

a altura pode diminuir dentro do gameplay.

A HUD deve refletir a altura real atual.

O recorde NÃO deve diminuir.

==================================================
41. QUEDA
=========

Exemplo:

recorde:
1500m

altura atual:
1200m

Se o jogador cair para:

900m

mostrar:

altura atual = 900m

recorde = 1500m

O recorde permanece.

==================================================
42. MORTE
=========

Quando o player morrer:

manter a HUD funcionando até o início da transição.

Depois:

Game Over.

O recorde deve ser atualizado antes de finalizar a partida.

Fluxo:

PLAYER MORRE
↓
calcular recorde
↓
salvar recorde
↓
Death Transition
↓
GAME OVER

==================================================
43. REINÍCIO
============

Ao iniciar uma nova partida:

current_height = 0

personal_best_height = valor salvo

current_milestone = primeira meta

A barra volta para:

0 → 1000m

mas o recorde continua visível.

==================================================
44. OBJETIVO PSICOLÓGICO
========================

A barra não deve ser apenas um medidor.

Ela deve comunicar:

"Quanto falta para meu próximo objetivo?"

O jogador deve conseguir entender rapidamente:

ONDE ESTOU?

ONDE ESTÁ A PRÓXIMA META?

QUAL FOI MEU RECORDE?

QUANTO FALTA?

==================================================
45. TESTE DA FUNCIONALIDADE
===========================

Criar uma opção de DEBUG para simular altitude.

Exemplo:

[ -100m ]

[ +100m ]

[ +500m ]

[ +1000m ]

Ou:

Height:
[ 0 ] [ 1000 ] [ 5000 ]

Isso permitirá testar:

* milestone;
* recorde;
* queda;
* progressão;
* mudança de escala.

==================================================
46. TESTES NECESSÁRIOS
======================

TESTE 1:

altura = 0

Resultado:

player no início.

TESTE 2:

altura = 500

Resultado:

player no meio da progressão para 1000m.

TESTE 3:

altura = 999

Resultado:

meta ainda não alcançada.

TESTE 4:

altura = 1000

Resultado:

milestone concluída.

TESTE 5:

altura = 1001

Resultado:

nova meta = 2000.

TESTE 6:

altura = 2000

Resultado:

segunda milestone concluída.

TESTE 7:

altura = 1500

recorde = 2000

Resultado:

player em 1500 e recorde em 2000.

TESTE 8:

altura = 2500

recorde = 2000

Resultado:

novo recorde = 2500.

TESTE 9:

altura cai para 1000.

Resultado:

altura atual = 1000.

Recorde permanece:

2500.

==================================================
47. CRITÉRIO DE SUCESSO
=======================

A funcionalidade estará concluída quando:

* existir uma barra vertical fixa na HUD;
* a barra representar progressão de altitude;
* o jogador possuir um marcador;
* o marcador utilizar a skin atual;
* existir uma seta/indicador;
* existir uma estrela para a próxima meta;
* a primeira meta for 1000m;
* novas metas forem criadas progressivamente;
* milestones anteriores permanecerem visíveis;
* o jogador puder cair e o marcador acompanhar;
* existir recorde pessoal;
* recorde permanecer mesmo após queda;
* recorde ser salvo localmente;
* existir feedback ao atingir uma milestone;
* a barra funcionar em diferentes resoluções;
* o sistema suportar progressão indefinida;
* os parâmetros principais forem configuráveis;
* a arquitetura estiver preparada para integração com biomas.

==================================================
48. REGRA ARQUITETURAL PRINCIPAL
================================

A HUD NÃO deve ser responsável por calcular gameplay.

Ela apenas visualiza dados.

Arquitetura:

PLAYER
↓
HEIGHT TRACKER
↓
PROGRESSION MANAGER
↓
┌───────────────────────┐
│                       │
▼                       ▼
HUD                 SAVE SYSTEM
│
├── Player Marker
├── Milestones
├── Next Goal
└── Record Marker

A HUD deve apenas receber:

current_height
current_milestone
personal_best_height
progress

e transformar esses dados em elementos visuais.

````

### Uma alteração importante no conceito

Eu faria a barra funcionar como uma **"régua de objetivo"**, e não como uma representação absoluta do pilar infinito.

Por exemplo, quando o jogador está em **730 m**:

```text
        ⭐ 1.000 m
           │
           │
           ● 730 m
           │
           │
           │
           │
           0 m
````

Ao chegar em **1.000 m**, a régua "avança":

```text
        ⭐ 2.000 m
           │
           │
           │
           ● 1.500 m
           │
           │
        ⭐ 1.000 m ✓
```

E depois:

```text
        ⭐ 3.000 m
           │
           │
           ● 2.400 m
           │
        ⭐ 2.000 m ✓
           │
        ⭐ 1.000 m ✓
```

Isso resolve um problema importante: **o pilar pode ser infinito, mas a HUD continua compacta e legível**.

E, principalmente, isso prepara muito bem a próxima evolução do projeto: fazer as **estrelas coincidirem com mudanças de bioma**. Assim, o jogador não estará simplesmente pensando *"quero chegar a 2.000 metros"*, mas sim:

> **"Estou em 1.650 m. Faltam 350 m para chegar ao próximo bioma."**

A barra passa a ser simultaneamente **progressão + objetivo + recorde + indicação de mundo**.
