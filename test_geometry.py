import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parent
OPENSCAD = os.environ.get("OPENSCAD") or shutil.which("openscad") or shutil.which("openscad.com")
if not OPENSCAD:
    OPENSCAD = "C:/Program Files/OpenSCAD/openscad.com"


def component_count(path):
    parents = {}

    def root(vertex):
        parents.setdefault(vertex, vertex)
        while parents[vertex] != vertex:
            parents[vertex] = parents[parents[vertex]]
            vertex = parents[vertex]
        return vertex

    vertices = []
    edges = {}
    for line in path.read_text().splitlines():
        if line.strip().startswith("vertex "):
            vertices.append(tuple(round(float(v), 5) for v in line.split()[1:]))
            if len(vertices) == 3:
                a, b, c = vertices
                parents[root(b)] = root(a)
                parents[root(c)] = root(a)
                for start, end in ((a, b), (b, c), (c, a)):
                    edge = tuple(sorted((start, end)))
                    edges[edge] = edges.get(edge, 0) + 1
                vertices = []
    if not parents or any(count != 2 for count in edges.values()):
        raise AssertionError("Malha vazia ou com arestas nao manifold")
    return len({root(vertex) for vertex in parents})


class GeometryTests(unittest.TestCase):
    def render(self, geometry="", empty=False, part=None):
        with tempfile.TemporaryDirectory(prefix="3dgen-test-") as directory:
            source = Path(directory) / "test.scad"
            target = Path(directory) / "test.stl"
            source.write_text(
                f"include <{ROOT.as_posix()}/parametros.scad>\n"
                + "\n".join(f"use <{ROOT.as_posix()}/{name}>" for name in (
                    "robo.scad", "partes/base.scad", "partes/suporte_pilhas.scad",
                    "partes/roda.scad", "partes/eixo.scad", "partes/braco.scad",
                    "partes/corpo.scad", "partes/cabeca.scad", "partes/pino.scad",
                )) + "\n" + geometry
                + (f'\ninclude <{ROOT.as_posix()}/robo.scad>\n' if part else ""),
                encoding="utf-8",
            )
            result = subprocess.run(
                [OPENSCAD, "--export-format", "asciistl", "-o", str(target)]
                + (["-D", f'part="{part}"'] if part else []) + [str(source)],
                capture_output=True, text=True, timeout=300,
            )
            output = result.stdout + result.stderr
            self.assertNotIn("WARNING:", output)
            self.assertNotIn("ERROR:", output)
            if empty:
                self.assertIn("Current top level object is empty", output)
                self.assertFalse(target.exists() and target.stat().st_size)
                return
            self.assertEqual(result.returncode, 0, output)
            return component_count(target)

    def test_wheel_spacing(self):
        self.render('assert(2*roda_y - roda_d >= 2); cube(1);')

    def test_axles_clear_loaded_holder(self):
        self.render('''
            intersection() {
                for (y = [-1, 1])
                    translate([eixo_x, y*roda_y, eixo_z]) eixo();
                translate([0, 0, suporte_z]) {
                    suporte_pilhas();
                    for (i = [-1.5, -0.5, 0.5, 1.5])
                        translate([i*(aa_dia + 2*folga + 1.2), 0, 3 + aa_dia/2])
                            rotate([90, 0, 0]) cylinder(d=aa_dia, h=aa_comp, center=true);
                }
            }
        ''', empty=True)

    def test_forearm_is_one_solid(self):
        self.assertEqual(self.render('braco_inf();'), 1)

    def test_print_layout_has_two_arm_segments(self):
        self.assertEqual(self.render('braco();'), 2)

    def test_arm_segments_do_not_intersect(self):
        self.assertEqual(self.render('braco_montado();'), 2)

    def test_joint_holes_are_coaxial(self):
        self.render('''
            intersection() {
                braco_montado();
                union() {
                    translate([-1, 0, 0]) rotate([0, 90, 0])
                        cylinder(d=braco_furo-0.1, h=braco_e+2);
                    translate([-1, brac_a*cos(65), -brac_a*sin(65)])
                        rotate([0, 90, 0])
                            cylinder(d=braco_furo-0.1, h=2*braco_e+folga+2);
                }
            }
        ''', empty=True)

    def test_arm_clears_torso(self):
        self.render('''
            intersection() {
                corpo();
                for (x = [-1, 1])
                    translate([x*(corpo_w/2+5+folga), 0, corpo_h-14])
                        scale([x, 1, 1]) braco_montado();
            }
        ''', empty=True)

    def test_chassis_and_holder_are_connected_solids(self):
        self.assertEqual(self.render('base();'), 1)
        self.assertEqual(self.render('suporte_pilhas();'), 1)

    def test_axles_clear_chassis(self):
        self.render('''
            intersection() {
                base();
                for (y = [-1, 1])
                    translate([eixo_x, y*roda_y, eixo_z]) eixo();
            }
        ''', empty=True)

    def test_loaded_holder_clears_chassis(self):
        self.render('''
            intersection() {
                base();
                translate([0, 0, (suporte_z) + 0.01]) {
                    suporte_pilhas();
                    for (i = [-1.5, -0.5, 0.5, 1.5])
                        translate([i*(aa_dia + 2*folga + 1.2), 0, 3 + aa_dia/2])
                            rotate([90, 0, 0]) cylinder(d=aa_dia, h=aa_comp, center=true);
                }
            }
        ''', empty=True)

    def test_head_and_body_are_connected_solids(self):
        self.assertEqual(self.render('cabeca();'), 1)
        self.assertEqual(self.render('corpo();'), 1)

    def test_axle_print_layout_has_two_solids(self):
        self.assertEqual(self.render(part="eixo"), 2)

    def test_screw_heads_and_tool_can_reach_columns(self):
        self.render('''
            intersection() {
                corpo();
                for (x=[-1,1], y=[-1,1])
                    translate([x*mont_x,y*mont_y,6.01])
                        cylinder(d=6, h=corpo_h+20);
            }
        ''', empty=True)

    def test_internal_wire_passage_is_clear(self):
        self.render('''
            intersection() {
                union() { corpo(); translate([0,0,corpo_h]) cabeca(); }
                translate([-5.5,-3.5,corpo_h-5]) cube([11,7,10]);
            }
        ''', empty=True)

    def test_display_can_slide_through_top(self):
        self.render('''
            intersection() {
                cabeca();
                translate([-led_tam/2,-cab_d/2+parede+folga,
                           led_base_z+0.01])
                    cube([led_tam,led_prof,cab_h+30]);
            }
        ''', empty=True)

    def test_microbit_can_slide_through_top(self):
        self.render('''
            intersection() {
                corpo();
                translate([-mb_w/2,-corpo_d/2+parede+folga,
                           mb_base_z+0.01])
                    cube([mb_w,mb_prof,corpo_h+30]);
            }
        ''', empty=True)

    def test_commercial_holder_can_be_inserted(self):
        self.render('''
            intersection() {
                base();
                translate([-31,-29,suporte_z+0.01]) cube([62,58,base_h+20]);
            }
        ''', empty=True)

    def test_head_pin_tips_have_axial_clearance(self):
        self.render('''
            intersection() {
                cabeca();
                translate([0,0,-corpo_h+folga])
                    intersection() {
                        corpo();
                        translate([-25,-21,corpo_h+0.01]) cube([50,42,10]);
                    }
            }
        ''', empty=True)

    def test_internal_panels_do_not_start_in_midair(self):
        for module in ("corpo", "cabeca"):
            with self.subTest(module=module):
                self.render(f'''
                    linear_extrude(height=0.1) difference() {{
                        projection(cut=true) translate([0,0,-8.05]) {module}();
                        offset(delta=0.2)
                            projection(cut=true) translate([0,0,-7.95]) {module}();
                    }}
                ''', empty=True)

    def test_arm_fasteners_clear_printed_parts(self):
        self.render('intersection() { braco_montado(); fixadores_braco(); }', empty=True)
        self.render('''
            intersection() {
                corpo();
                for (x=[-1,1])
                    translate([x*(corpo_w/2+5+folga),0,corpo_h-14])
                        scale([x,1,1]) fixadores_braco();
            }
        ''', empty=True)

    def test_head_seats_on_torso(self):
        self.render('''
            intersection() {
                corpo();
                translate([0,0,corpo_h+0.01]) cabeca();
            }
        ''', empty=True)

    def test_button_bodies_and_nuts_fit_below_microbit(self):
        self.render('''
            intersection() {
                union() {
                    corpo();
                    translate([-mb_w/2,-corpo_d/2+parede+folga,mb_base_z])
                        cube([mb_w,mb_prof,mb_h]);
                }
                for (x=[-1,1]) {
                    translate([x*botao_sep/2,-corpo_d/2,botao_z])
                        rotate([-90,0,0]) cylinder(d=12,h=parede+botao_prof);
                    translate([x*botao_sep/2,-corpo_d/2+parede+folga,botao_z])
                        rotate([-90,0,0]) cylinder(d=botao_porca_d,h=3);
                }
            }
        ''', empty=True)

    def test_wires_can_leave_electronics_pockets(self):
        for module, depth in (("corpo", "corpo_d"), ("cabeca", "cab_d")):
            with self.subTest(module=module):
                self.render(f'''
                    intersection() {{
                        {module}();
                        translate([-1.5,-{depth}/2+parede+1,parede+0.2])
                            cube([3,{depth}/2-parede,3]);
                    }}
                ''', empty=True)

    def test_body_seats_on_chassis(self):
        self.render('''
            intersection() {
                base();
                translate([0,0,base_h+0.01]) corpo();
            }
        ''', empty=True)


if __name__ == "__main__":
    unittest.main(verbosity=2)
