% rules.pl: O "cerebro" do sistema.
% Contem as regras de calculo e diagnostico.

:- encoding(utf8).

% --- O "Pipeline" Principal ---
% (Isso e o 'meta' que o professor gosta: filter/map/reduce)
meta_principal(Resultados, CustoGlobal) :-
    % 1. (Filter) Encontra todas as rotas
    findall(ID, rota(ID, _, _, _, _, _, _), ListaIDs),
    
    % 2. (Map) Processa cada rota
    processar_todas_rotas(ListaIDs, Resultados),
    
    % 3. (Reduce) Soma o custo de todas
    calcular_custo_global(Resultados, CustoGlobal).

processar_todas_rotas([], []).
processar_todas_rotas([ID|T], [Resultado|Resto]) :-
    processar_rota(ID, Resultado),
    processar_todas_rotas(T, Resto).

% --- Ordem dos Calculos (como o professor pediu) ---
processar_rota(ID, resultado(ID, Nome, CustoTotal, CustoAluno, Eficiencia, Diagnosticos)) :-
    rota(ID, Nome, _, _, _, _, _),
    
    % A ordem e importante:
    custo_total_rota(ID, CustoTotal),       % 1. Custo total
    custo_por_aluno(ID, CustoAluno),       % 2. Custo por aluno (depende do 1)
    eficiencia_km_por_aluno(ID, Eficiencia), % 3. Eficiencia
    
    % 4. Diagnosticos (depende dos calculos acima)
    findall(Diag, diagnostico(ID, Diag), Diagnosticos).

% --- Regras de Calculo ---

custo_por_km(ID, CustoKm) :-
    rota(ID, _, _, _, Consumo, Preco, _),
    CustoKm is Consumo * Preco.

custo_base_rota(ID, CustoBase) :-
    rota(ID, _, Km, _, _, _, _),
    custo_por_km(ID, CustoKm),
    CustoBase is Km * CustoKm.

penalidade(ID, Penalidade) :-
    rota(ID, _, _, _, _, _, Atraso),
    config(taxa_penalidade, Taxa),
    Penalidade is Atraso * Taxa.

custo_total_rota(ID, CustoTotal) :-
    custo_base_rota(ID, CustoBase),
    penalidade(ID, Penalidade),
    CustoTotal is CustoBase + Penalidade.

% Trata divisao por zero
custo_por_aluno(ID, CustoAluno) :-
    rota(ID, _, _, Alunos, _, _, _),
    custo_total_rota(ID, CustoTotal),
    (Alunos > 0 -> CustoAluno is CustoTotal / Alunos ; CustoAluno is 0.0).

% Trata divisao por zero
eficiencia_km_por_aluno(ID, Eficiencia) :-
    rota(ID, _, Km, Alunos, _, _, _),
    (Alunos > 0 -> Eficiencia is Km / Alunos ; Eficiencia is 0.0).

% Soma o total
calcular_custo_global([], 0.0).
calcular_custo_global([resultado(_, _, CustoTotal, _, _, _)|T], Soma) :-
    calcular_custo_global(T, SomaResto),
    Soma is CustoTotal + SomaResto.

% --- Regras de Diagnostico (8+ regras) ---

% R1: Garante que os dados de entrada sao validos
diagnostico(ID, 'Erro: Dados Inválidos (KM, Alunos ou Consumo <= 0)') :-
    rota(ID, _, Km, Alunos, Consumo, Preco, Atraso),
    (Km =< 0; Alunos =< 0; Consumo =< 0; Preco =< 0; Atraso < 0),
    adicionar_trilha(ID, 'R1: Falha na validação. KM, Alunos, Consumo e Preço devem ser > 0. Atraso deve ser >= 0.'),
    !. % (!) impede outras regras se os dados forem invalidos

% R2: Custo por aluno esta acima do limite
diagnostico(ID, 'Custo Elevado por Aluno') :-
    custo_por_aluno(ID, CustoAluno),
    custo_aluno_limite(adequado, Limite),
    CustoAluno > Limite,
    format(atom(Motivo), 'R2: Custo por aluno (R$ ~2f) > Limite (R$ ~2f).', [CustoAluno, Limite]),
    adicionar_trilha(ID, Motivo).

% R3: Custo por aluno esta OK
diagnostico(ID, 'Custo Adequado por Aluno') :-
    custo_por_aluno(ID, CustoAluno),
    custo_aluno_limite(adequado, Limite),
    CustoAluno > 0, CustoAluno =< Limite,
    format(atom(Motivo), 'R3: Custo por aluno (R$ ~2f) está dentro do limite (R$ ~2f).', [CustoAluno, Limite]),
    adicionar_trilha(ID, Motivo).

% R4: Eficiencia baixa
diagnostico(ID, 'Baixa Eficiência (km/aluno)') :-
    eficiencia_km_por_aluno(ID, Eficiencia),
    classificacao_eficiencia(baixa, Min, Max),
    Eficiencia >= Min, Eficiencia =< Max,
    format(atom(Motivo), 'R4: Eficiência (~2f km/aluno) na faixa BAIXA (~w-~w).', [Eficiencia, Min, Max]),
    adicionar_trilha(ID, Motivo).

% R5: Eficiencia media
diagnostico(ID, 'Eficiência Média (km/aluno)') :-
    eficiencia_km_por_aluno(ID, Eficiencia),
    classificacao_eficiencia(media, Min, Max),
    Eficiencia >= Min, Eficiencia =< Max,
    format(atom(Motivo), 'R5: Eficiência (~2f km/aluno) na faixa MÉDIA (~w-~w).', [Eficiencia, Min, Max]),
    adicionar_trilha(ID, Motivo).

% R6: Eficiencia alta
diagnostico(ID, 'Alta Eficiência (km/aluno)') :-
    eficiencia_km_por_aluno(ID, Eficiencia),
    classificacao_eficiencia(alta, Min, Max),
    Eficiencia >= Min, Eficiencia =< Max,
    format(atom(Motivo), 'R6: Eficiência (~2f km/aluno) na faixa ALTA (> ~w).', [Eficiencia, Min]),
    adicionar_trilha(ID, Motivo).

% R7: Penalidade por atraso e muito alta
diagnostico(ID, 'Penalidade Crítica por Atraso') :-
    penalidade(ID, Penalidade),
    custo_base_rota(ID, CustoBase),
    penalidade_critica_percentual(Percentual),
    LimitePenalidade is CustoBase * Percentual,
    Penalidade > 0, Penalidade > LimitePenalidade,
    format(atom(Motivo), 'R7: Penalidade (R$ ~2f) > ~2f%% do Custo Base (R$ ~2f).', [Penalidade, Percentual*100, CustoBase]),
    adicionar_trilha(ID, Motivo).

% R8: Regra composta (uma rota perfeita)
diagnostico(ID, 'Rota Otimizada') :-
    diagnostico(ID, 'Custo Adequado por Aluno'),
    diagnostico(ID, 'Alta Eficiência (km/aluno)'),
    \+ diagnostico(ID, 'Penalidade Crítica por Atraso'),
    adicionar_trilha(ID, 'R8: Rota otimizada (Custo adequado, alta eficiência, sem penalidade crítica).').

% R9: Rota sem atrasos
diagnostico(ID, 'Sem Atrasos') :-
    rota(ID, _, _, _, _, _, 0),
    adicionar_trilha(ID, 'R9: Rota executada sem atrasos.').