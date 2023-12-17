use `soccer1`;

select concat(cast(t.year as char), ' ', tt.`name`) as `name`, concat(o.`code`, ' ', o.`name`)as 'host_org', concat(e.`fifa_code`, ' ', e.`country`) as 'host_team',
	mt.`match_total`, w.`tournament_winner`
from `tournaments` t join `tournament types` tt on t.`type_id` = tt.`type_id`
	join `teams` e on e.`fifa_code` = t.`host_team`
    join `organizations` o on o.`code` = tt.`org_code`
	-- returns count of matches played in tournament
    join (select m.`tournament_id`, Count(m.`id`) as 'match_total'
		from `match results` m
		group by m.`tournament_id`) as mt on mt.`tournament_id` = t.`tournament_id`
	-- returns FIFA code and country in single field of FIFA team that won the final match
	join (select t.`tournament_id`, case when w.`fifa_code` is null then "n/a" else concat(w.`fifa_code`, ' ', e.`country`) end as 'tournament_winner'
		from tournaments t
		left outer join (select m.`team_code1` as 'fifa_code', m.`tournament_id`
		from `match results` m 
		where m.`round_id` = 1 and (m.`score1` > m.`score2` or m.`penalty_win` = 1)
		union
		select m.`team_code2` as 'fifa_code', m.`tournament_id`
		from `match results` m
		where m.`round_id` = 1 and (m.`score2` > m.`score1` or m.`penalty_win` = 2)) as w on t.`tournament_id` = w.`tournament_id`
		left outer join `teams` e on w.`fifa_code` = e.`fifa_code`) as w on w.`tournament_id` = t.`tournament_id`
where t.`year` is not null -- year of tournament
	and tt.`name` like '%%' -- name of tournament
    and (e.`country` like '%%' or e.`fifa_code` like '%%') -- name of host team
    and (o.`code` like '%%' or o.`name` like '%%') -- name of host organization
    and (w.`tournament_winner` like '%%') -- name of winning team
    order by t.`year`, tt.`name` -- order by tournament year, then by name
;