%%%% Prova 2 - B de Calculo numérico do Grupo 7 %%%%

% Dados disponibilizados

data = csvread('COVID-19_CBC_Data_cleaned.csv', 1, 0);

%%%% Análise 1 %%%%

disp('Análise 1: Seleção de variáveis');

disp('Com base nos dados fornecidos, escolha dois pares de variáveis que tenham o melhor ajuste para uma regressão linear. Isso significa olhar quais pares de variável possuem um comportamento linear entre si.')
% Calcular a matriz de correlação
data1 = corr(data);

% Calcular o r^2 dos coeficientes de correlação
data2 = data1 .^ 2;

% Inicializar a matriz para armazenar os valores de Sr
numVars = size(data, 2);
data3 = zeros(numVars, numVars); % Matriz de Sr para todas as combinações

% Calcular Sr para cada par de variáveis
for i = 1:numVars
    for j = 1:numVars
        if i ~= j
            % Seleciona o par de variáveis xi e yi
            xi = data(:, i);
            yi = data(:, j);

            % Cálculo das médias
            x_mean = mean(xi);
            y_mean = mean(yi);

            % Regressão linear simples para encontrar a0 e a1
            a1 = sum((xi - x_mean) .* (yi - y_mean)) / sum((xi - x_mean).^2);
            a0 = y_mean - a1 * x_mean;

            % Calcular Sr (soma dos quadrados dos resíduos)
            Sr = sum((yi - (a0 + a1 * xi)).^2);

            % Armazenar o valor de Sr na matriz
            data3(i, j) = Sr;
        end
    end
end

% Criar o heatmap
imagesc(data1);
colorbar;
colormap(jet);

% Adicionar os valores dentro das células
for i = 1:numVars
    for j = 1:numVars
        % Coloca o valor principal no topo, o valor adicional logo abaixo
        text(j, i - 0.25, sprintf('%.4f', data1(i, j)), 'HorizontalAlignment', 'center', 'Color', 'black', 'FontSize', 11);
        if i ~= j
             text(j, i, sprintf('%.4f', data2(i, j)), 'HorizontalAlignment', 'center', 'Color', 'red', 'FontSize', 8);
            text(j, i + 0.25, sprintf('%.4f', data3(i, j)), 'HorizontalAlignment', 'center', 'Color', 'blue', 'FontSize', 8);
        end
    end
end

% Definir siglas das variáveis para o eixo X
variableNames = {'Outc', 'Age', 'Gndr', 'Vent', 'RBC Dist.', 'Monoc(%)', ...
                 'WBC', 'Plt', 'Lympho', 'Neutro', 'Days Hosp'};

% Definir os rótulos nos eixos X e Y
set(gca, 'XTick', 1:length(variableNames), 'XTickLabel', variableNames);
set(gca, 'YTick', 1:length(variableNames), 'YTickLabel', variableNames);

% Configurar o gráfico
title('Heatmap com Valores de Correlação, r^2 em vermelho e Sr em azul');

display('')
display('Observar Figure 1')
display('')
display('Primeiro fizemos uma correlação entre todas as variáveis em forma de Heatmap. Para isso, calculamos o valor da correlação, o R2 (Coeficiente de Determinação), o Sr (Soma dos Quadrados do Resíduo). O nosso objetivo é obter variáveis cujo valor de correlação é proximo de 1 ou -1, o R2 próximo de 1, o Sr baixo. Por fim, optamos pelos pares Ventilation (Y/N) e Outcome (0/1), e Age junto de Outcome (0/1)')
display('')

%%%% Análise 2 %%%%

disp('Análise 2: Comparação estatísca das métricas ');
display('Essa análise é independente da Análise 1. Divida os pacientes em grupos etários (por exemplo, menores de 40, entre 40 e 60, e maiores de 60 anos). Avalie se há diferenças significativas entre esses grupos nas contagens de células sanguíneas (como linfócitos, neutrófilos e leucócitos) em relação ao desfecho clínico.')
display('')
% Extrair colunas relevantes
idade = data(:, 2); % Coluna de idades
outcome = data(:, 1); % Coluna de outcome (0 = morreu, 1 = vivo)
lin = data(:, 9); % Coluna de linfócitos
neu = data(:, 10); % Coluna de neutrófilos
white = data(:, 7); % Coluna de leucócitos (glóbulos brancos)

% Definir grupos etários
menos_37 = idade < 37;
entre_37_e_57 = idade >= 37 & idade <= 57;
mais_57 = idade > 57;

% Filtrar sobreviventes e falecidos
vivo = outcome ==1;
morto = outcome == 0;

% Calcular médias para sobreviventes em cada grupo etário
l_s = [mean(lin(vivo & menos_37)), ...
                              mean(lin(vivo & entre_37_e_57)), ...
                              mean(lin(vivo & mais_57))];
n_s = [mean(neu(vivo & menos_37)), ...
                              mean(neu(vivo & entre_37_e_57)), ...
                              mean(neu(vivo & mais_57))];
w_s = [mean(white(vivo & menos_37)), ...
                      mean(white(vivo & entre_37_e_57)), ...
                      mean(white(vivo & mais_57))];

% Calcular médias para falecidos em cada grupo etário
l_d = [mean(lin(morto & menos_37)), ...
                             mean(lin(morto & entre_37_e_57)), ...
                             mean(lin(morto & mais_57))];
n_d = [mean(neu(morto & menos_37)), ...
                             mean(neu(morto & entre_37_e_57)), ...
                             mean(neu(morto & mais_57))];
w_d = [mean(white(morto & menos_37)), ...
                     mean(white(morto & entre_37_e_57)), ...
                     mean(white(morto & mais_57))];

% Agrupar dados para facilitar o histograma
grupos = {'Menos de 37', '37-57', 'Mais que 57'};
x = 1:3; % Índices dos grupos etários

% Encontrar o limite máximo para o eixo y
max_y = 16;

% Plotar histograma para sobreviventes
figure;
subplot(1, 2, 1); % Subgráfico para sobreviventes
bar(x, [l_s; n_s; w_s]', 0.8); % Barras mais largas com largura 0.8
set(gca, 'XTick', x, 'XTickLabel', grupos);
xlabel('Idade dos grupos');
ylabel('Média');
title('Vivos - Amostra de sangue por idade');
legend({'Linfócitos', 'Neutrofilos', 'Celulas brancas'});
ylim([0, max_y]); % Definir o mesmo limite para o eixo y
grid on;

% Plotar histograma para falecidos
subplot(1, 2, 2); % Subgráfico para falecidos
bar(x, [l_d; n_d; w_d]', 0.8); % Barras mais largas com largura 0.8
set(gca, 'XTick', x, 'XTickLabel', age_groups);
xlabel('Idade dos grupos');
ylabel('Médiag');
title('Mortos - Amostra de sangue por idade');
legend({'Linfócitos', 'Neutrofilos', 'Celulas brancas'});
ylim([0, max_y]); % Definir o mesmo limite para o eixo y
grid on;
hold off;

display('Observar Figure 2')
display('')
display('Esses gráficos analisam diferenças significativas nas contagens de células sanguíneas em relação ao desfecho clínico — óbito (0) ou sobrevivência (1). Dividimos os pacientes em três faixas etárias: menores de 37 anos, entre 37 e 57 anos, e acima de 57 anos, de forma que cada grupo contivesse uma quantidade semelhante de pacientes.')

display('A partir dos gráficos, observamos um padrão nas contagens de células sanguíneas: uma maior quantidade de glóbulos brancos, seguidos pelos neutrófilos e, por fim, os linfócitos. Em geral, os pacientes que faleceram apresentaram mais neutrófilos e linfócitos. Para o grupo entre 37 e 57 anos, os sobreviventes tinham mais glóbulos brancos em comparação aos que faleceram. Os jovens que vieram a óbito mostraram uma contagem menor de glóbulos brancos, enquanto os pacientes do terceiro grupo etário que faleceram apresentaram quantidades maiores dos três tipos de células sanguíneas em relação aos sobreviventes.')
display('')

%%%% Análise 3 %%%%

disp('Análise 3: Predição');
display('Faça dois modelos de regressão linear. Aqui você deve implementar um modelo 𝑦1 = 𝑎0,1 + 𝑎1,1𝑥1 e outro 𝑦2 = 𝑎0,2 + 𝑎1,2𝑥2 onde 𝑥1 e 𝑥2 são variáveis que melhor preveem dias hospitalizados. Calcule as somas dos resíduos 𝑆𝑟,𝑟2 e 𝑠𝑦/𝑥 para cada modelo. Qual é melhor? Justifique.')
display('Implemente um terceiro modelo de regressão linear múltipla do tipo 𝑦3 = 𝑎0,3 + 𝑎1,3𝑥1 + 𝑎2,3𝑥2 que combina as duas métricas utilizadas em (3.1). Isso significa que você deve encontrar os parâmetros 𝑎0,3, 𝑎1,3 e 𝑎2,3 de tal maneira que a regressão 𝑦3 = 𝑎1𝑥1 + 𝑎2𝑥2 + 𝑎0 seja o melhor possível. Calcule qual a soma dos resíduos 𝑆𝑟, 𝑟2 e 𝑠𝑦/𝑥 para o modelo 𝑦3. Compare-o com 𝑦1 e 𝑦2. Qual é o melhor? Justifique.')
display('')

% Regressão 1: Dias Hospitalizados vs Gênero do Paciente
% Extração das colunas de interesse
x1 = data(:, 3);  % Coluna 3: Gender (0 para feminino, 1 para masculino)
y = data(:, 11);  % Coluna 11: Days Hospitalized

% Número de dados
n = length(x1);

% Cálculo dos coeficientes a0 e a1 para Gênero do Paciente usando as novas fórmulas
a1_1 = (n * sum(x1 .* y) - sum(x1) * sum(y)) / (n * sum(x1 .^ 2) - sum(x1)^2);
a0_1 = mean(y) - a1_1 * mean(x1);

% Predição dos valores de y para Gênero do Paciente
y_pred1 = a0_1 + a1_1 * x1;

% Cálculo das novas métricas para o primeiro modelo
St1 = sum((y - mean(y)).^2);
Sr1 = sum((y - (a0_1 + a1_1 * x1)).^2);
r_squared1 = (St1 - Sr1) / St1;
s_yx1 = sqrt(Sr1 / (n - 2));
s_y1 = sqrt(St1 / (n - 1));

% Regressão 2: Dias Hospitalizados vs Contagem de Plaquetas
% Extração das colunas de interesse
x2 = data(:, 8);  % Coluna 8: Platelet Count

% Cálculo dos coeficientes a0 e a1 para Contagem de Plaquetas usando as novas fórmulas
a1_2 = (n * sum(x2 .* y) - sum(x2) * sum(y)) / (n * sum(x2 .^ 2) - sum(x2)^2);
a0_2 = mean(y) - a1_2 * mean(x2);

% Predição dos valores de y para Contagem de Plaquetas
y_pred2 = a0_2 + a1_2 * x2;

% Cálculo das novas métricas para o segundo modelo
St2 = sum((y - mean(y)).^2);
Sr2 = sum((y - (a0_2 + a1_2 * x2)).^2);
r_squared2 = (St2 - Sr2) / St2;
s_yx2 = sqrt(Sr2 / (n - 2));
s_y2 = sqrt(St2 / (n - 1));

% Regressão Múltipla: Dias Hospitalizados vs Gênero do Paciente e Contagem de Plaquetas
% Criar a matriz de design X para o modelo múltiplo (incluindo o termo de bias)
X3 = [ones(n, 1), x1, x2];

% Cálculo dos coeficientes utilizando a fórmula de mínimos quadrados
XtX = X3' * X3;
Xty = X3' * y;
coef3 = XtX \ Xty;

% Predição dos valores de y usando o modelo de regressão múltipla
y_pred3 = X3 * coef3;

% Cálculo da soma dos resíduos (Sr), r^2 e s_y/x para o modelo múltiplo
St3 = sum((y - mean(y)).^2);
Sr3 = sum((y - y_pred3).^2);
r_squared3 = (St3 - Sr3) / St3;
s_yx3 = sqrt(Sr3 / (n - 3));  % Ajuste de graus de liberdade para 3 parâmetros
s_y3 = sqrt(St3 / (n - 1));

display('Observar Figure 3')
display('')
% Exibir os resultados das duas regressões simples e múltipla
fprintf('Regressão 1: Dias Hospitalizados vs Gênero do Paciente\n');
fprintf('Coeficiente a0: %.4f\n', a0_1);
fprintf('Coeficiente a1: %.4f\n', a1_1);
fprintf('Soma dos Resíduos (Sr): %.4f\n', Sr1);
fprintf('Coeficiente de Determinação (r^2): %.4f\n', r_squared1);
fprintf('Erro Padrão (s_y/x): %.4f\n', s_yx1);

fprintf('\nRegressão 2: Dias Hospitalizados vs Contagem de Plaquetas\n');
fprintf('Coeficiente a0: %.4f\n', a0_2);
fprintf('Coeficiente a1: %.4f\n', a1_2);
fprintf('Soma dos Resíduos (Sr): %.4f\n', Sr2);
fprintf('Coeficiente de Determinação (r^2): %.4f\n', r_squared2);
fprintf('Erro Padrão (s_y/x): %.4f\n', s_yx2);
display('')
display('Observar Figure 4')

fprintf('\nModelo de Regressão Múltipla:\n');
fprintf('Coeficientes do Modelo Múltiplo:\n');
fprintf('a0: %.4f\n', coef3(1));
fprintf('a1 (Gênero do Paciente): %.4f\n', coef3(2));
fprintf('a2 (Contagem de Plaquetas): %.4f\n', coef3(3));
fprintf('Soma dos resíduos (Sr): %.4f\n', Sr3);
fprintf('Coeficiente de Determinação (r^2): %.4f\n', r_squared3);
fprintf('Erro padrão (s_y/x): %.4f\n', s_yx3);

% Plotar os gráficos
figure;


% Gráfico 1: Dias Hospitalizados vs Gênero do Paciente
subplot(2,1,1);
plot(x1, y, 'o', 'MarkerSize', 5);
hold on;
plot(x1, y_pred1, '-r', 'LineWidth', 2);
title('Regressão Linear: Dias Hospitalizados vs Gênero do Paciente');
xlabel('Gênero do Paciente (0 = Feminino, 1 = Masculino)');
ylabel('Dias Hospitalizados');
legend('Dados Reais', 'Linha de Regressão');
hold off;

% Gráfico 2: Dias Hospitalizados vs Contagem de Plaquetas
subplot(2,1,2);
plot(x2, y, 'o', 'MarkerSize', 5);
hold on;
plot(x2, y_pred2, '-r', 'LineWidth', 2);
title('Regressão Linear: Dias Hospitalizados vs Contagem de Plaquetas');
xlabel('Contagem de Plaquetas');
ylabel('Dias Hospitalizados');
legend('Dados Reais', 'Linha de Regressão');
hold off;

% Gráfico 3: Modelo de Regressão Múltipla 3D
figure;
scatter3(x1, x2, y, 'filled');
hold on;
[x1_grid, x2_grid] = meshgrid(linspace(min(x1), max(x1), 20), linspace(min(x2), max(x2), 20));
y_grid = coef3(1) + coef3(2) * x1_grid + coef3(3) * x2_grid;
mesh(x1_grid, x2_grid, y_grid);
title('Regressão Linear Múltipla: Dias Hospitalizados vs Gênero do Paciente e Contagem de Plaquetas');
xlabel('Gênero do Paciente');
ylabel('Contagem de Plaquetas');
zlabel('Dias Hospitalizados');
legend('Dados Reais', 'Superfície de Regressão');
hold off;

display('')
display('A melhor regressão é a que relaciona dias hospitalizados com contagens de plaquetas. Chegamos a essa conclusão pois, em relação a regressão de dias hospitalizados e gênero, os resíduos são menores e o R2  mais próximo de 1. ')
display('')
display('A regressão múltipla é melhor. Os resíduos são menores e o R2  mais próximo de 1.')
display('')
display('Não, esse modelo não é bom, pois o R2 é de 0.2697. Isso significa que o modelo explica apenas 26,97% da variabilidade total dos dados de dias de hospitalização.')
display('')


