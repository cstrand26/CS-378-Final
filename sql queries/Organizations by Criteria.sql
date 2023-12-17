use `soccer1`;

select concat (o.`code`, ' ', o.`name`) as 'name', concat (s.`par_code`, ' ', s.`par_name`) as 'parent', ot.`team_count`, tc.`tournament_count`
from `organizations` o
	-- joins organization to itself on code and sup_code, outputting "n a" if an organizations sup_code is "null"
	join (select o.`code`, case when s.`code` is null then "n" else s.`code` end as 'par_code', case when s.`name` is null then "a" else s.`name` end as 'par_name'
		from `organizations` o left outer join `organizations` s on o.`sup_code` = s.`code`) as s on o.`code` = s.`code`
	-- returns count of teams with organization as their parent
	join (select o.`code`, case when o.`team_count` is null then '0' else o.`team_count` end as 'team_count'
		from(select o.`code`, Count(t.`fifa_code`) as 'team_count'
			from organizations o left outer join teams t on o.`code` = t.`org_code`
			group by o.`code`) as o) as ot on ot.`code` = o.`code`
	-- returns count of tournaments with organization as their host
	join (select o.`code`, case when t.`tournament_count` is null then '0' else t.`tournament_count` end as 'tournament_count'
		from `organizations` o left outer join (select tt.`org_code`, Count(t.`tournament_id`) as 'tournament_count'
			from `tournament types` tt join `tournaments` t on t.`type_id` = tt.`type_id`
			group by tt.`org_code`) as t on o.`code` = t.`org_code`) as tc on tc.`code` = o.`code`
where (o.`code` like '%%' or o.`name` like '%%') -- organization's name or FIFA code
	and (s.`par_code` like '%%' or s.`par_name` like '%%') -- parent organization's name or FIFA code
order by o.`sup_code`, o.`code` -- order by parent organization FIFA code, then organization FIFA code
;