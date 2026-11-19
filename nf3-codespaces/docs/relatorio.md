# Relatório NF3
Equipe e contribuições:
Data, versão MySQL e commit:

## Respostas 

### item 5

 -- Respostas do item 5
 -- Encontre produtos nunca vendidos em pedido concluído 
 SELECT p.rid, p.descricao FROM PRODUTO AS p WHERE NOT EXISTS (     SELECT 1     FROM ITEM AS i     JOIN PEDIDO AS ped ON ped.pid = i.pid     WHERE i.rid
= p.rid       AND ped.status = 'CONCLUIDO' ) ORDER BY p.rid;

 -- produtos nunca presentes em qualquer ITEM.

## Modelagem e normalização
Cardinalidades, chaves, dependências, formas normais e limitações das FKs.

## Consultas
SQL próprio, resultado esperado, resultado observado, interpretação.

## Administração
Plano antes/depois do índice; custo de escrita; view e trigger; permissões.

## Transações
| Cenário | Ordem A/B | Resultado observado | Causa | Correção |
|---|---|---|---|---|
| Leitura suja | | | | |
| Não repetível | | | | |
| Fantasma | | | | |
| Atualização perdida | | | | |
| Bloqueio | | | | |
| Deadlock | | | | |

## Recuperação
Arquivo, checksum, base restaurada, comparação de conteúdo e tempo medido.

## Modelos e distribuição
Partição x réplica; desatualização; objetos persistentes; JSON, chave-valor e grafos.

## Limitações e autoria
Separe medição, simulação e proposta. Não anexar senhas ou .env.
