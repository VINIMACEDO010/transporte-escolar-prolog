# 🚌 Sistema Especialista de Transporte Escolar (em Prolog)

Este é um projeto de Sistema Especialista construído em **SWI-Prolog** que analisa e diagnostica rotas de transporte escolar.

A ideia é simples: você fornece os dados de uma rota (como quilometragem, número de alunos e custos de combustível) e o sistema calcula métricas-chave (como custo por aluno e eficiência).  
Mais importante, ele usa um conjunto de regras lógicas para **diagnosticar problemas** (como “Baixa Eficiência” ou “Penalidade Crítica por Atraso”) e **explicar o porquê** de sua conclusão.

---

## 👨‍💻 Autores

- [@VINIMACEDO010](https://github.com/VINIMACEDO010)
- [@MisaelSarda](https://github.com/MisaelSarda)


---

## 🧠 O Paradigma: Por que Prolog?

O interessante deste projeto é o paradigma.  

Nós simplesmente definimos duas coisas:

1. **Fatos** (`kb.pl`): nossas “tabelas” de negócio.  
   Exemplo:
   ```prolog
   custo_aluno_limite(adequado, 25.0).
   ```

2. **Regras** (`rules.pl`): a lógica de inferência.  
   Exemplo:
   ```prolog
   diagnostico(ID, 'Rota Otimizada') :-
       diagnostico(ID, 'Custo Adequado por Aluno'),
       diagnostico(ID, 'Alta Eficiência (km/aluno)'),
       \+ diagnostico(ID, 'Penalidade Crítica por Atraso').
   ```

O motor do Prolog faz o trabalho pesado de conectar esses fatos e regras para encontrar a resposta.

---

### ⚙️ O "Pipeline" de Dados em Prolog

Para quem vem de linguagens funcionais, o projeto implementa o clássico pipeline  
`filter → map → reduce` de forma declarativa (em `rules.pl`):

- **Filter:** `findall(...)` é usado para coletar todas as rotas que o usuário inseriu.  
- **Map:** `processar_todas_rotas(...)` aplica `processar_rota` recursivamente em cada item da lista.  
- **Reduce:** `calcular_custo_global(...)` soma os custos de todos os resultados para gerar o total.

---

## 🏛️ Arquitetura do Projeto

O código é organizado em uma estrutura modular de 5 arquivos, cada um com uma responsabilidade clara:

```
/src/
│
├── main.pl      # O orquestrador: menu principal e fluxo da aplicação.
├── kb.pl        # Base de Conhecimento: armazena os fatos e "tabelas".
├── rules.pl     # O Cérebro: todas as regras de cálculo e diagnóstico (R1–R9).
├── ui.pl        # Interface: faz perguntas e coleta os dados do usuário.
└── explain.pl   # O Explicador: imprime a trilha de inferências.
```

---

## ▶️ Como Executar

Você vai precisar ter o [**SWI-Prolog**](https://www.swi-prolog.org/) instalado.

1. **Clone o repositório**
   ```bash
   git clone https://github.com/VINIMACEDO010/transporte-escolar-prolog
   cd transporte-escolar-prolog/src
   ```

2. **Inicie o SWI-Prolog** (dentro da pasta `src`)
   ```bash
   swipl
   ```

3. **Carregue o arquivo principal**
   ```prolog
   ?- ['main.pl'].
   ```
   *O sistema deve responder `true.`*

4. **Execute o sistema**
   ```prolog
   ?- start.
   ```

5. 🎉 **Pronto!** O menu será exibido e você pode começar a usar.

---

## 📋 Exemplo de Uso

### 🧩 Entradas
```
Opção: 1

--- Configuração Global ---
Taxa de Penalidade por Minuto de Atraso (R$): 0.50

Deseja adicionar uma rota? (s/n): s
--- Adicionando Nova Rota ---
ID da Rota: R-001
Nome da Rota: Rota Centro
Km Rodados: 50
Número de Alunos: 10
Consumo (L/km): 0.1
Preço Combustível (R$/L): 5.50
Atraso (minutos): 15

Deseja adicionar uma rota? (s/n): s
--- Adicionando Nova Rota ---
ID da Rota: R-002
Nome da Rota: Rota Rural Otimizada
Km Rodados: 70
Número de Alunos: 6
Consumo (L/km): 0.09
Preço Combustível (R$/L): 5.50
Atraso (minutos): 0

Deseja adicionar uma rota? (s/n): n
```

---

### 🧾 Saída
```prolog
--- Resultados Detalhados por Rota ---

Rota: Rota Centro (R-001)
  Custo Total: R$ 35.00
  Custo p/ Aluno: R$ 3.50
  Eficiência: 5.00 km/aluno
  Diagnósticos:
    - Custo Adequado por Aluno
    - Baixa Eficiência (km/aluno)
    - Penalidade Crítica por Atraso
--------------------

Rota: Rota Rural Otimizada (R-002)
  Custo Total: R$ 34.65
  Custo p/ Aluno: R$ 5.77
  Eficiência: 11.67 km/aluno
  Diagnósticos:
    - Custo Adequado por Aluno
    - Alta Eficiência (km/aluno)
    - Rota Otimizada
    - Sem Atrasos
--------------------

--- Sumário Global ---
Custo Global Total: R$ 69.65

--- Explicação das Inferências (Trilha) ---
  [Rota R-001]: R3: Custo por aluno (R$ 3.50) está dentro do limite (R$ 25.00).
  [Rota R-001]: R4: Eficiência (5.00 km/aluno) na faixa BAIXA (0-5.0).
  [Rota R-001]: R7: Penalidade (R$ 7.50) > 10.00% do Custo Base (R$ 27.50).
  [Rota R-002]: R3: Custo por aluno (R$ 5.77) está dentro do limite (R$ 25.00).
  [Rota R-002]: R6: Eficiência (11.67 km/aluno) na faixa ALTA (> 10.01).
  [Rota R-002]: R8: Rota otimizada (Custo adequado, alta eficiência, sem penalidade crítica).
  [Rota R-002]: R9: Rota executada sem atrasos.

Pressione [Enter] para voltar ao menu...
```

---

## 🧩 Tecnologias

- **SWI-Prolog**
- **Paradigma Lógico**
- **Inferência Baseada em Regras**
- **Arquitetura Modular**

---
