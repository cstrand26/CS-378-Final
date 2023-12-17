use `soccer1`;

select concat(e.`fifa_code`, ' ', e.`country`) as 'country', e.`official_FIFA_name`, e.`nickname`, e.`association`, e.`year_founded`,
	concat(o.`code`, ' ', o.`name`) as 'organization', tc.`tournmanent_count`, tw.`tournmanent_wins`, mc.`match_count`, tp.`sumscore`, lo.`losses`, wp.`penalty_wins`,
    mw.`wins`, mt.`ties`
from `teams` e join `organizations` o on o.`code` = e.`org_code`
	-- returns count of tournaments in which team played in at least 1 match
	join (select t.`fifa_code`, case when e.`tournmanent_count` is null then "0" else e.`tournmanent_count` end as 'tournmanent_count'
		from `teams` t left outer join (select e.`fifa_code`, Count(e.`tournament_id`) as 'tournmanent_count'
			from (select e.`team_code1` as 'fifa_code', e.`tournament_id`
				from `match results` e
				union
				select e.`team_code2` as 'fifa_code', e.`tournament_id`
				from `match results` e) as e
			group by e.`fifa_code`) as e on t.`fifa_code` = e.`fifa_code`) as tc on tc.`fifa_code` = e.`fifa_code`
	-- returns count of tournaments in which team won the final match
	join (select t.`fifa_code`, case when e.`tournmanent_wins` is null then "0" else e.`tournmanent_wins` end as 'tournmanent_wins'
		from `teams` t left outer join (select e.`fifa_code`, Count(e.`tournament_id`) as 'tournmanent_wins'
			from (select e.`team_code1` as 'fifa_code', e.`tournament_id`
				from `match results` e
				where e.`round_id` = 1 and (e.`score1` > e.`score2` or e.`penalty_win` = 1)
				union
				select e.`team_code2` as 'fifa_code', e.`tournament_id`
				from `match results` e
				where e.`round_id` = 1 and (e.`score2` > e.`score1` or e.`penalty_win` = 2)) as e
			group by e.`fifa_code`)as e on t.`fifa_code` = e.`fifa_code`) as tw on tw.`fifa_code` = e.`fifa_code`
	-- returns count of matches team played in
	join (select t.`fifa_code`, case when e.`match_count` is null then "0" else e.`match_count` end as 'match_count'
		from `teams` t left outer join (select e.`fifa_code`, Count(e.`id`) as 'match_count'
			from (select e.`team_code1` as 'fifa_code', e.`id`
				from `match results` e
				union
				select e.`team_code2` as 'fifa_code', e.`id`
				from `match results` e) as e
			group by e.`fifa_code`) as e on t.`fifa_code` = e.`fifa_code`) as mc on mc.`fifa_code` = e.`fifa_code`
	-- return sum of goals scored by team accross all matches
	join (select t.`fifa_code`, case when e.`sumscore` is null then "0" else e.`sumscore` end as 'sumscore'
		from `teams` t left outer join (select e.`fifa_code`, (x.`sumscore` + y.`sumscore`) as 'sumscore'
			from `teams` e left outer join (select m.`team_code1`, Sum(m.`score1`) as 'sumscore' 
				from `match results` m
				group by m.`team_code1`) x on e.`fifa_code` = x.`team_code1`
				left outer join (select m.`team_code2`, Sum(m.`score2`) as 'sumscore'
					from `match results` m
					group by m.`team_Code2`) y on e.`fifa_code` = y.`team_code2`) as e on t.`fifa_code` = e.`fifa_code`) as tp on tp.`fifa_code` = e.`fifa_code`
	-- returns count of matches team lost
	join (select t.`fifa_code`, case when e.`losses` is null then "0" else e.`losses` end as 'losses'
		from `teams` t left outer join (select e.`fifa_code`, (x.`losses` + y.`losses`) as 'losses'
			from `teams` e left outer join (select m.`team_code1`, Count(*) as 'losses'
				from `match results` m
				where m.`score1` < m.`score2` or m.`penalty_win` = 2
				group by m.`team_code1`) x on e.`fifa_code` = x.`team_code1`
				left outer join (select m.`team_code2`, count(*) as 'losses'
					from `match results` m
					where m.`score2` < m.`score1` or m.`penalty_win` = 1
					group by m.`team_code2`) y on e.`fifa_code` = y.`team_code2`) as e on t.`fifa_code` = e.`fifa_code`) as lo on lo.`fifa_code` = e.`fifa_code`
	-- returns count of matches team won, but only by penalty kick
	join (select t.`fifa_code`, case when e.`penalty_wins` is null then "0" else e.`penalty_wins` end as 'penalty_wins'
		from `teams` t left outer join (select e.`fifa_code`, (x.`wins` + y.`wins`) as 'penalty_wins'
			from `teams` e left outer join (select m.`team_code1`, Count(*) as 'wins'
				from `match results` m
				where m.`penalty_win` = 1
				group by m.`team_code1`) x on e.`fifa_code` = x.`team_code1`
				left outer join (select m.`team_code2`, count(*) as 'wins'
					from `match results` m
					where m.`penalty_win` = 2
					group by m.`team_code2`) y on e.`fifa_code` = y.`team_code2`) as e on t.`fifa_code` = e.`fifa_code`) as wp on wp.`fifa_code` = e.`fifa_code`
	-- returns count of matches team won
	join (select t.`fifa_code`, case when e.`wins` is null then "0" else e.`wins` end as 'wins'
		from `teams` t left outer join (select e.`fifa_code`, (x.`wins` + y.`wins`) as 'wins'
			from `teams` e left outer join (select m.`team_code1`, Count(*) as 'wins'
				from `match results` m
				where m.`score1` > m.`score2` or m.`penalty_win` = 1
				group by m.`team_code1`) x on e.`fifa_code` = x.`team_code1`
				left outer join (select m.`team_code2`, count(*) as 'wins'
					from `match results` m
					where m.`score2` > m.`score1` or m.`penalty_win` = 2
					group by m.`team_code2`) y on e.`fifa_code` = y.`team_code2`) as e on t.`fifa_code` = e.`fifa_code`) as mw on mw.`fifa_code` = e.`fifa_code`
	-- return count of matches team tied that did not determine a winner by penalty kick
	join (select t.`fifa_code`, case when e.`ties` is null then "0" else e.`ties` end as 'ties'
		from `teams` t left outer join (select e.`fifa_code`, (x.`ties` + y.`ties`) as 'ties'
			from `teams` e left outer join (select m.`team_code1`, Count(*) as 'ties'
				from `match results` m
				where m.`score1` = m.`score2` and m.`penalty_win` is null
				group by m.`team_code1`) x on e.`fifa_code` = x.`team_code1`
				left outer join (select m.`team_code2`, count(*) as 'ties'
					from `match results` m
					where m.`score2` = m.`score1` and m.`penalty_win` is null
					group by m.`team_code2`) y on e.`fifa_code` = y.`Team_Code2`) as e on t.`fifa_code` = e.`fifa_code`) as mt on mt.`fifa_code` = e.`fifa_code`
where (e.`country` like '%%' or e.`fifa_code` like '%%' or e.`official_FIFA_name` like "%%" or e.`nickname` like "%%" or e.`association` like "%%") -- lookup by team name
	and o.`code` like '%%' -- lookup by organization fifa_code
    and o.`name` like '%%' -- lookup by organization name
order by e.`fifa_code` --  order by teams FIFA code
;
		