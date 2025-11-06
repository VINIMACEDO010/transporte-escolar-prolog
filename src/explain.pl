% explain.pl: Modulo de Explicacao.
% Monta e imprime a trilha de regras.

:- encoding(utf8).

% Guarda uma linha na trilha de explicacao
adicionar_trilha(ID, Motivo) :-
    assertz(trilha(ID, Motivo)).

% Limpa a trilha para uma nova consulta
limpar_trilha :-
    retractall(trilha(_, _)).

% Imprime a trilha completa no final
imprimir_explicacao :-
    findall(trilha(ID, Motivo), trilha(ID, Motivo), Trilhas),
    ( Trilhas = [] ->
        write_ln('Nenhuma regra de diagnóstico foi acionada.')
    ;
        imprimir_lista_trilha(Trilhas)
    ).

% Funcao auxiliar para imprimir a lista
imprimir_lista_trilha([]).
imprimir_lista_trilha([trilha(ID, Motivo)|T]) :-
    format('  [Rota ~w]: ~w~n', [ID, Motivo]),
    imprimir_lista_trilha(T).