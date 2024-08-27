#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Display the service menu
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
    if [[ $1 ]]
    then
        echo -e "$1"
    fi

    # Get list of services
    SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

    echo -e "Welcome to My Salon, how can I help you?\n"
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done

    read SERVICE_ID_SELECTED

    # Check if service is valid
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    if [[ -z $SERVICE_NAME ]]
    then
        MAIN_MENU "I could not find that service. What would you like today?"
    else
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        # Check if customer exists
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

        if [[ -z $CUSTOMER_NAME ]]
        then
            # Customer not found, ask for name
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME

            # Insert new customer
            INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        fi

        # Get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

        # Ask for appointment time
        echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $CUSTOMER_NAME?"
        read SERVICE_TIME

        # Insert appointment
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

        # Confirmation message
        echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
}

MAIN_MENU
