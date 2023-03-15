#!/bin/bash
 PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

INPUT() {
  # check the input 
if [[ -z $1 ]]
  then
    echo "Please provide an element as an argument."
  elif [[ $1 =~ ^[0-9]+[a-Z] || $1 =~ ^[a-Z]+[0-9] ]]
  then 
      echo "I could not find that element in the database."
  elif [[ $1 =~ [0-9]+ ]]
  then
    NUMBER $1
  elif [[ $1 =~ [a-z] || $1 =~ [A-Z] ]]
  then 
    STRING $1
fi
}
# if variable 1 is a number
NUMBER() {

  ATOMIC_NUMBER=$($PSQL "select atomic_number from elements where atomic_number=$1")
  if [[ -z $ATOMIC_NUMBER ]]
  then
      echo "I could not find that element in the database."
  else 
    NAME=$($PSQL "select name from elements where atomic_number=$ATOMIC_NUMBER")
    SYMBOL=$($PSQL "select symbol from elements where atomic_number=$ATOMIC_NUMBER")
    GET_SECONDARY
  fi
}

STRING() {
  SYMBOL=$($PSQL "select symbol from elements where symbol='$1'")
  if [[ -z $SYMBOL ]]
  then 
    NAME=$($PSQL "select name from elements where name='$1'")
    if [[ -z $NAME ]]
    then 
      echo "I could not find that element in the database."
    else
    SYMBOL=$($PSQL "select symbol from elements where name='$NAME'")
    ATOMIC_NUMBER=$($PSQL "select atomic_number from elements where name='$NAME'")
    GET_SECONDARY
    fi
  else 
    ATOMIC_NUMBER=$($PSQL "select atomic_number from elements where symbol='$1'")
    NAME=$($PSQL "select name from elements where symbol='$1'")
    GET_SECONDARY
  fi

}

GET_SECONDARY() {
  TYPE=$($PSQL "select type from types inner join properties using(type_id) where atomic_number=$ATOMIC_NUMBER")
  MASS=$($PSQL "select atomic_mass from properties where atomic_number=$ATOMIC_NUMBER")
  MELTING_POINT=$($PSQL "select melting_point_celsius from properties where atomic_number=$ATOMIC_NUMBER")
  BOILING_POINT=$($PSQL "select boiling_point_celsius from properties where atomic_number=$ATOMIC_NUMBER")
PRINT_ELEMENT
}


PRINT_ELEMENT() {
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."

}

INPUT $1

