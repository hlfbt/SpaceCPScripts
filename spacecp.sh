#!/bin/sh

# Dem keys!!
SPACECP_APIKEY=""
# Mmh more tasty variables...
SPACECP_URL="http://spacecp.net"
# If you haven't guessed already, I'm going to declare all the important variables here
SPACECP_SERVJAR="bukkit.jar"
# Yes, yes, variables, good, good
SPACECP_PORT=25566
# There are a bunch more...
SPACECP_CONFFILE="SpaceCP/config.yml"
# Yup, and more...
SPACECP_SERVAPI="$SPACECP_URL/api/server"
# ...
SPACECP_PROPFILE="SpaceCP/properties"
# ((uh this is kinda awkward, is he gonna start talking or should I...))
SPACECP_RTKJAR="rtk.jar"
# soo...
SPACECP_SMJAR="toolkit/modules/spacemodule.jar"
# glaring display last night, eh?
SPACECP_RPJAR="plugins/rtkplugin.jar"
# well fuck you than, if you're not gonna talk you might as well just go UGH
SPACECP_DLAPIURL="http://dl.api.xereo.net"
SPACECP_GDNAPIURL="http://gdn.api.xereo.net"
SPACECP______="0.$(((5*2*10)/(4*5*5)))"
SPACECP_STARTCOMMAND="start-stop-daemon"
SPACECP_STARTARGS="--start --pidfile 'spacecp.pid' --chdir '$(pwd)' --background --make-pidfile --exec"
SPACECP_RTKARGS=""
if command -v tmux >/dev/null 2>&1
then SPACECP_STARTCOMMAND="tmux" && SPACECP_STARTARGS=""
else if command -v screen >/dev/null 2>&1
then SPACECP_STARTCOMMAND="screen" && SPACECP_STARTARGS="-dmLS 'SpaceCP'"
fi; fi

ultima_yes=0 # Never say no! ...or was it never...
force_update=0 # 0 nothing, 1 update, 2 install
dn='/dev/null'

#UUUHM plz dont change dis 1 kthxX
OPTIND=1

show_help () {
  printf '%s\n' "wow it's a fucking help"; # help stuff goes here I guess...
}
__ () {
  printf '%s\n' "$___";
}


## CAUTION
## Shitty-ass arguments handling incoming!!
## CAUTION
while getopts "h?yuir:c:C:k:a:j:p:" opt
do
  case "$opt" in
  h|\?) show_help; exit 0;;
  y) ultima_yes=1;;
  u) force_update=1;;
  i) force_update=2;;
  r) if [ -s "$OPTARG" ]
     then SPACECP_RTKJAR=$OPTARG
     else printf '%s\n' "'$OPTARG' is not a valid RTK jar."; exit 1
     fi;;
  c) if [ -s "$OPTARG" ]
     then SPACECP_CONFFILE=$OPTARG
     else printf '%s\n' "'$OPTARG' is not a valid configuration file."; exit 1
     fi;;
  C) if [ -s "$OPTARG" ]
     then SPACECP_PROPFILE=$OPTARG
     else printf '%s\n' "'$OPTARG' is not a valid properties file."; exit 1
     fi;;
  k) SPACECP_APIKEY=$(printf '%s' "$OPTARG" | tr '[:upper:]' '[:lower:]');;
  a) SPACECP_SERVAPI=$OPTARG;;
  j) if [ -s "$OPTARG" ]
     then SPACECP_SERVJAR="$OPTARG"
     else printf '%s\n' "'$OPTARG' is not a valid server jar/file."; exit 1
     fi;;
  p) if expr match "$OPTARG" '^[0-9]\+$' >$dn && [ "$OPTARG" -le 65535 -a "$OPTARG" -ge 1 ]
     then SPACECP_PORT="$OPTARG"
     else printf '%s\n' "'$OPTARG' is not a valid port number."; exit 1
     fi;;
  esac
done
shift $((OPTIND-1))
[ "$1" = "--" ] && shift
_____='--etc=lol'
for arg in "$@"
do
  ___='ur a fgt'
  args=$(expr "$arg" : '[^=]\+=\(.*\)')
  case "$arg" in
  --help)
    show_help
    exit 0
    ;;
  --always-yes) ultima_yes=1;;
  --update) force_update=1;;
  --install) force_update=2;;
  --server-api=*) SPACECP_SERVAPI="$args";;
  --rtk-jar=*)
    if [ $force_update -ne 2 -a -s "$args" ]
    then SPACECP_RTKJAR="$args"
    else
      printf '%s\n' "'$args' is not a valid RTK jar."
      exit 1
    fi
    ;;
  --config=*)
    if [ $force_update -ne 2 -a -s "$args" ]
    then SPACECP_CONFFILE="$args"
    else
      printf '%s\n' "'$args' is not a valid configuration file."
      exit 1
    fi
    ;;
  --properties=*)
    if [ $force_update -ne 2 -a -s "$args" ]
    then SPACECP_PROPFILE="$args"
    else
      printf '%s\n' "'$args' is not a valid properties file."
      exit 1
    fi
    ;;
  --api-key=*) SPACECP_APIKEY=$(printf '%s' "$args" | tr '[:upper:]' '[:lower:]');;
  --server-jar=*)
    if [ $force_update -ne 2 -a -s "$args" ]
    then SPACECP_SERVJAR="$args"
    else
      printf '%s\n' "'$args' is not a valid server jar/file."
      exit 1
    fi
    ;;
  --port=*)
    if expr match "$args" '^[0-9]\+$' >$dn && [ "$args" -le 65535 -a "$args" -ge 1 ]
    then SPACECP_PORT="$args"
    else
      printf '%s\n' "'$args' is not a valid port number."
      exit 1
    fi
    ;;
  "$_____") __ && exit 0;;
  esac
done
## Wow fucking arguments handling man
## But I have to say I like what I wrote there (for now)

urlencode () {
  perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$@"
}

install_spacecp () {
  ## Installing SpaceCP
  ## Checks for already existing files to not make the user redownload everything over an over again if he calls the
  ##  script wrongly or has some faulty values at first.
  printf '%s' "[     ] Getting configuration..."
  spacecp_conf=$(curl -sLA "SpaceCP Script $SPACECP______" "$SPACECP_SERVAPI/$SPACECP_APIKEY/config.yml")
  [ -z "$spacecp_conf" ] && (printf '\r[ERROR] \n%s\n' "Could not fetch the configuration under '$SPACECP_SERVAPI'.")
  echo "$spacecp_conf" > "$SPACECP_CONFFILE"
  [ -s "$SPACECP_CONFFILE" ] || (printf '\r[ERROR] \n%s\n' "Could not write to '$SPACECP_CONFFILE'." && exit 1)
  printf '\r%s\n' "[OK]    "
  printf '%s' "[     ] Getting properties..."
  spacecp_prop=$(curl -sLA "SpaceCP Script $SPACECP______" "$SPACECP_SERVAPI/$SPACECP_APIKEY/properties")
  [ -z "$spacecp_prop" ] && (printf '\r[ERROR] \n%s\n' "Could not fetch the properties under '$SPACECP_SERVAPI'.")
  echo "$spacecp_prop" > "$SPACECP_PROPFILE"
  [ -s "$SPACECP_PROPFILE" ] || (printf '\r[ERROR] \n%s\n' "Could not write to '$SPACECP_PROPFILE'." && exit 1)
  printf '\r%s\n' "[OK]    "
  printf '%s' "[     ] $SPACECP_SERVJAR..."
  if ! [ -s "$SPACECP_SERVJAR" ]
  then
    curl -sLA "SpaceCP Script $SPACECP______" \
    "$SPACECP_GDNAPIURL/$(urlencode "$(basename "$SPACECP_SERVJAR")")" -o "$SPACECP_SERVJAR" \
    || (printf '\r[ERROR] \n%s\n' \
        "Could not fetch the server jar '$(basename "$SPACECP_SERVJAR")' from SpaceGDN under '$SPACECP_GDNAPIURL'." \
        && exit 1)
  fi
  printf '\r%s\n' "[OK]    "
  printf '%s' "[     ] $SPACECP_RTKJAR..."
  if ! [ -s "$SPACECP_RTKJAR" ]
  then
    curl -sLA "SpaceCP Script $SPACECP______" \
    "$SPACECP_DLAPIURL/$(urlencode "$(basename "$SPACECP_RTKJAR")")" -o "$SPACECP_RTKJAR" \
    || (printf '\r[ERROR] \n%s\n' \
        "Could not download '$(basename "$SPACECP_RTKJAR")' from the download server under '$SPACECP_DLAPIURL'." \
        && exit 1)
  fi
  printf '\r%s\n' "[OK]    "
  printf '%s' "[     ] $SPACECP_RPJAR..."
  if ! [ -s "$SPACECP_RPJAR" ]
  then
    curl -sLA "SpaceCP Script $SPACECP______" \
    "$SPACECP_DLAPIURL/$(urlencode "$(basename "$SPACECP_RPJAR")")" -o "$SPACECP_RPJAR" \
    || (printf '\r[ERROR] \n%s\n' \
        "Could not download '$(basename "$SPACECP_RPJAR")' from the download server under '$SPACECP_DLAPIURL'." \
        && exit 1)
  fi
  printf '\r%s\n' "[OK]    "
  printf '%s' "[     ] $SPACECP_SMJAR..."
  if ! [ -s "$SPACECP_SMJAR" ]
  then
    curl -sLA "SpaceCP Script $SPACECP______" \
    "$SPACECP_DLAPIURL/$(urlencode "$(basename "$SPACECP_SMJAR")")" -o "$SPACECP_SMJAR" \
    || (printf '\r[ERROR] \n%s\n' \
        "Could not download '$(basename "$SPACECP_SMJAR")' from the download server under '$SPACECP_DLAPIURL'." \
        && exit 1)
  fi
  printf '\r%s\n' "[OK]    "
}

update_spacecp () {
  slug=$(cat "$SPACECP_CONFFILE" | sed -n '/^server:$/,/^[^ ]\+/s/^  slug: \(.*-\)*\([^-]\+\)/\2/p' \
         | tr '[:upper:]' '[:lower:]')
  wrapper_channel=$(cat "$SPACECP_CONFFILE" | sed -n '/^wrapper:$/,/^[^ ]\+/s/^  channel: \([a-zA-Z]\+\)/\1/p' \
                    | tr '[:upper:]' '[:lower:]')
  server_channel=$(cat "$SPACECP_CONFFILE" | sed -n '/^server:$/,/^[^ ]\+/s/^  channel: \([a-zA-Z]\+\)/\1/p' \
                   | tr '[:upper:]' '[:lower:]')
<<<<<<< HEAD
  server_build=$(cat "$SPACECP_CONFFILE" | sed -n '/^server:$/,/^[^ ]\+/s/^  build: \([a-zA-Z]\+\)/\1/p' \
                 | tr '[:upper:]' '[:lower:]')
  server_autoupdate=$(cat "$SPACECP_CONFFILE" | sed -n '/^server:$/,/^[^ ]\+/s/^  auto-update: \([a-zA-Z]\+\)/\1/p' \
                      | tr '[:upper:]' '[:lower:]')
=======
>>>>>>> 3e680003dd2ff18133fa52d98f3698fbd747a187
  spacecp_channel=$(cat "$SPACECP_CONFFILE" | sed -n '/^spacecp:$/,/^[^ ]\+/s/^  channel: \([a-zA-Z]\+\)/\1/p' \
                    | tr '[:upper:]' '[:lower:]')
  spacecp_build=$(cat "$SPACECP_CONFFILE" | sed -n '/^spacecp:$/,/^[^ ]\+/s/^  build: \([a-zA-Z]\+\)/\1/p' \
                  | tr '[:upper:]' '[:lower:]')
  spacecp_autoupdate=$(cat "$SPACECP_CONFFILE" | sed -n '/^spacecp:$/,/^[^ ]\+/s/^  auto-update: \([a-zA-Z]\+\)/\1/p' \
                       | tr '[:upper:]' '[:lower:]')
  [ -z "$SPACECP_APIKEY" ] && SPACECP_APIKEY=$(cat "$SPACECP_CONFFILE" \
                                               | sed -n '/^spacecp:$/,/^[^ ]\+/s/^  apikey: \([a-zA-Z]\+\)/\1/p' \
                                               | tr '[:upper:]' '[:lower:]')
  if [ -z "$slug" ] || [ -z "$wrapper_channel" ] || [ -z "$server_channel" ] || [ -z "$server_build" ] \
     || [ -z "$server_autoupdate" ] || [ -z "$spacecp_channel" ] || [ -z "$spacecp_build" ] \
     || [ -z "$spacecp_autoupdate" ] || [ -z "$SPACECP_APIKEY" ]
  then
    printf '%s\n' "ERROR: Some variables could not be found in '$SPACECP_CONFFILE', your configuration may be damaged."
    return 1
  fi
  ## TO DO
  ## Do updating stuff
  ## lolwat gdn?
  ## TO DO
}

start_spacecp () {
  printf '%s' "[     ] Starting SpaceCP..."
  ## Actually starting RTK now and checking the exit status.
  ## It is EXTREMELY important for the starting command to automatically fork itself into the background,
  ##  or else we can't correctly check if it started to begin with, and more importantly,
  ##  cannot send a POST request to the SpaceCP servers to notify them that the server started!
  if "$SPACECP_STARTCOMMAND" "$SPACECP_STARTARGS" "$SPACECP_RTKJAR" "$SPACECP_RTKARGS"
  then printf '\r%s\n' "[OK]    Starting SpaceCP... [$SPACECP_STARTCOMMAND]"
  else printf '\r[ERROR]\n%s\n' "Could not start '$SPACECP_RTKJAR' with '$SPACECP_STARTCOMMAND'."
  fi
  curl -sLA "SpaceCP Script $SPACECP______" -X POST "$SPACECP_SERVAPI/$SPACECP_APIKEY/start"
}

if [ -s "$SPACECP_CONFFILE" ]
then SPACECP_APIKEY=$(cat "$SPACECP_CONFFILE" | sed -n '/^spacecp:$/,/^[^ ]\+/s/^  apikey: \([a-zA-Z0-9]\+\)/\1/p')
fi
if [ -z "$SPACECP_APIKEY" ]
then
  printf '%s\n' "No API Key, exiting."
  exit 1
fi
SPACECP_APIKEY=$(urlencode "$SPACECP_APIKEY")

if [ -s "$SPACECP_CONFFILE" ]
then
  if ! update_spacecp
  then
    printf '%s' "Could not update SpaceCP. Start anyway? [Y/n] "
    [ $ultima_yes -eq 1 ] && yn="y" || read yn
    expr match "$yn" '^y.*' >$dn && yn=''
  fi
  if [ -z "$yn" ]
  then
    if ! start_spacecp
    then
      printf '%s\n' "Could not start SpaceCP."
      exit 1
    fi
  fi
else
  printf '%s' "No SpaceCP configuration found. Install SpaceCP? [Y/n] "
  [ $ultima_yes -eq 1 ] && (yn="y" && printf '\n') || read yn
  expr match "$yn" '^y.*' >$dn && yn=''
  if [ -z "$yn" ]
  then
    if install_spacecp
    then
      printf '%s\n' "SpaceCP installation succesfull. Starting SpaceCP for the first time."
      if ! start_spacecp
      then
        printf '%s\n' "Could not start SpaceCP."
        exit 1
      fi
    else
      printf '%s\n' "Could not install SpaceCP."
      exit 1
    fi
  fi
fi
