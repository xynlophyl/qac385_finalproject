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



#### Variable Descriptions

    - season: Soccer Season (year)
    - team: Team Name 
    - date: Date of match 
    - time: Start time of match 
    - comp: Soccer league  
    - gameweek: Matchweek of season (numerical) 
    - day: Day of match 
    - venue: Home or away game 
    - result: Outcome of game (W/L) 
    - gf: Goals for (scored by team in team var column) 
    - ga: Goals against (scored by opponent)
    - opponent: Opposition team
    - xg: Expected goals (includes penalties but not penalty shootout) 
    - xga: Expected opposition goals (includes penalties but not penalty shootout) 
    - poss: Possession (calculated as the percentage of passes attempted) 
    - attendance: number of fans in attendance
    - captain: captain of team
    - formation: Formation style of team
    - referee: Referee ruling the game
    - sh: Shots total (does not include penalties)
    - sot: Shots on target (shots on target do not include penalty kicks)
    - dist: Average distance, in yards, from goal of all shots taken (Minimum 0.395 shots per squad game to qualify as a leader, does not include penalty kicks) 
    - fk: Shots from free kicks 
    - pkscored: Penalty kicks made
    - pkatt: Penalty kicks attempted 
    - tkl: Number of players tackled 
    - tklw: Tackles in which tackler’s team won possession of the ball
    - tklvsdrb: Tackles won against opponent dribbles
    - attvsdrb: tackles attempted against opponent dribbles
    - press: Number of times applying pressure to opposing player who is receiving, carrying or releasing the ball 
    - succ: Number of times the squad gained possession within five seconds of applying pressure 
    - blocks: Number of times blocking the ball by standing in its path 
    - inter: Interceptions 
    - err: Mistakes leading to an opponent’s shot 
    - sota: Number of times blocking a shot by standing in its path 
    - saves: Number of times blocking a shot that was on target, by standing in its path 
    - psxg: Post-Shot Expected Goals (PSxG is expected goals based on how likely the goalkeeper is to save the shot) 
    - pxsg_pm: Psxg - Goals allowed
    - pass_cmp: Completed passes 
    - pass_att: Attempted Passes 
    - pass_totdist: Total distance of passes in a game 
    - sca: Shot-creating actions (the two offensive actions directly leading to a shot) 
    - sca_passlive: Completed live-ball passes that lead to a shot attempt 
    - sca_passdead: Completed dead-ball passes that lead to a shot attempt (includes free kicks, corner kicks, kick offs, throw-ins and goal kicks) 
    - sca_drib: Successful dribbles that lead to a shot attempt 
    - sca_sh: Shots that lead to another shot attempt 
    - sca_fld: Fouls drawn that lead to a shot attempt 
    - sca_def: Defensive actions that lead to a shot attempt 
    - gca: Goal-creating actions (the two offensive actions directly leading to a goal, such as passes, dribbles, and drawing fouls)
    - gca_passlive: Completed live passes in the build up to a goal
    - gca_passdead: Completed dead-ball (includes free kicks, corner kicks, kick offs, throw-ins and goal kicks) passes that lead to a goal 
    - gca_drib: Dribbles completed in the build up to a goal
    - gca_sh: Shots taken in the build up to a goal
    - gca_fld: Fouls drawn before a goal was scored
    - gca_def: Defensive actions that lead to a goal
    - touches: Total number of touches
    - touches_defthird: Number of touches in the defending third of the pitch
    - touches_attthird: Number of touches in the attacking third of the pitch
    - carries: Total dribbles
    - carries_totdist: Total distance of dribbles
    - carries_progdist: Total distance of progressive dribbles
    - progcarries: Number of progressive (at least 5 yards towards the opponent’s goal) dribbles
    - progpassrec: Number of progressive passes successfully received
    - crdy: Number of yellow card warnings given
    - crdr: Number of straight red card send offs
    - twocrdy: Number of two card yellow send offs
    - fls: Number of fouls committed
    - fld: Number of fouls given
    - off: Number of times offside
    - recov: Number of loose balls recovered
    - arlWon: Aerial duels Won
    - arlLost: Aerial duels lost

#### Summary Statistics



#### Data Source

    Our dataset was collected using resources provided by Sports Reference’s FBREF database, as well as, StatsBomb. Our group scraped Premier League statistics of the previous 5 seasons from these websites, and collated the data into one large dataframe for use in our project.

####




## Development Roadmap: Future Plans

