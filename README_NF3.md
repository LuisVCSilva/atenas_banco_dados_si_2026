# Nexus Comércio: banco de dados seguro e consistente

Projeto norteador de **Criação e Estruturação de Banco de Dados por meio de Consultas**, Sistemas de Informação, 2026/2.

## 1. Missão da equipe

Uma pequena distribuidora vende produtos, recebe pedidos e precisa controlar estoque. Atualmente, relatórios divergem, compras simultâneas podem vender a última unidade duas vezes e a aplicação utiliza acesso excessivo ao banco. Sua equipe deverá construir e demonstrar uma base MySQL que resolva esses problemas.

O foco é **implementar, executar e explicar** consultas, mecanismos de integridade e administração. A turma já conhece MySQL: os comandos básicos serão retomados no desenvolvimento do projeto, sem repetir um curso introdutório.

Este README é o **enunciado de um repositório a desenvolver**. Os caminhos abaixo são entregas esperadas, não arquivos já implementados. Não é necessário construir uma aplicação web completa: scripts de terminal são suficientes.

## 2. Escopo, ambiente e organização

- Equipes sugeridas de 3 a 4 estudantes; todos devem explicar uma consulta e uma decisão técnica.
- MySQL com tabelas InnoDB; registrar versão, sistema operacional e dependências utilizadas.
- SQL e uma linguagem de apoio, preferencialmente Python, para conexão, experimentos de senhas e otimização.
- Usar apenas dados sintéticos. Os laboratórios vulneráveis devem executar localmente, em base descartável e separados da versão corrigida.
- Não versionar credenciais, arquivos `.env` reais, dados pessoais ou dumps de outros sistemas. Fornecer `.env.example` sem segredos.
- Entregar comandos reais de instalação, criação da base, carga, execução e limpeza em `docs/execucao.md`. Fixar as dependências efetivamente testadas.

| Diretório esperado | Conteúdo |
|---|---|
| `sql/` | Scripts numerados de esquema, carga, consultas, views, índices, triggers e permissões |
| `app/` | Scripts mínimos de consulta e criação de pedido com parâmetros |
| `labs/` | Experimentos locais de injeção SQL, senhas e concorrência |
| `otimizacao/` | Dados e resolução do problema de pesquisa operacional |
| `docs/` | Modelo, álgebra relacional, instruções e decisões |
| `evidencias/` | Saídas reproduzíveis, resultados e medições |

## 3. Dados e regras de negócio

Implementar pelo menos as relações abaixo. Os atributos indicados são mínimos; a equipe deve definir tipos, nulabilidade, chaves e restrições.

| Relação | Atributos mínimos |
|---|---|
| `Cliente` | `id`, `nome`, `email`, `cidade` |
| `Produto` | `id`, `nome`, `categoria`, `preco`, `ativo` |
| `Estoque` | `produto_id`, `quantidade` |
| `Pedido` | `id`, `cliente_id`, `criado_em`, `status` |
| `ItemPedido` | `pedido_id`, `produto_id`, `quantidade`, `preco_unitario` |
| `Usuario` | `id`, `login`, `senha_hash`, `perfil` |
| `AuditoriaEstoque` | `id`, `produto_id`, `anterior`, `novo`, `instante` |

Regras obrigatórias:

1. Quantidades de itens são positivas; preços e estoque não podem ser negativos. Usar `DECIMAL` para valores monetários.
2. O preço registrado no item é o preço da venda, preservado quando o catálogo muda.
3. Pedido e itens não podem ficar parcialmente gravados quando a operação falhar.
4. Cancelar um pedido confirmado deve devolver seu estoque uma única vez.
5. Definir quais estados de pedido entram no faturamento. Não somar cancelados como receita.
6. A conta da aplicação não é administradora; dados de autenticação não aparecem em relatórios.

Carga mínima: 20 clientes, 15 produtos e 40 pedidos com itens. Incluir cliente sem pedido, produto nunca vendido, pedido cancelado, estoque zerado e valores repetidos. Criar uma carga maior, gerada com semente fixa, para o experimento de desempenho, informando o tamanho escolhido.

## 4. Etapas e calendário

As datas são marcos de desenvolvimento em aula, de 10 a 26/11/2026. O professor ajustará o tempo de cada etapa. Prova na primeira semana de dezembro, em data institucional a confirmar.

| Data | Etapa | Evidência mínima |
|---|---|---|
| 10/11, terça | Esquema inicial e injeção SQL | Modelo, carga inicial e comparação entre consulta vulnerável e corrigida |
| 11/11, quarta | Permissões, views e proteção de senhas | Matriz de acesso, teste de negação e experimento de pré-computação |
| 12/11, quinta | Álgebra relacional e consultas | Expressões, SQL equivalente e resultados conferidos |
| 17/11, terça | Índices e otimização de consultas | Planos de execução e medições antes/depois |
| 18/11, quarta | Transações e concorrência | Pedido atômico e disputa pela última unidade |
| 19/11, quinta | Triggers, integridade e evolução | Auditoria e migração de esquema explicadas |
| 24/11, terça | Backup, recuperação e bloqueios | Restauração validada em outra base e roteiro de duas sessões |
| 25/11, quarta | Modelos de bancos e pesquisa operacional | Comparação de modelos e plano ótimo de produção de kits |
| 26/11, quinta | Integração, demonstração e revisão | Execução reproduzível e discussão dos resultados |

### Etapa A — SQL seguro e administração de acesso

Criar um script de busca de produtos que monte uma consulta por concatenação e outro que utilize parâmetros do conector. Identificar a linha vulnerável e demonstrar, apenas na base didática, que uma entrada construída para alterar a condição da busca muda o resultado da versão vulnerável. Na versão corrigida, a mesma entrada deve ser tratada como dado.

Testar busca normal, nome com apóstrofo e entrada do experimento. Comparar os resultados esperados e observados. Não é necessário automatizar exploração ou acessar sistemas externos.

Parâmetros vinculam valores; nomes de colunas usados em ordenação exigem uma lista explícita de opções permitidas. Validação de entrada complementa a parametrização. Não apresentar remoção de aspas como solução principal.

Criar contas/perfis para aplicação, leitura de relatórios e administração. Implementar uma view de relatório sem dados de autenticação. Demonstrar uma operação permitida e uma negada. Uma view só limita efetivamente o acesso quando as permissões sobre as tabelas e o contexto de execução são coerentes com essa restrição.

### Etapa B — Hashes, salt e rainbow tables

Pergunta: **por que armazenar apenas um hash rápido da senha não resolve o problema?**

1. Inventar um conjunto pequeno de senhas didáticas, incluindo duas iguais, e calcular seus hashes SHA-256 sem salt. Esse esquema é exclusivamente experimental.
2. Construir uma tabela de consulta com os hashes desse conjunto e procurar os hashes de contas fictícias. Medir quantidade de acertos, tempo de preparação e tempo de consulta.
3. Repetir a geração com salts aleatórios individuais; verificar que senhas iguais produzem resultados distintos e que a tabela anterior não pode ser reutilizada diretamente.
4. Usar uma biblioteca de Argon2id para a versão correta do armazenamento e da verificação. Registrar parâmetros e tempo de verificação no equipamento utilizado; não implementar criptografia própria.
5. Explicar a diferença entre uma **tabela simples de hashes pré-calculados** e uma **rainbow table**, que utiliza cadeias de hash/redução com funções de redução que variam por posição e armazena extremos, trocando memória por trabalho de busca. Uma função de redução não é a inversa do hash. Desenhar uma cadeia didática; implementar rainbow tables completas é opcional.

Entregar `docs/senhas.md` com os resultados e limites. Salt não é secreto nem torna uma senha fraca forte; seu papel inclui impedir reaproveitamento geral de pré-computações. Hash rápido com salt continua sendo inadequado como solução final de senhas. Nunca utilizar senhas reais dos integrantes.

### Etapa C — Álgebra relacional e SQL

Documentar seleção (σ), projeção (π), renomeação (ρ), junção (⋈), união (∪), diferença (−) e produto cartesiano (×). Explicar por que juntar relações sem condição pode multiplicar linhas indevidamente.

Exemplo, considerando `Pedido.cliente_id` como referência a `Cliente.id`:

```text
π Cliente.id, Cliente.nome (
  Cliente ⋈ Cliente.id = Pedido.cliente_id
  (σ status = 'CONFIRMADO' (Pedido))
)
```

```sql
SELECT DISTINCT c.id, c.nome
FROM Cliente AS c
INNER JOIN Pedido AS p ON p.cliente_id = c.id
WHERE p.status = 'CONFIRMADO';
```

Elaborar **seis pares de expressão e SQL**: clientes de uma cidade; produtos ativos com preço acima de um limite; clientes com pedido confirmado; clientes sem pedidos; clientes que compraram na categoria A ou B; pares de produtos diferentes de uma mesma categoria usando renomeação. Definir esquemas compatíveis nas operações de conjuntos.

Explicar que a álgebra clássica usa conjuntos, enquanto SQL geralmente preserva duplicatas e possui `NULL`. Acrescentar dois relatórios com agregação, identificando γ como operador da **álgebra estendida**, caso utilizado.

O conjunto de consultas deve contemplar `INNER`, `LEFT` e `RIGHT JOIN`, `GROUP BY`, `HAVING`, subconsulta, filtros, ordenação, `CASE`, `COALESCE` e `UNION`. Mostrar que um `RIGHT JOIN` pode ser reescrito como `LEFT JOIN`. Registrar resultado esperado para a carga pequena.

### Etapa D — Desempenho, integridade e transações

- Escolher uma consulta por cliente e período, observar `EXPLAIN` e propor um índice coerente com os predicados. Comparar plano e tempo em execuções repetidas, registrando volume, equipamento, cache e limites da medição. Não presumir que todo índice acelerará uma tabela pequena.
- Demonstrar `CREATE`, `ALTER` e `DROP` em objetos de exercício; registrar uma migração que preserve os dados do projeto.
- Criar trigger de auditoria de alteração do estoque e explicar sua execução dentro da transação. Não registrar senhas ou informações desnecessárias.
- Implementar a compra como transação: verificar e reservar estoque de forma concorrente segura, gravar pedido e itens e confirmar; qualquer falha provoca rollback. Usar bloqueio de linha ou atualização condicional, justificando a escolha.
- Com estoque inicial igual a 1, executar duas compras concorrentes: somente uma pode confirmar. Registrar a sequência das duas sessões, nível de isolamento e resultado.
- Explicar ACID a partir dessa compra. Demonstrar bloqueio; apresentar um roteiro de deadlock e explicar rollback/repetição limitada da transação. Diferenciar demonstração executada de análise conceitual.
- Fazer backup, restaurar em outra base e conferir contagens, totais e integridade referencial. Descrever o que seria perdido se o único backup fosse do dia anterior e como uma estratégia de recuperação poderia reduzir essa perda.

### Etapa E — Pesquisa operacional básica: produção de kits

A distribuidora monta kits A e B para uma campanha. Cada kit utiliza unidades de embalagem e minutos de preparação:

| Recurso ou resultado | Kit A | Kit B | Disponibilidade |
|---|---:|---:|---:|
| Embalagens | 2 | 1 | 100 |
| Minutos de preparação | 1 | 2 | 80 |
| Margem de contribuição (R$) | 30 | 40 | — |
| Limite de demanda | 40 | 30 | — |

Definir inteiros não negativos `xA` e `xB`. Maximizar `30*xA + 40*xB`, sujeito a `2*xA + xB <= 100`, `xA + 2*xB <= 80`, `xA <= 40` e `xB <= 30`.

Guardar os parâmetros em tabelas auxiliares e extraí-los com SQL. Resolver por enumeração dos pares de 0 a 40 e de 0 a 30, descartando os inviáveis. Entregar plano ótimo, valor da função objetivo, consumo e folga de cada recurso. Comparar com uma regra intuitiva que prioriza o kit de maior margem unitária. Repetir com 10 minutos adicionais e interpretar a mudança. A correção exige verificar restrições, não apenas informar um número.

### Etapa F — Modelos não convencionais e distribuição

Comparar o modelo relacional com orientado a objetos, documentos e chave–valor. Representar um pedido como documento JSON e como objeto da linguagem, explicando por que isso, por si só, **não implementa um banco orientado a objetos**. Propor um caso adequado a cada modelo.

Desenhar uma possível divisão em duas filiais: o que seria replicado, o que seria particionado e o que aconteceria com uma venda durante falha de comunicação? Distinguir replicação, distribuição e backup. Não é obrigatório montar um cluster.

## 5. Entregáveis

- [ ] Modelo e dicionário de dados; scripts de criação, carga e migração.
- [ ] Consultas e álgebra relacional, com resultados conferidos.
- [ ] Laboratório de injeção SQL com correção e teste de regressão.
- [ ] Experimento de pré-computação, explicação de rainbow tables e verificação segura de senha.
- [ ] Views, perfis, índices e trigger documentados.
- [ ] Compra atômica e teste concorrente da última unidade.
- [ ] Backup restaurado e validado; comparação de modelos.
- [ ] Problema de pesquisa operacional resolvido a partir dos dados.
- [ ] Instruções suficientes para outro grupo reproduzir a entrega; autoria e referências declaradas.


## 7. Leituras

NF3 entrega o núcleo de dados; NF4 trabalha arquitetura, integração e decisões sobre o mesmo cenário. As turmas podem compartilhar esquema e dados sintéticos, mas cada repositório deve funcionar de maneira independente. Não depender da entrega de outra turma para concluir a atividade.

- [OWASP — prevenção de injeção SQL](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html)
- [OWASP — armazenamento de senhas](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
- [Manual do MySQL](https://dev.mysql.com/doc/): consultar a documentação correspondente à versão instalada.

