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
    def render(self, geometry, empty=False):
        with tempfile.TemporaryDirectory(prefix="3dgen-test-") as directory:
            source = Path(directory) / "test.scad"
            target = Path(directory) / "test.stl"
            source.write_text(
                f"include <{ROOT.as_posix()}/parametros.scad>\n"
                + "\n".join(f"use <{ROOT.as_posix()}/{name}>" for name in (
                    "robo.scad", "partes/base.scad", "partes/suporte_pilhas.scad",
                    "partes/roda.scad", "partes/eixo.scad", "partes/braco.scad",
                    "partes/corpo.scad",
                )) + "\n" + geometry,
                encoding="utf-8",
            )
            result = subprocess.run(
                [OPENSCAD, "--export-format", "asciistl", "-o", str(target), str(source)],
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


if __name__ == "__main__":
    unittest.main(verbosity=2)
