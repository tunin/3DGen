// ============================================================
// suporte_pilhas.scad — berço impresso para 4 pilhas AA em linha
// Alternativa ao suporte comercial 4xAA (~62 x 58): as pilhas
// encaixam por cima (efeito mola) e saem empurrando pelos rasgos
// inferiores.
// ATENÇÃO: o berço não tem contatos elétricos — use molas/
// rebites de contato ou prefira um suporte comercial 4xAA.
// Imprimir na orientação do modelo.
// ============================================================

include <../parametros.scad>

canal_d = aa_dia + 2*folga;            // diâmetro do canal
sep     = canal_d + 1.2;               // distância entre canais (parede 1,2)
cr_w    = 4 * canal_d + 3 * 1.2 + 2 * 2;   // ~68 mm, cabe na baia de 72
cr_d    = aa_comp + 7;                 // comprimento
cr_h    = 3 + aa_dia * 0.62;           // fundo + ~2/3 do diâmetro

module suporte_pilhas() {
    xs = [-1.5*sep, -0.5*sep, 0.5*sep, 1.5*sep];
    difference() {
        rbox(cr_w, cr_d, cr_h, 2);

        for (x = [-1, 1], y = [-1, 1])
            translate([x * mont_x, y * mont_y, -0.1])
                cylinder(d = 11 + 2*folga_berco, h = cr_h + 0.2);

        // canais das pilhas (abertos no topo — efeito mola)
        for (x = xs)
            translate([x, 0, 3 + aa_dia/2])
                rotate([-90, 0, 0])
                    cylinder(d = canal_d, h = cr_d + 2,
                             center = true);

        // rasgos para retirar as pilhas empurrando por baixo
        for (x = xs)
            translate([x, 0, -0.1])
                cylinder(d = 7, h = 30);
    }
}

suporte_pilhas();
