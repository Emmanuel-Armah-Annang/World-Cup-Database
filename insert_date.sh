#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

$PSQL "TRUNCATE games,teams RESTART IDENTITY"

declare -A inserted_teams

tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Insert WINNER team if not already inserted
  if [[ -z ${inserted_teams["$WINNER"]} ]]
  then
   $PSQL "INSERT INTO teams(name) VALUES('$WINNER')"
    echo "Inserted: $WINNER"
    inserted_teams["$WINNER"]=1
  fi

  # Insert OPPONENT team if not already inserted
  if [[ -z ${inserted_teams["$OPPONENT"]} ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')"
    echo "Inserted: $OPPONENT"
    inserted_teams["$OPPONENT"]=1
  fi

  #get winner_id
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

  #get opponent_id
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  
  #Insert all matches
  INSERT_ALL_ROUNDS=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES('$YEAR','$ROUND','$WINNER_ID','$OPPONENT_ID','$WINNER_GOALS','$OPPONENT_GOALS')")
  if [[ $INSERT_ALL_ROUNDS == "INSERT 0 1" ]]
  then 
      echo Inserted into games, $ROUND
  fi
done
