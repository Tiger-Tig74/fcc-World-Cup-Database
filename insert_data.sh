#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
$PSQL "TRUNCATE teams, games;"

cat games.csv | tail -n +2 | while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
  
  # Check if winner is already in teams table
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  
  # If not found, insert into teams table
  if [[ -z $WINNER_ID ]]; then
    insert_WINNER_result=$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER')")
    if [[ $insert_WINNER_result == "INSERT 0 1" ]]; then
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      echo "Inserted team: $WINNER"
    fi
  fi

  # Check if opponent is already in teams table
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  # If not found, insert into teams table
  if [[ -z $OPPONENT_ID ]]; then
    insert_OPPONENT_result=$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT')")
    if [[ $insert_OPPONENT_result == "INSERT 0 1" ]]; then
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      echo "Inserted team: $OPPONENT"
    fi
  fi

  # Insert the game data into the games table
  if [[ -n $WINNER_ID && -n $OPPONENT_ID ]]; then
    insert_result=$($PSQL "INSERT INTO games (YEAR, ROUND, WINNER_ID, OPPONENT_ID, WINNER_GOALS, OPPONENT_GOALS) VALUES ('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")
    
    # Check if insertion was successful
    if [[ $insert_result == "INSERT 0 1" ]]; then
      echo "Inserted game: $YEAR, $ROUND, $WINNER vs $OPPONENT"
    fi
  fi

done