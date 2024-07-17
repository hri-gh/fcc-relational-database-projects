#! /bin/bash

if [[ $1 == "test" ]]
then
    PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
    PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
    # Skip the header row
    if [[ $YEAR != "year" ]]
    then
        # get team_id
        TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

        # if not found
        if [[ -z $TEAM_ID ]]
        then
            # insert team
            INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
            if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
            then
                echo Inserted into teams, $WINNER
            fi

        fi

        # get team_id
        TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

        # if not found
        if [[ -z $TEAM_ID ]]
        then
            # insert team
            INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
            if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
            then
                echo Inserted into teams, $OPPONENT
            fi

        fi
    fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
    if [[ $YEAR != "year" ]]
    then
        # get team_id
        WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")


        # get team_id
        OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")


        # insert games data
        INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
        if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
        then
            echo "Inserted into games: $YEAR, $ROUND, $WINNER, $OPPONENT",
        fi
    fi
done

