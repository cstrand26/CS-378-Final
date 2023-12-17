-- individual total creating queries that were used in "Team Info by Criteria"
use `soccer1`;

-- total games tied --
select t.`fifa_code`, case when e.`ties` is null then "0" else e.`ties` end as 'ties'
from `teams` t left outer join (select e.`fifa_code`, (x.`ties` + y.`ties`) as 'ties'
	from `teams` e left outer join (select m.`team_code1`, Count(*) as 'ties'
		from `match results` m
		where m.`score1` = m.`score2` and m.`penalty_win` is null
		group by m.`team_code1`) x on e.`fifa_code` = x.`team_code1`
		left outer join (select m.`team_code2`, count(*) as 'ties'
			from `match results` m
			where m.`score2` = m.`score1` and m.`penalty_win` is null
			group by m.`team_code2`) y on e.`fifa_code` = y.`Team_Code2`) as e on t.`fifa_code` = e.`fifa_code`;
        
-- total games won --
select t.`fifa_code`, case when e.`wins` is null then "0" else e.`wins` end as 'wins'
from `teams` t left outer join (select e.`fifa_code`, (x.`wins` + y.`wins`) as 'wins'
	from `teams` e left outer join (select m.`team_code1`, Count(*) as 'wins'
		from `match results` m
		where m.`score1` > m.`score2` or m.`penalty_win` = 1
		group by m.`team_code1`) x on e.`fifa_code` = x.`team_code1`
		left outer join (select m.`team_code2`, count(*) as 'wins'
			from `match results` m
			where m.`score2` > m.`score1` or m.`penalty_win` = 2
			group by m.`team_code2`) y on e.`fifa_code` = y.`team_code2`) as e on t.`fifa_code` = e.`fifa_code`;
        
-- total games won in penalty --
select t.`fifa_code`, case when e.`penalty_wins` is null then "0" else e.`penalty_wins` end as 'penalty_wins'
from `teams` t left outer join (select e.`fifa_code`, (x.`wins` + y.`wins`) as 'penalty_wins'
	from `teams` e left outer join (select m.`team_code1`, Count(*) as 'wins'
		from `match results` m
		where m.`penalty_win` = 1
		group by m.`team_code1`) x on e.`fifa_code` = x.`team_code1`
		left outer join (select m.`team_code2`, count(*) as 'wins'
			from `match results` m
			where m.`penalty_win` = 2
			group by m.`team_code2`) y on e.`fifa_code` = y.`team_code2`) as e on t.`fifa_code` = e.`fifa_code`;

-- total games lost --
select t.`fifa_code`, case when e.`losses` is null then "0" else e.`losses` end as 'losses'
from `teams` t left outer join (select e.`fifa_code`, (x.`losses` + y.`losses`) as 'losses'
	from `teams` e left outer join (select m.`team_code1`, Count(*) as 'losses'
		from `match results` m
		where m.`score1` < m.`score2` or m.`penalty_win` = 2
		group by m.`team_code1`) x on e.`fifa_code` = x.`team_code1`
		left outer join (select m.`team_code2`, count(*) as 'losses'
			from `match results` m
			where m.`score2` < m.`score1` or m.`penalty_win` = 1
			group by m.`team_code2`) y on e.`fifa_code` = y.`team_code2`) as e on t.`fifa_code` = e.`fifa_code`;
        
-- total points scored by team --
select t.`fifa_code`, case when e.`sumscore` is null then "0" else e.`sumscore` end as 'sumscore'
from `teams` t left outer join (select e.`fifa_code`, (x.`sumscore` + y.`sumscore`) as 'sumscore'
	from `teams` e left outer join (select m.`team_code1`, Sum(m.`score1`) as 'sumscore' 
		from `match results` m
		group by m.`team_code1`) x on e.`fifa_code` = x.`team_code1`
		left outer join (select m.`team_code2`, Sum(m.`score2`) as 'sumscore'
			from `match results` m
			group by m.`team_Code2`) y on e.`fifa_code` = y.`team_code2`) as e on t.`fifa_code` = e.`fifa_code`;
        
-- total tournaments participated --
select t.`fifa_code`, case when e.`tournmanent_count` is null then "0" else e.`tournmanent_count` end as 'tournmanent_count'
from `teams` t left outer join (select e.`fifa_code`, Count(e.`tournament_id`) as 'tournmanent_count'
	from (select e.`team_code1` as 'fifa_code', e.`tournament_id`
		from `match results` e
		union
		select e.`team_code2` as 'fifa_code', e.`tournament_id`
		from `match results` e) as e
	group by e.`fifa_code`) as e on t.`fifa_code` = e.`fifa_code`;

-- total tournaments won --
select t.`fifa_code`, case when e.`tournmanent_wins` is null then "0" else e.`tournmanent_wins` end as 'tournmanent_wins'
from `teams` t left outer join (select e.`fifa_code`, Count(e.`tournament_id`) as 'tournmanent_wins'
	from (select e.`team_code1` as 'fifa_code', e.`tournament_id`
		from `match results` e
        where e.`round_id` = 1 and (e.`score1` > e.`score2` or e.`penalty_win` = 1)
		union
		select e.`team_code2` as 'fifa_code', e.`tournament_id`
		from `match results` e
        where e.`round_id` = 1 and (e.`score2` > e.`score1` or e.`penalty_win` = 2)) as e
	group by e.`fifa_code`)as e on t.`fifa_code` = e.`fifa_code`;

-- total matches played --
select t.`fifa_code`, case when e.`match_count` is null then "0" else e.`match_count` end as 'match_count'
from `teams` t left outer join (select e.`fifa_code`, Count(e.`id`) as 'match_count'
	from (select e.`team_code1` as 'fifa_code', e.`id`
		from `match results` e
		union
		select e.`team_code2` as 'fifa_code', e.`id`
		from `match results` e) as e
	group by e.`fifa_code`) as e on t.`fifa_code` = e.`fifa_code`;