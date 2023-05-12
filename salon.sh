#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

DISPLAY_SERVICES() {
  SERVICES_LIST=$($PSQL "SELECT service_id,name FROM services")
  echo "$SERVICES_LIST"  | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
}

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo -e "Welcome to My Salon, how can I help you?\n"
  

  DISPLAY_SERVICES

  read SERVICE_ID_SELECTED
  
  #echo -e "\n"
  
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?" # Invalid (not numeric) choice
  else
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    SERVICE=$( echo $SERVICE|sed -E 's/^ *| *$//g')
    if [[ -z $SERVICE ]]
    then
      #If you pick a service that doesn't exist, you should be shown the same list of services again
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      #echo $SERVICE
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      if [[ -z $CUSTOMER_PHONE ]]
      then
        MAIN_MENU "Invalid phone number"
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        CUSTOMER_NAME=$( echo $CUSTOMER_NAME|sed -E 's/^ *| *$//g')
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          CUSTOMER_NAME=$( echo $CUSTOMER_NAME|sed -E 's/^ *| *$//g')
          if [[ -z $CUSTOMER_NAME ]]
          then
            MAIN_MENU "Invalid name"
          else
            #echo "INSERT INTO CUSTOMERS (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
            INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO CUSTOMERS (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
          fi # customer_name
        fi # customer_name
      fi # customer_phone

      echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
    fi # service
  fi
}

MAIN_MENU
