#!/bin/bash

# Check if the script is running in test mode or production mode
if [[ $1 == "test" ]]
then
    PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
    PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Truncate the existing data in the tables
echo $($PSQL "TRUNCATE games, teams RESTART IDENTITY")

# Read the CSV file and insert data
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
    # Skip the header row
    if [[ $YEAR != "year" ]]
    then
        # Insert unique teams into the teams table
        for TEAM in "$WINNER" "$OPPONENT"
        do
            TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")
            if [[ -z $TEAM_ID ]]
            then
                INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$TEAM')")
                if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
                then
                    echo "Inserted into teams: $TEAM"
                fi
            fi
        done

        # Get the team_ids for the winner and opponent
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

        # Insert the game data into the games table
        INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
        if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
        then
            echo "Inserted into games: $YEAR, $ROUND, $WINNER vs $OPPONENT"
        fi
    fi
done
