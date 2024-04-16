#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c" 
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "How may I help you?" 
  echo "$SERVICES" | awk '{gsub(/ \| /, " "); print}' | while read -r SERVICE_ID NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    [1-4]) SCHEDULE_APPOINTMENT ;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}
SCHEDULE_APPOINTMENT(){
  # get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CHECK_CUSTOMER_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # if customer doesn't exist
        if [[ -z $CHECK_CUSTOMER_PHONE ]]
        then
          # get new customer name
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          # insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
        fi
    # get customer name, id and service name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
    read SERVICE_TIME
    # save appointment
    NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(time,customer_id,service_id) VALUES('$SERVICE_TIME','$CUSTOMER_ID','$SERVICE_ID_SELECTED')")
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
}

MAIN_MENU