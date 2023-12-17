use `soccer1`;

select concat(cast(t.`year` as char), ' ', y.`name`) as 'tournament', (r.`name`) as 'round',
	concat(m.`day`, '/', m.`month`, '/', m.`year`) as 'date',
	case when m.`penalty_win` = 1 then e1.`fifa_code` when m.`penalty_win` = 2 then e2.`fifa_code` -- for outputting winning team
	when m.`score1` > m.`score2` then e1.`fifa_code` when m.`score2` > m.`score1` then e2.`fifa_code` else "n/a" end as 'winner',
	case when m.`penalty_win` is not null then 'yes' else "no" end as 'penalty_win', -- for yes/no to if match was won by penalty
	concat(e1.`fifa_code`, ' ', e1.`country`) as 'team_1', (m.`score1`) as 'score_1',
	(m.`score2`) as 'score_2', concat(e2.`fifa_code`, ' ', e2.`country`) as 'team_2', (o.`name`) as 'host_org', 
    concat(tt.`fifa_code`, ' ', tt.`country`) as 'host_team'
from `match results` m join `tournaments` t on t.`tournament_id` = m.`tournament_id`
	join `teams` e1 on e1.`fifa_code` = m.`team_code1`
    join `teams` e2 on e2.`fifa_code` = m.`team_code2`
    join `tournament types` y on t.`type_id` = y.`type_id`
    join `teams` tt on tt.`fifa_code` = t.`host_team`
    join `rounds` r on m.`round_id` = r.`round_id`
    join `organizations` o on y.`org_code` = o.`code`
where (t.`year` is not null) -- tournament year
	and (y.`name` like '%%') -- tournament name
    and (r.`name` like '%%') -- name of round
    and (e1.`fifa_code` like '%%' or e2.`fifa_code` like '%%' or e1.`country` like '%%' or e2.`country` like '%%') -- name or fifa code of team
    and (o.`name` like '%%' or o.`code` like '%%') -- name or fifa code of organization
    and (tt.`fifa_code` like '%%' or tt.`country` like '%%') -- name or fifa code of host team
    and (m.`year` is not null) -- year of match
    and (m.`month` is not null) -- month of match
    and (m.`day` is not null) -- day of match
order by m.`year`, m.`month`, m.`day` -- order by date of match
;