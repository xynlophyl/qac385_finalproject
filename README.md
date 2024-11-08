# QAC385: FINAL PROJECT 
A school group project utilizing Machine Learning in R to predict a team's match performance in the English Premier League
# Installation

Clone this repository:
```
git clone https://github.com/xynlophyl/qac385_finalproject.git
```

## Development
<br />

### Background

<br />

In soccer, the outcome of a goal is determined by the number of goals scored by the two teams. However, since there are so few goals scored per game in soccer, the number of goals does not tell the whole story of a game and comes with a large amount of randomness and variability. There is always a chance that a bottom team can beat a top team in soccer because even though the top team will generally play at a higher level than the bottom team, the result of a game can be decided by a few critical moments. Sometimes the bottom team is lucky and all these critical moments go in their favor, resulting in an underdog victory. But theoretically, if that game was replayed an infinite amount of times, the probability that the top team would win more often than the bottom team would.

<br/>

The number of goals scored by a team is often inconsistent from game to game and does not provide any context to how the game was played out. Therefore, people have historically used other statistics to describe a soccer game, such as the percentage of time each team had control of the ball, the number of shots each team has, etc. More recently, a metric called Expected Goals, or xG in short, has taken the soccer world by storm. It calculates the probability of a shot resulting in a goal based on a number of variables, including shot location, body part of the shot, and goalkeeper location among many others. By adding up the xG values from all shots attempted by a team in a game, one can obtain an expected value of how many goals the team will score, based on the quality of their scoring chances. Although there still is some pushback on xG from soccer traditionalists, the metric is becoming more and more accepted among the general public and is widely used by professional clubs around the world. According to Stats Perform, one of the leading soccer analytics companies, xG is a more consistent measure of performance than goals scored, since it fluctuates much less from game to game.

<br/>


xG is an incredibly valuable metric, but only takes into account the quality of a team’s scoring opportunities. xG shows us that if a team can consistently create high-quality and quantity shot opportunities and prevent the opposition from doing the same, they will achieve good results over time. However, xG does not provide any context around how a team was able to create good scoring chances. In soccer, there are different playing styles. For example, some teams base their tactic around controlling the ball, and some teams try to defend deep and counterattack. Metrics like xG do not consider these playing styles. A good team will be put up good xG numbers regardless if they are a possession-heavy or a counter-attacking team because that is what makes them good in the first place. But what did these teams do well to allow them to create such good scoring opportunities? This question leads to our **problem statement**:

<br/>

_Can we create a consistent team performance measure in soccer that is based on both qualitative and stylistic elements?_

<br/>

Such a metric could allow us to compare two different good teams. For example, Liverpool’s biggest strength might be their ability to recover the ball high up the field, while Manchester City dominate their opponents with their precise passing game. They are both good, but they have different styles.



### Data Overview

#### Data Structure

Each row represents a team’s statistics in a given match. In a given match, there will be two observations, one for the home team and one for the away team. Our dataframe currently contains 3800 matches from the past 5 seasons of the English Premier League. The range of variables within the data cover a wide variety of statistics that we can use to analyze a team’s match performance, from the team’s attacking output, for instance (shots on target: sot, goal creating actions: gca), as well as defensive actions (tackles won: tklw, post shot expected goals: psxg) and other miscellaneous information (referee, yellow cards: crdy).



#### Variable Descriptions (column: description (additional info [format/type])
    
    season: Soccer season [yyyy_yyyy]
    
    team: Team name [str]
    
    date: Date of match [yy-mm-dd] 
    
    time: Start time of match [hh-mm-ss] 
    
    comp: Soccer league [str]
    
    gameweek: Matchweek of season ['Matchweek' 1-38] 
    
    day: Day of match [ddd]
    
    venue: Home or away game [Home/Away]
    
    result: Outcome of game [W/L] 
    
    gf: Goals for (scored by team in team var column) [int]
    
    ga: Goals against (scored by opponent) [int]
    
    opponent: Opposition team [str]
    
    xg: Expected goals (includes penalties but not penalty shootout) [float]
    
    xga: Expected opposition goals (includes penalties but not penalty shootout) [float]
    
    poss: Possession (calculated as the percentage of passes attempted) [int]
    
    attendance: Number of fans in attendance [int]
    
    captain: Captain of team [str]
    
    formation: Formation structure of team [str]
    
    referee: Referee officiating the game [str]
    
    sh: Number of shots attempted (excluding penalty attempts) [int]
    
    sot: Shots on target (excluding penatlies) [int]
    
    dist: Average shot distance, in yards, from the opposing goal [float]
    
    fk: Shots from free kicks [int]
    
    pkscored: Penalty kicks made [int]
    
    pkatt: Penalty kicks attempted [int]
    
    tkl: Number of players tackled [int]
    
    tklw: Tackles where tackler’s team wins the ball [int]
    
    tklvsdrb: Tackles won against opponent dribbles [int]
    
    attvsdrb: tackles attempted against opponent dribbles [int]
    
    press: Number of times pressuring opposing players, who are in possession of the ball [int]
    
    succ: Number of times possessions gained within five seconds of applying pressure [int]
    
    blocks: Number of times ball is blocked by team [int]
    
    inter: Interceptions of passes attempted by the opposing team [int]
    
    err: Errors leading to a shot by the opposing team [int]
    
    sota: Number of shots on target of goal by opposing team [int]
    
    saves: Number of opposing team's shots saved by the goalie [int]
    
    psxg: Post-Shot Expected Goals (PSxG: expected goals based on how likely the goalkeeper is to save the shot) [float]
    
    pxsg_pm: PSxG - Goals allowed [float]
    
    pass_cmp: Passes Completed [int]
    
    pass_att: Passes Attempted [int]
    
    pass_totdist: Total distance of passes [int]
    
    sca: Shot-creating actions (offensive actions directly leading to a shot) [int]
    
    sca_passlive: Completed live-ball passes that lead to a shot attempt [int]
    
    sca_passdead: Completed dead-ball passes that lead to a shot attempt (i.e. free kicks, corner kicks, kick offs, throw-ins and goal kicks) [int]
    
    sca_drib: Successful dribbles in the build up to a shot attempt [int]
    
    sca_sh: Shots in the build up to another shot attempt [int]
    
    sca_fld: Fouls drawn in the build up to a shot attempt [int]
    
    sca_def: Defensive actions in the build up to a shot attempt [int]
    
    gca: Goal-creating actions (offensive actions directly leading to a goal, such as passes, dribbles, and drawing fouls) [int]
    
    gca_passlive: Completed live passes in the build up to a goal
    
    gca_passdead: Completed dead-ball (includes free kicks, corner kicks, kick offs, throw-ins and goal kicks) passes that lead to a goal [int]
    
    gca_drib: Dribbles completed in the build up to a goal [int]
    
    gca_sh: Shots taken in the build up to a goal [int]
    
    gca_fld: Fouls drawn before a goal was scored [int]
    
    gca_def: Defensive actions that lead to a goal [int]
    
    touches: Total number of touches [int]
    
    touches_defthird: Number of touches in the defending third of the pitch [int]
    
    touches_attthird: Number of touches in the attacking third of the pitch [int]
    
    carries: Total dribbles [int]
    
    carries_totdist: Total distance of dribbles [int]
    
    carries_progdist: Total distance of progressive dribbles [int]
    
    progcarries: Number of progressive (at least 5 yards towards the opponent’s goal) dribbles [int]
    
    progpassrec: Number of progressive (at least 5 yards towards the opponent’s goal) passes successfully received [int]
    
    crdy: Number of yellow card warnings given [int]
    
    crdr: Number of straight red card send offs [int]
    
    twocrdy: Number of two card yellow send offs [int]
    
    fls: Number of fouls committed [int]
    
    fld: Number of fouls given [int]
    
    off: Number of times offside [int]
    
    recov: Number of loose balls recovered [int]
    
    arlWon: Aerial duels won [int]
    
    arlLost: Aerial duels lost [int]

#### Summary Statistics



#### Data Source

    Our dataset was collected using resources provided by Sports Reference’s FBREF database, as well as, StatsBomb. Our group scraped Premier League statistics of the previous 5 seasons from these websites, and collated the data into one large dataframe for use in our project.


## Development Roadmap: Future Plans

