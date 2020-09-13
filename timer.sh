#!/bin/bash
# Pomodoro Technique
# The Pomodoro Technique is a time management method developed by Francesco Cirillo in the late 1980s.
# The technique uses a timer to break down work into intervals, 
# traditionally 25 minutes in length, separated by short breaks. 
# Each interval is known as a pomodoro, from the Italian word for 'tomato', 
# after the tomato-shaped kitchen timer that Cirillo used as a university student.
# https://en.wikipedia.org/wiki/Pomodoro_Technique

# Define time spans
POMODORO=1500
SHORT_BREAK=300
LONG_BREAK=1800

# Testing
# POMODORO=1
# SHORT_BREAK=1
# LONG_BREAK=1

# Define sessions before taking a long break
POMODOROS_TILL_LONG_BREAK=4

# Filepaths to html notifiers
SHORT_BREAK_START='/home/xy/programming/shell_scripts/pomodoro/html/break_start.html'
SHORT_BREAK_FINISH='/home/xy/programming/shell_scripts/pomodoro/html/break_finish.html'
LONG_BREAK_START='/home/xy/programming/shell_scripts/pomodoro/html/long_break_start.html'
LONG_BREAK_FINISH='/home/xy/programming/shell_scripts/pomodoro/html/long_break_finish.html'
ALL_POMODOROS_FINISHED='/home/xy/programming/shell_scripts/pomodoro/html/finish.html'

# Style output
ERROR='\033[91m'
OKGREEN='\033[92m'
WARNING='\033[93m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
PINK='\033[95m'
LIGHTBLUE='\033[96m'
BLUE_UNDERLINED='\033[94;4m'
RED_BOLD='\033[31;1m'
ENDC='\033[0m' # Reset

# Helper function to output time
# Format: hh:mm:ss
echo_time() { 
  date +"%T"
}

# Get user input
ask_for_sessions() {
  printf "${LIGHTBLUE}Hi, how many Pomodoros would you like to do? (4 is recommended and thus the default)\n${ENDC}"
  printf "${PINK}Please press enter or type an integer >>${ENDC} "
  get_input
}

ask_for_pomodoro_length() {
  printf "${LIGHTBLUE}How long should a pomodoro be? (25 Minutes is the default))\n${ENDC}"
  printf "${PINK}Please press enter or type for how long you would like to study (in Minutes) >>${ENDC} "
  get_pomodoro_length
}

# Get no of sessions and define sessions variable
get_input() {
  read -r entered_sessions
  if [[ $entered_sessions = "" ]]; then 
    sessions=4
  elif ! [[ $entered_sessions =~ ^[0-9]+$ ]]; then
    printf "The value entered wasn't an integer. Please press enter or type an integer >> "
    get_input
  else
    sessions=$entered_sessions
  fi
}

get_pomodoro_length() {
  read -r pomodoro_length
  if [[ $pomodoro_length = "" ]]; then 
    POMODORO= $POMODORO
  elif ! [[ $entered_sessions =~ ^[0-9]+$ ]]; then
    printf "The value entered wasn't an integer. Please press enter or type an integer >> "
    get_pomodoro_length
  else
    POMODORO=$(( pomodoro_length*60 ))
  fi
}

# Run one pomodoro
pomodoro() {
  echo_time
  echo -e "${PINK}Pomodoro ${i} started.${ENDC}"
  sleep $POMODORO
  echo -e "${PINK}Congrats! Pomodoro ${i} is done.${ENDC}"
}

short_break() {
  echo_time
  echo -e "${LIGHTBLUE}Take ${SHORT_BREAK} seconds off, my friend.${ENDC}"
  firefox $SHORT_BREAK_START
  sleep $SHORT_BREAK
  echo_time
  echo -e "${RED_BOLD}Break is over.${ENDC}\n"
  firefox $SHORT_BREAK_FINISH
}

# Run one long break
long_break() {
  # Take 30 minutes off
  echo_time
  echo -e "${WARNING}Awesome, you have done ${i} Pomodoros. Take a longer break now${ENDC}!"
  firefox $LONG_BREAK_START
  sleep $LONG_BREAK
  echo_time
  echo -e "${RED_BOLD}Long break is over. Pomodoro starts.${ENDC}\n"
  firefox $LONG_BREAK_FINISH
}

# Ccontrol when to run what
run_sessions() {
  i=1
  while [ $i -le $sessions ]; do
    pomodoro
      if  (( $i % $POMODOROS_TILL_LONG_BREAK == 0)) && (( $i != $sessions )); then
        long_break
      elif (( $i != $sessions )); then
        short_break 
      else
        break
      fi
    i=$[$i+1]
  done
  echo "You finished all your pomodoros"
  firefox $ALL_POMODOROS_FINISHED
  
  # Prompt for input on how to proceed when all pomodoros are finished
  read -r -p "Would you like to go on? [y/n] " input
  
  case $input in
    [yY][eE][sS]|[yY])
      init;;
    [nN][oO]|[nN])
      echo "Have a good day!";; 
    *)
      echo "Invalid input. Exiting ..."
      exit 1;;
  esac
}
  
init() {
  ask_for_sessions
  echo "Sessions entered: ${sessions}"
  ask_for_pomodoro_length
  echo "Your pomodoro(s) will have a length of ${POMODORO} seconds."
  run_sessions
}

# Start program
init
