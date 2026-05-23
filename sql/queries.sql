-- Query 1: Top 10 clubs by money received (selling clubs)
SELECT 
    from_club_name AS selling_club,
    COUNT(*) AS players_sold,
    ROUND(SUM(transfer_fee)/1000000, 2) AS total_received_millions
FROM transfers
WHERE transfer_fee > 0
GROUP BY from_club_name
ORDER BY total_received_millions DESC
LIMIT 10;

-- Query 2: Top 10 clubs by money spent (buying clubs)
SELECT 
    to_club_name AS buying_club,
    COUNT(*) AS players_bought,
    ROUND(SUM(transfer_fee)/1000000, 2) AS total_spent_millions,
    ROUND(AVG(transfer_fee)/1000000, 2) AS avg_per_player_millions
FROM transfers
WHERE transfer_fee > 0
GROUP BY to_club_name
ORDER BY total_spent_millions DESC
LIMIT 10;

-- Query 3: Transfer activity by season year
SELECT 
    season_year,
    COUNT(*) AS num_transfers,
    COUNT(CASE WHEN fee_category = 'Paid Transfer' THEN 1 END) AS paid_transfers,
    ROUND(SUM(transfer_fee)/1000000, 2) AS total_spend_millions,
    ROUND(AVG(CASE WHEN transfer_fee > 0 THEN transfer_fee END)/1000000, 2) AS avg_fee_millions
FROM transfers
WHERE season_year BETWEEN 1993 AND 2024
GROUP BY season_year
ORDER BY season_year;

-- Note: seasons 2001-2012 used different format in source data
-- Core analysis focuses on 2013-2024 where data is complete





-- Query 4: Top 15 most expensive transfers ever
SELECT 
    player_name,
    from_club_name,
    to_club_name,
    ROUND(transfer_fee/1000000, 2) AS fee_millions,
    ROUND(market_value_in_eur/1000000, 2) AS market_value_millions,
    transfer_season,
    season_year
FROM transfers
WHERE transfer_fee > 0
ORDER BY transfer_fee DESC
LIMIT 15;

-- Query 5: Fee category breakdown

SELECT 
    fee_category,
    COUNT(*) AS num_transfers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM transfers
GROUP BY fee_category
ORDER BY num_transfers DESC;

-- Query 6: Market value vs transfer fee comparison

SELECT 
    player_name,
    from_club_name,
    to_club_name,
    ROUND(transfer_fee/1000000, 2) AS fee_millions,
    ROUND(market_value_in_eur/1000000, 2) AS market_value_millions,
    ROUND((transfer_fee - market_value_in_eur)/1000000, 2) AS premium_paid_millions
FROM transfers
WHERE transfer_fee > 0 
AND market_value_in_eur > 0
ORDER BY premium_paid_millions DESC
LIMIT 15;

-- Query 7: Transfer fee inflation: era comparison

SELECT 
    CASE 
        WHEN season_year BETWEEN 1993 AND 2002 THEN '1993-2002'
        WHEN season_year BETWEEN 2003 AND 2012 THEN '2003-2012'
        WHEN season_year BETWEEN 2013 AND 2024 THEN '2013-2024'
    END AS era,
    COUNT(*) AS num_transfers,
    COUNT(CASE WHEN fee_category = 'Paid Transfer' THEN 1 END) AS paid_deals,
    ROUND(AVG(CASE WHEN transfer_fee > 0 THEN transfer_fee END)/1000000, 2) AS avg_fee_millions,
    ROUND(SUM(transfer_fee)/1000000, 2) AS total_spend_millions
FROM transfers
WHERE season_year BETWEEN 1993 AND 2024
GROUP BY era
ORDER BY era;

-- Query 8: Most transferred players (most moves)

SELECT 
    player_name,
    COUNT(*) AS num_transfers,
    ROUND(SUM(transfer_fee)/1000000, 2) AS total_fees_millions,
    MIN(season_year) AS first_transfer,
    MAX(season_year) AS last_transfer
FROM transfers
GROUP BY player_name
HAVING COUNT(*) >= 4
ORDER BY num_transfers DESC
LIMIT 15;

-- Query 9: Club net spend (bought minus sold)

SELECT 
    club,
    ROUND(SUM(CASE WHEN direction = 'bought' THEN fee ELSE -fee END)/1000000, 2) AS net_spend_millions
FROM (
    SELECT to_club_name AS club, 'bought' AS direction, transfer_fee AS fee
    FROM transfers WHERE transfer_fee > 0
    UNION ALL
    SELECT from_club_name AS club, 'sold' AS direction, transfer_fee AS fee
    FROM transfers WHERE transfer_fee > 0
) AS combined
GROUP BY club
ORDER BY net_spend_millions DESC
LIMIT 20;

-- Query 10: Top scorers with market value (joining transfers + appearances + players)

SELECT 
    a.player_name,
    SUM(a.goals) AS total_goals,
    SUM(a.assists) AS total_assists,
    SUM(a.minutes_played) AS total_minutes,
    ROUND(SUM(a.goals) * 90.0 / NULLIF(SUM(a.minutes_played), 0), 2) AS goals_per_90,
    ROUND(p.market_value_in_eur/1000000, 2) AS market_value_millions
FROM appearances a
JOIN players p ON a.player_id = p.player_id
WHERE a.goals > 0
GROUP BY a.player_name, p.market_value_in_eur
HAVING SUM(a.goals) >= 10
ORDER BY total_goals DESC
LIMIT 20;