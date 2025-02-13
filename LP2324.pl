% ist1110633 Filipe Oliveira
:- use_module(library(clpfd)).
:- set_prolog_flag(answer_write_options,[max_depth(0)]).
:- ['puzzlesAcampar.pl'].
% Segue-se o codigo


/*
Predicado: vizinhanca/2
Identifica a vizinhanca de uma dada posicao de coordenadas (L,C).
Ou seja, as coordenadas da posicao imediatamente acima/abaixo/esquerda/direita.
Vizinhanca eh uma lista ordenada de cima para baixo e da esquerda para a direita.
*/
vizinhanca((L, C), Vizinhanca) :-
    L1 is L-1, %acima
    L2 is L+1, %abaixo
    C1 is C-1, %esquerda
    C2 is C+1, %direita
    Vizinhanca = [(L1, C), (L, C1), (L, C2), (L2, C)].






/*
Predicado: vizinhancaAlargada/2
Semelhante ao predicado vizinhanca/2, mas incluindo tambem as diagonais.
Ou seja, as coordenadas da vizinhanca e das diagonais de uma posicao de coordenadas (L,C).
VizinhancaAlargada eh uma lista ordenada de cima para baixo e da esquerda para a direita.
*/
vizinhancaAlargada((L, C), VizinhancaAlargada) :-
    L1 is L-1, %acima
    L2 is L+1, %abaixo
    C1 is C-1, %esquerda
    C2 is C+1, %direita
    VizinhancaAlargada = [(L1, C1), (L1, C), (L1, C2), (L, C1), (L, C2),(L2, C1), (L2, C), (L2, C2)].






/*
Predicado: todasCelulas/2
Identifica todas as coordenadas de um tabuleiro.
TodasCelulas eh uma lista ordenada de cima para baixo e da esquerda para a direita.
*/
%Acede as coordenadas individuais do tabuleiro e encontra todas as coordenadas (L, C).
todasCelulas(Tabuleiro, TodasCelulas) :-
    findall((L, C), (nth1(L, Tabuleiro, L1), nth1(C, L1, _)), TodasCelulas).






/*
Predicado: todasCelulas/3
Identifica todas as coordenadas de um tabuleiro que contem um dado tipo de objectos:
- Tenda (t)
- Relva (r)
- Arvore (a)
- Variavel (X ou Y por exemplo) (espacos nao preenchidos)
TodasCelulas eh uma lista ordenada de cima para baixo e da esquerda para a direita.
*/
%Obtem todas as celulas do tabuleiro e usa o predicado auxiliar para filtrar.
todasCelulas(Tabuleiro, TodasCelulas, Objecto) :-
    todasCelulas(Tabuleiro, TodasCelulasTabuleiro),
    incluirApenasObjecto(Tabuleiro, TodasCelulasTabuleiro, TodasCelulas, Objecto).

%Predicado auxiliar incluirApenasObjecto/4
%Filtra a lista de todas as coordenadas do tabuleiro,
%de modo a incluir apenas aquelas que contem o objecto especifico.
%Acede ao elemento de cada coordenada e verifica se eh um objecto (atomic) ou uma variavel (var).
%Se a condicao for satisfeita adiciona a coordenada na lista final, TodasCelulas.
incluirApenasObjecto(_, [], [], _).
incluirApenasObjecto(Tabuleiro, [(L, C)|R], Coordenadas, Objecto) :-
    nth1(L, Tabuleiro, L1),
    nth1(C, L1, Elem),
    (
        (atomic(Objecto), Elem == Objecto);
        (var(Objecto), var(Elem))
    ),
    !,
    Coordenadas = [(L, C)|CoordenadasResto],
    incluirApenasObjecto(Tabuleiro, R, CoordenadasResto, Objecto).
incluirApenasObjecto(Tabuleiro, [_|R], Coordenadas, Objecto) :-
    incluirApenasObjecto(Tabuleiro, R, Coordenadas, Objecto).






/*
Predicado: calculaObjectosTabuleiro/4
Conta os objectos de um dado tipo do tabuleiro por linhas/colunas.
CLinhas eh a lista com o numero desses objectos por linha.
CColunas eh a lista com o numero desses objectos por coluna.
*/
%Obtem o numero de objectos por linha e coluna atraves de tres predicados auxiliares.
calculaObjectosTabuleiro(Tabuleiro, CLinhas, CColunas, Objecto) :-
    contarObjectoEmTodasLinhas(Tabuleiro, Objecto, CLinhas),
    contarObjectoEmTodasColunas(Tabuleiro, Objecto, CColunas).

%Predicado auxiliar contarObjectoLista/3:
%Conta o numero de ocorrencias de um objecto numa lista de forma recursiva:
% - Se o objecto eh uma variavel, verifica se coordenada contem uma variavel.
% - Se o objecto eh um objecto especifico, verifica se a coordenada contem esse objecto especifico.
contarObjectoLista([], _, 0).
contarObjectoLista([Elem|R], Objecto, Counter) :-
    (
        var(Objecto) -> 
        (
            var(Elem) -> 
            CounterResto1 is 1;
            CounterResto1 is 0
        )
        ;
        (
            Elem == Objecto -> 
            CounterResto1 is 1;
            CounterResto1 is 0
        )
    ),
    contarObjectoLista(R, Objecto, CounterResto2),
    Counter is CounterResto1 + CounterResto2.

%Predicado auxiliar contarObjectoEmTodasLinhas/3:
%Recorre ao predicado auxiliar contarObjectoLista/3.
%Calcula o numero de ocorrencias de um objecto na linhas do tabuleiro.
contarObjectoEmTodasLinhas([], _, []).
contarObjectoEmTodasLinhas([L1|R], Objecto, [Counter|CounterResto2]) :-
    contarObjectoLista(L1, Objecto, Counter),
    contarObjectoEmTodasLinhas(R, Objecto, CounterResto2).

%Predicado auxiliar contarObjectoEmTodasColunas/3:
%Recorre ao predicado auxiliar contarObjectoEmTodasLinhas/3.
%Calcula o numero de ocorrencias de um objecto nas colunas do tabuleiro.
%Utiliza o tabuleiro transposto.
contarObjectoEmTodasColunas(Tabuleiro, Objecto, CColunas) :-
    transpose(Tabuleiro, TabuleiroTransposto),
    contarObjectoEmTodasLinhas(TabuleiroTransposto, Objecto, CColunas).






/*
Predicado: celulaVazia/2
Indica se uma coordenada de um tabuleiro esta vazia ou tem relva.
Se a coordenada nao fizer parte do tabuleiro, o predicado nao falha.
*/
%Acede a cada coordenada do tabuleiro e verifica se contem uma variavel ou relva.
celulaVazia(Tabuleiro, (L, C)) :-
    nth1(L, Tabuleiro, L1),
    nth1(C, L1, X),
    var(X).

%Predicado auxiliar para os casos em que a coordenada nao faz parte do tabuleiro.
celulaVazia(Tabuleiro, (L, C)) :-
    length(Tabuleiro, N),
    (L=:=0 ; L > N ; C=:=0 ; C > N).






/*
Predicado: insereObjectoCelula/3
Insere um objecto (tenda (t) ou relva (r)) numa coordenada do tabuleiro.
*/
%Verifica se a coordenada esta vazia ou contem relva e insere o objecto.
insereObjectoCelula(Tabuleiro, TouR, (L, C)) :- 
    celulaVazia(Tabuleiro, (L, C)), !,
    nth1(L, Tabuleiro, L1),
    nth1(C, L1, TouR).
insereObjectoCelula(_, _, _) :- !.






/*
Predicado: insereObjectoEntrePosicoes/4
Semelhante ao predicado insereObjectoCelula/3
Insere um objecto (tenda (t) ou relva (r)) entre coordenadas do tabuleiro.
(L, C1) e (L, C2) sao as coordenadas entre as quais, incluindo, se insere o objecto.
*/
%Recorre ao predicado insereObjectoCelula/3 para inserir o objecto numa coordenada.
%Encontra todas as coordenadas entre C1 e C2 que estao vazias.
%Insere o objeto nas coordenadas validas.
insereObjectoEntrePosicoes(Tabuleiro, TouR, (L, C1), (L, C2)) :-
    C1 =< C2, !,
    findall((L, C), (between(C1, C2, C), celulaVazia(Tabuleiro, (L, C))), Coordenadas),
    maplist(insereObjectoCelula(Tabuleiro, TouR), Coordenadas).






/*
Predicado: relva/1
Enche de relva uma linha/coluna caso esta esteja completa.
Por completa entede-se que tinha N tendas a colocar e foram colocadas as N tendas.
*/
%Existem dois predicados auxiliares relva/5 (iguais de certo modo):
% - um para o tabuleiro normal (linhas).
% - um para o tabuleiro transposto (colunas).
%Este predicado compara a lista de tendas que devem existir por linha/coluna.
%com a lista que indica quantas tendas existem atualmente por linha/coluna.
%Quando os respetivos elementos sao iguais, preenche-se a linha/coluna de relva.
relva((Tabuleiro, CLinhas, CColunas)) :- 
    length(CLinhas, Len),
    relva(Tabuleiro, CLinhas, 1, 0, Len),
    transpose(Tabuleiro, TabuleiroTransposto),
    relva(TabuleiroTransposto, CColunas, 1, 0, Len).
relva(_, _, _, Len, Len) :- !.

relva(Tabuleiro, [P|R], N, Counter1, Len) :-
    calculaObjectosTabuleiro(Tabuleiro, CLinhas2, _, t),
    nth0(Counter1, CLinhas2, X),
    P == X,
    Counter2 is Counter1 + 1,
    insereObjectoEntrePosicoes(Tabuleiro, r, (Counter2, N), (Counter2, Len)), !,
    relva(Tabuleiro, R, N, Counter2, Len).

relva(Tabuleiro, [_|R], N, Counter1, Len) :-
    Counter2 is Counter1 + 1,
    relva(Tabuleiro, R, N, Counter2, Len).






/*
Predicado: inacessiveis/1
Coloca relva em todas as posicoes inacessiveis do tabuleiro.
Ou seja, posicoes que nao estao na vizinhanca de nenhuma arvore.
*/
%Obtem todas as coordenadas do tabuleiro e todas as coordenadas com arvores.
%Filtra de modo a obter todas as coordenadas sem arvores (TodasCelulasSemArvore).
inacessiveis(Tabuleiro) :-
    todasCelulas(Tabuleiro, TodasCelulasArvore, a),
    todasCelulas(Tabuleiro, TodasCelulas),
    findall(EL, (member(EL, TodasCelulas), \+member(EL, TodasCelulasArvore)), TodasCelulasSemArvore),
    inacessiveis(Tabuleiro, TodasCelulasArvore, TodasCelulas, TodasCelulasSemArvore).

%Predicados auxiliares:
%Enontra a vizinhanca de cada arvore de TodasCelulasArvore.
%Filtra as coordenadas que nao pertencem a nenhuma vizinhanca, obtendo a lista Inacessivel.
%A lista Inacessivel representa as coordenadas inacessiveis, nas quais se insere relva.
inacessiveis(Tabuleiro, [P|R], TodasCelulas, TodasCelulasSemArvore) :- !,
    vizinhanca(P, Vizinhanca),
    findall(EL, (member(EL, TodasCelulasSemArvore),\+ member(EL, Vizinhanca)), Inacessivel),
    inacessiveis(Tabuleiro, R, TodasCelulas, Inacessivel).

inacessiveis(Tabuleiro, [], _, [P|R]) :- !,
    insereObjectoCelula(Tabuleiro, r, P),
    inacessiveis(Tabuleiro, [], _, R).

inacessiveis(_, [], _, []) :- !.






/*
Predicado: aproveita/1
Coloca as N tendas em falta numa linha/coluna caso existam N posicoes vazias nessa linha/coluna.
*/
%
aproveita((Tabuleiro, CLinhas, CColunas)) :-
    length(CColunas, Len),
    aproveitaAux(Tabuleiro, CLinhas, [], Len, 1, 0),
    transpose(Tabuleiro, TabuleiroTransposto),
    aproveitaAux(TabuleiroTransposto, CColunas, [], Len, 1, 0).

%Predicado auxiliar aproveitaAux/6:
%Obtem os elementos da linha/coluna do tabuleiro (Lista1).
%Exclui as variaveis (espacos nao preenchidos) da Lista1 obtendo Lista2.
%Se o numero de elementos nao vazios for igual ao numero de tendas a colocar, passa ao proximo caso.
%Insere tendas nas linhas/colunas elegiveis.
aproveitaAux(_, [], [], _, _, _) :- !.
aproveitaAux(Tabuleiro, [P|R], CColunas, Len, N, Counter1):-
    nth0(Counter1, Tabuleiro, Lista1),
    exclude(nonvar, Lista1, Lista2),
    length(Lista2, Len2),
    Len2 == P, !,
    Counter2 is Counter1 + 1,
    insereObjectoEntrePosicoes(Tabuleiro, t, (Counter2, N), (Counter2, Len)),
    aproveitaAux(Tabuleiro, R, CColunas, Len, N, Counter2).

aproveitaAux(Tabuleiro, [_|R], CColunas, Len, N, Counter1):-
    Counter2 is Counter1 + 1,
    aproveitaAux(Tabuleiro, R, CColunas, Len, N, Counter2).






/*
Predicado: limpaVizinhancas/1
Coloca relva na vizinhanca alargada de uma tenda.
*/
%Obtem todas as tendas do tabuleiro e aplica o predicado auxiliar para cada uma.
limpaVizinhancas((Tabuleiro, _, _)) :-
    todasCelulas(Tabuleiro, TodasCelulasTenda, t),
    maplist(limpaVizinhancasAux(Tabuleiro), TodasCelulasTenda).

%Predicado auxiliar limpaVizinhancasAux/2:
%Obtem a vizinhanca alargada de cada tenda.
%Insere relva nas coordenadas da vizinhanca alargada.
limpaVizinhancasAux(Tabuleiro, Tenda) :-
    vizinhancaAlargada(Tenda, VizinhancaAlargada),
    maplist(insereObjectoCelula(Tabuleiro, r), VizinhancaAlargada).

    




/*
Predicado: unicahipotese/1
Deteta quando existe apenas uma posicao que permite que uma arvore tenha uma tenda associada.
Coloca a tenda nessa posicao.
*/
%Obtem todas as celulas com arvores e a vizinhanca de cada uma.
%Explora as vizinhancas das arvores.
unicaHipotese((Tabuleiro, _, _)) :-
    todasCelulas(Tabuleiro, TodasCelulasArvore, a),
    todasCelulas(Tabuleiro, TodasCelulas),
    unicaHipotese(Tabuleiro, TodasCelulasArvore, TodasCelulas).
unicaHipotese(_, [], _) :- !.
unicaHipotese(Tabuleiro, [P1|R1], TodasCelulas) :-
    vizinhanca(P1, Vizinhanca),
    unicaHipotese(Tabuleiro, [P1|R1], TodasCelulas, Vizinhanca, []), !.

%Caso da coordenada da vizinhanca estar vazia e pertencer ao tabuleiro.
%Adiciona a coordenada a L1, originando a lista L2 (hipoteses).
unicaHipotese(Tabuleiro, Tas, TodasCelulas, [P2|R2], L1) :-
    celulaVazia(Tabuleiro, P2),
    member(P2, TodasCelulas),
    append(L1, [P2], L2),
    unicaHipotese(Tabuleiro, Tas, TodasCelulas, R2, L2).

%Caso exista ja uma tenda na vizinhanca da arvore.
unicaHipotese(Tabuleiro, [_|R3], TodasCelulas, [P2|_], _) :-
    todasCelulas(Tabuleiro, TodasTendas, t),
    member(P2, TodasTendas), !,
    unicaHipotese(Tabuleiro, R3, TodasCelulas).
unicaHipotese(Tabuleiro, Tas, TodasCelulas, [_|R2], L1) :-
    unicaHipotese(Tabuleiro, Tas, TodasCelulas, R2, L1).

%Depois de passar por todas as vizinhancas, verifica as hipoteses.
%Se Len igual a 1 (existe so uma hipotese para a tenda), insere a tenda na unica hipotese.
unicaHipotese(Tabuleiro, [_|R4], TodasCelulas, [], [P3|R3]) :-
    length([P3|R3], Len),
    Len == 1, !,
    insereObjectoCelula(Tabuleiro, t, P3),
    unicaHipotese(Tabuleiro, R4, TodasCelulas).

unicaHipotese(Tabuleiro, [_|R3], TodasCelulas, [], _) :-
    unicaHipotese(Tabuleiro, R3, TodasCelulas), !.




/*
Predicado: valida/2
Verifica se todas as arvores podem ser associadas a apenas uma unica tenda na sua vizinhanca.
LArv eh a lista com todas as coordenadas em que existem arvores.
LTen eh a lista com todas as coordenadas em que existem tendas.
*/
%Verifica se o numero de arvores eh igual ao numero de tendas.
valida(LArv, LTen) :-
    length(LArv, Len),
    length(LTen, Len),
    validaAux(LArv, LTen, []).

%Predicado auxiliar validaAux/3:
%Obtem a vizinhanca da tenda.
%Encontra todas as arvores na vizinhanca da tenda:
% - Caso nao haja nenhuma arvore na vizinhanca, o predicado falha.
% - Caso haja uma arvore na vizinhanca, remove a arvore de LArv e continua o processo.
% - Caso haja mais de uma arvore na vizinhanca, recorre ao predicado auxiliar validaTentaeErro/5
validaAux([], [], _) :- !.
validaAux(LArv, [P|R], Aux) :-
    vizinhanca(P, Vizinhanca),
    findall(X, (member(X, LArv), member(X, Vizinhanca)), ArvoresPossiveis),
    length(ArvoresPossiveis, N),
    ((N == 0,
        fail);
    (N == 1,
        ArvoresPossiveis = [Arvore],
        delete(LArv, Arvore, SemArvoreVerificada),
        validaAux(SemArvoreVerificada, R, Aux));
    (N > 1,
        validaTentaeErro(LArv, ArvoresPossiveis,
            [P|R], 1, N))).

%Predicado auxiliar validaTentaeErro/5:
%Usado quando existe mais de uma arvore na vizinhanca de uma tenda.
%Logica de tentativa e erro:
% - Tentativa bem sucedida: verifica uma associacao arvore-tenda e continua o processo.
% - Tentativa mal sucedida: tenta com a proxima arvore na vizinhanca e testa essa associacao.
validaTentaeErro(LArv, ArvoresPossiveis, [P|R], Counter1, Len) :-
    (
        nth1(Counter1, ArvoresPossiveis, ArvorePossivel),
        delete(LArv, ArvorePossivel, ArvoresATestar),
        validaAux(ArvoresATestar, R, []),
        !
    );
    (
        Counter2 is Counter1 + 1,
        Counter2 =< Len,
        validaTentaeErro(LArv, ArvoresPossiveis, [P|R], Counter2, Len)
    ).