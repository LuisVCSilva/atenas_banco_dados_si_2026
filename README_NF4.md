# Nexus Comércio: sistemas, segurança e decisões de negócio

Projeto norteador de **Atualizações em Sistemas de Informação III**, Sistemas de Informação, 2026/2.

## 1. Desafio

Uma distribuidora pretende integrar vendas, estoque, pagamentos e análise de dados. O crescimento expôs problemas: indisponibilidade, cadastros excessivos, acessos sem controle, relatórios inconsistentes e decisões de produção tomadas por intuição.

Sua equipe atuará como equipe de desenvolvimento e análise: construir um protótipo pequeno, testar situações críticas e recomendar uma solução justificável para o negócio. O objetivo é **integrar conhecimentos e avaliar alternativas**, demonstrando maturidade de uma turma de fim de curso.

Este README é o **enunciado do projeto a desenvolver**. Os diretórios e serviços descritos são entregas esperadas, não implementações já presentes. O escopo não exige um ERP completo, infraestrutura paga ou implantação pública.

## 2. Produto mínimo e organização

Equipes sugeridas de 3 a 4 pessoas. Dividir responsabilidades, mantendo revisão cruzada e capacidade de explicar o trabalho individualmente.

O protótipo obrigatório deve permitir:

1. Consultar produtos e registrar pedido sem permitir estoque negativo.
2. Simular pagamento aprovado, recusado e indisponível, sem serviço financeiro real.
3. Consultar um relatório de vendas e uma recomendação de produção baseada em otimização.
4. Demonstrar acesso permitido/negado e armazenamento adequado de senhas fictícias.
5. Reproduzir uma falha e mostrar o comportamento da interface e da integração.

Uma API, MySQL e um simulador de pagamento são suficientes. A interface pode ser simples; os estudos de nuvem, IA, Big Data e blockchain podem ser demonstrados em notebooks, diagramas e documentos. Não é obrigatório construir microsserviços, treinar redes neurais ou operar uma blockchain.

Escolher uma linguagem conhecida e registrar versões e dependências. Fornecer `.env.example`, instalação, carga de dados e comandos efetivamente testados. Usar apenas dados sintéticos. Laboratórios intencionalmente vulneráveis ficam locais, isolados e separados da aplicação corrigida; não utilizar credenciais reais.

| Diretório esperado | Conteúdo |
|---|---|
| `app/` | API e interface mínima |
| `simuladores/` | Pagamento e eventos de sensor fictícios |
| `dados/` | Esquema, carga sintética e parâmetros dos cenários |
| `labs/` | Experimentos controlados de SQL e senhas |
| `analise/` | Consultas, otimização e análise de demanda |
| `docs/` | Requisitos, UML, arquitetura, riscos e decisões |
| `testes/` | Casos de aceitação e falhas reproduzíveis |
| `evidencias/` | Resultados, medições e registros de demonstração |

## 3. Cenário e contrato de dados

Usar entidades `Cliente`, `Produto`, `Estoque`, `Pedido`, `ItemPedido` e `Usuario`. Pedidos possuem cliente, data, estado e itens; cada item guarda quantidade e preço no momento da venda. Definir chaves e integridade. Preços usam representação decimal apropriada; quantidades e estoque não podem ficar negativos.

Carga mínima: 20 clientes, 15 produtos e 40 pedidos com itens, incluindo pedidos cancelados, clientes sem compra e produto sem estoque. Para a análise temporal, gerar uma série sintética de demanda de pelo menos 60 dias, com semente e regra de geração documentadas. Esses dados servem ao exercício e não comprovam resultados comerciais reais.



## 5. Segurança, riscos e dados pessoais

### 5.1 Inventário e análise de riscos

Inventariar dados coletados, finalidade, usuários com acesso, retenção proposta e descarte. Justificar quais campos podem ser removidos. Não coletar CPF, endereço completo ou outros dados apenas porque sistemas comerciais costumam fazê-lo.

Construir matriz com pelo menos cinco riscos: injeção SQL, credencial exposta, acesso indevido a pedidos, indisponibilidade e perda de dados. Para cada um registrar ativo, ameaça, vulnerabilidade, probabilidade e impacto em escala definida, controle, responsável e risco residual.

Na aplicação da LGPD, discutir necessidade, finalidade, transparência e atendimento de solicitações dos titulares. Identificar hipóteses legais que precisariam ser verificadas no cenário escolhido; não presumir que consentimento resolve qualquer tratamento. A entrega é análise acadêmica, não parecer jurídico. Consultar o texto oficial e indicar artigos usados na argumentação.

### 5.2 Injeção SQL e autorização

Preparar uma busca local em duas versões: consulta concatenada e consulta parametrizada. Demonstrar como uma entrada modifica a lógica da primeira e é tratada como dado na segunda. Testar entrada normal, apóstrofo e entrada do experimento. Corrigir a aplicação principal e registrar teste de regressão. Se houver ordenação dinâmica, selecionar nomes de colunas por lista permitida.

Definir perfis `cliente`, `operador` e `gestor`. O cliente só consulta seus pedidos; o operador trabalha pedidos; o gestor acessa indicadores. Testar acesso a pedido de outro cliente, além de testar perfis. Diferenciar autenticação, autorização na aplicação e privilégios da conta de banco.

### 5.3 Rainbow tables e armazenamento de senhas

Executar um experimento com um pequeno conjunto de senhas inventadas:

1. Gerar hashes rápidos sem salt e uma tabela simples de consulta pré-calculada.
2. Medir preparação, consulta e número de acertos sobre contas fictícias, incluindo senhas repetidas.
3. Repetir com salts individuais e observar a impossibilidade de reutilizar diretamente a tabela anterior.
4. Demonstrar armazenamento e verificação com biblioteca de Argon2id, registrando configuração e tempo medido.
5. Explicar que uma tabela simples armazena pares, enquanto uma rainbow table utiliza cadeias de hash/redução, com redução variável por posição, para trocar espaço por trabalho de busca. Apresentar uma cadeia ilustrativa; não chamar a tabela simples construída de rainbow table completa.

Relacionar o resultado a um cenário de vazamento de hashes. Diferenciar hash, criptografia reversível, salt e segredo de aplicação. Salt pode ser armazenado com o hash; não impede tentativas sobre senhas fracas. SHA-256 com salt não é a implementação final de armazenamento de senha. Bibliotecas de senha devem realizar o trabalho criptográfico.

## 6. Redes, API e álgebra relacional

### 6.1 Caminho da requisição

Descrever navegador → resolução DNS → conexão TCP → HTTP/HTTPS → aplicação → banco, delimitando o que de fato foi observado. Em laboratório por `localhost`, DNS público e TLS podem não participar: explicar onde entrariam em implantação real. Diferenciar HTTP de HTTPS e registrar método, caminho, status e corpo de uma requisição sem incluir segredos.

Documentar contratos para:

| Operação | Entrada e resultado esperado |
|---|---|
| `GET /produtos` | Filtros e lista paginada |
| `POST /pedidos` | Itens e identificador de repetição; pedido ou erro explicado |
| `GET /pedidos/{id}` | Pedido autorizado ou resposta de acesso negado |
| `GET /indicadores` | Intervalo de datas e indicadores acessíveis ao gestor |
| Simulador de pagamento | Referência do pedido e resultado aprovado, recusado ou indisponível |

Escolher e justificar códigos HTTP, validações, representação de erros e autenticação. Documentar o contrato em OpenAPI ou tabela equivalente.

### 6.2 Consultas e significado dos indicadores

Produzir quatro pares de álgebra relacional e SQL: clientes com compra confirmada, clientes sem compra, produtos vendidos em determinado período e clientes que compraram na categoria A ou B. Explicitar seleção σ, projeção π, junção ⋈, união ∪ e diferença −; usar renomeação quando necessário.

Exemplo de clientes sem pedidos, com conjuntos de identificadores compatíveis:

```text
π id (Cliente) − ρ id←cliente_id (π cliente_id (Pedido))
```

```sql
SELECT c.id
FROM Cliente AS c
WHERE NOT EXISTS (
  SELECT 1 FROM Pedido AS p WHERE p.cliente_id = c.id
);
```

Explicar diferenças entre conjuntos da álgebra e duplicatas/`NULL` de SQL. Criar também faturamento e ticket médio com agregação; caso represente agregação em álgebra, identificar a extensão utilizada. Definir estados elegíveis e denominadores. Conferir uma amostra manualmente e verificar se uma junção com itens multiplicou indevidamente os pedidos.

## 7. Algoritmos, orientação a objetos e pesquisa operacional

### 7.1 Fluxo de negócio

Descrever em pseudocódigo a criação, reserva, pagamento e cancelamento de pedido. Implementar responsabilidades equivalentes a `Pedido`, `ItemPedido`, serviço de estoque e serviço de pagamento. Explicar encapsulamento e separação de responsabilidades sem criar classes apenas para aumentar a quantidade de código.

Definir uma máquina de estados coerente. Repetir uma requisição com o mesmo identificador não pode duplicar pedido ou cobrança simulada. Não manter uma transação de banco aberta durante uma chamada externa demorada: justificar uma estratégia de reserva, confirmação e compensação para falhas.

### 7.2 Decisão de produção de kits

A empresa monta kits A e B com recursos limitados:

| Parâmetro | Kit A | Kit B | Limite disponível |
|---|---:|---:|---:|
| Embalagens por kit | 2 | 1 | 100 |
| Minutos por kit | 1 | 2 | 80 |
| Margem por kit (R$) | 30 | 40 | — |
| Demanda máxima | 40 | 30 | — |

Definir inteiros não negativos `xA`, `xB`. Maximizar `Z = 30*xA + 40*xB`, sujeito a `2*xA + xB <= 100`, `xA + 2*xB <= 80`, `xA <= 40` e `xB <= 30`.

Resolver por enumeração ou solver e apresentar variáveis, função objetivo, restrições, solução, folgas e interpretação gerencial. Comparar com a política de produzir primeiro o item de maior margem unitária. Verificar a viabilidade de ambas.

Analisar dois cenários: preparação ampliada para 90 minutos e demanda máxima de B reduzida para 15. Avaliar o ganho marginal observado no primeiro cenário frente a um custo hipotético de horas adicionais; informar esse custo. Não generalizar um ganho de um cenário como constante para qualquer capacidade.

Conectar os dados ao protótipo: parâmetros devem ser carregados de arquivo ou banco e o resultado exibido no relatório. Distinguir descrição (SQL), previsão de demanda (análise/IA) e prescrição (otimização).

## 8. Arquitetura, nuvem e sistemas distribuídos

Entregar diagramas UML de casos de uso, classes e sequência da compra, incluindo falha de pagamento. Acrescentar um diagrama de implantação com interface, API, banco e simulador.

Comparar monólito modular e serviços separados; escolher a arquitetura mínima e justificar. Comparar infraestrutura local, máquinas virtuais, contêineres e serviços de nuvem. Distinguir VM de contêiner e discutir IaaS, PaaS e SaaS com exemplos do cenário. Custos podem ser hipotéticos, desde que explicitamente identificados; preços reais exigem fonte e data.

Explicar latência, falha parcial, repetição de mensagens, consistência e necessidade de observabilidade. Propor onde replicação, cache ou particionamento poderiam ajudar e seus custos. Não afirmar que múltiplos serviços tornam o sistema automaticamente escalável ou disponível.

## 9. Continuidade, integração e usabilidade

Executar três testes: pagamento recusado, timeout e repetição da solicitação. Para cada um, mostrar estado final do pedido, estoque e resposta ao usuário. Definir timeout e número limitado de novas tentativas. Verificar que a repetição não cria efeitos duplicados.

Definir metas acadêmicas de RPO (perda de dados tolerada no tempo) e RTO (tempo de recuperação), identificadas como metas. Executar backup/restauração em base separada, medir tempo e comparar o resultado com as metas. Documentar procedimento e responsável; não confundir backup com alta disponibilidade.

Fazer teste de usabilidade com dois colegas: localizar produto, concluir pedido e compreender uma falha. Registrar conclusão, tempo, erros e observações sem dados pessoais. Corrigir pelo menos dois problemas e documentar antes/depois. Incluir rótulos claros, navegação por teclado e mensagens de erro úteis.

## 10. IA, Big Data, IoT e blockchain

### IA e análise de dados

Construir indicadores de vendas e uma previsão simples de demanda. Separar treino e teste cronologicamente; comparar uma previsão ingênua com média móvel ou modelo simples. Informar erro absoluto médio (MAE), horizonte e limitações. Se utilizar um modelo de aprendizado, comparar com a linha de base e evitar usar informações futuras no treino. Não denominar qualquer média de inteligência artificial.

Propor uma aplicação de IA ao negócio, explicando dados necessários, decisão apoiada, risco de erro e supervisão humana. Desenhar um fluxo de ingestão, armazenamento e análise para aumento de volume e velocidade. A carga pequena do exercício não constitui Big Data: justificar o que mudaria em escala e diferenciar processamento em lote e em fluxo.

### IoT

Simular eventos de temperatura de armazenamento com `sensor_id`, instante, valor e unidade. Produzir evento normal, valor fora do limite e evento repetido. Validar e exibir um alerta; documentar como tratar duplicação e sensor sem comunicação. Não é necessário dispositivo físico.

### Blockchain

Avaliar a rastreabilidade de lotes entre fornecedores, distribuidora e transportadora. Comparar banco centralizado com auditoria versus registro compartilhado em blockchain, considerando confiança, governança, custo, privacidade e correção de erros. Concluir pela adoção ou rejeição com justificativa. Blockchain não garante a veracidade de um dado físico digitado ou medido incorretamente.

Opcionalmente, implementar uma cadeia local de hashes para ilustrar detecção de alteração, explicando que ela, sozinha, não constitui uma blockchain distribuída com consenso.

## 11. Entregáveis

- [ ] Protótipo mínimo e dados reproduzíveis; contratos e instruções de execução.
- [ ] Inventário de dados, matriz de riscos e matriz de acesso.
- [ ] Laboratórios de injeção e senhas, com correção e limitações.
- [ ] Álgebra, SQL e indicadores conferidos.
- [ ] Pseudocódigo, UML, arquitetura e decisão de infraestrutura.
- [ ] Otimização com comparação de políticas e cenários.
- [ ] Testes de integração, falha, recuperação e usabilidade.
- [ ] Análise temporal, proposta de IA, fluxo de Big Data, sensor e decisão sobre blockchain.
- [ ] Registro de autoria, fontes e contribuições; resultados reais separados de hipóteses.

Na demonstração, percorrer uma compra normal, uma falha e uma decisão de produção; usar as evidências para justificar as escolhas. Todos devem responder a perguntas sobre sua contribuição.

Pesos percentuais propostos para esta atividade, sujeitos à confirmação do professor e sem substituir os pesos oficiais:

| Critério | Peso |
|---|---:|
| Segurança, dados pessoais e laboratórios | 20% |
| Protótipo, algoritmos, UML e arquitetura | 20% |
| Redes, integração, continuidade e usabilidade | 20% |
| Álgebra relacional, indicadores e pesquisa operacional | 20% |
| IA, Big Data, IoT e análise de blockchain | 10% |
| Reprodutibilidade, evidências e defesa individual | 10% |

## 12. Referências

- [OWASP — prevenção de injeção SQL](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html)
- [OWASP — armazenamento de senhas](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
- [LGPD — texto oficial](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm)
- [Manual do MySQL](https://dev.mysql.com/doc/)
- [OMG — UML](https://www.omg.org/spec/UML/)

Consultar documentação correspondente às ferramentas efetivamente escolhidas. Referências fundamentam decisões; não substituem os experimentos e a análise da equipe.
