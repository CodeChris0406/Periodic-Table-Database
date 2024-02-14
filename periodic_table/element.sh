#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# Input validation
if [ "$#" -ne 1 ]; then
    echo "Please provide an element as an argument."
exit
fi

# Determine the type of the input
if [[ $1 =~ ^[0-9]+$ ]]; then
    QUERY_CONDITION="e.atomic_number = $1"
elif [[ $1 =~ ^[A-Za-z]+$ ]]; then
    # Check if input length is 1 or 2 for symbol, otherwise treat as name
    if [ ${#1} -le 2 ]; then
        QUERY_CONDITION="e.symbol ILIKE '$1'"
    else
        QUERY_CONDITION="e.name ILIKE '$1'"
    fi
else
    echo "I could not find that element in the database."
    exit 1
fi

# Fetch element details from the database
ELEMENT_DETAILS=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type FROM elements e JOIN properties p ON e.atomic_number = p.atomic_number JOIN types t ON p.type_id = t.type_id WHERE $QUERY_CONDITION LIMIT 1;")

# Check if the query returned a result
if [[ -z "$ELEMENT_DETAILS" ]]; then
    echo "I could not find that element in the database."
    exit
fi

# Remove leading and trailing whitespace
ELEMENT_DETAILS=$(echo $ELEMENT_DETAILS | xargs)

# Splitting the result into variables
read -r ATOMIC_NUMBER NAME SYMBOL ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE <<<$(echo $ELEMENT_DETAILS | sed 's/|/ /g')

# Formatting the output
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
