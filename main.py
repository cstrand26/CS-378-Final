from flask import Flask, render_template, request
from flask_sqlalchemy import SQLAlchemy
import pymysql


#innitialize flask object
#connect it to the database using sqlalchemy 
site = Flask(__name__, static_folder="./static")
site.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+mysqlconnector://root:1234@localhost/soccer1'
db = SQLAlchemy(site)


###################################################################################################################################
##
## Define all the functions that will manipulate the SQL quieries by executing them using the inputs from the user
##
###################################################################################################################################

# Notes for SQL queries have been placed on .sql files

#define a function for match results through workbench db
def matchresults(MT_Year, MT_Name, MR_Name, ME_Name, MO_Name, MH_Name, ME_Year, ME_Month, ME_Day):
    db = pymysql.connect(host='localhost', user='root', password='1234', database='soccer1')
    crsr = db.cursor()
    sql = """
        select concat(cast(t.`year` as char), ' ', y.`name`) as 'tournament', (r.`name`) as 'round',
            concat(m.`day`, '/', m.`month`, '/', m.`year`) as 'date',
            case when m.`penalty_win` = 1 then e1.`fifa_code` when m.`penalty_win` = 2 then e2.`fifa_code` 
            when m.`score1` > m.`score2` then e1.`fifa_code` when m.`score2` > m.`score1` then e2.`fifa_code` else "n/a" end as 'winner',
            case when m.`penalty_win` is not null then 'yes' else "no" end as 'penalty_win',
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
        where (y.`name` like %s)
            and (r.`name` like %s)
            and (e1.`fifa_code` like %s or e2.`fifa_code` like %s or e1.`country` like %s or e2.`country` like %s)
            and (o.`name` like %s or o.`code` like %s)
            and (tt.`fifa_code` like %s or tt.`country` like %s)
    """
    #check different parameters for each of the variable that are used to compute in the quiery
    #if the MT_Year variable has nothing in it, check if it is not null or convert it into a int type
    if MT_Year is None:
        sql += """
            and t.`year` is not null
        """
    else:
        try:
            MT_Year = int(MT_Year)
            sql += f"""
                and t.`year` = {MT_Year}
            """
        except (ValueError, TypeError):
            sql += """
                and t.`year` is not null
            """
    #if the ME_Year variable has nothing in it, check if it is not null or convert it into a int type
    if ME_Year is None:
        sql += """
            and m.`year` is not null
        """
    else:
        try:
            ME_Year = int(ME_Year)
            sql += f"""
                and m.`year` = {ME_Year}
            """
        except (ValueError, TypeError):
            sql += """
                and m.`year` is not null
            """
    #if the ME_Month variable has nothing in it, check if it is not null or convert it into a int type
    if ME_Month is None:
        sql += """
            and m.`month` is not null
        """
    else:
        try:
            ME_Month = int(ME_Month)
            sql += f"""
                and m.`month` = {ME_Month}
            """
        except (ValueError, TypeError):
            sql += """
                and m.`month` is not null
            """

    #if the ME_Day variable has nothing in it, check if it is not null or convert it into a int type
    if ME_Day is None:
        sql += """
            and m.`day` is not null
        """
    else:
        try:
            ME_Day = int(ME_Day)
            sql += f"""
                and m.`day` = {ME_Day}
            """
        except (ValueError, TypeError):
            sql += """
                and m.`day` is not null
            """
    sql += """
        order by m.`year`, m.`month`, m.`day`
    """
    #after checking all the parameters, input it into the queries, preventing sequel injection
    #use cursor execute to go over the sequel queries and input from the user
    crsr.execute(sql, [f"%{MT_Name}%", f"%{MR_Name}%", f"%{ME_Name}%", f"%{ME_Name}%", f"%{ME_Name}%", f"%{ME_Name}%", f"%{MO_Name}%", f"%{MO_Name}%", f"%{MH_Name}%", f"%{MH_Name}%"])
    results = crsr.fetchall()
    return results
    #matchresults()

#define a function for teams through workbench db
def teamscalc(ET_Name, EO_Name):
    db = pymysql.connect(host='localhost', user='root', password='1234', database='soccer1')
    crsr = db.cursor()
    sql = """
    select concat(e.`fifa_code`, ' ', e.`country`) as 'country', e.`official_FIFA_name`, e.`nickname`, e.`association`, e.`year_founded`,
        concat(o.`code`, ' ', o.`name`) as 'organization', tc.`tournmanent_count`, tw.`tournmanent_wins`, mc.`match_count`, tp.`sumscore`, lo.`losses`, wp.`penalty_wins`,
        mw.`wins`, mt.`ties`
    from `teams` e join `organizations` o on o.`code` = e.`org_code`
        join (select t.`fifa_code`, case when e.`tournmanent_count` is null then "0" else e.`tournmanent_count` end as 'tournmanent_count'
            from `teams` t left outer join (select e.`fifa_code`, Count(e.`tournament_id`) as 'tournmanent_count'
                from (select e.`team_code1` as 'fifa_code', e.`tournament_id`
                    from `match results` e
                    union
                    select e.`team_code2` as 'fifa_code', e.`tournament_id`
                    from `match results` e) as e
                group by e.`fifa_code`) as e on t.`fifa_code` = e.`fifa_code`) as tc on tc.`fifa_code` = e.`fifa_code`
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
        join (select t.`fifa_code`, case when e.`match_count` is null then "0" else e.`match_count` end as 'match_count'
            from `teams` t left outer join (select e.`fifa_code`, Count(e.`id`) as 'match_count'
                from (select e.`team_code1` as 'fifa_code', e.`id`
                    from `match results` e
                    union
                    select e.`team_code2` as 'fifa_code', e.`id`
                    from `match results` e) as e
                group by e.`fifa_code`) as e on t.`fifa_code` = e.`fifa_code`) as mc on mc.`fifa_code` = e.`fifa_code`
        join (select t.`fifa_code`, case when e.`sumscore` is null then "0" else e.`sumscore` end as 'sumscore'
            from `teams` t left outer join (select e.`fifa_code`, (x.`sumscore` + y.`sumscore`) as 'sumscore'
                from `teams` e left outer join (select m.`team_code1`, Sum(m.`score1`) as 'sumscore' 
                    from `match results` m
                    group by m.`team_code1`) x on e.`fifa_code` = x.`team_code1`
                    left outer join (select m.`team_code2`, Sum(m.`score2`) as 'sumscore'
                        from `match results` m
                        group by m.`team_Code2`) y on e.`fifa_code` = y.`team_code2`) as e on t.`fifa_code` = e.`fifa_code`) as tp on tp.`fifa_code` = e.`fifa_code`
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
    where (e.`country` like %s or e.`fifa_code` like %s or e.`official_FIFA_name` like %s or e.`nickname` like %s or e.`association` like %s)
        and (o.`code` like %s or o.`name` like %s)
    order by e.`fifa_code`
    """ 
    #use cursor execute to go over the sequel queries and input from the user
    #using the brackets, we prevent the sequel injection
    crsr.execute(sql, [f"%{ET_Name}%", f"%{ET_Name}%", f"%{ET_Name}%", f"%{ET_Name}%", f"%{ET_Name}%", f"%{EO_Name}%", f"%{EO_Name}%"])
    results = crsr.fetchall()
    return results
#teamscalc()

#define a function for tournaments through workbench db
def tournamentcalc(TT_Year, TT_Name, TO_Name, TH_Name, TW_Name):
    db = pymysql.connect(host='localhost', user='root', password='1234', database='soccer1')
    crsr = db.cursor()
    sql = """
    select concat(cast(t.year as char), ' ', tt.`name`) as `name`, concat(o.`code`, ' ', o.`name`)as 'host_org', concat(e.`fifa_code`, ' ', e.`country`) as 'host_team',
        mt.`match_total`, w.`tournament_winner`
    from `tournaments` t join `tournament types` tt on t.`type_id` = tt.`type_id`
        join `teams` e on e.`fifa_code` = t.`host_team`
        join `organizations` o on o.`code` = tt.`org_code`
        join (select m.`tournament_id`, Count(m.`id`) as 'match_total'
            from `match results` m
            group by m.`tournament_id`) as mt on mt.`tournament_id` = t.`tournament_id`
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
    where (tt.`name` like %s)
        and (e.`country` like %s or e.`fifa_code` like %s)
        and (o.`code` like %s or o.`name` like %s)
        and (w.`tournament_winner` like %s)
    """

    #if the TT_Year variable has nothing in it, check if it is not null or convert it into a int type
    if TT_Year is None:
        sql += """
            and t.`year` is not null
        """
    else:
        try:
            TT_Year = int(TT_Year)
            sql += f"""
                and t.`year` = {TT_Year}
            """
        except (ValueError, TypeError):
            sql += """
                and t.`year` is not null
            """
    sql += """
        order by t.`year`, tt.`name`
    """

    #after checking all the parameters, input it into the queries, preventing sequel injection
    #use cursor execute to go over the sequel queries and input from the user
    crsr.execute(sql, [f"%{TT_Name}%", f"%{TH_Name}%", f"%{TH_Name}%", f"%{TO_Name}%", f"%{TO_Name}%", f"%{TW_Name}%"])   
    results = crsr.fetchall()
    return results


#define a function for confederations list
def organizations(IO_Name, IP_Name):
    db = pymysql.connect(host='localhost', user='root', password='1234', database='soccer1')
    crsr = db.cursor()
    sql = """
        select concat (o.`code`, ' ', o.`name`) as 'name', concat (s.`par_code`, ' ', s.`par_name`) as 'parent', ot.`team_count`, tc.`tournament_count`
        from `organizations` o
            join (select o.`code`, case when s.`code` is null then "n" else s.`code` end as 'par_code', case when s.`name` is null then "a" else s.`name` end as 'par_name'
                from `organizations` o left outer join `organizations` s on o.`sup_code` = s.`code`) as s on o.`code` = s.`code`
            join (select o.`code`, case when o.`team_count` is null then '0' else o.`team_count` end as 'team_count'
                from(select o.`code`, Count(t.`fifa_code`) as 'team_count'
                    from organizations o left outer join teams t on o.`code` = t.`org_code`
                    group by o.`code`) as o) as ot on ot.`code` = o.`code`
            join (select o.`code`, case when t.`tournament_count` is null then '0' else t.`tournament_count` end as 'tournament_count'
                from `organizations` o left outer join (select tt.`org_code`, Count(t.`tournament_id`) as 'tournament_count'
                    from `tournament types` tt join `tournaments` t on t.`type_id` = tt.`type_id`
                    group by tt.`org_code`) as t on o.`code` = t.`org_code`) as tc on tc.`code` = o.`code`
        where (o.`code` like %s or o.`name` like %s)
            and (s.`par_code` like %s or s.`par_name` like %s)
        order by o.`sup_code`, o.`code`
        """
    
    #use cursor execute to go over the sequel queries and input from the user
    #using the brackets, we prevent the sequel injection
    crsr.execute(sql, [f"%{IO_Name}%", f"%{IO_Name}%", f"%{IP_Name}%", f"%{IP_Name}%"])        
    results = crsr.fetchall()
    return results


###################################################################################################################################
##
## Define the routes and the database output to the website based on the search of the user
##
###################################################################################################################################

#create a Teams class where we specify the type of each attribute and its nature (primary or foreign)
class Teams(db.Model):
    FIFA_Code = db.Column(db.String(3), primary_key=True)
    Country = db.Column(db.String(50), nullable=False)
    Official_FIFA_Name = db.Column(db.String(50), nullable=False)
    Nickname = db.Column(db.String(50), nullable=True)
    Association = db.Column(db.String(100), nullable=True)
    Org_Code = db.Column(db.String(10), nullable=True)
    Year_Founded = db.Column(db.Integer, nullable=True)
   


#add route to index (homepage website)
#define a function index
#get the input from the user on the website from the search bar
#create a list headers of the attributes
#using the dictionary, we use it to iterate over the database and output it into the website saving it in org_list 
@site.route('/', methods = ['GET', 'Post'])
def index():
    if request.method == 'POST':        
        IO_Name = request.form.get('IO.Name')
        IP_Name = request.form.get('IP.Name')
        results = organizations(IO_Name, IP_Name)
        org_list = []
        headers = ["name", "parent", "team_count", "tournament_count"]
        dic = {}
        for result in results:
            for i in range(len(headers)):
                dic[headers[i]] = result[i]
            org_list.append(dic)
            dic = {}
        #Go to page
        return render_template('index.html', response = org_list)
    #Go to page and return the output of the filtered search
    return render_template('index.html', response=[])


#add route to teams (teams website)
#define a function teams
#get the input from the user on the website from the search bar
#create a list headers of the attributes
#using the dictionary, we use it to iterate over the database and output it into the website saving it in teams_list for the search
#the teams_data is for the output of all the teams using the Teams class 
@site.route('/teams', methods = ['GET', 'Post'])
def teams():
    teams_data = Teams.query.all()
    if request.method == 'POST':
        ET_Name = request.form.get('ET.Name')
        EO_Name = request.form.get('EO.Name')
        results = teamscalc(ET_Name, EO_Name)
        team_list = []
        headers = ["country", "official_FIFA_name", "nickname", "association", "year_founded", "organization", "tournament_count", "tournament_wins", "match_count", "sumscore", "losses", "penalty_wins", "wins", "ties"]
        dic = {}
        for result in results:
            for i in range(len(headers)):
                dic[headers[i]] = result[i]
            team_list.append(dic)
            dic = {}
            #Go to page 
        return render_template('teams.html', teams = teams_data, response = team_list)  
    #Go to page and return the output of the filtered search
    return render_template('teams.html', teams = teams_data, response = [])  

#add route to scoreboard (team results)
#define a function scoreboard
#get the input from the user on the website from the search bar
#create a list headers of the attributes
#using the dictionary, we use it to iterate over the database and output it into the website saving it in match_list for the search
@site.route('/scoreboard', methods = ['GET', 'Post'])
def scoreboard():
    if request.method == 'POST':
        MT_Year = request.form.get('MT.Year')
        MT_Name = request.form.get('MT.Name')
        MR_Name = request.form.get('MR.Name')
        ME_Name = request.form.get('ME.Name')
        MO_Name = request.form.get('MO.Name')
        MH_Name = request.form.get('MH.Name')
        ME_Year = request.form.get('ME.Year')
        ME_Month = request.form.get('ME.Month')
        ME_Day = request.form.get('ME.Day')
        results = matchresults(MT_Year, MT_Name, MR_Name, ME_Name, MO_Name, MH_Name, ME_Year, ME_Month, ME_Day)
        match_list = []
        headers = ["tournament", "round", "date", "winner", "penalty_win", "team_1", "score_1", "score_2", "team_2", "host_org", "host_team"]
        dic = {}
        for result in results:
            for i in range(len(headers)):
                dic[headers[i]] = result[i]
            match_list.append(dic)
            dic = {}
        #Go to page 
        return render_template('scores.html', response = match_list)
    #Go to page and return the output of the filtered search
    return render_template('scores.html', responses = [])

#add route to tournaments (tournaments)
#define a function scoreboard
#get the input from the user on the website from the search bar
#create a list headers of the attributes
#using the dictionary, we use it to iterate over the database and output it into the website saving it in tour)list for the search
@site.route('/tournaments', methods = ['GET', 'POST'])
def tournaments():
    if request.method == 'POST':
        TT_Year = request.form.get('TT.Year')
        TT_Name = request.form.get('TT.Name')
        TO_Name = request.form.get('TO.Name')
        TH_Name = request.form.get('TH.Name')
        TW_Name = request.form.get('TW.Name')
        results = tournamentcalc(TT_Year, TT_Name, TO_Name, TH_Name, TW_Name)
        tour_list = []
        headers = ["name", "host_org", "host_team", "math_total", "tournament_winner"]
        dic = {}
        for result in results:
            for i in range(len(headers)):
                dic[headers[i]] = result[i]
            tour_list.append(dic)
            dic = {}
        #Go to page
        return render_template('tournaments.html', response = tour_list)
    #Go to page and return the output of the filtered search
    return render_template('tournaments.html', responses = [])

#add route to pete (pete website)
#define the function where it takes the user to that website
@site.route('/pete')
def pete():
    #Go to page
    return render_template('pete.html')

#Run site
#host it in the local host server
if __name__ == "__main__":
    site.run(host="0.0.0.0", port=80)



    