% main.pl: O arquivo principal que organiza tudo.
% Carrega os outros arquivos
:- [kb, rules, ui, explain].
:- encoding(utf8).

% O comando que inicia o sistema
start :-
    menu.

% Mostra o menu e le a opcao
menu :-
    imprimir_banner,
    write('Escolha uma opção:'), nl,
    write('  1. Executar consulta de custos'), nl,
    write('  2. Sair'), nl,
    imprimir_rodape,
    nl, write('Opção: '),
    read_line_to_string(user_input, OpcaoStr),
    atom_number(OpcaoStr, Opcao),
    processar_opcao(Opcao),
    !. % Corte para nao voltar ao menu

% Se a opcao for invalida
menu :-
    write_ln('Erro: Opção inválida. Tente novamente.'),
    nl,
    menu.

% Processa a escolha do usuario
processar_opcao(1) :-
    executar_consulta,
    write_ln('Pressione [Enter] para voltar ao menu...'),
    read_line_to_string(user_input, _), % Pausa
    menu.

processar_opcao(2) :-
    write_ln('Saindo do sistema...'),
    halt.

% Fluxo principal: limpa, coleta, processa e mostra
executar_consulta :-
    limpar_dados_anteriores,
    coletar_configuracao,
    loop_adicionar_rotas,
    
    ( \+ rota(_,_,_,_,_,_,_) -> 
        write_ln('Nenhuma rota foi adicionada. Consulta cancelada.')
    ;
        processar_e_exibir_resultados
    ).

% Limpa os dados da consulta anterior
limpar_dados_anteriores :-
    retractall(rota(_,_,_,_,_,_,_)),
    retractall(config(_,_)),
    limpar_trilha.

% Chama o processamento e imprime os resultados
processar_e_exibir_resultados :-
    meta_principal(Resultados, CustoGlobal), % Chama o "cerebro"
    
    nl, write('--- Resultados Detalhados por Rota ---'), nl,
    imprimir_resultados_rotas(Resultados),
    
    nl, write('--- Sumário Global ---'), nl,
    format('Custo Global Total: R$ ~2f~n', [CustoGlobal]),
    
    nl, write('--- Explicação das Inferências (Trilha) ---'), nl,
    imprimir_explicacao. % Mostra o "porquê"

% Helpers para imprimir a saida
imprimir_resultados_rotas([]).
imprimir_resultados_rotas([H|T]) :-
    imprimir_rota(H),
    imprimir_resultados_rotas(T).

imprimir_rota(resultado(ID, Nome, CustoTotal, CustoAluno, Eficiencia, Diagnosticos)) :-
    format('~nRota: ~w (~w)~n', [Nome, ID]),
    format('  Custo Total: R$ ~2f~n', [CustoTotal]),
    format('  Custo p/ Aluno: R$ ~2f~n', [CustoAluno]),
    format('  Eficiência: ~2f km/aluno~n', [Eficiencia]),
    write('  Diagnósticos:'), nl,
    imprimir_diagnosticos(Diagnosticos),
    write('--------------------'), nl.

imprimir_diagnosticos([]).
imprimir_diagnosticos([H|T]) :-
    format('    - ~w~n', [H]),
    imprimir_diagnosticos(T).

% O cabecalho do programa
imprimir_banner :-
    nl,
    write('=================================================='), nl,
    write('   Sistema Especialista de Transporte Escolar     '), nl,
    write('=================================================='), nl.

% O rodape com os nomes
imprimir_rodape :-
    write('--------------------------------------------------'), nl,
    write('  Desenvolvido por:'), nl,
    write('    Vinicius Policarpo Macedo e Misael Sardá      '), nl,
    write('=================================================='), nl.