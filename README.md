# Robôzinho — projeto para impressão 3D

Robô paramétrico em [OpenSCAD](https://openscad.org) com ~17 cm de altura:

- **Base** com 4 rodas (2 eixos + travas) e baia para **4 pilhas AA**
- **Torso** com bolso para placa **micro:bit** (a placa desliza por trilhos
  internos a partir de uma fenda no topo) e **2 furos para botões** de 12 mm
- **Cabeça** com janela 34×34 para **matriz de LED 8×8** (~32 mm) ou display
  OLED pequeno — o módulo desliza por trilhos a partir de uma fenda no topo;
  antena e "orelhas" decorativas
- **2 braços articulados** (ombro + cotovelo) com garra de 2 dedos

![Montagem](img/montagem.png)

## Peças para imprimir

| Arquivo STL | Qtd | Observações |
|---|---|---|
| `stl/base.stl` | 1 | Chassi — abertura para cima |
| `stl/corpo.stl` | 1 | Torso — abertura para baixo |
| `stl/cabeca.stl` | 1 | Cabeça — de pé |
| `stl/roda.stl` | 4 | Sulco no aro para elástico como "pneu" |
| `stl/eixo.stl` | 2 | Eixo em pé e trava separados; usar brim (ou eixo metálico M4 de comprimento adequado) |
| `stl/suporte_pilhas.stl` | 1 | Berço 4×AA (ou use suporte comercial) |
| `stl/braco.stl` | 2 | Cada arquivo traz os 2 segmentos do braço |
| `stl/pino.stl` | 4 | Pino + trava das articulações (ou M4×20 + porca) |

## Fatiamento sugerido

- Material: PLA (ou PETG)
- Altura de camada: 0,2 mm — perímetros: 3 — preenchimento: 15–20%
- Torso e cabeça: confira suportes para prateleiras, ressaltos e teto; os painéis internos agora começam na base, mas isso não elimina pontes e balanços. Verifique no fatiador o acesso para remover os suportes antes de imprimir.
- Eixo: imprimir em pé, apoiado na cabeça, com brim. A haste é longa e fina; para maior resistência, prefira eixo metálico. A trava deve aparecer como outra peça, não fundida à haste.
- Rodas: assente o cubo na mesa e confira o suporte sob aro e raios no fatiador.
- Tolerâncias: `folga = 0.3`, `folga_berco = 0.6` e `aperto_trava = 0.1` em `parametros.scad`. O último valor é interferência diametral, não folga radial. Faça um teste de pino/trava antes do lote.
- Imprima os arquivos de peças separadamente. `stl/montagem.stl` é referência visual, não um kit pronto para imprimir: contém contatos e encaixes por pressão intencionais.

## Hardware necessário

- 1 placa **micro:bit** (51,6 × 42 mm)
- 1 **matriz de LED 8×8** MAX7219 (~32 × 32 mm) ou OLED similar — para o rosto
- 2 **botões de painel** de 12 mm
- 1 **suporte de pilhas 4×AA** com interruptor (~62 × 58 × 17 mm)
  — ou use o berço impresso (requer contatos/molas próprios)
- 4 parafusos **M3 × 20** autoroscantes (torso ↔ chassi)
- Articulações dos braços: 4 pinos impressos **ou** parafusos **M4 × 20**
  com porcas autotravantes
- Elásticos/aneis de borracha para os "pneus" das rodas (opcional)

## Montagem

Use base, torso e berço desta mesma revisão: os centros das colunas passaram
para X = ±36,5 mm (Y = ±32 mm). Não misture essas peças com as versões antigas.

1. Monte os botões, os pinos dos ombros e a fiação no torso enquanto o fundo
   está acessível. Os botões ficam abaixo do micro:bit; confira as medidas
   do corpo, da porca e dos terminais do seu modelo.
2. Deslize o micro:bit pela fenda superior até as prateleiras. Passe os fios
   pela abertura do painel interno antes de fechar o conjunto.
3. Apoie o berço impresso ou suporte comercial nas duas travessas elevadas
   do chassi. O plano de apoio fica a 18,6 mm do fundo; a base tem 40 mm de
   altura. O berço tem 0,6 mm de folga nominal nas colunas. Um envelope
   comercial de 62 × 58 × 17 mm, inclusive com cantos retos, cabe centralizado.
4. Conecte a fiação necessária, assente o torso na base e introduza os quatro
   M3 × 20 pelos acessos de 7 mm no topo. Use cabeça de parafuso de até 6 mm
   e chave com haste de até 6 mm, com alcance útil mínimo de 56 mm. Aperte
   nas colunas sem forçar o plástico; não tente parafusar pelo fundo da base.
5. Instale o display e sua fiação na cabeça. Há uma saída sob o display para
   os fios alcançarem o interior e uma passagem central de 12 × 8 mm,
   alinhada à passagem do torso. Confira os conectores antes de fechar.
6. Monte os antebraços pelo lado externo dos cotovelos, com 0,3 mm entre os
   segmentos. Use os pinos atualizados e suas travas ou parafusos M4.
   A montagem de referência agora mostra também os pinos e travas.
7. Encaixe a cabeça nos quatro pinos. Eles têm 4,4 mm de altura e folga axial;
   o encaixe é removível, sem trava de retenção. Não use os fios para segurá-la.
8. Encaixe a primeira roda no eixo antes de atravessar o chassi, depois
   coloque a segunda roda e a trava externa. Repita no outro eixo e confira
   se as rodas giram sem raspar.

### Dimensões da eletrônica

Os testes usam envelopes conservadores, não modelos de componentes específicos:

| Componente | Envelope configurado | Entrada / acomodação |
|---|---|---|
| micro:bit | 51,6 × 42 × 11 mm | Fenda de 52,2 × 11,6 mm; apoio a 18 mm do fundo do torso |
| Display | Até 33 × 33 × 8 mm | Fenda de 33,6 × 8,6 mm; apoio a 8 mm do fundo da cabeça |
| Suporte comercial | 62 × 58 × 17 mm | Centralizado, com cantos retos e sem acessórios fora desse envelope |
| Botões | Corpo de 12 mm, profundidade interna até 10 mm | Porca com envelope de até 16 mm de diâmetro e 3 mm de espessura |

Meça a placa completa, USB/JST, soldas, cabos, interruptor e terminais. Ajuste
`mb_prof`, `led_prof`, `botao_prof` e os demais parâmetros se necessário e
rode os testes novamente. A passagem central não garante a passagem de
qualquer conector: o túnel sob o display tem 12 × 5 mm; um caminho de 3 × 3 mm
para fios foi verificado. O berço impresso continua exigindo contatos elétricos
próprios. A validação mecânica não valida o circuito de alimentação.

## Regenerar os STLs

Requer `openscad` (e `xvfb` para as imagens no Linux). Linux:

```bash
make            # gera stl/*.stl
make img        # gera img/*.png (xvfb-run)
```

Windows (Git Bash, sem `make`/`xvfb`):

```bash
./render_stl.sh   # gera stl/*.stl
./render_img.sh   # gera img/*.png
```

Se `openscad` não estiver no `PATH`, os scripts usam
`C:\Program Files\OpenSCAD\openscad.com` ou a variável `OPENSCAD`.
Os PNGs usam renderização completa (`--render`), evitando artefatos do
preview rápido. Na interface do OpenSCAD, use F6 para conferir a geometria
final; F5 é apenas uma prévia.

Ou diretamente:

```bash
openscad -o stl/roda.stl -D 'part="roda"' robo.scad
```

Peças disponíveis em `part`: `montagem`, `base`, `suporte_pilhas`, `roda`,
`eixo`, `corpo`, `cabeca`, `braco`, `pino`.

## Validação geométrica

Requer Python 3 e OpenSCAD; não usa pacotes Python adicionais:

```bash
python -B -m unittest -v test_geometry
```

Os testes renderizam malhas temporárias e verificam rodas, eixos, pilhas,
berço, articulações e fixadores. Também verificam o layout de impressão do
eixo, acesso dos parafusos e da ferramenta, inserção da eletrônica e do
suporte comercial, espaço dos botões, passagem dos fios e assentamento da
cabeça e do torso. As seções dos painéis internos são verificadas contra o
início de impressão no ar encontrado na auditoria; isso não substitui a
inspeção de todas as camadas no fatiador. Os layouts do braço e do eixo devem
conter exatamente dois sólidos fechados. `OPENSCAD` pode indicar o executável.

As rodas de 36 mm têm 42 mm entre centros (6 mm livres entre elas).
A validação digital não garante as tolerâncias reais da impressora nem o
encaixe de contatos elétricos, molas e suportes comerciais: teste os
encaixes antes de imprimir o conjunto completo.

## Personalizar

Todas as cotas estão em [`parametros.scad`](parametros.scad) — diâmetro das
rodas, dimensões do chassi/torso/cabeça, posição dos botões, tamanho da
janela do display etc. Edite e regenere os STLs.
