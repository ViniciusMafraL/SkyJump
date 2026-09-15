## SISTEMA DE DISTRIBUIÇÃO DE PLATAFORMAS POR BIOMA — SKYJUMP

Implementar no SkyJump um sistema de distribuição de plataformas baseado em biomas/temas.

O objetivo é fazer com que cada tema tenha uma identidade própria de gameplay durante a subida do nível, utilizando diferentes combinações de plataformas especiais.



### REGRA PRINCIPAL

A Plataforma Comum deve continuar sendo, em todos os temas, o tipo de plataforma mais frequente na geração dos mapas.

As plataformas especiais existem para variar a gameplay, criar situações diferentes de movimentação e introduzir desafios e oportunidades diferentes durante a subida.

Portanto, as plataformas especiais NÃO devem substituir a plataforma comum como elemento predominante do mapa.

Cada tema deve possuir:

* 1 plataforma especial característica, que será a plataforma especial mais comum daquele tema;
* 5 plataformas especiais secundárias, que aparecerão com frequências menores e diferentes entre si;
* 6 tipos de plataformas especiais disponíveis no total por tema.

A plataforma característica deve ajudar a definir a identidade mecânica do bioma.

---

# TIPOS DE PLATAFORMA ESPECIAL

Utilizar os seguintes tipos já definidos para o projeto:

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

Não criar novos tipos de plataforma neste momento.

---

# TEMAS E SUAS PLATAFORMAS

## Theme_Castle

Plataforma característica:

* Plataforma-Parede

Plataformas secundárias:

* Plataforma Móvel
* Trampolim Comum
* Plataforma Escada
* Canhão Móvel
* TNT

Identidade de gameplay:
O tema deve favorecer movimentação vertical e utilização de paredes, criando uma sensação de progressão técnica durante a subida.

---

## Theme_Winter

Plataforma característica:

* Plataforma Deslizante

Plataformas secundárias:

* Trampolim Comum
* Trampolim Diagonal
* Plataforma Bolha
* Plataforma Escada
* Vinhas

Identidade de gameplay:
O tema deve favorecer movimentação, timing e antecipação das trajetórias das plataformas.

---

## Theme_Forest

Plataforma característica:

* Vinhas

Plataformas secundárias:

* Plataforma Móvel
* Trampolim Comum
* Plataforma-Parede
* Plataforma Escada
* Tubo Transportador

Identidade de gameplay:
O tema deve transmitir a sensação de utilizar elementos naturais para continuar subindo pelo cenário.

---

## Theme_Magma

Plataforma característica:

* TNT

Plataformas secundárias:

* Plataforma Móvel
* Trampolim Diagonal
* Plataforma Deslizante
* Canhão Móvel
* Portal

Identidade de gameplay:
O tema deve possuir uma sensação mais perigosa e imprevisível, utilizando a TNT como principal elemento especial.

---

## Theme_Spooky

Plataforma característica:

* Portal

Plataformas secundárias:

* Plataforma Bolha
* Plataforma Móvel
* Plataforma-Parede
* Tubo Transportador
* TNT

Identidade de gameplay:
O tema deve criar sensação de imprevisibilidade e alteração de rota, utilizando portais para modificar o caminho da subida.

---

## Theme_Windy

Plataforma característica:

* Canhão Móvel

Plataformas secundárias:

* Trampolim Diagonal
* Plataforma Móvel
* Plataforma Deslizante
* Plataforma Bolha
* Portal

Identidade de gameplay:
O tema deve favorecer grandes deslocamentos, mudanças de trajetória e movimentação horizontal.

---

## Theme_Electricity

Plataforma característica:

* Trampolim Diagonal

Plataformas secundárias:

* Plataforma Móvel
* Plataforma Deslizante
* Tubo Transportador
* Portal
* Canhão Móvel

Identidade de gameplay:
O tema deve favorecer velocidade, impulsos diagonais e sequências rápidas de movimentação.

---

## Theme_Waterfall

Plataforma característica:

* Tubo Transportador

Plataformas secundárias:

* Trampolim Comum
* Trampolim Diagonal
* Plataforma Bolha
* Vinhas
* Plataforma Móvel

Identidade de gameplay:
O tema deve criar sensação de fluxo, utilizando tubos e outras plataformas para transportar o jogador entre diferentes regiões da subida.

---

## Theme_MudWorld

Plataforma característica:

* Plataforma Bolha

Plataformas secundárias:

* Plataforma Móvel
* Trampolim Comum
* Plataforma Deslizante
* Vinhas
* TNT

Identidade de gameplay:
O tema deve transmitir instabilidade e movimentação menos previsível.

---

## Theme_Totem

Plataforma característica:

* Trampolim Comum

Plataformas secundárias:

* Plataforma-Parede
* Trampolim Diagonal
* Plataforma Escada
* Portal
* Tubo Transportador

Identidade de gameplay:
O tema deve favorecer sequências de saltos e utilização contínua de impulsos para manter a progressão vertical.

---

# DISTRIBUIÇÃO DE FREQUÊNCIA

A geração deve utilizar pesos para controlar a frequência das plataformas.

A prioridade geral deve ser:

1. Plataforma Comum — extremamente predominante
2. Plataforma especial característica do tema — especial mais frequente
3. Especial secundária 1
4. Especial secundária 2
5. Especial secundária 3
6. Especial secundária 4
7. Especial secundária 5

Como ponto de partida, utilizar aproximadamente:

* Plataforma Comum: 65%
* Especial característica: 12%
* Especial secundária 1: 7%
* Especial secundária 2: 6%
* Especial secundária 3: 4%
* Especial secundária 4: 3%
* Especial secundária 5: 3%

Os valores devem ser tratados como pesos configuráveis, permitindo balanceamento posterior sem necessidade de alterar a lógica de geração.

A soma deve ser normalizada pelo sistema caso necessário.

---

# REGRAS IMPORTANTES DE GERAÇÃO

A plataforma comum deve continuar aparecendo constantemente durante a subida.

As plataformas especiais devem ser utilizadas para quebrar a repetição da gameplay, e não para transformar o mapa em uma sequência contínua de plataformas especiais.

A plataforma característica de cada tema deve aparecer mais frequentemente do que qualquer outra plataforma especial daquele tema.

As cinco plataformas secundárias devem possuir pesos diferentes para evitar que todas apareçam com a mesma frequência.

A seleção da plataforma deve ser separada da posição da plataforma.

Primeiro o sistema deve determinar qual tipo de plataforma será utilizado.

Depois o sistema deve determinar uma posição válida para aquela plataforma considerando:

* posição atual do jogador;
* alcance de salto;
* altura da próxima plataforma;
* distância horizontal;
* direção da progressão;
* colisões;
* plataformas próximas;
* características específicas da plataforma escolhida.

Não gerar plataformas especiais em posições impossíveis de alcançar.

---

# SISTEMA CONFIGURÁVEL POR TEMA

A arquitetura deve permitir que cada tema possua sua própria configuração de plataformas.

Exemplo conceitual:

Theme_Castle:

* Common Platform → 65
* Wall Platform → 12
* Moving Platform → 7
* Common Trampoline → 6
* Stairs Platform → 4
* Mobile Cannon → 3
* TNT → 3

Theme_Winter:

* Common Platform → 65
* Sliding Platform → 12
* Common Trampoline → 7
* Diagonal Trampoline → 6
* Bubble Platform → 4
* Stairs Platform → 3
* Vines → 3

Seguir o mesmo padrão para todos os outros temas.

Não é necessário utilizar exatamente esses valores como valores permanentes. Eles devem ser facilmente editáveis para futuros testes de balanceamento.

---

# SEPARAÇÃO ENTRE TEMA E PLATAFORMA

Não criar lógica específica de geração diretamente espalhada pelo código de cada bioma.

Criar uma estrutura de configuração que permita definir:

* tema;
* plataforma característica;
* plataformas disponíveis;
* peso de cada plataforma;
* prioridade/frequência;
* regras específicas futuras.

O gerador de mapa deve consultar essa configuração para saber quais plataformas podem aparecer naquele tema.

Isso permitirá adicionar novos temas e novas plataformas posteriormente sem precisar reescrever o sistema principal de geração.

---

# SALA DE TESTES

Todas as plataformas devem continuar disponíveis para teste individual na Sala de Testes do SkyJump.

A implementação do sistema de temas NÃO deve remover ou esconder plataformas da Sala de Testes.

A Sala de Testes deve permitir verificar individualmente o comportamento de cada uma das 12 plataformas:

* Plataforma Móvel
* Trampolim Comum
* Trampolim Diagonal
* Plataforma-Parede
* Plataforma Bolha
* Plataforma Deslizante
* Plataforma Escada
* Tubo Transportador
* Vinhas
* Portal
* TNT
* Canhão Móvel

Também deve ser possível testar os temas separadamente para verificar se a distribuição de plataformas está respeitando a configuração de cada bioma.

---

# OBJETIVO FINAL

O resultado deve fazer com que os dez temas tenham diferenças reais de gameplay.

O jogador deve sentir que:

* a Plataforma Comum continua sendo a base do SkyJump;
* cada bioma possui uma mecânica especial predominante;
* as outras cinco plataformas especiais aparecem como variações;
* diferentes temas apresentam diferentes combinações de desafios;
* a subida de cada bioma possui uma identidade própria;
* a geração continua sendo jogável e previsível o suficiente para o jogador entender as mecânicas;
* o sistema seja facilmente balanceável e expansível no futuro.

Não implementar funcionalidades futuras que não estejam descritas neste prompt.

Não criar novas plataformas ou mecânicas além das especificadas.

Priorizar uma arquitetura organizada, modular e configurável, permitindo ajustar posteriormente as frequências e combinações de cada tema sem alterar o núcleo do gerador de mapas.
