#!/bin/bash
# Pomodoro Technique
# The Pomodoro Technique is a time management method developed by Francesco Cirillo in the late 1980s.
# The technique uses a timer to break down work into intervals,
# traditionally 25 minutes in length, separated by short breaks.
# Each interval is known as a pomodoro, from the Italian word for 'tomato',
# after the tomato-shaped kitchen timer that Cirillo used as a university student.
# https://en.wikipedia.org/wiki/Pomodoro_Technique

################

# Testing
# POMODORO=1
# SHORT_BREAK=1
# LONG_BREAK=1
# sessions=4

#########################

# Define time spans
POMODORO=1500
SHORT_BREAK=300
LONG_BREAK=1800
sessions=4

# Define sessions before taking a long break
POMODOROS_TILL_LONG_BREAK=4

# Filepaths to html notifiers
SHORT_BREAK_START="${HOME}/PROGRAMMING/pomodoro/html/break_start.html"
SHORT_BREAK_FINISH="${HOME}/PROGRAMMING/pomodoro/html/break_finish.html"
LONG_BREAK_START="${HOME}/PROGRAMMING/pomodoro/html/long_break_start.html"
LONG_BREAK_FINISH="${HOME}/PROGRAMMING/pomodoro/html/long_break_finish.html"
ALL_POMODOROS_FINISHED="${HOME}/PROGRAMMING/pomodoro/html/finish.html"

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

# Command to open the browser
OPEN_BROWSER='open -a firefox'

# Helper function to output time
# Format: hh:mm:ss
echo_time() {
  date +"%T"
}

# Display a help message
usage() {
  echo -e "This is an implementation of the ${RED_BOLD}pomodoro${ENDC}
  technique, a time management method."
  echo 'It will interrupt your work every 25 minutes and ask you to take a 5 minute break, four times in a row. (2h in total).'
  echo -e "If you want to change the amount of intervals, pass it a number
  between 0 and 9. There is also an option to tune the interval length.\n"
  echo -e "Usage: pomodoro [options] [arguments]\n"
  echo Options:
  echo "-h, --help        show this message"
  echo "-c, --custom      start wizzard to define number and length of the intervals"
}

# Get user input
ask_for_sessions() {
  printf "${PINK}How many Pomodoros would you like to do? (default: 4) >> ${ENDC}"
  get_input
}

ask_for_pomodoro_length() {
  printf "${LIGHTBLUE}How long should a pomodoro be? (default: 25 min) >> ${ENDC}"
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
    POMODORO=$POMODORO
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
  eval $OPEN_BROWSER $SHORT_BREAK_START &
  sleep $SHORT_BREAK
  echo_time
  echo -e "${RED_BOLD}Break is over.${ENDC}\n"
  eval $OPEN_BROWSER $SHORT_BREAK_FINISH &
}

# Run one long break
long_break() {
  # Take 30 minutes off
  echo_time
  echo -e "${WARNING}Awesome, you have done ${i} Pomodoros. Take a longer break now${ENDC}!"
  eval $OPEN_BROWSER $LONG_BREAK_START &
  sleep $LONG_BREAK
  echo_time
  echo -e "${RED_BOLD}Long break is over. Pomodoro starts.${ENDC}\n"
  eval $OPEN_BROWSER $LONG_BREAK_FINISH &
}


# control when to run what
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
  eval $OPEN_BROWSER $ALL_POMODOROS_FINISHED &

  # Prompt for input
  echo "Would you like to go on? [y/n] "
  read -r input

  case $input in
    [yY][eE][sS]|[yY])
      init;;
    [nN][oO]|[nN])
      echo "Have a good day!"
      exit 0;;
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

# HANDLE ARGUMENTS + OPTIONS

# If more than one argument was passed
# run usage and exit
[[ $# -gt 1 ]] && usage && exit 1

## If no argument
if [[ $# -eq 0 ]]; then
  # start with default values
  echo 'you will be doing 4 pomodoros'
  run_sessions
fi

# If one argument was passed
# Test if the argument was a number between 1-9
re='^[1-9]+$'
if [[ ${1} =~ $re ]] ; then
  # run $1 sessions of default length
  sessions=$1
  echo "running $1 sessions, have fun!"
  run_sessions
else
  # run usage
  case "${1}" in
    -c) init ;;
    --custom) init ;;
    -h) usage && exit 1 ;;
    --help) usage && exit 1 ;;
    *) usage && exit 1 ;;
  esac
fi
