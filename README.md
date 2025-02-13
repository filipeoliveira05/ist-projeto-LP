# LP 23/24 - Projeto  
**Filipe Oliveira**  
**Número de estudante**: ist1110633  

## 📌 Descrição do Projeto  
Este projeto implementa a resolução do puzzle **"Tendas e Árvores"** em **Prolog**. O objetivo é criar um programa que posicione tendas próximas a árvores seguindo regras específicas, garantindo que os participantes de um festival tenham um local adequado para acampar.  

O projeto envolve a criação de **estruturas de dados**, manipulação de **tabuleiros NxN** e implementação de **predicados lógicos** para validar e resolver o puzzle.  

---

## 🎯 Regras do Jogo "Tendas e Árvores"  
1. O tabuleiro é uma matriz **NxN** onde algumas células contêm árvores.  
2. Cada árvore deve estar associada a **exatamente uma tenda**.  
3. As tendas devem estar **adjacentes** (cima, baixo, esquerda ou direita) a pelo menos uma árvore.  
4. **Duas tendas não podem estar lado a lado**, nem nas diagonais.  
5. O número de tendas em cada linha e coluna é **pré-definido**.  
6. O objetivo é encontrar uma disposição válida de tendas que respeite todas as regras.  

---

## 🔹 Estruturas de Dados  
O puzzle é representado como um triplo:  
- **Tabuleiro** → Matriz de **NxN** com árvores ('a'), tendas ('t'), relva ('r') e espaços vazios (`_`).  
- **Lista de tendas por linha** → Indica quantas tendas devem existir em cada linha.  
- **Lista de tendas por coluna** → Indica quantas tendas devem existir em cada coluna.  

Exemplo de representação de um tabuleiro inicial:  
```prolog
([
[_, _, _, _, a, _],
[a, _, _, _, _, _],
[_, a, _, a, a, _],
[_, _, _, a, _, a],
[_, _, _, _, _, _],
[_, a, _, _, _, _]],
[2,1,2,1,1,1],
[3,0,1,1,0,3])

---

## 🛠 Predicados Implementados  

### 🔍 Consultas  
- `vizinhanca/2` → Retorna as coordenadas **imediatamente adjacentes** a uma posição.  
- `vizinhancaAlargada/2` → Retorna as coordenadas **incluindo diagonais**.  
- `todasCelulas/2` → Lista **todas as coordenadas** do tabuleiro.  
- `todasCelulas/3` → Lista **coordenadas com um determinado objeto** (`'t'`, `'a'`, `'r'`, `_`).  
- `calculaObjectosTabuleiro/4` → Conta os objetos (**tendas, árvores, relva ou espaços vazios**) no tabuleiro por linha e por coluna.  
- `celulaVazia/2` → Verifica se uma célula está **vazia ou contém relva**.  

### 🏕️ Manipulação do Tabuleiro  
- `insereObjectoCelula/3` → Insere uma **tenda ou relva** numa célula específica.  
- `insereObjectoEntrePosicoes/4` → Insere **tendas ou relva** entre duas posições.  

### 🤖 Estratégias de Resolução  
- `relva/1` → Preenche automaticamente **linhas/colunas completas** com relva.  
- `inacessiveis/1` → Marca como **relva todas as posições não acessíveis** a árvores.  
- `aproveita/1` → Preenche automaticamente **todas as tendas restantes** em linhas/colunas com espaços exatos disponíveis.  
- `limpaVizinhancas/1` → Marca como **relva todas as posições ao redor** de tendas já colocadas.  
- `unicaHipotese/1` → Identifica árvores com **apenas uma opção válida** para tenda e insere a tenda automaticamente.  

### 🔁 Tentativa e Erro (Backtracking)  
- `valida/2` → Verifica se **todas as árvores têm exatamente uma tenda associada**.  
- `resolve/1` → Tenta **resolver o puzzle automaticamente**, aplicando todas as estratégias e recorrendo a tentativa e erro se necessário.  
