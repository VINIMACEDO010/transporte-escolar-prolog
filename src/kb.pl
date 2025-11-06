% kb.pl: A Base de Conhecimento.
% Guarda os fatos e tabelas.

:- encoding(utf8).

% --- Fatos Dinamicos ---
% (Sao fatos que o usuario insere)
:- dynamic rota/7.  % (ID, Nome, Km, Alunos, Consumo, Preco, Atraso)
:- dynamic config/2. % (Chave, Valor)
:- dynamic trilha/2. % (ID, Motivo)

% --- Fatos Estaticos ---
% (Sao as nossas "tabelas" de regras de negocio)

% Tabela de eficiencia (km por aluno)
classificacao_eficiencia(baixa, 0, 5.0).
classificacao_eficiencia(media, 5.01, 10.0).
classificacao_eficiencia(alta, 10.01, 9999).

% Tabela de custo por aluno (qual o limite aceitavel)
custo_aluno_limite(adequado, 25.0).
custo_aluno_limite(elevado, 25.01).

% Tabela de penalidade (qual o percentual critico)
penalidade_critica_percentual(0.10). % 10%