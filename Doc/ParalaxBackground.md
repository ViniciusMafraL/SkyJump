Crie no projeto SkyJump um sistema de TEMAS DE NÍVEL baseado em cenas independentes do Godot.

OBJETIVO
O SkyJump deverá possuir diferentes temas visuais de cenário. Cada tema deve possuir sua própria Scene no Godot, permitindo que sua identidade visual, cores, materiais e iluminação sejam configuradas separadamente.

Nesta etapa, NÃO criar os assets específicos dos biomas.
Não criar árvores, castelos, pedras, nuvens, lava, construções, elementos decorativos ou qualquer outro objeto característico de cada tema.

O objetivo desta implementação é criar somente a estrutura base de cada tema.

A troca de temas devem ser possivel testar na sala de testes

--------------------------------------------------
1. ESTRUTURA VISUAL DO FUNDO
--------------------------------------------------

O fundo do nível deve utilizar um SEMICILINDRO 3D posicionado atrás da área de gameplay.

A referência conceitual para a geometria é uma seção de um cilindro, utilizando aproximadamente metade de sua superfície.

O semicilindro deverá funcionar como uma espécie de "parede curva" de fundo.

Motivação:
- O fundo precisa acompanhar a câmera do jogador.
- A curvatura permite que a câmera se movimente dinamicamente para os dois lados.
- Um cilindro completamente fechado não deve ser utilizado.
- O semicilindro evita uma sensação visual excessiva de estar dentro de um tubo.
- A geometria curva também facilita a construção posterior dos cenários e backgrounds dos diferentes biomas.

O semicilindro deverá:
- ficar sempre atrás da área jogável;
- acompanhar a posição da câmera horizontalmente;
- manter uma distância adequada do gameplay;
- possuir dimensões suficientes para evitar que suas extremidades apareçam durante a movimentação normal da câmera;
- possuir material próprio;
- permitir alteração independente de suas cores;
- utilizar um gradiente vertical de cor.

A referência visual enviada pelo usuário deve ser utilizada para compreender a ideia da curvatura do fundo.

--------------------------------------------------
2. GRADIENTE DO FUNDO
--------------------------------------------------

Cada tema deverá possuir duas cores principais:

- BASE_COLOR = cor inferior do cenário;
- TOP_COLOR = cor superior do cenário.

O material do semicilindro deverá gerar um gradiente vertical entre essas duas cores.

O gradiente deve seguir:

BASE_COLOR
      ↓
transição vertical suave
      ↓
TOP_COLOR

A configuração das cores deve ficar centralizada na Scene/estrutura do respectivo tema, e não espalhada pelos objetos individuais.

--------------------------------------------------
3. CENAS DOS TEMAS
--------------------------------------------------

Crie uma Scene independente para cada um dos seguintes temas.

Os nomes das Scenes devem ser exatamente:

Theme_Castle
Theme_Winter
Theme_Forest
Theme_Magma
Theme_Spooky
Theme_Windy
Theme_Electricity
Theme_Waterfall
Theme_MudWorld
Theme_Totem

Cada Scene representa exclusivamente a configuração visual daquele tema.

--------------------------------------------------
4. CONTEÚDO DE CADA SCENE
--------------------------------------------------

Cada Scene de tema deverá conter SOMENTE:

1. O semicilindro de fundo;
2. A configuração visual necessária para definir o tema;
3. Configurações de cores;
4. Configurações de materiais que posteriormente poderão ser utilizadas pelas Plataformas e Objetos Especiais daquele tema.

NÃO adicionar nesta etapa:
- plataformas;
- obstáculos;
- árvores;
- pedras;
- construções;
- personagens;
- inimigos;
- partículas específicas;
- objetos decorativos;
- elementos exclusivos do bioma;
- gameplay;
- objetos de interação.

As Scenes devem funcionar como uma espécie de "Theme Configuration".

--------------------------------------------------
5. CONFIGURAÇÕES DE CORES DOS TEMAS
--------------------------------------------------

Utilize exatamente as seguintes cores:

CASTLE
Nome: Castle
BASE_COLOR: #FF99CC
TOP_COLOR: #CC6699

WINTER
Nome: Winter / Ice
BASE_COLOR: #99FFFF
TOP_COLOR: #33CCFF

FOREST
Nome: Forest / Jungle
BASE_COLOR: #66CC66
TOP_COLOR: #009933

MAGMA
Nome: Magma
BASE_COLOR: #FF6600
TOP_COLOR: #CC0000

SPOOKY
Nome: Spooky
BASE_COLOR: #660066
TOP_COLOR: #330066

WINDY
Nome: Windy
BASE_COLOR: #66CCFF
TOP_COLOR: #0066CC

ELECTRICITY
Nome: Electricity / City
BASE_COLOR: #000033
TOP_COLOR: #330066

WATERFALL
Nome: Waterfall / Beach
BASE_COLOR: #00CCCC
TOP_COLOR: #009999

MUD WORLD
Nome: Mud World
BASE_COLOR: #996633
TOP_COLOR: #663300

TOTEM
Nome: Totem / Desert
BASE_COLOR: #FFCC66
TOP_COLOR: #CC9933

--------------------------------------------------
6. CONFIGURAÇÃO DE MATERIAIS
--------------------------------------------------

Cada Theme Scene deverá possuir configurações centralizadas para os materiais utilizados posteriormente pelos elementos do nível.

Criar parâmetros/configurações para:

PLATFORMS
- material principal;
- cor principal;
- cor secundária;
- propriedades visuais necessárias para o material.

SPECIAL OBJECTS
- material principal;
- cor principal;
- cor secundária;
- propriedades visuais necessárias para o material.

Essas configurações NÃO significam que as plataformas ou objetos especiais devem ser criados agora.

A Scene apenas deverá definir quais materiais e cores esses objetos deverão utilizar quando forem instanciados naquele tema.

--------------------------------------------------
7. SISTEMA DE APLICAÇÃO DO TEMA
--------------------------------------------------

Quando um determinado tema for selecionado, todas as configurações definidas pela respectiva Theme Scene deverão ser aplicadas automaticamente.

Exemplo:

Theme_Castle
→ fundo utiliza #FF99CC → #CC6699
→ plataformas recebem as configurações de material do Castle
→ objetos especiais recebem as configurações de material do Castle

Theme_Magma
→ fundo utiliza #FF6600 → #CC0000
→ plataformas recebem as configurações de material do Magma
→ objetos especiais recebem as configurações de material do Magma

E assim sucessivamente.

Não duplicar manualmente essas configurações em cada plataforma ou objeto.

O objeto deve receber suas propriedades visuais a partir do tema ativo.

--------------------------------------------------
8. SEPARAÇÃO ENTRE TEMA E ASSETS
--------------------------------------------------

É importante manter uma separação clara entre:

THEME
→ define identidade visual, cores, materiais e iluminação/configurações visuais.

ASSETS
→ serão criados posteriormente e representarão os elementos específicos daquele bioma.

PLATFORMS / SPECIAL OBJECTS
→ serão objetos reutilizáveis que poderão receber as configurações do tema ativo.

Nesta etapa, implementar somente o sistema THEME.

--------------------------------------------------
9. ORGANIZAÇÃO DO PROJETO
--------------------------------------------------

Organizar os arquivos de forma que cada tema possa ser desenvolvido separadamente.

Sugestão:

Themes/
    Castle/
        Theme_Castle.tscn
        ...
        
    Winter/
        Theme_Winter.tscn
        ...

    Forest/
        Theme_Forest.tscn
        ...

    Magma/
        Theme_Magma.tscn
        ...

    Spooky/
        Theme_Spooky.tscn
        ...

    Windy/
        Theme_Windy.tscn
        ...

    Electricity/
        Theme_Electricity.tscn
        ...

    Waterfall/
        Theme_Waterfall.tscn
        ...

    MudWorld/
        Theme_MudWorld.tscn
        ...

    Totem/
        Theme_Totem.tscn
        ...

A organização pode ser adaptada à arquitetura atual do projeto, mas deve manter cada tema isolado e facilmente editável.

--------------------------------------------------
10. ILUMINAÇÃO
--------------------------------------------------

A estrutura das Theme Scenes deve permitir que cada tema possua futuramente suas próprias configurações de iluminação.

Nesta etapa, criar somente a estrutura necessária para que a iluminação possa ser definida individualmente por tema.

Não criar ainda uma iluminação complexa ou elementos específicos de cada bioma.

--------------------------------------------------
11. TESTE
--------------------------------------------------

Cada Theme Scene deve poder ser aberta e testada individualmente no Godot.

Deve ser possível visualizar:
- o semicilindro;
- seu gradiente;
- suas cores;
- seus materiais/configurações;
- o comportamento do fundo em relação à câmera.

Criar uma forma simples de testar todas as Theme Scenes individualmente.

O objetivo é conseguir verificar rapidamente se cada tema está utilizando corretamente sua configuração.

--------------------------------------------------
12. REQUISITOS IMPORTANTES
--------------------------------------------------

Priorize uma arquitetura limpa, modular e fácil de expandir.

Não criar sistemas desnecessários nesta etapa.

Não criar os assets dos biomas.

Não definir quais objetos específicos cada bioma terá.

Não adicionar funcionalidades que não fazem parte da criação do sistema de temas.

O resultado desta implementação deve ser uma base sólida para que, posteriormente, cada bioma possa receber seus próprios assets sem precisar modificar a arquitetura principal do sistema.

O sistema deve permitir que um novo tema seja adicionado futuramente criando uma nova Theme Scene e suas respectivas configurações, sem precisar reestruturar o sistema existente.

Use as duas imagens fornecidas como referências visuais:
- a primeira para compreender a ideia de um cenário vertical de plataforma com fundo temático;
- a segunda para compreender a ideia geométrica do semicilindro/seção do cilindro utilizado como fundo.