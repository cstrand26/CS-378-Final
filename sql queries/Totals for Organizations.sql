-- individual total creating queries that were used in "Organizations by Criteria"
use `soccer1`;
-- teams in organization --
select o.`code`, case when o.`team_count` is null then '0' else o.`team_count` end as 'team_count'
from(select o.`code`, Count(t.`fifa_code`) as 'team_count'
	from organizations o left outer join teams t on o.`code` = t.`org_code`
    group by o.`code`) as o;
-- tournaments hosted by organization --
select o.`code`, case when t.`tournament_count` is null then '0' else t.`tournament_count` end as 'tournament_count'
		from `organizations` o left outer join (select tt.`org_code`, Count(t.`tournament_id`) as 'tournament_count'
			from `tournament types` tt join `tournaments` t on t.`type_id` = tt.`type_id`
			group by tt.`org_code`) as t on o.`code` = t.`org_code`;