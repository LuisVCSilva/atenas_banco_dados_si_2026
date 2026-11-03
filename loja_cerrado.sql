-- ================================================================
-- LOJA CERRADO
-- Compatibilidade-alvo: MySQL 8.0+ | codificacao: UTF-8
-- CLIENTE (5), PEDIDO (5), PRODUTO (5), ITEM (9)
-- Extensoes: CLIENTE_PF, CLIENTE_PJ, ENDERECO_ENTREGA
-- ATENCAO: o DROP DATABASE abaixo APAGA a base 'loja_cerrado'.
-- Nao execute se voce tiver dados proprios com esse nome.
-- ================================================================
DROP DATABASE IF EXISTS loja_cerrado;
CREATE DATABASE loja_cerrado
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE loja_cerrado;

-- ENTIDADE FORTE: a chave cid identifica CLIENTE independentemente.
CREATE TABLE CLIENTE (
    cid     INT NOT NULL,
    nome    VARCHAR(100) NOT NULL,
    cidade  VARCHAR(100) NOT NULL,
    PRIMARY KEY (cid)
) ENGINE=InnoDB;

-- PEDIDO tem identidade propria (pid), mesmo possuindo FK cid.
CREATE TABLE PEDIDO (
    pid     INT NOT NULL,
    cid     INT NOT NULL,
    status  VARCHAR(12) NOT NULL,
    PRIMARY KEY (pid),
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (cid)
        REFERENCES CLIENTE (cid)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_pedido_status CHECK (status IN ('CONCLUIDO','PENDENTE','CANCELADO'))
) ENGINE=InnoDB;

CREATE TABLE PRODUTO (
    rid        INT NOT NULL,
    descricao  VARCHAR(100) NOT NULL,
    categoria  VARCHAR(100) NOT NULL,
    PRIMARY KEY (rid)
) ENGINE=InnoDB;

-- ENTIDADE ASSOCIATIVA: representa o relacionamento PEDIDO N:N PRODUTO.
-- qtd e preco sao atributos da participacao, e nao do produto cadastrado.
-- Uma linha por produto em cada pedido, com chave primaria composta.
CREATE TABLE ITEM (
    pid    INT NOT NULL,
    rid    INT NOT NULL,
    qtd    INT NOT NULL,
    preco  DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (pid, rid),
    CONSTRAINT fk_item_pedido FOREIGN KEY (pid)
        REFERENCES PEDIDO (pid)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_item_produto FOREIGN KEY (rid)
        REFERENCES PRODUTO (rid)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_item_qtd CHECK (qtd > 0),
    CONSTRAINT chk_item_preco CHECK (preco >= 0)
) ENGINE=InnoDB;

-- Especializacao: cid e PK do subtipo e FK para o supertipo CLIENTE.
CREATE TABLE CLIENTE_PF (
    cid  INT NOT NULL,
    cpf  CHAR(11) NOT NULL,
    PRIMARY KEY (cid),
    UNIQUE KEY uq_cliente_pf_cpf (cpf),
    CONSTRAINT fk_pf_cliente FOREIGN KEY (cid)
        REFERENCES CLIENTE (cid)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE CLIENTE_PJ (
    cid      INT NOT NULL,
    cnpj     CHAR(14) NOT NULL,
    contato  VARCHAR(100) NOT NULL,
    PRIMARY KEY (cid),
    UNIQUE KEY uq_cliente_pj_cnpj (cnpj),
    CONSTRAINT fk_pj_cliente FOREIGN KEY (cid)
        REFERENCES CLIENTE (cid)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ENTIDADE FRACA: seq identifica o endereco apenas dentro do cliente.
-- Chave completa = (cid,seq); seq sozinho nao e unico globalmente.
CREATE TABLE ENDERECO_ENTREGA (
    cid         INT NOT NULL,
    seq         INT NOT NULL,
    logradouro  VARCHAR(150) NOT NULL,
    PRIMARY KEY (cid, seq),
    CONSTRAINT fk_endereco_cliente FOREIGN KEY (cid)
        REFERENCES CLIENTE (cid)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_endereco_seq CHECK (seq > 0)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- REGISTROS ORIGINAIS DOS SLIDES (mantidos integralmente)
-- ----------------------------------------------------------------
INSERT INTO CLIENTE (cid, nome, cidade) VALUES
  (1, 'Ana',   'Catalao'),
  (2, 'Bruno', 'Paracatu'),
  (3, 'Carla', 'Catalao'),
  (4, 'Diego', 'Goiania'),
  (5, 'Eva',   'Catalao');

INSERT INTO PEDIDO (pid, cid, status) VALUES
  (101, 1, 'CONCLUIDO'),
  (102, 1, 'PENDENTE'),
  (103, 2, 'CONCLUIDO'),
  (104, 3, 'CONCLUIDO'),
  (105, 4, 'CANCELADO');

INSERT INTO PRODUTO (rid, descricao, categoria) VALUES
  (10, 'Teclado', 'Informatica'),
  (20, 'Mouse',   'Informatica'),
  (30, 'Cadeira', 'Moveis'),
  (40, 'Monitor', 'Informatica'),
  (50, 'Mesa',    'Moveis');

INSERT INTO ITEM (pid, rid, qtd, preco) VALUES
  (101, 10, 1, 150.00),
  (101, 20, 2,  80.00),
  (102, 30, 1, 600.00),
  (103, 20, 1,  80.00),
  (103, 40, 1, 900.00),
  (104, 10, 1, 150.00),
  (104, 20, 1,  80.00),
  (104, 40, 1, 900.00),
  (105, 30, 2, 600.00);

-- ENDERECO_ENTREGA: tres exemplos explicitamente dados na lista.
INSERT INTO ENDERECO_ENTREGA (cid, seq, logradouro) VALUES
  (1, 1, 'Rua do Comercio, 10'),
  (1, 2, 'Rua das Flores, 20'),
  (2, 1, 'Avenida Central, 30');

-- SUBTIPOS: dados ficticios adicionais para a demonstracao pratica.
-- O cid=5 (Eva) representa neste laboratorio um nome comercial PJ.
-- Os documentos abaixo sao identificadores de teste, nao dados reais.
INSERT INTO CLIENTE_PF (cid, cpf) VALUES
  (1, '90000000001'),
  (2, '90000000002'),
  (3, '90000000003'),
  (4, '90000000004');
INSERT INTO CLIENTE_PJ (cid, cnpj, contato) VALUES
  (5, '90000000000005', 'Contato comercial da Eva');

-- Regras conceituais NAO garantidas apenas pelas FKs:
-- 1) Todo cliente ser PF OU PJ, mas nao ambos (total e disjunta);
-- 2) Todo pedido FINALIZADO possuir pelo menos um ITEM.
-- A carga de exemplos atende essas regras, mas novos INSERTs precisariam
-- de validacao adicional na aplicacao, trigger ou fluxo transacional.

SELECT 'CLIENTE' AS tabela, COUNT(*) AS registros FROM CLIENTE
UNION ALL SELECT 'PEDIDO', COUNT(*) FROM PEDIDO
UNION ALL SELECT 'PRODUTO', COUNT(*) FROM PRODUTO
UNION ALL SELECT 'ITEM', COUNT(*) FROM ITEM
UNION ALL SELECT 'CLIENTE_PF', COUNT(*) FROM CLIENTE_PF
UNION ALL SELECT 'CLIENTE_PJ', COUNT(*) FROM CLIENTE_PJ
UNION ALL SELECT 'ENDERECO_ENTREGA', COUNT(*) FROM ENDERECO_ENTREGA;
