// ============================================================
// parametros.scad — dimensões compartilhadas do robô
// Todas as medidas em milímetros.
// ============================================================

$fa = 4;
$fs = 0.5;

// ---------- tolerância de impressão ----------
folga = 0.3;        // folga padrão em furos/encaixes
folga_berco = 0.6;
aperto_trava = 0.1;
passagem_w = 12;
passagem_d = 8;

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
mont_x = 36.5;
mont_y = 32;
acesso_m3_d = 7;

// ---------- micro:bit ----------
mb_w    = 51.6;     // largura da placa
mb_h    = 42;       // altura da placa
mb_prof = 11;       // profundidade do bolso (placa + componentes + fios)
mb_base_z = 18;

// ---------- botões ----------
botao_d   = 12.4;   // botão de painel de 12 mm
botao_sep = 26;     // distância entre centros dos botões
botao_z = 9;
botao_prof = 10;
botao_porca_d = 16;

// ---------- cabeça ----------
cab_w   = 58;
cab_d   = 50;
cab_h   = 48;
led_tam = 33;       // janela p/ matriz LED 8x8 (~32 mm) ou OLED pequeno
led_prof = 8;       // profundidade do alojamento do display
led_base_z = 8;
cab_pino_h = led_base_z - 3 - 2*folga;

assert(mb_base_z + mb_h + folga <= corpo_h, "Microbit acima do torso");
assert(led_base_z + led_tam + folga <= cab_h - parede, "Display acima da cabeca");
assert(cab_pino_h > parede, "Pino da cabeca sem engate");
assert(botao_z + botao_porca_d/2 + folga <= mb_base_z, "Botoes invadem a placa");
assert(botao_prof + folga < mb_prof + 2*folga, "Botoes invadem o painel interno");
assert(acesso_m3_d >= 6 + 2*folga, "Acesso insuficiente para cabeca do parafuso");
assert(aperto_trava > 0 && aperto_trava <= 0.2, "Calibre a interferencia das travas");

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
