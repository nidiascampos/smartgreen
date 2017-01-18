# WEKA

## wmlog_sensor1.arff

### preprocess

#### nó 01
- filtro *RemoveRange -R 182-last* para remover datas finais fora do escopo
- filtro *RemoveRange -R 1-15* para remover datas iniciais fora do escopo
- WM1: aparentemente ok até 08/Jan 09am, depois ele 'reinicia' com valores baixos
- WM2: aparentemente ok até 08/Jan 09am, depois ele 'salta' para altos valores e começa a decair
- WM3: aparentemente ok

#### nó 02
- filtro *RemoveRange -R 194-last* (01/09/2017 17:14:25) para remover datas finais fora do escopo
- filtro *RemoveRange -R 1-20* (12/28/2016 12:29:32) para remover datas iniciais fora do escopo
- WM1: aparentemente ok
- WM2: grande maioria das leituras foram nulas (-1 ou -4700), ignorando todos os valores
- WM3: aparentemente ok

#### nó 03
- totalmente ignorado, não gravou dados corretamente

#### nó 04
- filtro *RemoveRange -R 1-14* (12/29/2016 08:40) para remover datas iniciais fora do escopo
- WM1: valores meio espalhados, e os numeros dos valores estão muito altos, *update:* em comparação aos outros dados ele está totalmente fora de escala (x100 no mínimo)
- WM2: aparentemente ok
- WM3: também com valores espalhados, mas os numeros estão mais realistas