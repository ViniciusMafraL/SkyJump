Quero implementar no projeto SkyJump um conjunto de novas plataformas e objetos especiais para expandir as possibilidades de gameplay e criar diferentes situações durante a escalada vertical.

============================================================
1. CONTEXTO DO PROJETO
============================================================

O SkyJump é um jogo 3D desenvolvido na Godot 4.x.

O gameplay principal consiste em um personagem que escala verticalmente um grande cilindro/pilar através de plataformas distribuídas ao redor de sua superfície.

O jogador possui movimentação lateral ao redor do cilindro e pulo automático.

O objetivo principal é utilizar as plataformas e os diferentes elementos do cenário para continuar ganhando altura.

O projeto já possui sistemas básicos de:

- Player 3D;
- movimentação;
- gravidade;
- pulo automático;
- plataformas;
- mundo cilíndrico;
- câmera;
- sistema de altura;
- geração procedural;
- configurações através de Resources/.tres;
- Sala de Testes.

Esta etapa deve ser dedicada exclusivamente à criação e implementação dos novos objetos de gameplay descritos neste documento.

============================================================
2. OBJETIVO DESTA IMPLEMENTAÇÃO
============================================================

Criar uma biblioteca modular de plataformas e objetos especiais que possam ser utilizados no mundo do SkyJump.

Os objetos devem:

- possuir comportamento próprio;
- ser reutilizáveis;
- ser configuráveis;
- funcionar corretamente no mundo cilíndrico;
- interagir corretamente com o Player;
- possuir placeholders visuais;
- poder ser testados individualmente;
- poder ser configurados através do Inspector e/ou Resources .tres;
- estar disponíveis na Sala de Testes.

A arquitetura deve permitir que novos objetos sejam adicionados posteriormente sem necessidade de modificar excessivamente os sistemas existentes.

============================================================
3. IMPORTANTE — BIOMAS
============================================================

O sistema de plataformas especiais deve permanecer separado do sistema de biomas.

Os objetos especiais NÃO devem possuir dependência direta de um bioma específico.

Um mesmo objeto deve poder ser utilizado independentemente do tema visual do mundo.

Posteriormente, o sistema de biomas poderá definir quais objetos especiais podem aparecer em determinado bioma.

Exemplo conceitual:

BIOMA
   ↓
DEFINE OBJETOS PERMITIDOS
   ↓
GERADOR
   ↓
PLATAFORMAS / OBJETOS ESPECIAIS

Porém, essa integração NÃO deve ser implementada nesta etapa.

Nesta etapa deve ser criada apenas uma arquitetura que permita essa separação.

============================================================
4. PLACEHOLDERS VISUAIS
============================================================

Não criar os assets 3D finais.

Todos os objetos deverão utilizar placeholders simples para permitir o desenvolvimento e teste da mecânica.

Podem ser utilizados:

- BoxMesh;
- SphereMesh;
- CylinderMesh;
- CapsuleMesh;
- formas primitivas;
- materiais simples;
- partículas básicas;
- efeitos simples.

Os assets definitivos serão produzidos e substituídos manualmente posteriormente.

A lógica dos objetos NÃO pode depender do modelo visual.

Quando o modelo definitivo for substituído, o comportamento deverá continuar funcionando.

============================================================
5. ARQUITETURA MODULAR
============================================================

Cada objeto especial deve possuir sua própria cena e lógica.

Exemplo:

MovingPlatform.tscn
MovingPlatform.gd

Trampoline.tscn
Trampoline.gd

Portal.tscn
Portal.gd

Cannon.tscn
Cannon.gd

etc.

Evitar criar um único script gigante contendo todos os tipos de plataforma.

Cada objeto deve ser responsável pelo seu próprio comportamento.

Quando existir lógica realmente compartilhada, criar componentes ou classes reutilizáveis.

============================================================
6. CONFIGURAÇÃO
============================================================

Todos os parâmetros importantes devem ser configuráveis.

Utilizar:

- @export;
- Resources;
- arquivos .tres;
- configurações no Inspector.

Evitar valores importantes hardcoded diretamente no código.

Exemplos de parâmetros:

- velocidade;
- força;
- direção;
- distância;
- tempo;
- cooldown;
- duração;
- quantidade de usos;
- retorno;
- ângulo.

============================================================
7. SALA DE TESTES — REQUISITO OBRIGATÓRIO
============================================================

TODOS os objetos implementados neste documento devem poder ser testados na Sala de Testes existente do projeto.

Nenhuma plataforma deve ser considerada concluída se não puder ser facilmente adicionada e testada na Sala de Testes.

A Sala de Testes deve permitir testar individualmente cada objeto.

Exemplo:

SALA DE TESTES

[ Plataforma Normal ]

[ Plataforma Móvel ]

[ Trampolim ]

[ Trampolim Diagonal ]

[ Plataforma-Parede ]

[ Tubo ]

[ Plataforma Deslizante ]

[ Vinhas ]

[ Plataforma Bolha ]

[ Escada ]

[ Portal ]

[ TNT ]

[ Canhão ]

Cada objeto deve poder ser colocado em uma área de teste sem depender da geração procedural do mapa.

============================================================
8. TESTE INDIVIDUAL NA SALA DE TESTES
============================================================

Sempre que possível, a Sala de Testes deverá permitir visualizar e modificar os principais parâmetros dos objetos.

Exemplos:

PLATAFORMA MÓVEL
Speed
Distance
Movement Type

TRAMPOLIM
Jump Force

TNT
Fuse Time
Explosion Force

CANHÃO
Aim Speed
Launch Force
Min Angle
Max Angle

Isso será utilizado para testar e balancear as mecânicas.

Não é necessário criar uma interface complexa caso a Sala de Testes já possua um sistema de configuração.

Priorizar integração com a estrutura existente.

============================================================
9. PLATAFORMA MÓVEL
============================================================

Criar uma plataforma que se movimenta seguindo uma trajetória predefinida.

A plataforma deve poder transportar o Player enquanto ele estiver sobre ela.

Movimentos inicialmente suportados:

- horizontal;
- vertical;
- diagonal.

Preparar a arquitetura para outras trajetórias posteriormente.

Parâmetros:

- posição inicial;
- posição final;
- velocidade;
- aceleração;
- desaceleração;
- loop;
- ping-pong;
- tempo de espera.

Comportamento padrão:

POSIÇÃO INICIAL
↓
MOVIMENTO
↓
DESTINO
↓
RETORNO
↓
LOOP

O Player deve acompanhar corretamente a plataforma.

Evitar:

- player sendo deixado para trás;
- player sendo arremessado incorretamente;
- atravessamento da plataforma;
- comportamento físico instável.

============================================================
10. PLATAFORMA-PAREDE
============================================================

Criar um elemento vertical que permite ao jogador utilizar a parede como ponto de apoio e impulso.

O objetivo é permitir uma sequência de saltos entre paredes.

Exemplo:

PAREDE
   ↘
    PLAYER
       ↘
        PAREDE
           ↘
            PLAYER

O sistema deve detectar o contato do Player.

Ao utilizar a parede, o Player poderá receber um impulso em uma direção configurada.

Parâmetros:

- força do salto;
- direção;
- ângulo;
- tempo de apoio;
- cooldown.

A direção do impulso deve ser previsível.

============================================================
11. TRAMPOLIM DIAGONAL
============================================================

Criar um trampolim capaz de lançar o Player para cima e lateralmente.

Exemplo:

        PLAYER
          ↗
         /
        /
   [TRAMPOLIM]

O lançamento deverá possuir:

- força vertical;
- força horizontal;
- direção.

Parâmetros:

vertical_force
horizontal_force
launch_direction
cooldown

A direção deverá ser baseada na orientação do próprio objeto.

============================================================
12. TRAMPOLIM COMUM
============================================================

Criar um trampolim tradicional.

Ao tocar:

PLAYER
 ↓
TRAMPOLIM
 ↓
IMPULSO VERTICAL

Parâmetros:

- jump_force;
- cooldown;
- multiplicador.

Permitir diferentes intensidades.

Exemplo:

LOW
NORMAL
HIGH
EXTREME

============================================================
13. TUBO TRANSPORTADOR
============================================================

Criar um sistema de tubos que transporta o Player de uma entrada para uma saída.

Durante o transporte:

- o controle normal do Player deve ser suspenso;
- o sistema controla a trajetória;
- o Player percorre o caminho;
- ao chegar à saída, o controle volta ao jogador.

Os tubos devem permitir:

- linhas retas;
- diagonais;
- curvas;
- múltiplas curvas;
- formato em S.

Preferencialmente utilizar Path3D/Curve3D ou solução equivalente.

Parâmetros:

- velocidade;
- trajetória;
- força de saída;
- direção de saída;
- preservação de velocidade.

============================================================
14. SAÍDA DO TUBO
============================================================

Criar um ExitPoint.

Esse ponto deve definir:

- posição;
- orientação;
- direção;
- velocidade de saída.

Ao sair:

TUBO
↓
EXIT POINT
↓
PLAYER
↓
CONTROLE NORMAL

============================================================
15. PLATAFORMA DESLIZANTE
============================================================

Criar uma plataforma que reage à direção de movimentação do Player.

Exemplo:

PLAYER → → →
PLATAFORMA → → →

A plataforma deve poder deslizar de acordo com a direção escolhida.

Parâmetros:

- movement_speed;
- maximum_distance;
- return_speed;
- activation_threshold;
- return_to_start;
- cooldown.

Fluxo:

PLAYER ATIVA
↓
PLATAFORMA SE MOVE
↓
ATINGE LIMITE
↓
PARA / RETORNA

============================================================
16. VINHAS ESCALÁVEIS
============================================================

Criar vinhas verticais ou diagonais que permitam progressão através de pequenos saltos.

As vinhas deverão possuir pontos de apoio.

Exemplo:

│
●
│
●
│
●
│
●

O sistema deve separar:

VISUAL DA VINHA

de:

PONTOS JOGÁVEIS

Assim, o asset visual poderá ser substituído posteriormente.

Parâmetros:

- quantidade de pontos;
- espaçamento;
- tamanho;
- direção;
- inclinação.

============================================================
17. PLATAFORMA BOLHA / TEMPORÁRIA
============================================================

Criar uma plataforma que desaparece após ser ativada.

Fluxo:

PLAYER TOCA
↓
ATIVAÇÃO
↓
AVISO VISUAL
↓
CONTAGEM
↓
DESAPARECE
↓
AGUARDA
↓
REAPARECE

Estados:

IDLE
ACTIVATED
WARNING
DISABLED
RESPAWNING
READY

Parâmetros:

- activation_time;
- disappear_delay;
- respawn_time;
- max_uses;
- auto_respawn.

Cada estado deve possuir feedback visual simples.

============================================================
18. PLATAFORMA ESCADA
============================================================

Criar um conjunto de pequenas plataformas formando uma escada.

Exemplo:

       ●
      ●
     ●
    ●
   ●
  ●

Parâmetros:

- quantidade de degraus;
- tamanho;
- distância horizontal;
- distância vertical;
- rotação.

Tipos:

- reta;
- diagonal;
- zigue-zague;
- alternada.

============================================================
19. PORTAIS
============================================================

Criar um sistema de dois portais conectados.

Exemplo:

PORTAL A
↓
TELETRANSPORTE
↓
PORTAL B

Cada portal deverá possuir:

- identificação;
- destino;
- ponto de entrada;
- ponto de saída;
- orientação.

Fluxo:

PLAYER
↓
DETECTA PORTAL
↓
VALIDA DESTINO
↓
TELEPORTA
↓
PORTAL DE DESTINO
↓
CONTINUA GAMEPLAY

============================================================
20. MOVIMENTAÇÃO APÓS TELEPORTE
============================================================

O sistema deve permitir configurar como a velocidade do Player será tratada.

Opções:

KEEP_VELOCITY
RESET_VELOCITY
REDIRECT_VELOCITY

A opção inicial recomendada é:

REDIRECT_VELOCITY

A velocidade deverá ser adaptada à orientação do portal de saída.

============================================================
21. PROTEÇÃO CONTRA TELEPORTE INFINITO
============================================================

Impedir que o jogador seja teleportado infinitamente entre dois portais.

Utilizar:

- cooldown;
- estado de teleporte;
- bloqueio temporário.

Exemplo:

PORTAL A
↓
PORTAL B
↓
COOLDOWN
↓
PLAYER NÃO PODE REATIVAR IMEDIATAMENTE

============================================================
22. PLATAFORMA TNT
============================================================

Criar uma plataforma explosiva.

Fluxo:

PLAYER TOCA
↓
ATIVA TNT
↓
APROXIMADAMENTE 2 SEGUNDOS
↓
EXPLOSÃO
↓
IMPULSO
↓
PLAYER É LANÇADO

O tempo padrão deve ser aproximadamente 2 segundos, mas deve ser configurável.

Parâmetros:

- fuse_time;
- explosion_force;
- vertical_force;
- horizontal_force;
- explosion_radius;
- cooldown;
- destroy_after_use;
- respawn.

============================================================
23. FEEDBACK DA TNT
============================================================

Criar feedback durante a contagem.

Exemplo:

ATIVAÇÃO
↓
PAVIO
↓
ANIMAÇÃO
↓
CONTAGEM
↓
EXPLOSÃO

Utilizar placeholders para:

- partículas;
- luz;
- animação;
- som.

Os assets finais serão substituídos posteriormente.

============================================================
24. CANHÃO MÓVEL
============================================================

Criar um canhão que permita ao jogador escolher a direção de lançamento.

Fluxo:

PLAYER
↓
ENTRA NO CANHÃO
↓
MODO DE MIRA
↓
ESCOLHE DIREÇÃO
↓
CONFIRMA
↓
DISPARO
↓
PLAYER É LANÇADO
↓
CONTROLE NORMAL

============================================================
25. MODO DE MIRA DO CANHÃO
============================================================

Quando o Player entrar no canhão:

- suspender movimentação normal;
- prender temporariamente o Player;
- ativar modo de mira;
- mostrar uma seta;
- movimentar a seta continuamente;
- permitir confirmação do disparo.

Exemplo:

          ↗
         /
        /
    [CANHÃO]

A seta representa a direção do lançamento.

============================================================
26. MOVIMENTO DA MIRA
============================================================

A mira deve oscilar entre dois ângulos.

Exemplo:

↖
↓
↗
↓
↖

Parâmetros:

- min_angle;
- max_angle;
- aim_speed;
- launch_force.

O jogador deverá confirmar o disparo utilizando o comando de salto existente.

============================================================
27. DISPARO DO CANHÃO
============================================================

Ao confirmar:

CAPTURAR ÂNGULO
↓
CALCULAR VETOR
↓
LIBERAR PLAYER
↓
APLICAR IMPULSO
↓
PLAYER VOANDO
↓
RESTAURAR CONTROLE

O lançamento deve respeitar:

- direção da mira;
- força configurada;
- orientação do canhão.

============================================================
28. ESTADOS DO PLAYER
============================================================

Os objetos especiais devem interagir corretamente com os estados do Player.

Quando necessário, utilizar estados ou flags como:

NORMAL
LAUNCHED
IN_TUBE
IN_CANNON
TELEPORTING
ON_MOVING_PLATFORM

Evitar conflitos entre sistemas.

Exemplo:

Enquanto estiver dentro do tubo:

IN_TUBE

O Player não deve receber controle normal.

Ao sair:

NORMAL

============================================================
29. GRAVIDADE
============================================================

Os objetos especiais devem utilizar o sistema de física e gravidade existente.

Não criar um segundo sistema de gravidade.

Objetos como:

- trampolim;
- trampolim diagonal;
- TNT;
- canhão;

devem aplicar um impulso ou alterar a velocidade do Player e permitir que o sistema de física existente continue funcionando.

Exemplo:

OBJETO
↓
APLICA IMPULSO
↓
GRAVIDADE EXISTENTE
↓
PLAYER CONTINUA TRAJETÓRIA

============================================================
30. COMPATIBILIDADE COM O CILINDRO
============================================================

Todos os objetos devem funcionar corretamente no mundo cilíndrico.

Não assumir que os eixos globais representam diretamente:

- esquerda;
- direita;
- frente;
- trás.

A orientação deverá respeitar o transform/local space do objeto.

Isso é especialmente importante para:

- paredes;
- trampolins diagonais;
- tubos;
- portais;
- TNT;
- canhões.

============================================================
31. ORIENTAÇÃO DOS OBJETOS
============================================================

Os objetos podem estar posicionados em diferentes regiões da circunferência do cilindro.

O comportamento deverá funcionar independentemente da posição angular.

Exemplo:

0°
90°
180°
270°

O vetor de movimento ou lançamento deverá ser calculado a partir da orientação do próprio objeto.

Evitar valores globais fixos sempre que possível.

============================================================
32. RESOURCES .TRES
============================================================

Quando fizer sentido, criar Resources específicos para os objetos.

Exemplos:

MovingPlatformConfig.tres
TrampolineConfig.tres
DiagonalTrampolineConfig.tres
TubeConfig.tres
SlidingPlatformConfig.tres
VineConfig.tres
BubblePlatformConfig.tres
PortalConfig.tres
TNTConfig.tres
CannonConfig.tres

Os Resources devem armazenar dados.

A lógica deve permanecer nos scripts/cenas responsáveis pelo comportamento.

============================================================
33. ORGANIZAÇÃO NO INSPECTOR
============================================================

Organizar parâmetros por categorias.

Exemplo:

[Movement]

Speed
Distance
Acceleration

[Gameplay]

Force
Cooldown
Duration

[Visual]

Effects
Animation

Facilitar o trabalho de configuração e balanceamento.

============================================================
34. FEEDBACK VISUAL
============================================================

Cada objeto deverá possuir feedback visual suficiente para que o jogador entenda sua função.

Exemplos:

Trampolim:
→ direção do impulso

TNT:
→ contagem

Canhão:
→ seta de mira

Portal:
→ indicação de ativação

Bolha:
→ indicação de tempo restante

Plataforma móvel:
→ movimento claramente perceptível

Inicialmente podem ser utilizados efeitos simples.

============================================================
35. FEEDBACK SONORO
============================================================

Preparar pontos de integração para áudio.

Não é necessário criar os sons finais.

Preparar referências para:

activation_sound
launch_sound
break_sound
teleport_sound
explosion_sound

============================================================
36. RESET
============================================================

Todos os objetos que possuírem estados temporários devem possuir comportamento de reset.

Exemplo:

reset()

ou sistema equivalente.

Isso permitirá reiniciar os testes e retornar todos os objetos ao estado inicial.

============================================================
37. ESTADO INICIAL
============================================================

Após reiniciar a Sala de Testes, os objetos devem voltar ao estado inicial.

Exemplos:

TNT
→ READY

Bolha
→ VISIBLE

Plataforma móvel
→ START_POSITION

Canhão
→ IDLE

Portal
→ READY

============================================================
38. DEBUG
============================================================

Criar ferramentas que facilitem o desenvolvimento e balanceamento.

Quando apropriado, permitir:

- ativar manualmente;
- resetar;
- alterar força;
- alterar velocidade;
- alterar direção;
- alterar tempo;
- visualizar direção;
- visualizar trajetória.

Essas ferramentas são principalmente para desenvolvimento.

============================================================
39. COMPATIBILIDADE COM O GERADOR
============================================================

Os objetos devem ser construídos de maneira que possam futuramente ser instanciados pelo sistema de geração procedural existente.

Não é necessário alterar profundamente o gerador nesta etapa.

O importante é que cada objeto possua uma cena independente e possa ser instanciado através de uma referência.

Exemplo conceitual:

MovingPlatform.tscn
Trampoline.tscn
TNT.tscn
Cannon.tscn

O gerador poderá futuramente selecionar essas cenas.

============================================================
40. IDENTIFICAÇÃO DOS OBJETOS
============================================================

Criar uma maneira organizada de identificar os diferentes tipos.

Exemplo:

NORMAL
MOVING
WALL
TRAMPOLINE
DIAGONAL_TRAMPOLINE
TUBE
SLIDING
VINE
BUBBLE
STAIR
PORTAL
TNT
CANNON

Evitar espalhar strings diferentes pelo projeto para identificar os mesmos objetos.

============================================================
41. VALIDAÇÃO DE POSICIONAMENTO
============================================================

Verificar se os objetos funcionam corretamente quando posicionados no cilindro.

Testar:

- colisão;
- posição;
- rotação;
- direção;
- interação;
- lançamento;
- teleporte;
- retorno.

Especial atenção aos objetos direcionais.

============================================================
42. LIMITES
============================================================

Nenhum objeto deve causar comportamento físico capaz de quebrar o gameplay.

Evitar:

- lançar o Player infinitamente;
- teletransportar para posição inválida;
- atravessar geometria;
- lançar o Player para fora do mundo;
- criar loops infinitos;
- causar velocidades absurdamente altas sem configuração.

Criar limites configuráveis quando necessário.

============================================================
43. ORDEM DE IMPLEMENTAÇÃO
============================================================

Implementar nesta ordem:

1. Plataforma Móvel
2. Trampolim Comum
3. Trampolim Diagonal
4. Plataforma-Parede
5. Plataforma Bolha
6. Plataforma Deslizante
7. Plataforma Escada
8. Tubo Transportador
9. Vinhas
10. Portal
11. TNT
12. Canhão Móvel

Começar pelos objetos mais simples.

Após cada objeto:

- implementar;
- adicionar à Sala de Testes;
- testar;
- corrigir;
- validar física;
- validar reset;
- validar configuração;
- somente então avançar.

============================================================
44. CRITÉRIO OBRIGATÓRIO DE CONCLUSÃO
============================================================

Um objeto NÃO deve ser considerado implementado apenas porque sua cena ou código existe.

Para cada objeto, obrigatoriamente:

1. Cena criada.
2. Script implementado.
3. Colisão funcionando.
4. Interação com Player funcionando.
5. Parâmetros configuráveis.
6. Reset funcionando.
7. Feedback visual básico.
8. Compatibilidade com o mundo cilíndrico.
9. Teste realizado.
10. Objeto disponível na Sala de Testes.

============================================================
45. RESULTADO ESPERADO
============================================================

Ao final desta etapa, o SkyJump deverá possuir uma biblioteca funcional de objetos especiais:

- Plataforma Móvel;
- Plataforma-Parede;
- Trampolim;
- Trampolim Diagonal;
- Tubo Transportador;
- Plataforma Deslizante;
- Vinhas;
- Plataforma Bolha;
- Plataforma Escada;
- Portal;
- TNT;
- Canhão Móvel.

Todos os objetos deverão:

- funcionar no mundo cilíndrico;
- interagir com o Player;
- respeitar a física existente;
- possuir configuração;
- utilizar placeholders;
- ser independentes;
- poder ser testados individualmente;
- estar disponíveis na Sala de Testes.

O sistema deverá permanecer separado do sistema de biomas.

No futuro, os biomas poderão definir quais desses objetos fazem parte de cada ambiente, mas essa decisão e integração não devem ser implementadas agora.

============================================================
46. REGRA PRINCIPAL
============================================================

Não tentar desenvolver todas as plataformas simultaneamente.

Implementar uma por vez.

Após implementar cada objeto:

IMPLEMENTAR
↓
ADICIONAR À SALA DE TESTES
↓
TESTAR
↓
CORRIGIR
↓
VALIDAR
↓
AVANÇAR

Priorizar:

- estabilidade;
- simplicidade;
- modularidade;
- reutilização;
- facilidade de configuração;
- compatibilidade com o mundo cilíndrico.

Os assets finais serão substituídos posteriormente.

O objetivo desta etapa é construir uma base sólida e funcional para as mecânicas de plataformas especiais do SkyJump.