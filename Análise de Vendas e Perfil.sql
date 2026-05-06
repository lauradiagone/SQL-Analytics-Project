```sql
-- =====================================================
-- PROJETO - ANÁLISE DE VENDAS E PERFIL DOS LEADS
-- =====================================================


-- =====================================================
-- QUERY 1
-- Receita, Leads, Conversão e Ticket Médio Mês a Mês
-- =====================================================

with 
    leads as (
        select
            date_trunc('month', visit_page_date)::date as visit_page_month,
            count(*) as visit_page_count

        from sales.funnel
        group by visit_page_month
        order by visit_page_month
    ),

    payments as (
        select
            date_trunc('month', fun.paid_date)::date as paid_month,
            count(fun.paid_date) as paid_count,
            sum(
                pro.price * (1 + fun.discount)
            ) as receita
			
        from sales.funnel as fun
        left join sales.products as pro
            on fun.product_id = pro.product_id
        where fun.paid_date is not null
        group by paid_month
        order by paid_month
    )

select
    leads.visit_page_month as "mês",
    leads.visit_page_count as "leads (#)",
    payments.paid_count as "vendas (#)",
    (payments.receita/1000) as "receita (k, R$)",
    (
        payments.paid_count::float /
        leads.visit_page_count::float
    ) as "conversão (%)",

    (
        payments.receita /
        payments.paid_count / 1000
    ) as "ticket médio (k, R$)"

from leads
left join payments
    on leads.visit_page_month = paid_month;



-- =====================================================
-- QUERY 2
-- Estados que Mais Venderam
-- =====================================================

select
    'Brazil' as país,
    cus.state as estado,
    count(fun.paid_date) as "vendas (#)"
	
from sales.funnel as fun
left join sales.customers as cus
    on fun.customer_id = cus.customer_id
	
where paid_date between '2021-08-01' and '2021-08-31'

group by país, estado
order by "vendas (#)" desc
limit 10;



-- =====================================================
-- QUERY 3
-- Marcas que Mais Venderam no Mês
-- =====================================================

select
    pro.brand as marca,
    count(fun.paid_date) as "vendas (#)",
    sum(
        pro.price * (1 + fun.discount)
    ) as receita

from sales.funnel as fun

left join sales.products as pro
    on fun.product_id = pro.product_id

where paid_date between '2021-08-01' and '2021-08-31'
group by marca
order by receita desc
limit 10;


-- =====================================================
-- QUERY 4
-- Lojas que Mais Venderam
-- =====================================================

select
    sto.store_name as loja,
    count(fun.paid_date) as "vendas (#)",
    sum(
        pro.price * (1 + fun.discount)
    ) as receita

from sales.funnel as fun

left join sales.stores as sto
    on fun.store_id = sto.store_id

left join sales.products as pro
    on fun.product_id = pro.product_id

where paid_date between '2021-08-01' and '2021-08-31'

group by loja
order by receita desc
limit 10;



-- =====================================================
-- QUERY 5
-- Dias da Semana com Maior Número de Visitas
-- =====================================================

select

    extract('dow' from visit_page_date) as dia_semana,

    case 

        when extract('dow' from visit_page_date)=0 then 'domingo'
        when extract('dow' from visit_page_date)=1 then 'segunda'
        when extract('dow' from visit_page_date)=2 then 'terça'
        when extract('dow' from visit_page_date)=3 then 'quarta'
        when extract('dow' from visit_page_date)=4 then 'quinta'
        when extract('dow' from visit_page_date)=5 then 'sexta'
        when extract('dow' from visit_page_date)=6 then 'sábado'

        else null

    end as "dia da semana",

    count(*) as "visitas (#)"

from sales.funnel

where visit_page_date between '2021-08-01' and '2021-08-31'

group by dia_semana

order by "visitas (#)" desc;


-- =====================================================
-- QUERY 6
-- Status Profissional dos Leads
-- =====================================================

select

    case

        when professional_status = 'freelancer' then 'freelancer'
        when professional_status = 'retired' then 'aposentado(a)'
        when professional_status = 'clt' then 'clt'
        when professional_status = 'self_employed' then 'autônomo(a)'
        when professional_status = 'other' then 'outro'
        when professional_status = 'businessman' then 'empresário(a)'
        when professional_status = 'civil_servant' then 'funcionário(a) público(a)'
        when professional_status = 'student' then 'estudante'

    end as "status profissional",

    (
        count(*)::float /
        (select count(*) from sales.customers)
    ) as "leads (%)"

from sales.customers

group by professional_status
order by "leads (%)" desc;



-- =====================================================
-- QUERY 7
-- Faixa Salarial dos Leads
-- =====================================================

select

    case

        when income < 5000 then '0-5000'
        when income < 10000 then '5000-10000'
        when income < 15000 then '10000-15000'
        when income < 20000 then '15000-20000'

        else '20000+'

    end as "faixa salarial",

    count(*)::float /
    (
        select count(*)
        from sales.customers
    ) as "leads (%)"

from sales.customers

group by "faixa salarial"
order by "leads (%)" desc;



-- =====================================================
-- QUERY 8
-- Veículos Mais Visitados por Marca
-- =====================================================

select

    pro.brand,

    pro.model,

    count(*) as "visitas (#)"

from sales.funnel as fun

left join sales.products as pro
    on fun.product_id = pro.product_id

group by
    pro.brand,
    pro.model

order by "visitas (#)" desc

limit 10;
