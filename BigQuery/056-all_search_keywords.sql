select * from (
select * except(id, transaction_id, purchase_revenue, row_num, max_popular, min_popular)

from (

select *,

case when transaction_id is not null then ( purchase_revenue / max_popular )
else 0 end purchase_revenue_keywords,
case when transaction_id is not null then ( min_popular / max_popular )
else 0 end purchase_transaction_keywords

from (

select *,
LAST_VALUE(row_num) OVER (partition by id ORDER BY id) AS max_popular,
FIRST_VALUE(row_num) OVER (partition by id ORDER BY id) AS min_popular

from (

with search_keywords as (
select
    parse_date("%Y%m%d",event_date) true_date,
    format_date('%G%W',parse_date("%Y%m%d",event_date)) week_of_year,
    format_date('%Y%m',parse_date("%Y%m%d",event_date)) as month_of_year,
    case when device.category like 'desktop' and platform like 'WEB' then 'DESKTOP_WEB'
    when device.category like 'mobile' and platform like 'WEB' then 'DESKTOP_MOB'
    when device.category like 'tablet' and platform like 'WEB' then 'DESKTOP_MOB'
    else 'DESKTOP_WEB' end device,
    concat(user_pseudo_id,(select value.int_value from unnest(event_params) where key = 'ga_session_id')) id,
    case when (SELECT value.string_value FROM unnest(event_params) WHERE key = 'is_autocomplete') = 'false' then false
    else true end is_autocomplete,
    case when (SELECT value.string_value FROM unnest(event_params) WHERE key = 'search_term') is null
    then cast ((SELECT value.int_value FROM unnest(event_params) WHERE key = 'search_term') as string)
    else (SELECT value.string_value FROM unnest(event_params) WHERE key = 'search_term') end keywords,
    cast ((SELECT value.int_value FROM unnest(event_params) WHERE key = 'searchFacetProposedCategory') as string) proposed_category,
    count(*) cnt_search

from `empik-mobile-app.analytics_183670685.events_*`
where
    _table_suffix between '20210101' and '20220801'
    -- _table_suffix = FORMAT_DATE("%Y%m%d", DATE_SUB(CURRENT_DATE(), INTERVAL 3 DAY))
    and platform like 'WEB'
    and event_name = 'search'
group by 1,2,3,4,5,6,7,8),

ecommerce_web as (
select
    parse_date("%Y%m%d",event_date) true_date,
    format_date('%G%W',parse_date("%Y%m%d",event_date)) week_of_year,
    format_date('%Y%m',parse_date("%Y%m%d",event_date)) as month_of_year,
    case when device.category like 'desktop' and platform like 'WEB' then 'DESKTOP_WEB'
    when device.category like 'mobile' and platform like 'WEB' then 'DESKTOP_MOB'
    when device.category like 'tablet' and platform like 'WEB' then 'DESKTOP_MOB'
    else 'DESKTOP_WEB' end device,
    concat(user_pseudo_id,(select value.int_value from unnest(event_params) where key = 'ga_session_id')) id,
    ecommerce.purchase_revenue,
    ecommerce.transaction_id,
    count(distinct ecommerce.transaction_id) purchase

from `empik-mobile-app.analytics_183670685.events_*`
where
    _table_suffix between '20210101' and '20220801'
    -- _table_suffix = FORMAT_DATE("%Y%m%d", DATE_SUB(CURRENT_DATE(), INTERVAL 3 DAY))
    and event_name like 'purchase'
    and platform like 'WEB'
group by 1,2,3,4,5,6,7
)

select
s.true_date,
s.week_of_year,
s.month_of_year,
s.device,
s.is_autocomplete,
s.keywords,
s.cnt_search,
case when starts_with (proposed_category, '51') then 'AGD'
WHEN STARTS_WITH (proposed_category, "35") THEN "Audiobooki i Ebooki"
WHEN STARTS_WITH (proposed_category, "39") THEN "Dom i ogród"
WHEN STARTS_WITH (proposed_category, "42") THEN "Dziecko i mama"
WHEN STARTS_WITH (proposed_category, "36") THEN "Elektronika"
WHEN STARTS_WITH (proposed_category, "33") THEN "Filmy"
WHEN STARTS_WITH (proposed_category, "34") THEN "Gry i programy"
WHEN STARTS_WITH (proposed_category, "46") THEN "Kolekcje własne"
WHEN STARTS_WITH (proposed_category, "31") THEN "Książki"
WHEN STARTS_WITH (proposed_category, "43") THEN "Moda"
WHEN STARTS_WITH (proposed_category, "32") THEN "Muzyka"
WHEN STARTS_WITH (proposed_category, "20") THEN "Obcojęzyczne"
WHEN STARTS_WITH (proposed_category, "44") THEN "Prasa"
WHEN STARTS_WITH (proposed_category, "45") THEN "Przyjęcia i okazje"
WHEN STARTS_WITH (proposed_category, "41") THEN "Sport"
WHEN STARTS_WITH (proposed_category, "40") THEN "Szkolne i papiernicze"
WHEN STARTS_WITH (proposed_category, "37") THEN "Zabawki"
WHEN STARTS_WITH (proposed_category, "38") THEN "Zdrowie i uroda"
WHEN STARTS_WITH (proposed_category, "48") THEN "Motoryzacja"
WHEN STARTS_WITH (proposed_category, "undefined") THEN "--Bez wybranej branży--"
else "Niezmapowane kategorie" end proposed_category,
s.id,
e.purchase_revenue,
e.transaction_id,
ROW_NUMBER () OVER (partition by e.transaction_id ORDER BY e.transaction_id) AS row_num

from search_keywords s
left join ecommerce_web e on s.true_date=e.true_date and s.device=e.device and s.id=e.id)
where keywords is not null))

union all

select * except(id, transaction_id, purchase_revenue, row_num, max_popular, min_popular)

from (

select *,
case when transaction_id is not null then ( purchase_revenue / max_popular )
else 0 end purchase_revenue_keywords,
case when transaction_id is not null then ( min_popular / max_popular )
else 0 end purchase_transaction_keywords

from (

select *,
LAST_VALUE(row_num) OVER (partition by id ORDER BY id) AS max_popular,
FIRST_VALUE(row_num) OVER (partition by id ORDER BY id) AS min_popular


from (

with search_keywords as (
select
    parse_date("%Y%m%d",event_date) true_date,
    format_date('%G%W',parse_date("%Y%m%d",event_date)) week_of_year,
    format_date('%Y%m',parse_date("%Y%m%d",event_date)) as month_of_year,
    'APP' device,
    concat(user_pseudo_id,(select value.int_value from unnest(event_params) where key = 'ga_session_id')) id,
    case when (SELECT value.int_value FROM unnest(event_params) WHERE key = 'is_autocomplete') = 0 then false
    else true end is_autocomplete,
    case when (SELECT value.string_value FROM unnest(event_params) WHERE key = 'search_term') is null
    then cast ((SELECT value.int_value FROM unnest(event_params) WHERE key = 'search_term') as string)
    else (SELECT value.string_value FROM unnest(event_params) WHERE key = 'search_term') end keywords,
    'Brak danych' proposed_category,
    count(*) cnt_search

from `empik-mobile-app.analytics_183670685.events_*`
where
    _table_suffix between '20210101' and '20220801'
    -- _table_suffix = FORMAT_DATE("%Y%m%d", DATE_SUB(CURRENT_DATE(), INTERVAL 3 DAY))
    and platform <> 'WEB'
    and event_name in ('search')
group by 1,2,3,4,5,6,7,8),

ecommerce_web as (
select
    parse_date("%Y%m%d",event_date) true_date,
    format_date('%G%W',parse_date("%Y%m%d",event_date)) week_of_year,
    format_date('%Y%m',parse_date("%Y%m%d",event_date)) as month_of_year,
    'APP' device,
    concat(user_pseudo_id,(select value.int_value from unnest(event_params) where key = 'ga_session_id')) id,
    case when (select value.double_value from unnest(event_params) where key = "value") is null
    then (select value.int_value from unnest(event_params) where key = "value")
    else (select value.double_value from unnest(event_params) where key = "value") end purchase_revenue,
    (SELECT value.string_value FROM unnest(event_params) WHERE key = 'order_id') transaction_id,
    count(distinct (SELECT value.string_value FROM unnest(event_params) WHERE key = 'order_id')) purchase

from `empik-mobile-app.analytics_183670685.events_*`
where
    _table_suffix between '20210101' and '20220801'
    -- _table_suffix = FORMAT_DATE("%Y%m%d", DATE_SUB(CURRENT_DATE(), INTERVAL 3 DAY))
    and platform <> 'WEB'
    and event_name in ('purchase', 'ecommerce_purchase')
group by 1,2,3,4,5,6,7
)

select
s.true_date,
s.week_of_year,
s.month_of_year,
s.device,
s.is_autocomplete,
s.keywords,
s.cnt_search,
proposed_category,
s.id,
e.purchase_revenue,
e.transaction_id,
ROW_NUMBER () OVER (partition by e.transaction_id ORDER BY e.transaction_id) AS row_num

from search_keywords s
left join ecommerce_web e on s.true_date=e.true_date and s.id=e.id
) where keywords is not null ))) order by 1 desc