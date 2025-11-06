% ui.pl: Funcoes para interagir com o usuario.
% Pede os dados e salva na base de conhecimento (com assertz).

:- encoding(utf8).

% --- Funcoes de Leitura ---

% Le uma string
ler_string(Prompt, Valor) :-
    write(Prompt),
    read_line_to_string(user_input, Valor).

% Pede um numero e insiste se o usuario digitar texto
ler_numero(Prompt, Valor) :-
    write(Prompt),
    read_line_to_string(user_input, String),
    ( atom_number(String, Valor) ->
        true % Sucesso
    ;
        write_ln('Erro: Valor inválido. Por favor, insira um número.'),
        ler_numero(Prompt, Valor) % Tenta de novo
    ).

% Pede 's' ou 'n' e insiste se a resposta for invalida
ler_sn(Prompt, Resposta) :-
    format('~w (s/n): ', [Prompt]),
    read_line_to_string(user_input, String),
    string_lower(String, Lower),
    ( (Lower = "s"; Lower = "sim") ->
        Resposta = s
    ; (Lower = "n"; Lower = "nao") ->
        Resposta = n
    ;
        write_ln('Erro: Resposta inválida. Digite "s" ou "n".'),
        ler_sn(Prompt, Resposta) % Tenta de novo
    ).

% --- Coleta de Dados ---

% Pergunta a configuracao global
coletar_configuracao :-
    write_ln('--- Configuração Global ---'),
    ler_numero('Taxa de Penalidade por Minuto de Atraso (R$): ', Taxa),
    assertz(config(taxa_penalidade, Taxa)). % Salva o fato

% Pergunta se quer adicionar mais rotas
loop_adicionar_rotas :-
    nl,
    ler_sn('Deseja adicionar uma rota?', Resposta),
    ( Resposta = s ->
        coletar_dados_rota,
        loop_adicionar_rotas % Chama a si mesmo
    ;
        write_ln('Coleta de rotas concluída.')
    ).

% Pede os dados de uma rota
coletar_dados_rota :-
    write_ln('--- Adicionando Nova Rota ---'),
    ler_string('ID da Rota (ex: R-001): ', ID),
    ler_string('Nome da Rota (ex: Rota Centro): ', Nome),
    ler_numero('Km Rodados (ex: 50.5): ', Km),
    ler_numero('Número de Alunos (ex: 10): ', AlunosInt),
    Alunos is round(AlunosInt),
    ler_numero('Consumo (L/km) (ex: 0.1): ', Consumo),
    ler_numero('Preço Combustível (R$/L) (ex: 5.50): ', Preco),
    ler_numero('Atraso (minutos) (ex: 15): ', AtrasoInt),
    Atraso is round(AtrasoInt),
    
    assertz(rota(ID, Nome, Km, Alunos, Consumo, Preco, Atraso)), % Salva o fato
    format('Rota "~w" adicionada.~n', [Nome]).