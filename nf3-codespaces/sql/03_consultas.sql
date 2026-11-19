USE loja_cerrado;
SELECT cid,nome,cidade FROM CLIENTE WHERE cidade='Catalao' ORDER BY nome,cid;
SELECT rid,descricao FROM PRODUTO WHERE categoria IN ('Informatica','Moveis') ORDER BY categoria,rid;
SELECT pid,rid,qtd,preco FROM ITEM WHERE preco BETWEEN 80 AND 150 ORDER BY pid,rid;
SELECT cid,nome FROM CLIENTE WHERE nome LIKE 'A%' ORDER BY cid;
SELECT cid,nome,cidade FROM CLIENTE ORDER BY cidade,cid LIMIT 2 OFFSET 0;
SELECT c.cid,c.nome,p.pid,p.status FROM CLIENTE c INNER JOIN PEDIDO p ON p.cid=c.cid ORDER BY c.cid,p.pid;
-- Q11: preservar todos os clientes. Aqui CONCLUIDO substitui PAGO da prova.
SELECT c.cid,c.nome,p.pid FROM CLIENTE c LEFT JOIN PEDIDO p
 ON p.cid=c.cid AND p.status='CONCLUIDO' ORDER BY c.cid,p.pid;
-- Equivalente usando RIGHT JOIN: agora CLIENTE está à direita.
SELECT c.cid,c.nome,p.pid FROM PEDIDO p RIGHT JOIN CLIENTE c
 ON p.cid=c.cid AND p.status='CONCLUIDO' ORDER BY c.cid,p.pid;
-- Compare: filtrar coluna da tabela opcional no WHERE elimina linhas NULL.
SELECT c.cid,c.nome,p.pid FROM CLIENTE c LEFT JOIN PEDIDO p ON p.cid=c.cid
 WHERE p.status='CONCLUIDO' ORDER BY c.cid,p.pid;
SELECT p.pid,SUM(i.qtd*i.preco) total FROM PEDIDO p JOIN ITEM i ON i.pid=p.pid
 WHERE p.status='CONCLUIDO' GROUP BY p.pid HAVING SUM(i.qtd*i.preco)>500 ORDER BY total DESC,p.pid;
SELECT c.cid,c.nome FROM CLIENTE c WHERE NOT EXISTS
 (SELECT 1 FROM PEDIDO p WHERE p.cid=c.cid) ORDER BY c.cid;
SELECT rid,descricao FROM PRODUTO WHERE rid IN
 (SELECT i.rid FROM ITEM i JOIN PEDIDO p ON p.pid=i.pid WHERE p.status='CONCLUIDO') ORDER BY rid;
SELECT COUNT(*) linhas_itens,COUNT(DISTINCT p.pid) pedidos,SUM(i.qtd*i.preco) faturamento
 FROM PEDIDO p JOIN ITEM i ON i.pid=p.pid WHERE p.status='CONCLUIDO';
-- Agregar por pedido antes de calcular ticket médio.
SELECT COUNT(*) pedidos,SUM(total) faturamento,ROUND(AVG(total),2) ticket_medio
 FROM (SELECT p.pid,SUM(i.qtd*i.preco) total FROM PEDIDO p JOIN ITEM i ON p.pid=i.pid
 WHERE p.status='CONCLUIDO' GROUP BY p.pid) t;


 -- Respostas do item 5
 -- Encontre produtos nunca vendidos em pedido concluído 
 SELECT p.rid, p.descricao FROM PRODUTO AS p WHERE NOT EXISTS (     SELECT 1     FROM ITEM AS i     JOIN PEDIDO AS ped ON ped.pid = i.pid     WHERE i.rid
= p.rid       AND ped.status = 'CONCLUIDO' ) ORDER BY p.rid;

 -- produtos nunca presentes em qualquer ITEM.