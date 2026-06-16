###"Este projeto foi desenvolvido como um estudo prático baseado no projeto guiado do canal Lore So What, com o objetivo de aprofundar conhecimentos em SQL (CTEs, Window Function, Funções de Agregação - MySQL), lógicas de Funil de Vendas e CRM."

# 🛒 Análise Avançada de Funil de Vendas e CRM Analytics com SQL

[![SQL](https://img.shields.io/badge/SQL-MySQL-4479A1?style=flat&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![E-Commerce](https://img.shields.io/badge/Data-Analytics-orange?style=flat)](https://github.com/)
[![Funnel](https://img.shields.io/badge/Funnel-Conversion-brightgreen?style=flat)](https://github.com/)

Este projeto consiste no desenvolvimento de uma solução analítica em banco de dados para mapear a jornada do usuário em uma plataforma de e-commerce. Através do processamento de dados de web analytics (`user_events`), foi estruturado um modelo macro de **Funil de Vendas**, taxas de conversão por canais de tráfego e métricas de tempo de resposta (*Time to Conversion*).

---

## 🎯 Objetivos de Negócio

O objetivo central é responder a perguntas estratégicas da diretoria de Growth e Produto:
1. **Onde a empresa está perdendo dinheiro?** Em qual estágio da jornada de compra o usuário desiste?
2. **Eficiência de Mídia:** Quais canais de aquisição de tráfego (E-mail, Social Media, Paid Search, etc.) trazem os clientes mais qualificados e com maior retorno financeiro?
3. **Velocidade de Compra:** Quanto tempo o usuário leva, em média, desde a primeira visualização de página até a confirmação do pagamento?
4. **Rentabilidade:** Qual o Ticket Médio por pedido e a receita gerada por visitante (*RPV*)?

---

## 🧠 Arquitetura de Consultas & Técnicas SQL Aplicadas

A modelagem foi desenvolvida utilizando **MySQL**, fazendo uso de recursos de performance e manipulação de dados avançados:
* **Tabelas Temporárias e Expressões de Tabela Comuns (CTEs):** Uso de `WITH` para segmentar e estruturar os estágios gerenciais do funil antes da aplicação de cálculos de taxa.
* **Funções de Janela (Window Functions):** Aplicação de `SUM() OVER (ORDER BY)` para calcular o faturamento acumulado de forma contínua ao longo dos meses.
* **Agregações Condicionais complexas:** Implementação de lógicas de pivotagem com `COUNT(DISTINCT CASE WHEN THEN)` para contabilizar usuários únicos em cada etapa da jornada.
* **Funções de Data e Tempo:** Uso de `TIMESTAMPDIFF` para mensurar o tempo de conversão exato em minutos entre os eventos, e `DATE_FORMAT` para consolidação mensal.

---

## 📊 Estrutura do Funil de Vendas Mapeado

A jornada do usuário foi dividida em 5 macroetapas sequenciais:
1. **Stage 1 (Page View):** Visualização inicial do produto.
2. **Stage 2 (Add to Cart):** Inclusão do item no carrinho de compras.
3. **Stage 3 (Checkout Start):** Início do processo de preenchimento de dados de envio.
4. **Stage 4 (Payment Info):** Inserção dos dados de pagamento.
5. **Stage 5 (Purchase):** Confirmação e processamento com sucesso do pedido.

---

## 📈 Insights de Negócio & Recomendações Estratégicas

### 1. Diagnóstico da Taxa de Conversão Geral (Overall Rate)
* A taxa de conversão final do funil (da visualização do produto à compra efetiva) consolidou-se em **17%**.
* Trata-se de um indicador de performance altamente eficiente para os padrões de varejo digital global. A jornada principal possui boa fluidez e atração.
* **Ação Recomendada:** Em vez de desgastar a margem de lucro com cupons em massa logo no primeiro contato, o time de produto deve focar em **Gatilhos de Escassez e Urgência** na página do produto (ex: *"Apenas mais 3 unidades disponíveis deste item"*) para acelerar a decisão do usuário.

### 2. Atrito no Checkout e Abandono de Carrinho
* A taxa de conversão de usuários que adicionaram itens ao carrinho e concluíram a compra estabilizou-se em torno de **50%**, apontando um abandono de carrinho de metade da base interessada.
* esse comportamento indica barreiras financeiras ou de experiência no momento final da escolha (como frete inesperado ou falta de opções de pagamento).
* **Ação Recomendada:** 1. Facilitar a jornada implementando métodos de pagamento instantâneos (Pix em 1 clique) e maior flexibilidade de parcelamento sem juros.
  2. Implementar réguas automáticas de **Remarketing via CRM** para resgatar usuários que abandonaram o carrinho nas últimas 2 horas.

### 3. Eficiência de Performance por Canal de Tráfego
* O canal de **E-mail** despontou com a maior eficiência de conversão final, atingindo **34%** de taxa agregada (*Overall*). Por outro lado, **Social Media** apresentou o menor desempenho, convertendo apenas **13,6%**.
* O E-mail atua como uma mídia de público quente (base de clientes fidelizados ou leads capturados), o que justifica seu alto aproveitamento. As Redes Sociais funcionam como canais de descoberta (público frio), atraindo volume, mas com menor intenção de compra imediata.
* **Ação Recomendada:** Otimizar a alocação de orçamento de marketing. Manter as redes sociais focadas em geração de *awareness* (tráfego de topo de funil) e direcionar esforços agressivos de conversão e ofertas exclusivas via e-mail e automações de base.

---

## 🔗 Como Executar o Projeto

1. Certifique-se de possuir um ambiente MySQL ou similar configurado.
2. Crie o banco de dados utilizando a query inicial contida no script.
3. Execute o script completo de análise: [Sales_funnel_analysis.sql](./Sales_funnel_analysis.sql) para extrair os relatórios gerenciais estruturados.

---
Desenvolvido por **Carlos** — [LinkedIn]((https://www.linkedin.com/in/carlos-vital-junior-429138122/)) | [GitHub](https://github.com/cvitaljr)
