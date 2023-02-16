#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

random_number=$(( ( RANDOM % 1000 )  + 1 ))
echo "Enter your username:"
read USERNAME
echo $random_number
number_of_guesses=0

CORRECT(){
  if [[ $GUESS = $random_number ]]
then
((number_of_guesses++))
echo "You guessed it in $number_of_guesses tries. The secret number was $random_number. Nice job!"
if [[ $best_game_info -lt $number_of_guesses  ]]
then
new_record=$(( $games_played_info + 1 ))
INSERT_DATA=$($PSQL "UPDATE info set best_game=$number_of_guesses ,games_played=$new_record where info.username='$USERNAME'")
fi
fi
}

QUESTIONS(){
if [[ ! $GUESS =~ ^[0-9]+$ ]]
then
echo "That is not an integer, guess again:"
read GUESS
else 
if [[ $GUESS -lt $random_number ]]
then
echo  "It's higher than that, guess again:"
((number_of_guesses++))
elif [[ $GUESS -gt $random_number ]]
then
echo "It's lower than that, guess again:"
((number_of_guesses++))
fi
read GUESS
CORRECT
fi
}

LOOP(){
  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  CORRECT
  while [[ ! $GUESS = $random_number ]]
  do
  QUESTIONS
  done
}

if [[ ! ${#USERNAME} -lt 22 ]]
then
echo "username must be less than 22 characters"
else
username_info=$($PSQL "select username from info where username='$USERNAME'")
if [[ -z $username_info ]]
then
echo Welcome, $USERNAME! It looks like this is your first time here.
INSERT_USERNAME=$($PSQL "insert into info(username,games_played,best_game) values('$USERNAME',0,0)")
games_played_info=$($PSQL "select games_played from info where username='$USERNAME'")
best_game_info=$($PSQL "select best_game from info where username='$USERNAME'")
else
games_played_info=$($PSQL "select games_played from info where username='$USERNAME'")
best_game_info=$($PSQL "select best_game from info where username='$USERNAME'")

echo "Welcome back, $USERNAME! You have played $games_played_info games, and your best game took $best_game_info guesses."
fi
LOOP
fi
