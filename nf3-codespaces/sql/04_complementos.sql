USE loja_cerrado;
WITH totais AS (
 SELECT p.pid,p.cid,SUM(i.qtd*i.preco) total
 FROM PEDIDO p JOIN ITEM i ON i.pid=p.pid WHERE p.status='CONCLUIDO' GROUP BY p.pid,p.cid
)
SELECT pid,cid,total,DENSE_RANK() OVER(ORDER BY total DESC) posicao FROM totais ORDER BY total DESC,pid;
SELECT c.cid,c.nome,COALESCE(SUM(i.qtd*i.preco),0) total_concluido
 FROM CLIENTE c LEFT JOIN PEDIDO p ON p.cid=c.cid AND p.status='CONCLUIDO'
 LEFT JOIN ITEM i ON i.pid=p.pid GROUP BY c.cid,c.nome ORDER BY c.cid;
SELECT pid,CASE status WHEN 'CONCLUIDO' THEN 'Receita elegivel'
 WHEN 'CANCELADO' THEN 'Excluir' ELSE 'Aguardar' END situacao FROM PEDIDO ORDER BY pid;
SELECT cidade FROM CLIENTE WHERE cid<=3 UNION SELECT cidade FROM CLIENTE WHERE cid>=3;
SELECT cidade FROM CLIENTE WHERE cid<=3 UNION ALL SELECT cidade FROM CLIENTE WHERE cid>=3;
-- NOT IN e NULL: a comparação pode resultar UNKNOWN.
SELECT 5 NOT IN (1,2,NULL) AS resultado;

 -- respostas
 -- Encontre produtos nunca vendidos em pedido concluído e diferencie de produtos nunca presentes em qualquer ITEM.

SELECT p.rid, p.descricao
FROM PRODUTO AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM ITEM AS i
    JOIN PEDIDO AS ped ON ped.pid = i.pid
    WHERE i.rid = p.rid
      AND ped.status = 'CONCLUIDO'
)
ORDER BY p.rid;