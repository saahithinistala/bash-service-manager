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

health_check() {
  port=$1
  service_name=$2
  status=""

  printf "\n"
  echo "Performing health check on ${service_name}"
  count=$(/usr/sbin/lsof -i tcp:"${port}" | wc -l)
  if [ "${count}" -eq 0 ] ; then
      status="not_running"
      echo "${service_name} --> NOT RUNNING"
      printf "\n"
  else
      status="running"
      echo "${service_name} --> RUNNING"
      printf "\n"
  fi

}

handle_stop() {
    service_name=$1
    service_name=$(echo "${service_name}" | tr '[:upper:]' '[:lower:]')

    if [ "${service_name}" = "all" ] ; then
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
}

handle_start() {
    service_name=$1
    service_name=$(echo "${service_name}" | tr '[:upper:]' '[:lower:]')

    if [ "${service_name}" = "all" ] ; then
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
}

handle_restart() {
    service_name=$1
    service_name=$(echo "${service_name}" | tr '[:upper:]' '[:lower:]')

    if [ "${service_name}" = "all" ] ; then
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
}

handle_health() {
    service_name=$1
    service_name=$(echo "${service_name}" | tr '[:upper:]' '[:lower:]')

    if [ "${service_name}" = "all" ] ; then
      cat services_config.cfg | while read line
      do
        service_name=$(echo "$line" | cut -d "," -f1)
        port=$(echo "$line" | cut -d "," -f4)
        health_check "${port}" "${service_name}"
      done
    else
      port=$(grep "${service_name}" services_config.cfg | cut -d "," -f4)
      health_check "${port}" "${service_name}"
    fi
}

summary_report() {
  clear
  script_dir=$(dirname "$0")

  if [ -s "${script_dir}/status$$.log" ] ; then
    echo "===== AUTO RECOVERY SUMMARY ====="
    cat "${script_dir}/status$$.log" | while read line
    do
      service_name=$(echo "$line" | cut -d "," -f1)
      status=$(echo "$line" | cut -d "," -f2)
      status=$(echo "${status}" | tr '[:lower:]' '[:upper:]')
      printf "%-22s : %s\n" "${service_name}" "${status}"
    done
  else
    echo "Status log is empty. Unable to report summary"
  fi
}

handle_auto_recover() {
  service_name=$1
  service_name=$(echo "${service_name}" | tr '[:upper:]' '[:lower:]')
  script_dir=$(dirname "$0")


  if [ "${service_name}" = "all" ] ; then
      cat services_config.cfg | while read line
      do
        service_name=$(echo "$line" | cut -d "," -f1)
        port=$(echo "$line" | cut -d "," -f4)
        health_check "${port}" "${service_name}"

        if [ "${status}" = "not_running" ] ; then
          echo "Performing auto-recovery for ${service_name}"
          printf "\n"
          handle_stop "${service_name}"
          handle_start "${service_name}"
            if [ "${status}" = "running" ] ; then
              echo "${service_name},recovered" >> "${script_dir}/status$$.log"
            elif [ "${status}" = "not_running" ] ; then
              echo "${service_name},failed" >> "${script_dir}/status$$.log"
            else
              echo "${service_name},running" >> "${script_dir}/status$$.log"
            fi
        else
            echo "${service_name},running" >> "${script_dir}/status$$.log"
        fi
      done
  else
      port=$(grep "${service_name}" services_config.cfg | cut -d "," -f4)
      health_check "${port}" "${service_name}"
      if [ "${status}" = "not_running" ] ; then
        echo "Performing auto-recovery for ${service_name}"
        printf "\n"
        handle_stop "${service_name}"
        handle_start "${service_name}"
        if [ "${status}" = "running" ] ; then
            echo "${service_name},recovered" >> "${script_dir}/status$$.log"
        elif [ "${status}" = "not_running" ] ; then
            echo "${service_name},failed" >> "${script_dir}/status$$.log"
        else
            echo "${service_name},running" >> "${script_dir}/status$$.log"
        fi
      else
            echo "${service_name},running" >> "${script_dir}/status$$.log"
      fi
  fi

  summary_report
}

#############
# MAIN MENU #
#############

<<<<<<< HEAD
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
=======
#--User Inputs--#
action=$1
service_name=$2

#--Converting user inputs into lowercase--#
action=$(echo "${action}" | tr '[:upper:]' '[:lower:]')
service_name=$(echo "${service_name}" | tr '[:upper:]' '[:lower:]')

if [ "$#" -eq 0 ] ; then
  running=true
  while [ "${running}" = true ]
  do
    display_menu
    case $choice in
      1) service_menu
         if [ $? -ne 0 ]; then
            continue
         fi
         handle_start "${service_name}"
         ;;
      2) service_menu
         if [ $? -ne 0 ]; then
            continue
         fi
         handle_stop "${service_name}"
         ;;
      3) service_menu
         if [ $? -ne 0 ]; then
            continue
         fi
         handle_restart "${service_name}"
         ;;
      4) service_menu
         if [ $? -ne 0 ]; then
            continue
         fi
         handle_health "${service_name}"
         ;;
      5) running=false
         ;;
      *) echo "Enter a valid choice"
    esac
  done
elif [ "$#" -lt 2 ] ; then   #--Validating no of arguments--#
  echo "Invalid no of arguments"
else
  if [ "${action}" = "start" ] || [ "${action}" = "stop" ] || [ "${action}" = "restart" ] || [ "${action}" = "health" ] || [ "${action}" = "auto-recover" ] ; then
    if [ "$(grep -c "^${service_name}," services_config.cfg)" -gt 0 ] || [ "${service_name}" = "all" ] ; then
      case "${action}" in
          start)
            handle_start "${service_name}"
            ;;
          stop)
            handle_stop "${service_name}"
            ;;
          restart)
            handle_restart "${service_name}"
            ;;
          health)
            handle_health "${service_name}"
            ;;
          auto-recover)
            handle_auto_recover "${service_name}"
            ;;
        esac
    else
      echo "Invalid service name. Check services_config.cfg or use all."
    fi
  else
      echo "Invalid action. Use start, stop, restart, health, or auto-recover."
  fi
fi

#--Housekeeping
script_dir=$(dirname "$0")
rm -f "${script_dir}"/status$$.log
