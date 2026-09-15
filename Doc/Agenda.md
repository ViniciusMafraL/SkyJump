============================================================
SKYJUMP — IMPLEMENTAÇÃO DO DAILY CHALLENGE
============================================================

Implementar no projeto SkyJump um sistema completo de
DAILY CHALLENGE (DESAFIO DIÁRIO), integrado ao sistema atual
de gameplay, temas/biomas, geração procedural de mapas,
checkpoints e menu do jogador.

IMPORTANTE:

- Esta implementação deve ser LOCAL.
- Não implementar servidor, banco de dados online, login,
  ranking online ou sincronização online.
- O progresso deve ser salvo localmente no computador do jogador.
- A data utilizada nesta primeira versão será a data local do
  dispositivo.
- A arquitetura deve ser organizada de forma que futuramente
  seja possível substituir a fonte da data/seed por uma fonte
  externa, mas NÃO implementar essa parte agora.
- Não modificar sistemas existentes que não sejam necessários
  para integrar o Daily Challenge.
- Reutilizar os sistemas existentes de geração de mapa,
  plataformas, checkpoints, temas e personagem sempre que possível.
- Evitar duplicar lógica que já exista no projeto.


============================================================
1. OBJETIVO PRINCIPAL
============================================================

Criar um modo chamado:

DAILY CHALLENGE

Também pode ser exibido como:

DESAFIO DIÁRIO

O Daily Challenge funciona como um desafio diferente a cada dia.

Cada data possui:

1. Uma seed determinística.
2. Um único tema/bioma.
3. Um mapa gerado a partir dessa seed.
4. Três checkpoints.
5. Até três estrelas de progresso através dos checkpoints.
6. Um estado próprio no calendário.
7. Histórico de progresso salvo localmente.

Além disso, o jogador recebe:

+1 estrela ao entrar no jogo pela primeira vez naquele dia.

Portanto, o jogador pode ganhar no máximo:

1 estrela pelo login diário
+
3 estrelas pelos checkpoints

TOTAL:

4 estrelas por dia.


============================================================
2. CALENDÁRIO DO DAILY CHALLENGE
============================================================

Criar um calendário mensal visual para representar os Daily
Challenges.

Estrutura:

             SETEMBRO

     SEG TER QUA QUI SEX SÁB DOM

            1   2   3   4   5   6
            7   8   9  10  11  12  13
           14  15  16  17  18  19  20
           21  22  23  24  25  26  27
           28  29  30

O calendário deve mostrar:

- Dias passados.
- Dia atual.
- Dias futuros.
- Progresso dos dias.
- Dias concluídos.
- Dias em andamento.
- Dias bloqueados/futuros.

O calendário deve utilizar o mês e ano reais do dispositivo.


============================================================
3. ESTADOS DOS DIAS
============================================================

Cada dia deve possuir um estado lógico.

Estados:

FUTURE
AVAILABLE
IN_PROGRESS
COMPLETED
RECORD
ENDED
INVALIDATED

Nesta primeira implementação, priorizar os estados realmente
necessários para o funcionamento:

FUTURE
AVAILABLE
IN_PROGRESS
COMPLETED

Os outros estados devem ser suportados pela arquitetura, mas
não precisam possuir funcionalidades especiais ainda.

--------------------------------
FUTURE
--------------------------------

O dia ainda não chegou.

Exemplo:

16
🔒

O jogador não pode iniciar esse Daily.

Ao selecionar um dia futuro, mostrar uma indicação de que ele
ainda não está disponível.

Exemplo:

AVAILABLE IN 05:42:21

O contador deve representar quanto tempo falta para o início
do dia.

--------------------------------
AVAILABLE
--------------------------------

O dia atual chegou, mas o jogador ainda não iniciou o Daily.

Exemplo:

15
▶ PLAY

Ao selecionar:

PLAY

inicia o Daily correspondente à data.

--------------------------------
IN_PROGRESS
--------------------------------

O jogador iniciou o Daily e possui progresso salvo, mas ainda
não coletou os três checkpoints.

Exemplo:

15

⭐⭐○

CONTINUE

Ao selecionar, o jogador deve poder continuar o Daily.

--------------------------------
COMPLETED
--------------------------------

Os três checkpoints foram coletados.

Exemplo:

15

⭐⭐⭐

✓ COMPLETED

O Daily é considerado concluído.


============================================================
4. DATA DO DAILY
============================================================

Cada Daily deve ser identificado pela sua data.

Formato lógico:

YYYY-MM-DD

Exemplo:

2026-09-15

A data deve ser utilizada como identificador único do Daily.

Nunca utilizar apenas o número do dia.

Errado:

15

Correto:

2026-09-15

Isso evita conflitos entre meses e anos.


============================================================
5. SEED DETERMINÍSTICA
============================================================

O Daily Challenge deve utilizar geração determinística.

A data deve gerar uma seed estável.

Exemplo conceitual:

2026-09-15
      ↓
DAILY SEED
      ↓
THEME
      ↓
MAP GENERATION


A mesma data deve SEMPRE produzir a mesma seed.

Exemplo:

15/09/2026

Seed:

XXXXXXXX

Se o jogador:

- abrir o jogo de manhã;
- fechar o jogo;
- abrir novamente;
- reiniciar o computador;
- jogar à noite;

a seed deve continuar sendo exatamente a mesma.

Não utilizar randomização baseada no momento em que o jogador
abre o jogo.

Não utilizar:

randomize()

para determinar o Daily de maneira não determinística.


============================================================
6. TEMA DO DAILY
============================================================

Atualmente existem 10 temas/biomas disponíveis no SkyJump.

Cada Daily deve possuir exatamente UM tema.

Exemplo:

Dia 1
→ Mountain

Dia 2
→ Snow

Dia 3
→ Clouds


A escolha do tema deve ser determinística.

O mesmo dia deve sempre possuir o mesmo tema.


============================================================
7. REGRA DE ROTAÇÃO DOS TEMAS
============================================================

Implementar uma rotação determinística dos 10 temas.

REGRA PRINCIPAL:

Um mesmo tema NÃO pode aparecer duas vezes dentro da mesma
semana.

Exemplo válido:

SEG → Mountain
TER → Snow
QUA → Clouds
QUI → Forest
SEX → Volcano
SÁB → Desert
DOM → Space

Exemplo inválido:

SEG → Mountain
TER → Snow
QUA → Mountain

Mountain não pode aparecer novamente naquela mesma semana.

Na semana seguinte, os temas podem voltar a aparecer.

Exemplo:

SEMANA 1:
Mountain
Snow
Clouds
Forest
Volcano
Desert
Space

SEMANA 2:
Mountain
Forest
Snow
Clouds
Ocean
Cave
Space


IMPORTANTE:

Não usar simplesmente randomização independente para cada dia.

A lógica deve considerar a semana como unidade de rotação.

Uma abordagem recomendada:

1. Gerar uma seed baseada no ano + número da semana.
2. Criar uma cópia da lista dos 10 temas.
3. Embaralhar a lista utilizando essa seed.
4. Utilizar os primeiros 7 temas para os 7 dias da semana.

Exemplo:

LISTA ORIGINAL:

Mountain
Snow
Clouds
Forest
Volcano
Desert
Ocean
Cave
City
Space

Após embaralhamento determinístico:

Cave
Mountain
Space
Snow
Forest
Ocean
City
Clouds
Desert
Volcano

Semana:

SEG → Cave
TER → Mountain
QUA → Space
QUI → Snow
SEX → Forest
SÁB → Ocean
DOM → City

Na próxima semana, gerar uma nova ordem utilizando uma nova
seed de semana.


============================================================
8. INTEGRAÇÃO COM A GERAÇÃO DO MAPA
============================================================

O Daily deve utilizar o sistema existente de geração procedural
do SkyJump.

Fluxo:

DATA
↓
DAILY SEED
↓
TEMA
↓
LEVEL SEED
↓
GERAÇÃO DO MAPA


O mapa do Daily deve ser reproduzível.

Se dois jogadores tivessem a mesma versão do jogo e a mesma
seed, o sistema deverá produzir a mesma configuração de mapa,
desde que o sistema de geração seja determinístico.

Não criar um segundo sistema de geração de mapas.

Reutilizar o gerador procedural existente.


============================================================
9. CHECKPOINTS
============================================================

Cada Daily possui exatamente 3 checkpoints.

Estrutura:

START
 │
 │
 │
CHECKPOINT 1
500m
 │
 │
 │
CHECKPOINT 2
800m
 │
 │
 │
CHECKPOINT 3
1000m
 │
 │
 └── FINAL


Os valores de distância devem ser CONFIGURÁVEIS.

Não deixar:

500
800
1000

hardcoded em diversos scripts.

Criar uma configuração central:

checkpoint_1_distance
checkpoint_2_distance
checkpoint_3_distance


Exemplo:

checkpoint_1_distance = 500
checkpoint_2_distance = 800
checkpoint_3_distance = 1000


============================================================
10. RECOMPENSA DOS CHECKPOINTS
============================================================

Cada checkpoint concede:

+1 ⭐

Checkpoint 1:
+1 estrela

Checkpoint 2:
+1 estrela

Checkpoint 3:
+1 estrela

Total máximo:

⭐⭐⭐


IMPORTANTE:

A recompensa deve ser concedida SOMENTE UMA VEZ por checkpoint.

Se o jogador alcançar o checkpoint novamente, não receber
outra estrela.


============================================================
11. ESTRELA DE LOGIN DIÁRIO
============================================================

Adicionar uma recompensa diária independente dos checkpoints.

Ao abrir o jogo pela primeira vez naquele dia:

+1 ⭐


Exemplo:

14/09

Primeira abertura:
+1 ⭐

Fecha o jogo.

Abre novamente no mesmo dia:

+0 ⭐


Ao virar para:

15/09

Primeira abertura:

+1 ⭐


O sistema deve registrar a última data em que a recompensa
de login foi concedida.


Exemplo:

last_daily_login_reward = 2026-09-15


Ao abrir:

Se data_atual != last_daily_login_reward:

conceder +1 estrela

e atualizar:

last_daily_login_reward = data_atual


============================================================
12. CURRENCY DE ESTRELAS
============================================================

Criar uma currency global:

STARS

Representação:

⭐ 247

As estrelas devem ser armazenadas no save local do jogador.

Exemplo:

total_stars = 247


As estrelas acumulam permanentemente.

Exemplo:

Dia 14:
+1 login
+3 checkpoints

Total:
+4

Dia 15:
+1 login
+2 checkpoints

Total:
+3

Total acumulado:

+7


A currency não deve ser reiniciada ao trocar o dia.


============================================================
13. PROGRESSO DO DAILY
============================================================

Cada Daily deve possuir seu próprio progresso.

Estrutura conceitual:

DailyProgress:

date
theme
seed

checkpoint_1
checkpoint_2
checkpoint_3

started
completed

record
state


Exemplo:

date = 2026-09-15
theme = Snow
seed = 123456

started = true

checkpoint_1 = true
checkpoint_2 = true
checkpoint_3 = false

completed = false


Após o terceiro checkpoint:

checkpoint_1 = true
checkpoint_2 = true
checkpoint_3 = true

completed = true


============================================================
14. CHECKPOINT PERSISTENTE
============================================================

O progresso deve sobreviver ao fechamento do jogo.

Exemplo:

Dia 15

Player começa:

START
↓
500m
↓
CHECKPOINT 1
↓
+1 ⭐

Depois fecha o jogo.

Ao abrir novamente:

DAILY 15

⭐ CHECKPOINT 1 ✓
⭐ CHECKPOINT 2 ○
⭐ CHECKPOINT 3 ○

O jogador deve poder continuar.

Não reiniciar o progresso do Daily simplesmente porque o jogo
foi fechado.


============================================================
15. CONTINUAÇÃO DO DAILY
============================================================

Se existir um Daily IN_PROGRESS, o calendário deve mostrar:

CONTINUE

em vez de:

PLAY


Exemplo:

15
⭐⭐○

▶ CONTINUE


Ao selecionar:

CONTINUE

o jogo deve carregar o Daily correspondente à data salva e
retomar o progresso.


============================================================
16. MUDANÇA DE DIA / 00:00
============================================================

O Daily atual muda quando a data local do dispositivo muda.

Exemplo:

14/09
23:59

Daily 14 está disponível.

Ao virar:

15/09
00:00

Daily 15 passa a ser o Daily atual.

PORÉM:

o progresso do Daily anterior não deve ser apagado.

Se o jogador havia iniciado o Daily 14 e ainda não terminou:

Daily 14:
⭐⭐○
CONTINUE

Daily 15:
▶ PLAY


O jogador deve poder continuar o Daily anterior conforme a
regra de histórico definida para o modo.

Não apagar progresso automaticamente à meia-noite.


============================================================
17. ESTRELAS MOSTRADAS NO CALENDÁRIO
============================================================

O calendário deve mostrar visualmente o progresso dos
checkpoints de cada dia.

Cada Daily possui três estrelas de progresso:

○ ○ ○
⭐ ○ ○
⭐ ⭐ ○
⭐ ⭐ ⭐


Exemplo:

Dia 14

⭐⭐⭐

Dia 15

⭐⭐○

Dia 16

🔒


IMPORTANTE:

A estrela de LOGIN DIÁRIO não deve ser confundida com as
três estrelas de progresso do Daily.

As três estrelas exibidas no calendário representam os
CHECKPOINTS.

A estrela de login pertence à currency global do jogador.


============================================================
18. DAILY COMPLETED
============================================================

Um Daily é considerado COMPLETED quando:

checkpoint_1 == true
checkpoint_2 == true
checkpoint_3 == true


Ao completar:

state = COMPLETED

completed = true


O calendário deve atualizar visualmente o dia.


============================================================
19. STREAK
============================================================

Preparar um sistema de sequência diária.

Exemplo:

Dia 8 → COMPLETED
Dia 9 → COMPLETED
Dia 10 → COMPLETED
Dia 11 → COMPLETED
Dia 12 → COMPLETED
Dia 13 → COMPLETED
Dia 14 → COMPLETED

Resultado:

🔥 7 DAYS


Ao completar o Daily seguinte:

🔥 8 DAYS


O sistema deve possuir:

current_streak
best_streak


Exemplo:

current_streak = 7
best_streak = 12


Nesta implementação, o comportamento de quebra do streak deve
ser separado da lógica principal e facilmente configurável.

Não criar ainda recompensas especiais de streak.


============================================================
20. FUTURAS RECOMPENSAS DE STREAK
============================================================

Preparar a arquitetura para futuramente permitir:

7 dias
→ recompensa

14 dias
→ recompensa

30 dias
→ recompensa especial

100 dias
→ recompensa rara


NÃO implementar essas recompensas agora.

Apenas garantir que o sistema de streak permita adicionar
milestones posteriormente sem refatorar completamente o sistema.


============================================================
21. SAVE LOCAL
============================================================

Todo o sistema deve ser salvo localmente.

O save deve possuir, no mínimo, informações equivalentes a:

PLAYER

total_stars

last_daily_login_reward

current_streak

best_streak


DAILY HISTORY

Para cada Daily necessário:

date
seed
theme

started

checkpoint_1
checkpoint_2
checkpoint_3

completed

state


Não salvar dados redundantes que possam ser reconstruídos
deterministicamente.

Por exemplo:

O tema pode ser recalculado pela data/seed.

Porém, se for mais seguro para a arquitetura atual, ele pode
ser armazenado junto ao progresso.


============================================================
22. ARQUITETURA DO SAVE
============================================================

O sistema deve ser criado de maneira modular.

Separar:

1. Dados do jogador
2. Dados do Daily
3. Gerenciamento do calendário
4. Geração da seed
5. Seleção do tema
6. Recompensa diária
7. Recompensas dos checkpoints
8. Streak
9. Persistência do save
10. Interface do calendário


Evitar colocar toda a lógica em um único script.


============================================================
23. DATA MANAGER
============================================================

Criar uma camada responsável pela data do jogo.

Exemplo conceitual:

DailyDateManager

Responsabilidades:

- obter data atual;
- obter ano;
- obter mês;
- obter dia;
- identificar semana;
- calcular próxima mudança de dia;
- calcular tempo restante para o próximo Daily.


Não espalhar chamadas de data pelo projeto inteiro.

Isso permitirá futuramente substituir a fonte da data por uma
fonte externa sem modificar todos os sistemas.


============================================================
24. DAILY SEED MANAGER
============================================================

Criar uma camada responsável pelas seeds.

Responsabilidades:

get_daily_seed(date)

get_week_seed(year, week)

get_theme_for_date(date)

A mesma entrada deve sempre produzir o mesmo resultado.


Exemplo:

get_daily_seed(2026-09-15)

→ sempre retorna a mesma seed.


============================================================
25. THEME ROTATION MANAGER
============================================================

Criar um sistema responsável exclusivamente pela rotação
dos temas.

Entrada:

data

Saída:

tema daquele dia.


Regras:

- Existem 10 temas.
- Uma semana possui 7 dias.
- Cada tema só pode aparecer uma vez dentro daquela semana.
- Semana seguinte pode repetir temas.
- A escolha é determinística.
- Não depender do momento em que o jogo foi aberto.


============================================================
26. DAILY MANAGER
============================================================

Criar um sistema central para controlar o Daily Challenge.

Responsabilidades:

- descobrir Daily atual;
- descobrir Daily anterior;
- descobrir Daily futuro;
- obter estado do Daily;
- iniciar Daily;
- continuar Daily;
- registrar checkpoint;
- verificar conclusão;
- recuperar progresso salvo;
- gerar seed;
- descobrir tema;
- atualizar histórico.


Conceitualmente:

DailyManager

├── get_current_daily()
├── get_daily(date)
├── get_daily_state(date)
├── start_daily(date)
├── continue_daily(date)
├── register_checkpoint(index)
├── is_completed(date)
└── get_daily_progress(date)


============================================================
27. STAR MANAGER
============================================================

Criar um sistema responsável pela currency.

Responsabilidades:

get_stars()

add_stars(amount)

can_claim_daily_login()

claim_daily_login()

claim_checkpoint_reward(daily_date, checkpoint)


Exemplo:

add_stars(1)


Nunca permitir que o mesmo checkpoint seja recompensado duas
vezes.


============================================================
28. INTEGRAÇÃO COM CHECKPOINT
============================================================

Quando o jogador alcançar um checkpoint:

1. Detectar o checkpoint.
2. Verificar se aquele checkpoint já foi coletado.
3. Se NÃO foi coletado:
   - marcar como coletado;
   - conceder +1 estrela;
   - salvar imediatamente.
4. Se já foi coletado:
   - não conceder recompensa;
   - não duplicar o progresso.


O save deve ocorrer imediatamente após uma recompensa ser
concedida para reduzir risco de perda de progresso.


============================================================
29. RECOMPENSA DE LOGIN
============================================================

A recompensa diária deve ser processada na inicialização
do jogo.

Fluxo:

ABRIR JOGO
↓
OBTER DATA LOCAL
↓
VERIFICAR last_daily_login_reward
↓
É UM NOVO DIA?
↓
SIM
↓
+1 STAR
↓
ATUALIZAR SAVE


Se não for um novo dia:

não conceder recompensa novamente.


============================================================
30. INTERFACE DA CURRENCY
============================================================

Adicionar a quantidade de estrelas no menu do jogador.

Exemplo:

⭐ 247


A quantidade deve ser atualizada imediatamente quando o jogador
ganhar uma estrela.

Ao ganhar:

+1 ⭐

O valor total deve ser atualizado.

Exemplo:

247
↓
248


A apresentação visual pode utilizar a identidade visual
pixel-art existente do SkyJump.


============================================================
31. FEEDBACK DE RECOMPENSA
============================================================

Ao ganhar uma estrela, apresentar feedback visual simples.

Exemplo:

⭐ +1

ou:

+1 ⭐

Esse feedback deve ser utilizado tanto para:

- login diário;
- checkpoint.


Não criar ainda sistemas complexos de animação.


============================================================
32. CALENDÁRIO — COMPORTAMENTO
============================================================

Ao abrir o Daily Challenge:

1. Mostrar o mês atual.
2. Mostrar os dias.
3. Identificar o dia atual.
4. Bloquear dias futuros.
5. Mostrar progresso dos dias anteriores.
6. Mostrar o progresso do Daily atual.
7. Permitir selecionar dias jogáveis.
8. Mostrar o estado de cada dia.


Exemplo:

DIA 14
⭐⭐⭐
COMPLETED

DIA 15
⭐⭐○
CONTINUE

DIA 16
🔒
FUTURE


============================================================
33. DIA FUTURO
============================================================

Ao clicar em um dia futuro:

NÃO iniciar o jogo.

Mostrar:

LOCKED

ou:

AVAILABLE IN

com contador até o próximo dia.


O jogador não deve conseguir iniciar um Daily futuro
manipulando apenas a interface.


============================================================
34. HISTÓRICO
============================================================

Os Daily anteriores devem permanecer registrados.

Exemplo:

10
⭐⭐⭐

11
⭐⭐

12
⭐

13
⭐⭐⭐

14
⭐⭐⭐

15
⭐⭐○


O jogador deve conseguir visualizar o histórico dos Daily
anteriores.


============================================================
35. SEGURANÇA DA LÓGICA LOCAL
============================================================

Como o sistema é totalmente local, não é necessário criar
proteção contra manipulação do save nesta versão.

Entretanto:

- evitar duplicação de recompensas;
- validar os dados carregados;
- tratar save inexistente;
- tratar save corrompido;
- utilizar valores padrão quando necessário;
- não conceder recompensas simplesmente por carregar um arquivo
  de progresso.


============================================================
36. PRIMEIRA EXECUÇÃO
============================================================

Se o jogador nunca abriu o jogo:

Não deve existir histórico anterior.

Ao iniciar:

1. Criar save.
2. Identificar data atual.
3. Criar Daily atual.
4. Conceder a primeira recompensa diária:
   +1 ⭐
5. Registrar a data do login.
6. Permitir acesso ao Daily atual.


============================================================
37. MUDANÇA DE MÊS
============================================================

O calendário deve funcionar corretamente quando o mês mudar.

Exemplo:

30/09
↓
01/10

O sistema deve:

- mudar o mês mostrado;
- gerar o Daily correspondente;
- manter histórico de setembro;
- iniciar o Daily de outubro;
- manter a currency de estrelas.


============================================================
38. MUDANÇA DE ANO
============================================================

O sistema também deve funcionar corretamente entre anos.

Exemplo:

31/12/2026
↓
01/01/2027

A seed deve considerar o ano.

Não permitir que:

01/01/2026

e

01/01/2027

tenham necessariamente o mesmo Daily apenas porque possuem
o mesmo mês/dia.


============================================================
39. RESET / TESTE
============================================================

Criar ferramentas/configurações de DEBUG para permitir testar
o sistema sem precisar esperar dias reais.

O modo de teste deve permitir, quando ativado:

- definir uma data simulada;
- avançar um dia;
- testar Daily futuro;
- testar mudança de semana;
- testar mudança de mês;
- testar mudança de ano;
- testar recompensa diária;
- testar checkpoints;
- testar streak;
- resetar progresso do Daily.


IMPORTANTE:

Essas ferramentas devem estar disponíveis apenas em modo de
desenvolvimento/debug e não devem interferir na versão final.


============================================================
40. TESTES OBRIGATÓRIOS
============================================================

Testar pelo menos os seguintes cenários:

TESTE 1
Primeira abertura do jogo.

Resultado:
+1 estrela.


TESTE 2
Fechar e abrir novamente no mesmo dia.

Resultado:
nenhuma estrela adicional de login.


TESTE 3
Alcançar checkpoint 1.

Resultado:
+1 estrela.


TESTE 4
Alcançar checkpoint 1 novamente.

Resultado:
nenhuma estrela adicional.


TESTE 5
Alcançar os três checkpoints.

Resultado:
+3 estrelas totais dos checkpoints.


TESTE 6
Fechar o jogo após checkpoint 1.

Abrir novamente.

Resultado:
checkpoint 1 permanece coletado.


TESTE 7
Continuar Daily após fechar o jogo.

Resultado:
progresso restaurado.


TESTE 8
Virar o dia.

Resultado:
novo Daily.


TESTE 9
Daily anterior iniciado e incompleto.

Resultado:
progresso não desaparece.


TESTE 10
Verificar tema do mesmo dia várias vezes.

Resultado:
mesmo tema.


TESTE 11
Verificar seed do mesmo dia várias vezes.

Resultado:
mesma seed.


TESTE 12
Gerar os 7 dias de uma semana.

Resultado:
nenhum tema repetido.


TESTE 13
Gerar semana seguinte.

Resultado:
temas podem repetir.


TESTE 14
Abrir calendário em mês diferente.

Resultado:
datas e Daily corretos.


TESTE 15
Testar streak.

Resultado:
sequência aumenta ao completar Daily consecutivos.


============================================================
41. CRITÉRIOS DE ACEITAÇÃO
============================================================

A implementação só deve ser considerada concluída quando:

[ ] Daily Challenge existe como modo separado.

[ ] Calendário mensal funciona.

[ ] Data atual é identificada corretamente.

[ ] Dias futuros são bloqueados.

[ ] Daily atual pode ser iniciado.

[ ] Daily iniciado pode ser continuado.

[ ] Cada data possui seed determinística.

[ ] A mesma data sempre produz a mesma seed.

[ ] Existem 10 temas disponíveis.

[ ] Cada Daily possui exatamente um tema.

[ ] Tema não se repete dentro da mesma semana.

[ ] Tema pode repetir na semana seguinte.

[ ] O mapa utiliza a seed do Daily.

[ ] Existem 3 checkpoints.

[ ] Cada checkpoint concede +1 estrela.

[ ] O mesmo checkpoint não concede recompensa duas vezes.

[ ] Login diário concede +1 estrela.

[ ] Login diário só pode ser recebido uma vez por data.

[ ] Currency de estrelas é persistente.

[ ] Progresso do Daily é persistente.

[ ] Calendário mostra as três estrelas dos checkpoints.

[ ] Daily pode ser marcado como COMPLETED.

[ ] Streak é atualizado ao completar Daily.

[ ] Melhor streak é armazenado.

[ ] Mudança de dia funciona.

[ ] Mudança de mês funciona.

[ ] Mudança de ano funciona.

[ ] Save local funciona.

[ ] Dados inválidos/corrompidos são tratados.

[ ] Existe modo de teste/debug para simular datas.

[ ] Não existe dependência de servidor.

[ ] Não existe dependência de conexão com internet.


============================================================
42. PRINCÍPIO DE IMPLEMENTAÇÃO
============================================================

Priorizar código:

- modular;
- reutilizável;
- determinístico;
- configurável;
- fácil de testar;
- compatível com os sistemas existentes;
- sem hardcodes desnecessários;
- sem duplicação de lógica.


A implementação deve ser feita respeitando a arquitetura atual
do projeto SkyJump.

Antes de criar novos sistemas, verificar se já existem:

- sistema de save;
- sistema de temas;
- sistema de geração procedural;
- sistema de checkpoints;
- sistema de menu;
- sistema de player data;
- sistema de calendário/interface.

Se esses sistemas já existirem, integrar-se a eles em vez de
criar versões paralelas.


============================================================
43. RESULTADO FINAL ESPERADO
============================================================

O jogador deve experimentar o seguinte fluxo:

ABRE O SKYJUMP
       ↓
RECEBE
+1 ⭐ DAILY REWARD
       ↓
MENU
       ↓
DAILY CHALLENGE
       ↓
CALENDÁRIO
       ↓
SELECIONA O DIA ATUAL
       ↓
PLAY
       ↓
DAILY DEFINE:
- SEED
- TEMA
- MAPA
       ↓
JOGA
       ↓
CHECKPOINT 1
+1 ⭐
       ↓
CHECKPOINT 2
+1 ⭐
       ↓
CHECKPOINT 3
+1 ⭐
       ↓
DAILY COMPLETED
       ↓
STREAK +1
       ↓
PROGRESSO SALVO
       ↓
VOLTA AO CALENDÁRIO
       ↓
DIA MOSTRA:
⭐⭐⭐


No dia seguinte:

NOVO DAILY
↓
NOVA SEED
↓
NOVO TEMA
↓
NOVO MAPA

O histórico anterior permanece.

