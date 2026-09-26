import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import os
from pathlib import Path
import re
import shutil
import subprocess

from PIL import Image, ImageChops, ImageDraw, ImageFont, ImageOps


HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
CACHE = HERE / ".cache"
PDF = HERE / "manual_montagem.pdf"
PAGE_SIZE = (3508, 2480)
STEPS = (
    ("Rodas e eixos", "2 EIXOS + 4 RODAS + 2 TRAVAS",
     "Coloque a primeira roda no eixo e atravesse a base. Encaixe a segunda roda e a trava. Repita no outro eixo.", "", "0,0,20,55,0,-35,360"),
    ("Suporte de pilhas", "1 SUPORTE",
     "Apoie o suporte nas duas travessas da base. Use suporte comercial ou berço com contatos instalados.", "Mantenha a alimentação desligada durante a montagem.", "0,0,35,45,0,-35,300"),
    ("Prepare o torso", "MICRO:BIT + 2 BOTÕES",
     "Instale os botões e deslize a micro:bit pela fenda. Organize os fios enquanto o torso está aberto.", "Confira as medidas da sua eletrônica.", "0,0,50,65,0,-30,350"),
    ("Monte os braços", "2 BRAÇOS · 4 PINOS + 4 TRAVAS",
     "Una os segmentos com pino e trava. Fixe os braços nos ombros com os pinos pelo lado interno do torso.", "Deixe 0,3 mm entre os segmentos; não force as travas.", "10,0,10,40,0,-55,200"),
    ("Una torso e base", "4 PARAFUSOS M3 × 20",
     "Assente o torso sem prender fios. Aperte os quatro parafusos pelos furos superiores; não pelo fundo.", "Chave: haste até 6 mm e alcance útil mínimo de 56 mm.", "0,0,65,60,0,-30,440"),
    ("Prepare a cabeça", "1 DISPLAY",
     "Deslize o display pela fenda. Passe os fios pela abertura interna e pela passagem no fundo da cabeça.", "Os fios desenhados indicam a saída pelo fundo.", "0,0,40,65,0,-30,300"),
    ("Encaixe a cabeça", "4 PINOS DE ALINHAMENTO",
     "Conecte os fios, alinhe os quatro pinos e encaixe a cabeça. Não force nem aperte os cabos.", "A cabeça é removível: não erga o robô por ela.", "0,0,85,65,0,-30,500"),
    ("Confira o conjunto", "MONTAGEM CONCLUÍDA",
     "Confira o giro das rodas, o movimento dos braços e todos os encaixes. Verifique a alimentação antes de ligar.", "Use alimentação adequada à micro:bit.", "0,0,75,65,0,-30,440"),
)


def font(size, bold=False):
    names = (
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
    )
    for name in names:
        if Path(name).is_file():
            return ImageFont.truetype(name, size)
    raise RuntimeError("Instale Arial ou DejaVu Sans para gerar o manual.")


def executable():
    value = os.environ.get("OPENSCAD") or shutil.which("openscad.com") or shutil.which("openscad")
    if value:
        return value
    value = "C:/Program Files/OpenSCAD/openscad.com"
    if Path(value).is_file():
        return value
    raise RuntimeError("OpenSCAD não encontrado. Defina OPENSCAD com o caminho do executável.")


def render_all(force=False):
    program = executable()
    sources = [HERE / "montagem.scad", ROOT / "parametros.scad", ROOT / "robo.scad", *sorted((ROOT / "partes").glob("*.scad"))]
    version = subprocess.run([program, "--version"], capture_output=True, text=True, check=True)
    digest = hashlib.sha256((version.stdout + version.stderr + repr(STEPS) + "manual-render-v1").encode())
    for source in sources:
        digest.update(source.read_bytes())
    key = digest.hexdigest()
    stamp = CACHE / "render.sha256"
    valid = stamp.exists() and stamp.read_text() == key and not force

    def render(index):
        target = CACHE / f"etapa_{index+1}.png"
        if valid and target.exists():
            return
        command = [program, "--render", "--projection=o", "--colorscheme=Monotone",
                   "--autocenter", "--viewall", "--imgsize=1400,1050",
                   f"--camera={STEPS[index][4]}", "-D", f"etapa={index+1}",
                   "-D", "$fa=8", "-D", "$fs=0.9", "-o", str(target), str(HERE / "montagem.scad")]
        if os.name != "nt" and not os.environ.get("DISPLAY") and shutil.which("xvfb-run"):
            command = ["xvfb-run", "-a", *command]
        result = subprocess.run(command, capture_output=True, text=True, timeout=600)
        output = result.stdout + result.stderr
        if result.returncode or "ERROR:" in output or "WARNING:" in output or not target.exists():
            raise RuntimeError(f"Falha na etapa {index+1}:\n{output}")
        print(f"Ilustração {index+1}/8 pronta", flush=True)

    with ThreadPoolExecutor(max_workers=2) as pool:
        list(pool.map(render, range(8)))
    stamp.write_text(key)


def illustration(index):
    image = Image.open(CACHE / f"etapa_{index+1}.png").convert("RGB")
    background = Image.new("RGB", image.size, image.getpixel((0, 0)))
    mask = ImageChops.difference(image, background).convert("L").point(lambda v: 255 if v > 5 else 0)
    bbox = mask.getbbox()
    if bbox is None:
        raise RuntimeError(f"Ilustração vazia na etapa {index+1}")
    gray = ImageOps.grayscale(image).point(lambda v: round(v * 0.85)).convert("RGB")
    clean = Image.composite(gray, Image.new("RGB", image.size, "white"), mask)
    return clean.crop(bbox)


def paragraph(draw, text, x, y, width, style, fill, line_height):
    words = text.split()
    line = ""
    for word in words:
        candidate = f"{line} {word}".strip()
        if line and draw.textlength(candidate, font=style) > width:
            draw.text((x, y), line, font=style, fill=fill)
            y += line_height
            line = word
        else:
            line = candidate
    if line:
        draw.text((x, y), line, font=style, fill=fill)
        y += line_height
    return y


def build_pdf():
    result = subprocess.run(["git", "log", "-1", "--format=%h", "--", "parametros.scad", "partes", "robo.scad"],
                            cwd=ROOT, capture_output=True, text=True, check=True)
    revision = result.stdout.strip()
    pages = []
    margin, gap = 150, 100
    column = (PAGE_SIZE[0] - 2*margin - gap)//2
    title_font, step_font = font(105, True), font(62, True)
    body_font, small_font = font(45), font(34)
    for page_number in range(2):
        page = Image.new("RGB", PAGE_SIZE, "white")
        draw = ImageDraw.Draw(page)
        draw.text((margin, 95), "ROBÔZINHO", font=title_font, fill="#202020")
        draw.text((margin, 228), "Siga os números. As setas mostram o sentido de encaixe.", font=body_font, fill="#555555")
        label = f"MONTAGEM  /  {page_number*4+1}–{page_number*4+4}"
        draw.text((PAGE_SIZE[0]-margin-draw.textlength(label, font=body_font), 153), label, font=body_font, fill="#333333")
        for position in range(4):
            index = page_number*4 + position
            title, quantity, text, note, camera = STEPS[index]
            x = margin + (position % 2)*(column+gap)
            y = 350 + (position//2)*955
            draw.ellipse((x, y, x+84, y+84), fill="#303030")
            draw.text((x+42, y+39), str(index+1), font=font(54, True), fill="white", anchor="mm")
            draw.text((x+110, y+2), title, font=step_font, fill="#222222")
            draw.text((x+110, y+78), quantity, font=small_font, fill="#666666")
            figure = illustration(index)
            figure.thumbnail((column-100, 585), Image.Resampling.LANCZOS)
            page.paste(figure, (x+(column-figure.width)//2, y+135+(585-figure.height)//2))
            end = paragraph(draw, text, x, y+754, column, body_font, "#222222", 55)
            if note:
                end = paragraph(draw, note, x, end+8, column, small_font, "#555555", 43)
            if end > y+940:
                raise RuntimeError(f"Texto excedeu o espaço da etapa {index+1}")
            if position < 2:
                draw.line((x, y+930, x+column, y+930), fill="#cccccc", width=2)
        draw.line((margin, 2285, PAGE_SIZE[0]-margin, 2285), fill="#333333", width=3)
        footer = ("Antes de montar: remova suportes e rebarbas. Use base, torso e berço da mesma revisão."
                  if page_number == 0 else
                  "Guia mecânico. Eletrônica ilustrativa: siga o esquema do seu circuito e confira a polaridade.")
        draw.text((margin, 2310), footer, font=small_font, fill="#444444")
        draw.text((margin, 2370), f"Modelo {revision} · 3DGen", font=font(28), fill="#777777")
        draw.text((PAGE_SIZE[0]-margin, 2370), f"{page_number+1} / 2", font=font(28), fill="#777777", anchor="ra")
        page.save(CACHE / f"pagina_{page_number+1}.png")
        pages.append(page)
    pages[0].save(PDF, "PDF", save_all=True, append_images=pages[1:], resolution=300,
                  quality=95, subsampling=0, title="Robôzinho — manual de montagem",
                  author="3DGen", subject="Sequência ilustrada de montagem em português")
    content = PDF.read_bytes()
    if not content.startswith(b"%PDF-") or len(re.findall(rb"/Type\s*/Page\b", content)) != 2:
        raise RuntimeError("PDF inválido ou número de páginas incorreto")
    print(f"Manual pronto: {PDF} ({PDF.stat().st_size:,} bytes)")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Gera o manual ilustrado de montagem em português.")
    parser.add_argument("--force", action="store_true", help="Renderiza novamente todas as imagens.")
    args = parser.parse_args()
    CACHE.mkdir(exist_ok=True)
    render_all(args.force)
    build_pdf()
