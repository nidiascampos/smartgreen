# Fórmulas de conversão de Ohm para kPa ou cbar

## Conversão Direta

### Fórmula
Ta = (Rs-550)/137.5

### Dados da Fórmula
Rs = resistencia (Ohms)

Ta = tensao do solo (kPa ou cbar, são equivalentes)

### Exemplo
```
Rs = 1600 Ohm
Ta = (1600-550)/137.5
Ta = 7,636363636
```

## Conversão considerando a temperatura do solo

### Fórmula
P = (3.213 * R + 4.093) / (1-0.009733 * R – 0.01205 * T)

### Dados da Fórmula
R = resistencia do solo (kOhms)

T = temperatura do solo (Celsius)

P = tensao do solo (kPa ou cbar)

### Exemplo
```
R = 1600 Ohm = 1.6 kOhm
T = 28
P = (3.213 * 1.6 + 4.093) / (1-0.009733 * 1.6 – 0.01205 * 28)
P = 14,27111565 kPa
```