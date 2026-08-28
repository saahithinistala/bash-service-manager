#!/bin/sh

display_menu() {
  echo "********************************"
  echo "*      SERVICE MANAGER         *"
  echo "********************************"
  echo "* 1. Start Service             *"
  echo "* 2. Stop Service              *"
  echo "* 3. Restart Service           *"
  echo "* 4. Health Check              *"
  echo "* 5. Exit                      *"
  echo "********************************"

  read -p "Enter your choice: " choice
}

service_menu() {
  while true
  do
    echo "***************************"
    echo "*      SERVICES LIST      *"
    echo "***************************"
    echo "* 1. Payment Service      *"
    echo "* 2. Account Service      *"
    echo "* 3. Notification Service *"
    echo "* 4. Batch Service        *"
    echo "* 5. All Services         *"
    echo "* q. Quit                 *"
    echo "***************************"

    read -p "Enter the service: " ch

    case $ch in
      1) service_name=payment-service
         return 0
         ;;
      2) service_name=account-service
         return 0
         ;;
      3) service_name=notification-service
         return 0
         ;;
      4) service_name=batch-service
         return 0
         ;;
      5) service_name=ALL
         return 0
         ;;
      q) return 1
         ;;
      *) echo "Invalid choice"
         ;;
    esac
  done
}

health_check() {
  port=$1
  service_name=$2

  echo "Performing health check on ${service_name}"
  count=$(/usr/sbin/lsof -i tcp:"${port}" | wc -l)
  if [ "${count}" -eq 0 ] ; then
      printf "\n"
      echo "${service_name} --> NOT RUNNING"
      printf "\n"
  else
      printf "\n"
      echo "${service_name} --> RUNNING"
      printf "\n"
  fi
}


start_service() {
  services_directory=$1
  service_name=$2
  start_script=$3
  port=$4

  echo "Starting ${service_name}"
  sh "${services_directory}/${service_name}/${start_script}.sh"

  sleep 3
  health_check "${port}" "${service_name}"

}

stop_service() {
    services_directory=$1
    service_name=$2
    stop_script=$3
    port=$4

  echo "Stopping ${service_name}"
  sh "${services_directory}/${service_name}/${stop_script}.sh"

  sleep 3
  health_check "${port}" "${service_name}"

}

#############
# MAIN MENU #
#############

running=true
while [ "${running}" = true ]
do
  display_menu
  case $choice in
    1) service_menu

       if [ $? -ne 0 ]; then
          continue
       fi

       if [ "${service_name}" = "ALL" ] ; then
          cat services_config.cfg | while read line
          do
            service_name=$(echo "$line" | cut -d "," -f1)
            start_script=$(echo "$line" | cut -d "," -f2)
            port=$(echo "$line" | cut -d "," -f4)
            services_directory=$(echo "$line" | cut -d "," -f5)

            start_service "${services_directory}" "${service_name}" "${start_script}" "${port}"
          done
      else
            start_script=$(grep "${service_name}" services_config.cfg | cut -d "," -f2)
            port=$(grep "${service_name}" services_config.cfg | cut -d "," -f4)
            services_directory=$(grep "${service_name}" services_config.cfg | cut -d "," -f5)

            start_service "${services_directory}" "${service_name}" "${start_script}" "${port}"
       fi
       ;;
    2) service_menu

      if [ $? -ne 0 ]; then
          continue
      fi

      if [ "${service_name}" = "ALL" ] ; then
          cat services_config.cfg | while read line
          do
            service_name=$(echo "$line" | cut -d "," -f1)
            stop_script=$(echo "$line" | cut -d "," -f3)
            port=$(echo "$line" | cut -d "," -f4)
            services_directory=$(echo "$line" | cut -d "," -f5)

            stop_service "${services_directory}" "${service_name}" "${stop_script}" "${port}"
          done
      else
            stop_script=$(grep "${service_name}" services_config.cfg | cut -d "," -f3)
            port=$(grep "${service_name}" services_config.cfg| cut -d "," -f4)
            services_directory=$(grep "${service_name}" services_config.cfg | cut -d "," -f5)

            stop_service "${services_directory}" "${service_name}" "${stop_script}" "${port}"
       fi
       ;;
    3) service_menu

       if [ $? -ne 0 ]; then
          continue
       fi

       if [ "${service_name}" = "ALL" ] ; then
          cat services_config.cfg | while read line
          do
            service_name=$(echo "$line" | cut -d "," -f1)
            start_script=$(echo "$line" | cut -d "," -f2)
            stop_script=$(echo "$line" | cut -d "," -f3)
            port=$(echo "$line" | cut -d "," -f4)
            services_directory=$(echo "$line" | cut -d "," -f5)

            stop_service "${services_directory}" "${service_name}" "${stop_script}" "${port}"
            start_service "${services_directory}" "${service_name}" "${start_script}" "${port}"
          done
        else
            start_script=$(grep "${service_name}" services_config.cfg | cut -d "," -f2)
            stop_script=$(grep "${service_name}" services_config.cfg | cut -d "," -f3)
            port=$(grep "${service_name}" services_config.cfg | cut -d "," -f4)
            services_directory=$(grep "${service_name}" services_config.cfg | cut -d "," -f5)

            stop_service "${services_directory}" "${service_name}" "${stop_script}" "${port}"
            start_service "${services_directory}" "${service_name}" "${start_script}" "${port}"

        fi
      ;;
    4) cat services_config.cfg | while read line
       do
         service_name=$(echo "$line" | cut -d "," -f1)
         port=$(echo "$line" | cut -d "," -f4)
         health_check "${port}" "${service_name}"
       done
      ;;
    5) running=false
      ;;
    *) echo "Enter a valid choice"
  esac
done
