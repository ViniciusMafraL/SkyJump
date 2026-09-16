
## Objetivo

Implementar a nova identidade visual e interface do **Sky Jump**, substituindo a UI atual pela nova UI apresentada nos assets de referência fornecidos.

A implementação deve ser feita de forma **nativa dentro do projeto**, utilizando os componentes de UI do jogo e mantendo todos os elementos funcionais/interativos.

Os mockups enviados devem ser tratados como **referência visual principal** para espaçamento, hierarquia, proporções, posicionamento, tipografia, cores, ícones e aparência geral.

**Não utilizar os mockups como uma imagem única de fundo para simular a interface.**

Cada elemento da interface deve continuar sendo um componente independente e funcional.

---

# 1. Nova identidade visual

Aplicar a nova identidade visual em todo o jogo.

A mudança deve ser global, não limitada apenas ao menu principal.

### Fonte

Substituir a fonte atualmente utilizada pelo jogo pela fonte:

**Outfit ExtraBold**

A nova fonte deve ser aplicada globalmente aos elementos textuais da UI, incluindo:

* títulos;
* botões;
* menus;
* textos auxiliares;
* números;
* contadores;
* calendário;
* informações de tema;
* streak;
* textos de seleção;
* textos de status;
* qualquer outro texto pertencente à interface.

Priorizar a utilização da variante:

**Outfit ExtraBold**

A aparência da tipografia deve seguir os mockups:

* letras grandes;
* peso elevado;
* aparência amigável;
* alta legibilidade;
* textos centralizados quando indicado;
* contorno/sombra quando necessário para reproduzir o visual apresentado.

### Importante

Não simplesmente aumentar o tamanho da fonte para compensar a troca.

Recalibrar:

* `font_size`;
* espaçamento;
* alinhamento;
* margens;
* tamanho dos botões;
* altura dos elementos;
* posicionamento dos textos.

A nova fonte deve parecer integrada ao layout, e não apenas substituída mecanicamente.

---

# 2. Paleta de cores

Utilizar a seguinte paleta como base oficial da nova UI:

| Nome            | Hex       |
| --------------- | --------- |
| Preto           | `#000000` |
| Verde           | `#0ACF83` |
| Azul            | `#3759FF` |
| Vermelho escuro | `#CC1919` |
| Roxo            | `#CC9EFF` |
| Vermelho        | `#CF0000` |
| Coral           | `#FA5F45` |
| Amarelo         | `#FFC100` |
| Branco          | `#FFFFFF` |

Criar uma configuração centralizada para essas cores, evitando espalhar valores hex diretamente pelos scripts/cenas.

Exemplo conceitual:

```text
SkyJumpColors
├── BLACK
├── GREEN
├── BLUE
├── DARK_RED
├── PURPLE
├── RED
├── CORAL
├── YELLOW
└── WHITE
```

Caso o projeto já possua um sistema de tema/cores, integrar a nova paleta nesse sistema em vez de criar uma estrutura paralela.

---

# 3. Assets fornecidos

Utilizar os seguintes arquivos fornecidos para a implementação:

### Referências de UI

* `Group 2085667766.png`
* `Group 2085667767.png`
* `f47afb19-f55a-4a72-b66b-2af144017d20.png`

Essas imagens representam referências dos novos layouts da interface.

### Ícones

* `icon-strike.png`
* `icon-star.png`
* `icon-bronze.png`
* `icon-prata.png`

### Background do calendário

* `BackgroundAgenda.png`

Os assets devem ser utilizados diretamente no projeto, preservando sua qualidade e transparência.

Não redesenhar os ícones utilizando formas primitivas caso os arquivos fornecidos já possam ser utilizados.

---

# 4. Ícones de status/moedas

Implementar os novos ícones apresentados.

## Streak

Asset:

`icon-strike.png`

Utilizar para representar o sistema de **Streak**.

Exemplo visual:

```text
🔥 1 Streak
```

O ícone deve aparecer antes do número/texto quando utilizado como indicador.

---

## Bronze

Asset:

`icon-bronze.png`

Representa a medalha/ícone de bronze.

Utilizar nos locais onde o jogo apresenta a classificação/recompensa correspondente.

---

## Prata

Asset:

`icon-prata.png`

Representa a medalha/ícone de prata.

---

## Estrelas

Asset:

`icon-star.png`

Representa a currency de estrelas do Sky Jump.

O contador deve seguir o padrão visual apresentado nos mockups:

```text
⭐ 1
```

O número deve ser um elemento de texto separado do ícone para permitir atualização dinâmica.

Não transformar o contador inteiro em uma imagem.

---

# 5. Menu Principal

Atualizar o menu principal para seguir a referência visual apresentada.

Estrutura aproximada:

```text
[contador de bronze] [contador de prata] [contador de estrelas]


              Sky Jump


             [Ruby]
              personagem


            [ Day ]

          🔥 1 Streak

         [ Infinity ]

         [ Training ]

         [ Options ]
```

### Título

Exibir:

**Sky Jump**

Utilizar:

* Outfit ExtraBold;
* branco;
* grande;
* centralizado.

---

## Personagem

Manter o personagem selecionável atualmente utilizado pelo jogo.

Na referência existe:

* personagem centralizado;
* nome `RUBY`;
* setas laterais para navegação.

Preservar a funcionalidade existente de seleção de personagem.

As setas devem permanecer interativas.

---

# 6. Botões principais

Atualizar os botões para o novo padrão visual.

Botões principais:

* `Day`
* `Infinity`
* `Training`
* `Options`

Cada botão deve possuir:

* cantos arredondados;
* aparência sólida;
* texto em Outfit ExtraBold;
* texto centralizado;
* tamanho consistente;
* espaçamento vertical consistente.

Utilizar a paleta fornecida.

A aparência aproximada deve seguir:

### Day

Amarelo:

`#FFC100`

### Infinity

Coral/vermelho:

`#FA5F45`

### Training

Verde:

`#0ACF83`

### Options

Roxo:

`#CC9EFF`

Não transformar esses botões em imagens estáticas.

Devem continuar sendo botões reais com estados:

* normal;
* hover;
* pressed;
* disabled, quando necessário.

---

# 7. Sistema de calendário / Day

Atualizar completamente a interface do modo **Day** para seguir a segunda referência visual.

A tela deve possuir aparência de uma agenda/calendário.

Estrutura:

```text
┌─────────────────────────────┐
│        September            │
│           2026              │
│                             │
│    [ calendário mensal ]    │
│                             │
│        🔥 1 Streak          │
│                             │
│  15 September   Theme:Jungle│
│                             │
│          [ Play ]           │
└─────────────────────────────┘
```

---

# 8. Background do calendário

Utilizar:

`BackgroundAgenda.png`

como background da tela de calendário.

O asset já representa o visual de uma agenda/calendário e deve ser utilizado como base visual.

### Importante

O background deve permanecer como **background visual**.

Os elementos funcionais devem ser renderizados por cima dele:

* mês;
* ano;
* setas;
* dias;
* seleção do dia;
* ícones;
* streak;
* tema;
* botão Play.

Não utilizar o texto ou calendário contido no mockup como imagem estática se esses elementos precisam ser dinâmicos.

---

# 9. Cabeçalho do calendário

Implementar:

### Mês

Exemplo:

**September**

### Ano

Exemplo:

**2026**

O mês e ano devem continuar sendo gerados dinamicamente pelo sistema.

Não deixar `September` e `2026` fixos.

Adicionar setas de navegação:

```text
◀ September ▶
       2026
```

As setas devem continuar funcionais caso a navegação entre meses seja suportada pelo sistema.

---

# 10. Calendário

Criar o calendário utilizando elementos reais de UI.

Estrutura:

```text
SEG TER QUA QUI SEX SÁB DOM

       1   2   3   4   5   6
   7   8   9  10  11  12  13
  14  [15] 16  17  18  19  20
  21  22  23  24  25  26  27
  28  29  30
```

Cada dia deve ser um elemento individual.

O sistema deve continuar podendo determinar:

* dia atual;
* dias anteriores;
* dias futuros;
* dia selecionado;
* dia disponível;
* dia bloqueado.

---

# 11. Dia selecionado

O dia atualmente selecionado deve possuir destaque visual seguindo a referência.

Exemplo:

```text
    15
   ⭐⭐⭐
```

O destaque deve ser implementado através de UI real, e não como parte fixa do background.

A seleção deve mudar de acordo com o dia selecionado pelo jogador.

---

# 12. Streak no calendário

Adicionar:

```text
🔥 1 Streak
```

Utilizando o asset:

`icon-strike.png`

O valor deve ser dinâmico.

Não utilizar `1` como valor fixo.

Exemplo:

```text
🔥 1 Streak
🔥 5 Streak
🔥 17 Streak
```

---

# 13. Informações do Daily Challenge

Na parte inferior do calendário apresentar:

```text
15 September      Theme: Jungle
```

O dia deve ser dinâmico.

O tema também deve ser dinâmico.

Exemplo:

```text
15 September      Theme: Jungle
```

O nome do tema deve utilizar a cor apropriada da nova paleta.

Não alterar o sistema existente de geração dos temas; apenas adaptar a apresentação visual para a nova UI.

---

# 14. Botão Play

Adicionar o botão:

**Play**

Na parte inferior da tela.

Utilizar o mesmo padrão visual dos botões do menu.

O botão deve:

* possuir estado hover;
* possuir estado pressed;
* ser clicável;
* iniciar o Daily Challenge selecionado;
* respeitar as regras atuais de disponibilidade do modo Day.

---

# 15. Contadores superiores

No menu e onde aplicável, implementar a nova apresentação dos recursos:

```text
🥉 1    🥈 1    ⭐ 1
```

Cada elemento deve ser composto por:

```text
[ícone] [valor]
```

e não uma única imagem.

Os valores precisam ser conectados aos sistemas reais do jogo.

Exemplo:

```text
Bronze: player.bronze
Prata: player.silver
Stars: player.stars
```

Se esses sistemas ainda não estiverem conectados, criar a camada de UI preparada para receber os valores posteriormente, sem criar valores falsos permanentes.

---

# 16. Escala e responsividade

A UI deve ser construída de forma que o layout permaneça consistente em diferentes resoluções.

Não posicionar todos os elementos apenas através de coordenadas absolutas.

Utilizar os sistemas de layout do Godot quando apropriado:

* Containers;
* anchors;
* size flags;
* margins;
* separation;
* alignment.

O objetivo é preservar a composição visual dos mockups sem deixar a UI quebrar caso a resolução ou escala da janela seja alterada.

---

# 17. Separação entre visual e lógica

Manter separadas:

### Lógica

* seleção de personagem;
* calendário;
* seleção de dia;
* streak;
* stars;
* medalhas;
* temas;
* navegação;
* iniciar partida.

### Visual

* cores;
* fonte;
* ícones;
* background;
* espaçamentos;
* botões;
* labels;
* animações da UI.

Evitar colocar lógica de gameplay diretamente dentro dos componentes puramente visuais.

---

# 18. Organização assets

Organizar os assets de forma clara.

Exemplo:

art/
Fonte
C:\Code\sky-jump\art\outfit

art/
        backgrounds/
            BackgroundAgenda.png

        icons/
            icon-strike.png
            icon-star.png
            icon-bronze.png
            icon-prata.png

        references/
            Group 2085667766.png
            Group 2085667767.png
```
---

# 19. Animações e feedback visual

Adicionar pequenos feedbacks visuais aos elementos interativos, sem fugir do estilo apresentado.

Botões:

* leve alteração de escala ou posição no hover;
* feedback visual ao pressionar;
* transição curta e suave.

Calendário:

* feedback ao selecionar um dia;
* destaque claro do dia selecionado.

Setas:

* feedback ao passar o mouse;
* feedback ao clicar.

As animações devem ser sutis.

**Não adicionar efeitos exagerados que não estejam alinhados com o estilo visual atual do Sky Jump.**

---

# 20. Fidelidade visual

Usar as imagens fornecidas como referência principal.

Observar especialmente:

* proporção dos elementos;
* distância entre componentes;
* tamanho dos textos;
* peso da fonte;
* arredondamento dos botões;
* alinhamento;
* hierarquia visual;
* tamanho dos ícones;
* relação entre ícone e texto;
* espaçamento vertical;
* posicionamento do personagem;
* composição do calendário.

O resultado deve parecer uma implementação real da mesma identidade visual apresentada nos mockups.

---

# 21. Compatibilidade com funcionalidades existentes

**Não quebrar nenhuma funcionalidade existente.**

A implementação deve alterar principalmente a camada visual.

Preservar:

* navegação entre menus;
* seleção de personagem;
* modo Day;
* modo Infinity;
* Training;
* Options;
* sistema de Streak;
* sistema de Stars;
* calendário;
* seleção de datas;
* sistema de temas;
* início das partidas.

Se algum elemento visual atualmente possuir lógica própria, refatorar apenas quando necessário para adequá-lo à nova arquitetura.

---

# 22. Critérios de aceitação

A implementação será considerada concluída quando:

* [ ] Outfit ExtraBold estiver aplicada globalmente à UI.
* [ ] Nova paleta estiver centralizada e sendo utilizada.
* [ ] Novo menu principal estiver visualmente alinhado ao mockup.
* [ ] Botões `Day`, `Infinity`, `Training` e `Options` estiverem atualizados.
* [ ] Personagem e seleção continuarem funcionando.
* [ ] Ícone de Streak estiver implementado.
* [ ] Ícone de Bronze estiver implementado.
* [ ] Ícone de Prata estiver implementado.
* [ ] Ícone de Stars estiver implementado.
* [ ] Contadores forem dinâmicos.
* [ ] Tela Day estiver atualizada.
* [ ] `BackgroundAgenda.png` estiver sendo utilizado.
* [ ] Calendário continuar sendo gerado dinamicamente.
* [ ] Dia selecionado possuir destaque visual.
* [ ] Streak aparecer na tela do calendário.
* [ ] Data selecionada aparecer dinamicamente.
* [ ] Tema do dia aparecer dinamicamente.
* [ ] Botão Play estiver funcional.
* [ ] UI funcionar corretamente em diferentes resoluções.
* [ ] Nenhum mockup for utilizado como uma imagem única para substituir componentes funcionais.
* [ ] Nenhuma funcionalidade existente for quebrada.

---

## Regra final de implementação

**Prioridade: fidelidade visual + funcionalidade + organização do código.**

Não criar novas mecânicas ou sistemas de gameplay nesta tarefa.

Esta tarefa é exclusivamente para **implementar a nova identidade visual/UI do Sky Jump e conectar os elementos visuais aos sistemas que já existem**.

Antes de finalizar, testar todas as telas e interações afetadas e corrigir problemas de:

* alinhamento;
* escala;
* sobreposição;
* clipping;
* fonte;
* espaçamento;
* resolução;
* estados dos botões;
* atualização dos valores dinâmicos.

O resultado final deve ser uma versão funcional da nova UI apresentada nas referências, e não apenas uma reprodução estática dos screenshots.
