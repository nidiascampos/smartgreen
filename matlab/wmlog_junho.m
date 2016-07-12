clear;
load('wmlog-jun-1a7');

n = 17606;
sequencia = [1:n];

for i=1:n
    sequencia(:,i) = sequencia(:,i)*30;
end

valores = WMLOGJUN1a7(:,2:2:end);
valores=[valores;sequencia]
valores_ajustados=(valores-550)/137.5;

figure;
plot(valores(2,:)/60,smooth(valores(1,:)));
xlabel('Tempo (minutos)');
ylabel('Resistencia (Ohms)');
annot_start = [0.7, 0.75];
annot_end = [0.6, 0.6];
annotation('textarrow',annot_start,annot_end,'String','chuva');