# Fluxo do projeto

- Projeto OpenSCAD; medidas em milímetros. Consulte README.md para geração e montagem.
- Rode `python -B -m unittest -v test_geometry` após mudanças geométricas. Os testes requerem OpenSCAD e Python 3, sem dependências Python externas.
- No Windows, o executável de linha de comando é `C:/Program Files/OpenSCAD/openscad.com`; a variável OPENSCAD permite outro caminho.
- Atualize os STLs e previews correspondentes quando alterar a geometria. Não trate a renderização como prova de encaixe físico ou tolerância de impressão.
- O usuário pediu que as alterações sejam commitadas e enviadas ao GitHub após validação. A branch padrão é main. Não reescreva o histórico nem descarte alterações locais.
