#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"
# generates a random number between 1 and 1000
MAGIC_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "secret number: $MAGIC_NUMBER"
ATUAL_GUESSING_ATTEMPTS=0
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
  IFS="|" read PLAYER_USERNAME GAMES_PLAYED BEST_GAME <<< $PLAYER_INFO_RESULT
  
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
}

PLAY() {
  echo "Guess the secret number between 1 and 1000:"

  USER_GUESS=0
  while [[ $USER_GUESS != $MAGIC_NUMBER ]]
  do
    USER_GUESS=$(GET_USER_GUESS)
    (( ATUAL_GUESSING_ATTEMPTS++ ))
    echo "New user input: $USER_GUESS, attempt $ATUAL_GUESSING_ATTEMPTS"
  done
}

GET_USER_GUESS() {
  read USER_INPUT
  
  while [[ -z $USER_INPUT || ! $USER_INPUT =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read USER_INPUT
  done

  echo $USER_INPUT
}

echo "Enter your username:"
read USERNAME

while [[ -z $USERNAME || ! $USERNAME =~ ^[a-zA-Z0-9_]{1,22}$ ]]
do
  echo "Invalid input. Please, provide a valid username:"
  read USERNAME
done

START_GAME $USERNAME
