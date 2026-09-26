// ============================================================
// parametros.scad — dimensões compartilhadas do robô
// Todas as medidas em milímetros.
// ============================================================

$fa = 4;
$fs = 0.5;

// ---------- tolerância de impressão ----------
folga = 0.3;        // folga padrão em furos/encaixes

// ---------- roda ----------
roda_d   = 36;      // diâmetro da roda
roda_w   = 10;      // largura da roda
eixo_d   = 4;       // diâmetro do eixo (haste impressa ou M4)
eixo_l   = 112;     // comprimento do eixo (haste + chanfro)

// ---------- base (chassi) ----------
base_w  = 84;       // largura (X)
base_d  = 74;       // profundidade (Y)
base_h  = 40;       // altura
parede  = 2.4;      // espessura das paredes (todas as peças)
eixo_z  = 12;       // altura do centro do eixo medida do fundo do chassi
roda_y  = roda_d/2 + 3;       // distância do centro do chassi ao centro de cada roda (Y)

// ---------- compartimento das pilhas ----------
// baia dimensionada para suporte comercial 4xAA (~62 x 58 x 17)
// ou para o suporte impresso em suporte_pilhas.scad
aa_bay_w = 72;
aa_bay_d = 58;
aa_dia   = 14.5;    // diâmetro da pilha AA
aa_comp  = 50.5;    // comprimento da pilha AA
suporte_z = eixo_z + 6 + 2*folga;
roda_x = base_w/2 + 2*folga + roda_w/2;
eixo_x = -roda_x - roda_w/2 - folga;

assert(2*roda_y >= roda_d + 2, "Rodas sem folga longitudinal");
assert(roda_y + 6 <= base_d/2, "Buchas fora do chassi");
assert(suporte_z + max(3 + aa_dia, 17) + folga <= base_h,
       "Pilhas acima do topo do chassi");
assert(eixo_z - eixo_d/2 - folga >= parede, "Eixo invade o fundo do chassi");
assert(eixo_x + eixo_l - 4 >= roda_x + roda_w/2 + folga + 2,
       "Eixo curto para as rodas e a trava");

// ---------- corpo (torso) ----------
// mesma pegada do chassi: as paredes alinham e as colunas de
// fixação ficam uma sobre a outra
corpo_w = 84;
corpo_d = 74;
corpo_h = 62;

// posição das colunas de fixação torso↔base (parafuso M3)
mont_x = 35;
mont_y = 32;

// ---------- micro:bit ----------
mb_w    = 51.6;     // largura da placa
mb_h    = 42;       // altura da placa
mb_prof = 11;       // profundidade do bolso (placa + componentes + fios)

// ---------- botões ----------
botao_d   = 12.4;   // botão de painel de 12 mm
botao_sep = 26;     // distância entre centros dos botões

// ---------- cabeça ----------
cab_w   = 58;
cab_d   = 50;
cab_h   = 48;
led_tam = 33;       // janela p/ matriz LED 8x8 (~32 mm) ou OLED pequeno
led_prof = 8;       // profundidade do alojamento do display

// ---------- braço ----------
braco_furo = 4.4;   // furo da articulação (parafuso M4 ou pino impresso)
braco_e    = 7;     // espessura dos segmentos do braço
brac_a     = 16;    // distância entre furos do segmento superior
brac_b     = 16;    // comprimento do antebraço até a palma
brac_r     = 7;     // raio das extremidades arredondadas

// ---------- auxiliar: caixa com cantos arredondados ----------
// caixa de w x d x h, centrada em X/Y, base em z = 0
module rbox(w, d, h, r = 3) {
    hull()
        for (x = [-1, 1], y = [-1, 1])
            translate([x * (w/2 - r), y * (d/2 - r), 0])
                cylinder(r = r, h = h);
}
