#!/bin/sh

# Dem keys!!
SPACECP_APIKEY=""
# Mmh more tasty variables...
SPACECP_URL="http://spacecp.net"
# If you haven't guessed already, I'm going to declare all the important variables here
SPACECP_SERVJAR="craftbukkit.jar"
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
SPACECP_DLAPIURL="http://dl.api.xereo.net/v1"
SPACECP_GDNAPIURL="http://gdn.api.xereo.net/v1"
SPACECP______="0.$(((5*2*10)/(4*5*5)))"
___=""
_____=""
# Change the following two variables to use a custom start command
# IMPORTANT: Arguments must be in a string!
# DEFAULT: "start-stop-daemon"
SPACECP_STARTCOMMAND="start-stop-daemon"
# DEFAULT: "--start --pidfile 'spacecp.pid' --chdir '$(pwd)' --background --make-pidfile --exec"
SPACECP_STARTARGS="--start --pidfile 'spacecp.pid' --chdir '$(pwd)' --background --make-pidfile --exec"
# Also comment out those if blocks to not make it overwrite it accidentally
if command -v tmux >/dev/null 2>&1
# DEFAULT: "tmux"
# DEFAULT: "new-session -d -s 'SpaceCP'"
then SPACECP_STARTCOMMAND="tmux" && SPACECP_STARTARGS="new-session -d -s 'SpaceCP'"
else if command -v screen >/dev/null 2>&1
# DEFAULT: "screen"
# DEFAULT: "-dmLS 'SpaceCP'"
then SPACECP_STARTCOMMAND="screen" && SPACECP_STARTARGS="-dmLS 'SpaceCP'"
fi; fi
# Variable for custom args passed to RTK
# IMPORTANT: Arguments must be in a string!
# DEFAULT: ""
SPACECP_RTKARGS=""
# Variable pointing to Javas binary
# DEFAULT: "java"
SPACECP_JAVABIN="java"
# Variable for custom args passed to Java
# It is suggested to only change this if you are certain of what you are doing.
# IMPORTANT: Arguments must be in a string!
# DEFAULT: "-Djava.library.path=./libs/ -jar"
SPACECP_JAVAARGS="-Djava.library.path=./libs/ -jar"

ultima_yes=0 # Never say no! ...or was it never...
force_update=0 # 0 nothing, 1 update, 2 install
dn='/dev/null'

# UUUHM plz dont change dis 1 kthxX
OPTIND=1

show_help () {
  printf '%s\n' "wow it's a fucking help"; # TODO help stuff goes here I guess...
}
urlencode () {
  perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$@"
}
__ () {
  printf '%s\n' "$___";
}
# Next is this masterpiece: a json-parser written 100% in sh and coreutils.
# It can traverse json-arrays as well, only downside is it only supports json with a depth of 1
#  (f.i. {foo:bar, json:{1:2}} but not {foo:bar, json:{json:{1:2}}}).
# It's really fucking basic and will probably fail on anything just slightly more complicated,
#  but it works for what I need it so that's fine with me!
#
# *so proud*
json_parse () {
  # Read json from stdin and set subjson to dummy value to "start" the loop
  json="$(tr -d '\n' </dev/stdin)"
  subjson="_"
  d="$(echo "$json" | sed -n 's/^[ ]*\({\|\[\).*/\1/p')"
  expr "$d" : "\({\|\[\)" >$dn && json="$(echo "$json" | sed 's/^[ ]*\({\|\[\)//')" || d=""
  # Json parsing
  if [ -z "$d" -o "$d" = "{" ]
  then
    # Return json and exit code 2 if no keys are given
    [ -z "$1" ] && echo "$d$json" && return 2
    while [ -n "$subjson" ] && expr "$subjson" : "^[ ]*}[ ]*$">$dn
    do
      # = Find subjson =
      # subjson is just a key:value pair in the json.
      # For this I simply wrote a regular expression in BRE that should match most if not all json key:value pairs
      #  (it catches numbers and strings as key and numbers, strings, json and arrays as values).
      # grep returns the first found pair (grep | head -n1 is practically a non-greedy version of sed 's/.*REGEXP//').
      subjson="$(echo "$json" \
                 | grep -o "\(\"[^\"]\+\"\|[^\":]\+\)[ ]*:[ ]*\({[^}]*}\|\[[^]]*\]\|[^\",}]\+\|\"[^}\"]*\"\)" \
                 | head -n1)"
      # Now simply check if the key of the pair is the given key.
      if expr "$subjson" : "[ ]*[\"]\?$1[\"]\?[ ]*:.*" >$dn
      then
        # If it is, isolate the value of the key...
        hit="$(echo "$subjson" | sed "s/[\"]\?$1[\"]\?[ ]*:[ ]*//; s/\(^\"\|\"$\)//g; s/\(^[ ]*\|[ ]*$\)//g")"
        # ...and return it!
        echo "$hit"
        return 0
      fi
      # Escape that bitch!
      subjson=$(echo "$subjson" | sed 's/\(\$\|\.\|\*\|\/\|\[\|\\\|\]\|\^\)/\\&/g')
      # If the found key was not the given key, remove subjson from the whole json string and start from top!
      # (stderr from sed is suppressed because it may throw errors on certain subjson)
      json="$(echo "$json" | sed "s/.*$subjson[, ]*//")"
    done
  # Array parsing
  else if [ -n "$d" -a "$d" = "[" ]
  then
    # Return json and exit code 2 if no number is given
    #  (no arguments are ok since it's supposed to return the number of elements in the array then).
    [ -n "$1" ] && ! expr "$1" : '^[0-9]\+$'>$dn && echo "$d$json" && return 2
    i=1
    # Traverse array until no elements are left.
    while [ -n "$subjson" ] || expr "$subjson" : "^[ ]*\][ ]*$">$dn
    do
      # = Find 'subjson' (subarray) =
      # This is basically just the second part of the subjson regexp, not really much to explain...
      subjson="$(echo "$json" | grep -o "\({[^}]*}\|\[[^]]*\]\|[^\",}]\+\|\"[^}\"]*\"\)[ ]*\(,\|\]\)[ ]*" | head -n1)"
      # Return the current element if it's the wanted one.
      if [ -n "$1" ] && [ $i -eq $1 ]
      then
        hit="$(echo "$subjson" | sed "s/[ ]*\(,\|\]\)[ ]*$//; s/\(^\"\|\"$\)//g; s/\(^[ ]*\|[ ]*$\)//g")"
        echo "$hit"
        return 0
      fi
      subjson=$(echo "$subjson" | sed 's/\(\$\|\.\|\*\|\/\|\[\|\\\|\]\|\^\)/\\&/g')
      json="$(echo "$json" | sed "s/.*$subjson[ ]*//")"
      i=$(expr $i + 1)
    done
    # Return the maximal number of elements if it couldn't find the wanted element or no argument was given.
    # (i is always 2 bigger since the loop checks if subjson is zero, which will only be set 1 turn after json is zero,
    #  and because it got initialized as 1 and not 0).
    # But also exit code 2 since it's not a found element!
    echo "$(expr $i - 2)"
    return 2
  fi; fi
  return 1
}

## CAUTION
## Shitty-ass arguments handling incoming!!
## CAUTION
while getopts "h?yuir:c:C:k:a:j:p:d:" opt
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
  d) if expr match "$OPTARG" '^[0-9a-fA-F]\+$' >$dn
     then SPACECP_SERVERID=$(echo "$OPTARG" | tr '[:upper:]' '[:lower:]')
     else printf '%s\n' "'$OPTARG' is not a valid server id."; exit 1
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

install_spacecp () {

  ## Installing SpaceCP
  ## Checks for already existing files to not make the user redownload everything over an over again if he calls the
  ##  script wrongly or has some faulty values at first.


  temp=$(mktemp -d -t 'spacecp')


  printf '%s' "[     ] Getting configuration..."
  curl -sLA "SpaceCP Script $SPACECP______" \
  "$SPACECP_URL/api/getServerConfigs?key=$SPACECP_APIKEY&serverid=$SPACECP_SERVERID" -o "$temp/spacecp_conf.zip"
  [ -e "$temp/spacecp_conf.zip" ] || (printf '\r[ERROR] \n%s\n' \
    "Could not fetch the configuration under '$SPACECP_SERVAPI'." && exit 1) || return 1
  unzip -uo "$temp/spacecp_conf.zip" >$dn
  [ -e "$SPACECP_CONFFILE" ] || (printf '\r[ERROR] \n%s\n' "Could not extract/find '$SPACECP_CONFFILE'." && exit 1) \
                             || return 1
#  echo "$spacecp_conf" > "$SPACECP_CONFFILE"
#  [ -s "$SPACECP_CONFFILE" ] || (printf '\r[ERROR] \n%s\n' "Could not write to '$SPACECP_CONFFILE'." && exit 1) \
#                             || return 1
  printf '\r%s\n' "[OK]    "


  printf '%s' "[     ] Getting properties..."
  spacecp_prop=$(curl -sLA "SpaceCP Script $SPACECP______" "$SPACECP_SERVAPI/$SPACECP_APIKEY/properties")
  [ -z "$spacecp_prop" ] && printf '\r[ERROR] \n%s\n' "Could not fetch the properties under '$SPACECP_SERVAPI'." \
                         && return 1
  [ -s "$SPACECP_PROPFILE" ] || echo "$spacecp_prop" > "$SPACECP_PROPFILE"
  [ -s "$SPACECP_PROPFILE" ] || (printf '\r[ERROR] \n%s\n' "Could not write to '$SPACECP_PROPFILE'." && exit 1) \
                             || return 1
  printf '\r%s\n' "[OK]    "


  printf '%s' "[     ] $SPACECP_SERVJAR..."
  if ! [ -s "$SPACECP_SERVJAR" ]
  then
    ## UGLY HARDCODED STUFF
    if expr "$SPACECP_SERVJAR" : "craftbukkit\.jar$" >$dn
    then
      dlurl=$(curl -sLA "SpaceCP Script $SPACECP______" -H "accept:application/json" \
      "$SPACECP_GDNAPIURL/jar/3/channel/5/build?sort=build.build.desc" | grep -om1 '"url"[ ]*:[ ]*"[^"]*"' \
      | head -n1 | sed 's/"url"[ ]*:[ ]*"\([^"]*\)"/\1/')
      [ -z "$dlurl" ] && printf '\r[ERROR] \n%s\n' \
        "Could not find any recommended build for '$SPACECP_SERVJAR' from SpaceGDN under\
 '$SPACECP_GDNAPIURL/jar/3/channel/5/build?sort=build.build.desc'." && return 1
      curl -sLA "SpaceCP Script $SPACECP_____" "$dlurl" -o "$SPACECP_SERVJAR"
      [ -s "$SPACECP_SERVJAR" ] || (printf '\r[ERROR] \n%s\n' \
        "Could not fetch the server jar '$(basename "$SPACECP_SERVJAR")' from '$dlurl'." && exit 1) || return 1
    else
      printf '\r[ERROR] \n%s\n' "Could not find '$SPACECP_SERVJAR'. Please install it first."
      return 1
    fi
    ## PHEW, IT'S OVER (FOR NOW)
  fi
  printf '\r%s\n' "[OK]    "


  printf '%s' "[     ] $SPACECP_RTKJAR..."
  if ! [ -s "$SPACECP_RTKJAR" ]
  then
    dlurl=$(curl -sLA "SpaceCP Script $SPACECP______" \
    "$SPACECP_DLAPIURL/software/remotetoolkit?channel=rec" | grep -om1 '"url"[ ]*:[ ]*"[^"]*"' \
    | head -n1 | sed 's/"url"[ ]*:[ ]*"\([^"]*\)"/\1/')
    [ -z "$dlurl" ] && printf '\r[ERROR] \n%s\n' \
      "Could not find any recommended build for '$SPACECP_RTKJAR' from SpaceDL under\
 '$SPACECP_DLAPIURL/software/remotetoolkit?channel=rec'." && return 1
    curl -sLA "SpaceCP Script $SPACECP_____" "$dlurl" -o "$SPACECP_RTKJAR"
    [ -s "$SPACECP_RTKJAR" ] || (printf '\r[ERROR] \n%s\n' \
      "Could not fetch the Remotetoolkit jar '$(basename "$SPACECP_RTKJAR")' from '$dlurl'." && exit 1) || return 1
  fi
  printf '\r%s\n' "[OK]    "


  printf '%s' "[     ] $SPACECP_RPJAR..."
  if ! [ -s "$SPACECP_RPJAR" ]
  then
    dlurl=$(curl -sLA "SpaceCP Script $SPACECP______" \
    "$SPACECP_DLAPIURL/software/remotetoolkitplugin?channel=rec" | grep -om1 '"url"[ ]*:[ ]*"[^"]*"' \
    | head -n1 | sed 's/"url"[ ]*:[ ]*"\([^"]*\)"/\1/')
    [ -z "$dlurl" ] && printf '\r[ERROR] \n%s\n' \
      "Could not find any recommended build for '$SPACECP_RPJAR' from SpaceDL under\
 '$SPACECP_DLAPIURL/software/remotetoolkitplugin?channel=rec'." && return 1
    curl -sLA "SpaceCP Script $SPACECP_____" "$dlurl" -o "$SPACECP_RPJAR"
    [ -s "$SPACECP_RPJAR" ] || (printf '\r[ERROR] \n%s\n' \
      "Could not fetch the RTKplugin jar '$(basename "$SPACECP_RPJAR")' from '$dlurl'." && exit 1) || return 1
  fi
  printf '\r%s\n' "[OK]    "


  printf '%s' "[     ] $SPACECP_SMJAR..."
  if ! [ -s "$SPACECP_SMJAR" ]
  then
    dlurl=$(curl -sLA "SpaceCP Script $SPACECP______" \
    "$SPACECP_DLAPIURL/software/spacecp_module?channel=rec" | grep -om1 '"url"[ ]*:[ ]*"[^"]*"' \
    | head -n1 | sed 's/"url"[ ]*:[ ]*"\([^"]*\)"/\1/')
    [ -z "$dlurl" ] && printf '\r[ERROR] \n%s\n' \
      "Could not find any recommended build for '$SPACECP_SMJAR' from SpaceDL under\
 '$SPACECP_DLAPIURL/software/spacecp_module?channel=rec'." && return 1
    curl -sLA "SpaceCP Script $SPACECP_____" "$dlurl" -o "$SPACECP_SMJAR"
    [ -s "$SPACECP_SMJAR" ] || (printf '\r[ERROR] \n%s\n' \
      "Could not fetch the SpaceModule jar '$(basename "$SPACECP_SMJAR")' from '$dlurl'." && exit 1) || return 1
  fi
  printf '\r%s\n' "[OK]    "


  printf '%s' "[     ] SpaceCP Libraries..."
  libver=$(cat "$SPACECP_CONFFILE" | sed -n '/^libraries:$/,/^[^ ]\+/s/^  version: \([0-9]\+\)/\1/p')
  libjson=$(curl -sLA "SpaceCP Script $SPACECP_____" "$SPACECP_DLAPIURL/software/spacecp_libraries?channel=rec")
  newliburl=$(echo "$libjson" | grep -om1 '"url"[ ]*:[ ]*"[^"]*"' | head -n1 | sed 's/"url"[ ]*:[ ]*"\([^"]*\)"/\1/')
  newlibver=$(echo "$libjson" | grep -om1 '"createdAt"[ ]*:[ ]*"[^"]*"' \
              | head -n1 | sed 's/"createdAt"[ ]*:[ ]*"\([^"]*\)"/\1/')
  if [ -z "$libver" ]
  then
    if [ -n "$newliburl" ] && [ -n "$newlibver" ]
    then
      ## NEW CONF FOUND
      curl -sLA "SpaceCP Script $SPACECP_____" "$newliburl" -o "$temp/spacecp_libraries.zip"
      [ -s "spacecp_libraries.zip" ] || (printf '\r[ERROR] \%s\n' \
                                         "Could not fetch the SpaceCP Libraries from '$newliburl'." && exit 1) \
                                     || return 1
      unzip -uo "$temp/spacecp_libraries.zip" >$dn
    else
      printf '\r[ERROR] \n%s\n' "Could not fetch the SpaceCP Libraries from SpaceDL under\
 '$SPACECP_DLAPIURL/software/spacecp_libraries?channel=rec'."
      return 1
    fi
  else
    if [ -n "$newliburl" ] && [ -n "$newlibver" ]
    then
      if [ "$libver" -lt "$newlibver" ]
      then
        ## CONF EXISTS AND NEW CONF FOUND
        curl -sLA "SpaceCP Script $SPACECP_____" "$newliburl" -o "$temp/spacecp_libraries.zip"
        [ -s "spacecp_libraries.zip" ] || (printf '\r[ERROR] \%s\n' \
                                           "Could not update the SpaceCP Libraries from '$newliburl'." && exit 1) \
                                       || return 0
        unzip -uo "$temp/spacecp_libraries.zip" >$dn
      fi
    fi
  fi
  printf '\r%s\n' "[OK]    "


  printf '%s' "[     ] Removing temporary files..."
  if rm -r "$temp"
  then printf '\r%s\n' "[OK]    "
  fi


  return 0

}

update_spacecp () {

  ## NOT FULLY IMPLEMENTED YET
  return 0

#  wrapper_channel=$(cat "$SPACECP_CONFFILE" | sed -n '/^wrapper:$/,/^[^ ]\+/s/^  channel: \([a-zA-Z]\+\)/\1/p' \
#                    | tr '[:upper:]' '[:lower:]')
#  case "$wrapper_channel" in
#    development) spacecp_channel='dev';;
#    recommended) spacecp_channel='rec';;
#    latest) spacecp_channel='.*';;
#  esac
#  spacecp_channel=$(cat "$SPACECP_CONFFILE" | sed -n '/^spacecp:$/,/^[^ ]\+/s/^  channel: \([a-zA-Z]\+\)/\1/p' \
#                    | tr '[:upper:]' '[:lower:]')
#  case "$spacecp_channel" in
#    development) spacecp_channel='dev';;
#    recommended) spacecp_channel='rec';;
#    latest) spacecp_channel='.*';;
#  esac
#  spacecp_build=$(cat "$SPACECP_CONFFILE" | sed -n '/^spacecp:$/,/^[^ ]\+/s/^  build: \([a-zA-Z]\+\)/\1/p' \
#                  | tr '[:upper:]' '[:lower:]')
#  spacecp_autoupdate=$(cat "$SPACECP_CONFFILE" | sed -n '/^spacecp:$/,/^[^ ]\+/s/^  auto-update: \([a-zA-Z]\+\)/\1/p' \
#                       | tr '[:upper:]' '[:lower:]')
#  [ -z "$SPACECP_APIKEY" ] && SPACECP_APIKEY=$(cat "$SPACECP_CONFFILE" \
#                                               | sed -n '/^spacecp:$/,/^[^ ]\+/s/^  apikey: \([a-zA-Z]\+\)/\1/p' \
#                                               | tr '[:upper:]' '[:lower:]')
#  if [ -z "$slug" ] || [ -z "$wrapper_channel" ] || [ -z "$server_channel" ] || [ -z "$server_build" ] \
#     || [ -z "$server_autoupdate" ] || [ -z "$spacecp_channel" ] || [ -z "$spacecp_build" ] \
#     || [ -z "$spacecp_autoupdate" ] || [ -z "$SPACECP_APIKEY" ]
#  then
#    printf '%s\n' "ERROR: Some variables could not be found in '$SPACECP_CONFFILE', your configuration may be damaged."
#    return 1
#  fi
#  # RTK Update Check
#  artifacts_json=$(curl -sLA "SpaceCP Script $SPACECP______" -H "accept:application/json" \
#                   "$SPACECP_DLAPIURL/software/remotetoolkit" | json_parse artifacts)
#  for i in $(seq 1 $(echo "$artifacts_json" | json_parse))
#  do
#    
#  done
#
#  # RTK Plugin Update Check
#  artifacts_json=$(curl -sLA "SpaceCP Script $SPACECP______" -H "accept:application/json" \
#                   "$SPACECP_DLAPIURL/v1/software/remotetoolkitplugin" | json_parse artifacts)
#  for i in $(seq 1 $(echo "$artifacts_json" | json_parse))
#  do
#    
#  done
#
#  # SpaceCP Update Check
#  artifacts_json=$(curl -sLA "SpaceCP Script $SPACECP______" -H "accept:application/json" \
#                   "$SPACECP_DLAPIURL/software/spacecp_module" | json_parse artifacts)
#  update_url=''
#  for i in $(seq 1 $(echo "$artifacts_json" | json_parse))
#  do
#    artifact="$(echo "$artifact_json" | json_parse $i)"
#    if expr "$(echo "$artifact" | json_parse channel)" : '^'"$spacecp_channel"'$' >$dn
#    then
#      if [ "$(echo "$artifact" | json_parse createdAt)" -gt "$(date '+%s')" ]
#      then
#        update_url="$(echo "$artifact" | json_parse url)"
#        break
#      fi
#    fi
#  done
#  if [ -n "$update_url" ]
#  then
#    hash="$(echo "$artifact" | json_parse hash)"
#    curl -sLA "SpaceCP Script $SPACECP______" "$update_url" -o "$SPACECP_SMJAR"
#    if [ "$hash" = "$(md5sum "$SPACECP_SMJAR" | cut -d' ' -f1)" ]
#    then
#      ##
#      ## UPDATED SPACECP MODULE
#      ##
#    else
#      ##
#      ## FAILED TO UPDATE SPACECP MODULE
#      ##
#    fi
#  fi
#
#  ## TO DO
#  ## Do updating stuff
#  ## lolwat dlapi?
#  ## TO DO
}

start_spacecp () {
  printf '%s' "[     ] Starting SpaceCP..."
  ## Actually starting RTK now and checking the exit status.
  ## It is EXTREMELY important for the starting command to automatically fork itself into the background,
  ##  or else we can't correctly check if it started to begin with, and more importantly,
  ##  cannot send a POST request to the SpaceCP servers to notify them that the server started!
  if eval "$SPACECP_STARTCOMMAND" "$SPACECP_STARTARGS" "$SPACECP_JAVABIN" "$SPACECP_JAVAARGS" \
          "$SPACECP_RTKJAR" "$SPACECP_RTKARGS"
  then printf '\r%s\n' "[OK]    Starting SpaceCP... [$SPACECP_STARTCOMMAND]"
  else printf '\r[ERROR]\n%s\n' "Could not start '$SPACECP_JAVABIN $SPACECP_JAVAARGS $SPACECP_RTKJAR $SPACECP_RTKARGS'\
 with '$SPACECP_STARTCOMMAND $SPACECP_STARTARGS'."
  fi
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
  then # Already installed but couldn't successfully update
    printf '%s' "Could not update SpaceCP. Start anyway [Y/n]? "
    [ $ultima_yes -eq 1 ] && yn="y" && printf 'Y' || read yn
    expr match "$yn" '^y.*' >$dn && yn=''
  fi
  if [ -z "$yn" ]
  then
    if ! start_spacecp
    then # Already installed but couldn't successfully start
      printf '%s\n' "Could not start SpaceCP."
      exit 1
    fi
  fi
else
  printf '%s' "No SpaceCP configuration found. Install SpaceCP [Y/n]? "
  [ $ultima_yes -eq 1 ] && yn="y" && printf 'Y' || read yn
  expr match "$yn" '^y.*' >$dn && yn=''
  if [ -z "$yn" ]
  then
    if install_spacecp
    then # Successfully installed
      printf '%s\n' "SpaceCP installation succesfull. Starting SpaceCP for the first time."
      if ! start_spacecp
      then # Successfully installed but not successfully started
        printf '%s\n' "Could not start SpaceCP."
        exit 1
      else # Successfully installed and started
        curl -sLA "SpaceCP Script $SPACECP______" -X POST "$SPACECP_SERVAPI/$SPACECP_APIKEY/start"
      fi
    else # Not successfully installed
      printf '%s\n' "Could not install SpaceCP."
      exit 1
    fi
  fi
fi
