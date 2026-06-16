-- Garante que estamos usando o banco certo
USE studyprojects;

-- Criação da tabela com os ajustes necessários
CREATE TABLE user_events (
    event_id INT PRIMARY KEY,         -- Identificador único
    user_id INT,                      -- ID do usuário
    event_type VARCHAR(50),           -- Tipo de evento (purchase, page_view, etc)
    event_date DATETIME(6),           -- Suporta: 2025-12-30 04:58:24.517006
    product_id INT,                   -- ID do produto
    amount DOUBLE NULL,               -- Aceita valores decimais e também vazios (NULL)
    traffic_source VARCHAR(50)        -- Origem do tráfego
);

SELECT * FROM user_events LIMIT 20;

-- FATURAMENTO x ANO:
SELECT 
    YEAR(event_date), 
    ROUND(SUM(amount),2) AS total_vendido
FROM user_events
WHERE event_type = 'purchase'
GROUP BY YEAR(event_date);

-- FATURAMENTO ACUMULADO POR MÊS
SELECT 
    data_venda,
    total_venda,
    SUM(total_venda) OVER (ORDER BY data_venda) AS venda_acumulada -- Removido o espaço antes do parêntese
FROM
(
    SELECT
        DATE_FORMAT(event_date, '%Y-%m-01') AS data_venda,
        SUM(amount) AS total_venda
    FROM user_events
    WHERE event_type = 'purchase'
    GROUP BY DATE_FORMAT(event_date, '%Y-%m-01')
) AS vendas_mensais;


-- QUAL FONTE DE TRÁFEGO OBTEVE MAIOR TOTAL FATURAMENTO
SELECT 
    traffic_source, 
    SUM(amount) AS total_faturado
FROM user_events
WHERE event_type = 'purchase'
GROUP BY traffic_source
ORDER BY total_faturado DESC;



-- DEFINIR OS ESTÁGIOS DO FUNIL DE VENDAS
WITH funnel_stages AS (
	SELECT 
	COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS stage_1_views,
	COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS stage_2_tocart,
	COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
	COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS stage_4_payment,
	COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS stage_5_purchase
	
	FROM user_events
	
	-- WHERE event_date >= TIMESTAMP(DATE_SUB(CURRENT_DATE(), INTERVAL 120 DAY))
)

SELECT * FROM funnel_stages


-- TAXAS ENTRE OS ESTÁGIOS DO FUNIL DE VENDAS - CONVERSION RATES
WITH funnel_stages AS (
	SELECT 
	COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS stage_1_views,
	COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS stage_2_tocart,
	COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
	COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS stage_4_payment,
	COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS stage_5_purchase
	
	FROM user_events
)

SELECT
	stage_1_views,
	stage_2_tocart,
	ROUND(stage_2_tocart * 100 / stage_1_views) AS view_to_cart_rate, -- quantos visualizações resultaram em incluir no carrinho
	
	stage_3_checkout,
	ROUND(stage_3_checkout * 100 / stage_2_tocart) AS cart_to_checkout_rate, -- quanto do carrinho resultaram em checkout do item
	
	stage_4_payment,
	ROUND(stage_4_payment * 100 / stage_3_checkout) AS checkout_to_payment_rate, -- quantos checkouts resultaram página de pagamento
	
	stage_5_purchase,
	ROUND(stage_5_purchase * 100 / stage_4_payment) AS payment_to_purchase_rate, -- quantos pagamentos resultaram em compras
	
	ROUND(stage_5_purchase * 100 / stage_1_views) AS overallconversion -- quantos visualizações resultaram em compras

FROM funnel_stages


-- FUNIL POR FONTE (SOURCE) - Quantidade de usuários que visualizaram, colocaram no carrinho e compraram de acordo com o tipo de acesso
WITH source_funnel AS (
	SELECT
	traffic_source,
	COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS views,
	COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS cart,
	COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchases
	
	FROM user_events
	
	GROUP BY traffic_source
)

SELECT
	traffic_source,
	views,
	cart,
	purchases,
	ROUND(cart * 100 / views,2) AS cart_conversion_rate,
	ROUND(purchases * 100 / cart,2) AS purchase_conversion_rate,
	ROUND(purchases * 100 / views,2) AS purchaseoverall_conversion_rate

FROM source_funnel
ORDER BY purchases DESC


-- TIME TO CONVERSION ANALYSIS - tempo em que o usuário está passando entre os estágios do funil de vendas
WITH time_source_funnel AS (
	SELECT
	user_id,
	MIN(CASE WHEN event_type = 'page_view' THEN event_date END) AS min_time_view,
	MIN(CASE WHEN event_type = 'add_to_cart' THEN event_date END) AS min_time_cart,
	MIN(CASE WHEN event_type = 'purchase' THEN event_date END) AS min_time_purchases
	
	FROM user_events
	
	GROUP BY user_id
	
	HAVING MIN(CASE WHEN event_type = 'purchase' THEN event_date END) IS NOT NULL
)

SELECT
	COUNT(*) AS time_source_funnel,
	ROUND(AVG(TIMESTAMPDIFF(MINUTE, min_time_view, min_time_cart)),2) AS avg_view_to_cart_minutes,
	ROUND(AVG(TIMESTAMPDIFF(MINUTE, min_time_cart, min_time_purchases)),2) AS avg_cart_to_purchases_minutes,
	ROUND(AVG(TIMESTAMPDIFF(MINUTE, min_time_view, min_time_purchases)),2) AS avg_view_to_purchases_minutes
FROM time_source_funnel


-- REVENUE FUNNEL ANALYSIS  - Ticket Médio 
WITH funnel_revenue AS (
	SELECT
	COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS total_visitors,
	COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS total_buyers,
	ROUND(SUM(CASE WHEN event_type = 'purchase' THEN amount END),2) AS total_revenue,
	COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS total_orders
	
	FROM user_events
)

SELECT 

	total_visitors,
	total_buyers,
	total_revenue,
	total_orders,
	ROUND(total_revenue / total_orders,2) AS avg_order_value, -- ticket médio
	ROUND(total_revenue / total_buyers,2) AS revenue_per_buyer, -- ticket médio por comprador
	ROUND(total_revenue / total_visitors,2) AS revenue_per_visitor -- ticket médio por visitantes

FROM funnel_revenue


