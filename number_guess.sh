#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"
# generates a random number between 1 and 1000
MAGIC_NUMBER=$(( RANDOM % 1000 + 1 ))
ATUAL_GUESSING_ATTEMPTS=1
IS_FIRST_GAME=false
# max integer value
PLAYER_BEST_GAME=$(( 2**63 - 1 ))

START_GAME() {
  # get player info
  PLAYER_INFO_RESULT=$($PSQL "SELECT username, games_played, best_game FROM games WHERE username = '$1'")

  # if no player info
  if [[ -z $PLAYER_INFO_RESULT ]]
  then
    # insert new player
    INSERT_PLAYER_INFO=$($PSQL "INSERT INTO games(username) VALUES('$1')")
    # get new player info
    PLAYER_INFO_RESULT=$($PSQL "SELECT username, games_played, best_game FROM games WHERE username = '$1'")
    IS_FIRST_GAME=true
  fi

  PLAYER_INFO_RESULT=$(echo $PLAYER_INFO_RESULT | sed 's/ //g')
  echo $PLAYER_INFO_RESULT | while IFS="|" read PLAYER_USERNAME GAMES_PLAYED BEST_GAME
  do
    if [[ $BEST_GAME -gt 0 && $BEST_GAME -lt $PLAYER_BEST_GAME ]]
    then
      PLAYER_BEST_GAME=$BEST_GAME
    fi

    if $IS_FIRST_GAME
    then
      echo "Welcome, $PLAYER_USERNAME! It looks like this is your first time here."
    else
      echo "Welcome back, $PLAYER_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    fi

    PLAY $PLAYER_USERNAME $PLAYER_BEST_GAME
  done
}

PLAY() {
  echo $1 $2
}

echo "Enter your username:"
read USERNAME

while [[ -z $USERNAME || ! $USERNAME =~ ^[a-zA-Z0-9]{2,22}$ ]]
do
  echo "Invalid input. Please, provide a valid username:"
  read USERNAME
done

START_GAME $USERNAME
