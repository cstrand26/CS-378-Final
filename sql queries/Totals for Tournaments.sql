-- individual total creating queries that were used in "Tournaments by Criteria"
use `soccer1`;
-- total matches per tournament --
select m.`tournament_id`, Count(m.`id`) as 'match_total'
	from `match results` m
    group by m.`tournament_id`
    ;
-- winning team per tournament --
	select t.`tournament_id`, case when w.`fifa_code` is null then "n/a" else concat(w.`fifa_code`, ' ', e.`country`) end as 'tournmanent_winner'
    from tournaments t
    left outer join (select m.`team_code1` as 'fifa_code', m.`tournament_id`
	from `match results` m 
    where m.`round_id` = 1 and (m.`score1` > m.`score2` or m.`penalty_win` = 1)
    union
    select m.`team_code2` as 'fifa_code', m.`tournament_id`
    from `match results` m
    where m.`round_id` = 1 and (m.`score2` > m.`score1` or m.`penalty_win` = 2)) as w on t.`tournament_id`=w.`tournament_id`
    left outer join `teams` e on w.`fifa_code` = e.`fifa_code`
    ;