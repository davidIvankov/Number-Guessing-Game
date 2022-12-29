#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER_GUESS() {
  if [[ -z $GUESS ]]
  then
  SECRET_NUMBER=$(( $RANDOM % 1000 + 1))
echo "Guess the secret number between 1 and 1000:"
read GUESS
if [[ $GUESS =~ ^[-+]?([0-9][[:digit:]]*|0)$  &&  $GUESS -gt 0 ]]
then
TRIES=1
if [[ $GUESS > $SECRET_NUMBER ]]
then
echo "It's lower than that, guess again:"
NUMBER_GUESS
elif [[ $GUESS < $SECRET_NUMBER ]]
then
echo  "It's higher than that, guess again:"
NUMBER_GUESS
elif [[ $GUESS == $SECRET_NUMBER ]]
then
BEST_RESULT_RESULTS=$($PSQL"UPDATE results SET best_game=1 WHERE user_id=$USER_ID")
echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
fi
else
echo "That is not an integer, guess again:"
NUMBER_GUESS
fi
else
read GUESS
if [[ $GUESS =~ ^[-+]?([0-9][[:digit:]]*|0)$ && $GUESS -gt 0 ]]
then
TRIES=$(($TRIES + 1))
if [[ $GUESS < $SECRET_NUMBER ]]
then
echo "It's higher than that, guess again:"
NUMBER_GUESS
elif [[ $GUESS > $SECRET_NUMBER ]]
then
echo "It's lower than that, guess again:"
NUMBER_GUESS
elif [[ $GUESS == $SECRET_NUMBER ]]
then
GAMES_PLAYED_RESULT=$($PSQL"UPDATE users SET games_played=games_played + 1 WHERE name='$NAME'")
GAMES_PLAYED=$($PSQL"SELECT games_played FROM users WHERE user_id=$USER_ID")
BEST_RESULT=$($PSQL"SELECT MIN(best_game) FROM results WHERE user_id=$USER_ID")
RESULTS_RESULT=$($PSQL"INSERT INTO results(user_id,best_game) VALUES($USER_ID,$TRIES)")
echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
fi

else
echo "That is not an integer, guess again:"
NUMBER_GUESS
fi
fi
}
echo "Enter your username:"
read NAME
USER_ID=$($PSQL"SELECT user_id FROM users WHERE name='$NAME'")
if [[ -z $USER_ID ]]
then
INSERT_USER_RESULT=$($PSQL"INSERT INTO users(name, games_played) VALUES('$NAME', 0)")
USER_ID=$($PSQL"SELECT user_id FROM users WHERE name='$NAME'")
echo "Welcome, $NAME! It looks like this is your first time here."
NUMBER_GUESS
else
GAMES_PLAYED=$($PSQL"SELECT games_played FROM users WHERE user_id=$USER_ID")
BEST_GAME=$($PSQL"SELECT MIN(best_game) FROM results WHERE user_id=$USER_ID")
echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
NUMBER_GUESS
fi
