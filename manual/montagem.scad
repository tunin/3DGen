include <../parametros.scad>
use <../robo.scad>
use <../partes/base.scad>
use <../partes/roda.scad>
use <../partes/eixo.scad>
use <../partes/suporte_pilhas.scad>
use <../partes/corpo.scad>
use <../partes/cabeca.scad>
use <../partes/braco.scad>
use <../partes/pino.scad>

etapa = 1;

module seta(a, b) {
    v = b - a;
    l = norm(v);
    translate(a) rotate([0, acos(v[2]/l), atan2(v[1], v[0])]) {
        cylinder(d=1.2, h=l-4, $fn=12);
        translate([0,0,l-4]) cylinder(d1=4.5, d2=0, h=4, $fn=12);
    }
}

module chassi(com_berco=true) {
    base();
    if (com_berco) translate([0,0,suporte_z]) suporte_pilhas();
    for (y=[-1,1]) {
        translate([eixo_x,y*roda_y,eixo_z]) eixo();
        translate([roda_x+roda_w/2+folga,y*roda_y,eixo_z])
            rotate([0,90,0]) trava_eixo();
        for (x=[-1,1]) translate([x*roda_x,y*roda_y,eixo_z])
            rotate([0,90,0]) roda();
    }
}

module placa_ilustrativa() {
    difference() {
        translate([-mb_w/2,0,0]) cube([mb_w,1.6,mb_h]);
        for (x=[-20,-10,0,10,20]) translate([x,-0.1,4])
            rotate([-90,0,0]) cylinder(d=3,h=1.8);
    }
    for (x=[-2:2],z=[-2:2]) translate([x*4-1,-0.8,27+z*4])
        cube([2,0.9,2]);
    translate([-4,1.6,mb_h-5]) cube([8,4,5]);
}

module display_ilustrativo() {
    difference() {
        translate([-led_tam/2,0,0]) cube([led_tam,led_prof,led_tam]);
        for (x=[0:7],z=[0:7])
            translate([(x-3.5)*3.6,-0.1,led_tam/2+(z-3.5)*3.6])
                rotate([-90,0,0]) cylinder(d=2,h=1);
    }
}

module botao_ilustrativo() {
    rotate([-90,0,0]) {
        cylinder(d=12,h=parede+botao_prof);
        translate([0,0,-3]) cylinder(d=16,h=3);
    }
}

module parafuso_ilustrativo() {
    cylinder(d=3,h=20);
    translate([0,0,20]) difference() {
        cylinder(d=6,h=2.5);
        translate([-2,-0.5,1.5]) cube([4,1,2]);
        translate([-0.5,-2,1.5]) cube([1,4,2]);
    }
}

module torso_pronto() {
    corpo();
    translate([0,-corpo_d/2+parede+folga,mb_base_z]) placa_ilustrativa();
    for (x=[-1,1]) {
        translate([x*botao_sep/2,-corpo_d/2,botao_z]) botao_ilustrativo();
        translate([x*(corpo_w/2+5+folga),0,corpo_h-14]) scale([x,1,1]) {
            braco_montado();
            fixadores_braco();
        }
    }
}

module cabeca_pronta() {
    cabeca();
    translate([0,-cab_d/2+parede+folga,led_base_z]) display_ilustrativo();
}

if (etapa == 1) {
    base();
    for (y=[-1,1]) {
        translate([eixo_x,y*roda_y,eixo_z]) eixo();
        translate([-roda_x,y*roda_y,eixo_z]) rotate([0,90,0]) roda();
        translate([roda_x+(y<0?23:0),y*roda_y,eixo_z]) rotate([0,90,0]) roda();
        translate([roda_x+roda_w/2+folga+(y<0?36:0),y*roda_y,eixo_z])
            rotate([0,90,0]) trava_eixo();
    }
    seta([-78,-roda_y,eixo_z],[-58,-roda_y,eixo_z]);
    seta([68,-roda_y-12,eixo_z+8],[49,-roda_y-12,eixo_z+8]);
    seta([87,-roda_y-8,eixo_z+8],[74,-roda_y-8,eixo_z+8]);
} else if (etapa == 2) {
    chassi(false);
    translate([0,0,suporte_z+36]) suporte_pilhas();
    seta([0,-base_d/2-6,58],[0,-base_d/2-6,34]);
} else if (etapa == 3) {
    corpo();
    translate([0,-corpo_d/2+parede+folga,corpo_h+18]) placa_ilustrativa();
    for (x=[-1,1]) {
        translate([x*botao_sep/2,-corpo_d/2-18,botao_z]) botao_ilustrativo();
        seta([x*botao_sep/2,-corpo_d/2-17,botao_z+12],
             [x*botao_sep/2,-corpo_d/2-3,botao_z+12]);
    }
    seta([32,-corpo_d/2+8,corpo_h+22],[32,-corpo_d/2+8,corpo_h+3]);
} else if (etapa == 4) {
    braco_sup();
    translate([brac_a,0,braco_e+folga+14]) rotate([0,0,-25]) braco_inf();
    translate([brac_a,0,-26]) pino();
    translate([brac_a,0,42]) trava_pino();
    seta([brac_a,-10,-16],[brac_a,-10,-2]);
    seta([brac_a,-12,25],[brac_a,-12,9]);
    seta([brac_a+8,0,40],[brac_a+8,0,30]);
} else if (etapa == 5) {
    chassi();
    translate([0,0,base_h+26]) torso_pronto();
    for (x=[-1,1],y=[-1,1])
        translate([x*mont_x,y*mont_y,base_h+26+corpo_h+10]) parafuso_ilustrativo();
    seta([0,-base_d/2-14,base_h+24],[0,-base_d/2-14,base_h+2]);
    seta([mont_x+8,-mont_y,base_h+corpo_h+44],
         [mont_x+8,-mont_y,base_h+corpo_h+28]);
} else if (etapa == 6) {
    cabeca();
    translate([0,-cab_d/2+parede+folga,cab_h+14]) display_ilustrativo();
    for (x=[-1.2,1.2]) translate([x,0,-28]) cylinder(d=1,h=31);
    seta([23,-cab_d/2+7,cab_h+17],[23,-cab_d/2+7,cab_h+3]);
} else if (etapa == 7) {
    chassi();
    translate([0,0,base_h]) torso_pronto();
    translate([0,0,base_h+corpo_h+22]) cabeca_pronta();
    seta([-cab_w/2-10,-cab_d/2-10,base_h+corpo_h+25],
         [-cab_w/2-10,-cab_d/2-10,base_h+corpo_h+5]);
} else if (etapa == 8) {
    chassi();
    translate([0,0,base_h]) torso_pronto();
    translate([0,0,base_h+corpo_h]) cabeca_pronta();
}
