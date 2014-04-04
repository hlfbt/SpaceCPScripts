#!/bin/sh

# Dem keys!!
SPACECP_APIKEY=""
# Mmh more tasty variables...
SPACECP_SERVID=""
# If you haven't guessed already, I'm going to declare all the important variables here
SPACECP_URL="http://spacecp.net"
# Yes, yes, variables, good, good
SPACECP_SERVJAR="craftbukkit.jar"
# There are a bunch more...
SPACECP_CONFFILE="SpaceCP/config.yml"
# Yup, and more...
SPACECP_RTKJAR="remotetoolkit.jar"
# ...
SPACECP_SMJAR="toolkit/modules/spacemodule.jar"
# soo...
SPACECP_RPJAR="plugins/rtkplugin.jar"
# glaring display last night, eh?
SPACECP_DLAPIURL="http://dl.api.xereo.net/v1"
# well fuck you than, if you're not gonna talk you might as well just go UGH
SPACECP_GDNAPIURL="http://gdn.api.xereo.net/v1"
SPACECP______="0.$(((5*2*10)/(4*5*5)))"
[ "$_" != "$0" ] || sourced=1
___=""
____=""
_____=""
# Change the following two variables to use a custom start command
# IMPORTANT: Arguments must be in a string!
# DEFAULT: "start-stop-daemon"
SPACECP_STARTCOMMAND="start-stop-daemon"
# DEFAULT: "--start --pidfile 'spacecp.pid' --chdir '$(pwd)' --background --make-pidfile --exec"
SPACECP_STARTPRE="--start --pidfile 'spacecp.pid' --chdir '$(pwd)' --background --make-pidfile --exec"
SPACECP_STARTSU=""
# Also comment out those if blocks to not make it overwrite it accidentally
if command -v tmux >/dev/null 2>&1
# DEFAULT: "tmux"
# DEFAULT: "new-session -d -s 'SpaceCP' \""
# DEFAULT: "\""
then SPACECP_STARTCOMMAND="tmux" && SPACECP_STARTPRE="new-session -d -s 'SpaceCP' \"" && SPACECP_STARTSU="\""
elif command -v screen >/dev/null 2>&1
# DEFAULT: "screen"
# DEFAULT: "-dmLS 'SpaceCP'"
then SPACECP_STARTCOMMAND="screen" && SPACECP_STARTPRE="-dmLS 'SpaceCP'"
fi
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
o='/dev/null'

show_help () {
  printf '%s\n' "wow it's a fucking help"; # TODO help stuff goes here I guess...
}
__ () {
  printf '%s\n' "$___";
}
ask () {
   printf '%s [Y/n] ' "$1"
   [ "$ultima_yes" -eq 1 ] && printf "Y\n" && return 0
   read yn
   case "$yn" in [Yy]*|'') return 0;; esac
   return 1
}

[ "$1" = "--" ] && shift
_____=$(awk 'BEGIN{printf "\x2d\x2d\x65\x74\x63"}')
____=$(awk 'BEGIN{printf "\x6c\x6f\x6c"}')
___=$(awk 'BEGIN{printf "\x75\x72\x20\x61\x20\x66\x67\x74"}')
while [ -n "$1" ]
do
  case "$1" in
    --*=*)
      par=$(printf "$1"|sed 's/^\([^=]\)\+=.*$/\1/')
      arg=$(printf "$1"|sed 's/^[^=]\+=\(.*\)$/\1/')
      ds=0
      ;;
    --*)
      par="$1"
      arg="$2"
      ds=1
      ;;
    -*)
      par="$1"
      arg="$2"
      ds=1
      ;;
    *)
      printf '%s\n' "Invalid argument '$1'"
      [ -n "$sourced" ] && return 1 || exit 1
      ;;
  esac

  case "$par" in
    --help|-h|-\?)
      show_help
      [ -n "$sourced" ] && return 0 || exit 0
      ;;
    --always-yes|-y) ultima_yes=1;;
    --update|-U) force_update=1;;
    --install|-I) force_update=2;;
    --url|-u) SPACECP_URL="$arg"; [ "$ds" -eq 1 ] && shift;;
    --rtk-jar|-r)
      if [ $force_update -ne 2 -a -s "$arg" ]
      then SPACECP_RTKJAR="$arg"
      else
        printf '%s\n' "'$arg' is not a valid RTK jar."
        [ -n "$sourced" ] && return 1 || exit 1
      fi
      [ "$ds" -eq 1 ] && shift;;
    --config|-c)
      if [ $force_update -ne 2 -a -s "$arg" ]
      then SPACECP_CONFFILE="$arg"
      else
        printf '%s\n' "'$arg' is not a valid configuration file."
        [ -n "$sourced" ] && return 1 || exit 1
      fi
      [ "$ds" -eq 1 ] && shift;;
    --api-key|-k) if printf "$arg"|awk '{if(!match($1,"^[0-9a-fA-F]+$")){exit 2}}' >$o
       then SPACECP_APIKEY=$(printf '%s' "$arg" | tr '[:upper:]' '[:lower:]')
       else printf '%s\n' "'$arg' is not a valid API key."; [ -n "$sourced" ] && return 1 || exit 1
       fi
       [ "$ds" -eq 1 ] && shift;;
    --server-id|-i) if printf "$arg"|awk '{if(!match($1,"^[0-9a-fA-F]+$")){exit 2}}' >$o
       then SPACECP_SERVID=$(printf '%s' "$arg" | tr '[:upper:]' '[:lower:]')
       else printf '%s\n' "'$arg' is not a valid server id."; [ -n "$sourced" ] && return 1 || exit 1
       fi
       [ "$ds" -eq 1 ] && shift;;
    --server-jar|-j)
      if [ $force_update -ne 2 -a -s "$arg" ]
      then SPACECP_SERVJAR="$arg"
      else
        printf '%s\n' "'$arg' is not a valid server jar/file."
        [ -n "$sourced" ] && return 1 || exit 1
      fi
      [ "$ds" -eq 1 ] && shift;;
    $_____) if [ "$arg" = "$____" ]; then __; [ -n "$sourced" ] && return 1 || exit 1; fi;;
    *)
      printf '%s\n' "Invalid argument '$1'"
      [ -n "$sourced" ] && return 1 || exit 1
      ;;
  esac

  shift
done

install_spacecp () {

  ## Installing SpaceCP
  ## Forces install (overwrites) if any argument is given.


  tmp=$(TMPDIR=$(pwd) mktemp -d 'spacecptmp_XXXXXXXXXX')
  [ "$force_update" -eq 2 ] && set 1


  printf '%s' "[     ] Getting configuration..."
  curl -sLA "SpaceCP Script $SPACECP______" -o "$tmp/spacecp_conf.zip" --create-dirs \
  "$SPACECP_URL/api/getServerConfigs?key=$SPACECP_APIKEY&serverid=$SPACECP_SERVID"
  [ -s "$tmp/spacecp_conf.zip" ] || (printf '\r[ERROR] \n %s\n' "Could not fetch the configuration under\
 '$SPACECP_URL/api/getServerConfigs?key=$SPACECP_APIKEY&serverid=$SPACECP_SERVID'." && exit 1) || return 1
  if [ -n "$1" ]
  then unzip -o "$tmp/spacecp_conf.zip" >$o
  else unzip -uo "$tmp/spacecp_conf.zip" >$o
  fi
  [ -s "$SPACECP_CONFFILE" ] || (printf '\r[ERROR] \n %s\n' "Could not extract/find '$SPACECP_CONFFILE'." && exit 1) \
                             || return 1
  printf '\r%s\n' "[OK]    "


  thisdl="$SPACECP_SERVJAR"
  thisurl="$SPACECP_GDNAPIURL/jar/2/channel/4/build?sort=build.build.desc"
  thisbase=$(basename "$thisdl")
  printf '%s' "[     ] $thisdl..."
  if [ -n "$1" ] || ([ -s "$thisdl" ] && ask "'$thisdl' already exists. Overwrite?") || ! [ -s "$thisdl" ]
  then
    ## HARDCODED STUFF ;_;
    if printf "$thisdl"|awk '{if(!match($1,"craftbukkit.jar$")){exit 2}}' >$o
    then
      dljson=$(curl -sLA "SpaceCP Script $SPACECP______" -H "accept:application/json" "$thisurl")
      dlurl=$(printf '%s' "$dljson" | grep -om1 '"url"[ ]*:[ ]*"[^"]\+"' \
              | head -n1 | sed -n 's/"url"[ ]*:[ ]*"\([^"]\+\)"/\1/p')
      dlhash=$(printf '%s' "$dljson" | grep -om1 '"checksum"[ ]*:[ ]*"[^"]\+"' \
               | head -n1 | sed -n 's/"checksum"[ ]*:[ ]*"\([^"]\+\)"/\1/p')
      [ -z "dlhash" ] || [ -z "$dlurl" ] && printf '\r[ERROR] \n %s\n' \
                                            "Could not find any recommended build for '$thisdl' under '$thisurl'." \
                                         && return 1
      curl -sLA "SpaceCP Script $SPACECP______" -o "$tmp/$thisbase" --create-dirs "$dlurl"
      [ -s "$tmp/$thisbase" ] || (printf '\r[ERROR] \n %s\n' "Could not fetch '$thisbase' from '$dlurl'." && exit 1) \
                              || return 1
      thishash=$(openssl md5 "$tmp/$thisbase" | sed 's/.* //')
      if [ -z "$dlhash" ] || [ "$thishash" = "$dlhash" ]
      then mkdir -p $(dirname "$thisdl") && mv "$tmp/$thisbase" "$thisdl"
      else
        printf '\t[ERROR] \n %s\n' "Wrong hash '$thishash', should be '$dlhash'."
        return 1
      fi
    else
      printf '\r[ERROR] \n %s\n' "Could not find '$thisdl'. Please install it first."
      return 1
    fi
  fi
  printf '\r%s\n' "[OK]    "


  thisdl="$SPACECP_RTKJAR"
  thisurl="$SPACECP_DLAPIURL/software/remotetoolkit?channel=rec"
  thisbase=$(basename "$thisdl")
  printf '%s' "[     ] $thisdl..."
  if [ -n "$1" ] || ([ -s "$thisdl" ] && ask "'$thisdl' already exists. Overwrite?") || ! [ -s "$thisdl" ]
  then
    dljson=$(curl -sLA "SpaceCP Script $SPACECP______" -H "accept:application/json" "$thisurl")
    dlurl=$(printf '%s' "$dljson" | grep -om1 '"url"[ ]*:[ ]*"[^"]\+"' \
            | head -n1 | sed -n 's/"url"[ ]*:[ ]*"\([^"]\+\)"/\1/p')
    dlhash=$(printf '%s' "$dljson" | grep -om1 '"hash"[ ]*:[ ]*"[^"]\+"' \
             | head -n1 | sed -n 's/"hash"[ ]*:[ ]*"\([^"]\+\)"/\1/')
    [ -z "dlhash" ] || [ -z "$dlurl" ] && printf '\r[ERROR] \n %s\n' \
                                          "Could not find any recommended build for '$thisdl' under '$thisurl'." \
                                       && return 1
    curl -sLA "SpaceCP Script $SPACECP______" -o "$tmp/$thisbase" --create-dirs "$dlurl"
    [ -s "$tmp/$thisbase" ] || (printf '\r[ERROR] \n %s\n' "Could not fetch '$thisbase' from '$dlurl'." && exit 1) \
                            || return 1
    thishash=$(openssl sha1 "$tmp/$thisbase" | sed 's/.* //')
    if [ -z "$dlhash" ] || [ "$thishash" = "$dlhash" ]
    then mkdir -p $(dirname "$thisdl") && mv "$tmp/$thisbase" "$thisdl"
    else
      printf '\t[ERROR] \n %s\n' "Wrong hash '$thishash', should be '$dlhash'."
      return 1
    fi
  else
    printf '\r[ERROR] \n %s\n' "Could not find '$thisdl'. Please install it first."
    return 1
  fi
  printf '\r%s\n' "[OK]    "


  thisdl="$SPACECP_RPJAR"
  thisurl="$SPACECP_DLAPIURL/software/remotetoolkitplugin?channel=rec"
  thisbase=$(basename "$thisdl")
  printf '%s' "[     ] $thisdl..."
  if [ -n "$1" ] || ([ -s "$thisdl" ] && ask "'$thisdl' already exists. Overwrite?") || ! [ -s "$thisdl" ]
  then
    dljson=$(curl -sLA "SpaceCP Script $SPACECP______" -H "accept:application/json" "$thisurl")
    dlurl=$(printf '%s' "$dljson" | grep -om1 '"url"[ ]*:[ ]*"[^"]\+"' \
            | head -n1 | sed -n 's/"url"[ ]*:[ ]*"\([^"]\+\)"/\1/p')
    dlhash=$(printf '%s' "$dljson" | grep -om1 '"hash"[ ]*:[ ]*"[^"]\+"' \
             | head -n1 | sed -n 's/"hash"[ ]*:[ ]*"\([^"]\+\)"/\1/p')
    [ -z "dlhash" ] || [ -z "$dlurl" ] && printf '\r[ERROR] \n %s\n' \
                                          "Could not find any recommended build for '$thisdl' under '$thisurl'." \
                                       && return 1
    curl -sLA "SpaceCP Script $SPACECP______" -o "$tmp/$thisbase" --create-dirs "$dlurl"
    [ -s "$tmp/$thisbase" ] || (printf '\r[ERROR] \n %s\n' "Could not fetch '$thisbase' from '$dlurl'." && exit 1) \
                            || return 1
    thishash=$(openssl sha1 "$tmp/$thisbase" | sed 's/.* //')
    if [ -z "$dlhash" ] || [ "$thishash" = "$dlhash" ]
    then mkdir -p $(dirname "$thisdl") && mv "$tmp/$thisbase" "$thisdl"
    else
      printf '\t[ERROR] \n %s\n' "Wrong hash '$thishash', should be '$dlhash'."
      return 1
    fi
  else
    printf '\r[ERROR] \n %s\n' "Could not find '$thisdl'. Please install it first."
    return 1
  fi
  printf '\r%s\n' "[OK]    "


  thisdl="$SPACECP_SMJAR"
  thisurl="$SPACECP_DLAPIURL/software/spacecp_module?channel=rec"
  thisbase=$(basename "$thisdl")
  printf '%s' "[     ] $thisdl..."
  if [ -n "$1" ] || ([ -s "$thisdl" ] && ask "'$thisdl' already exists. Overwrite?") || ! [ -s "$thisdl" ]
  then
    dljson=$(curl -sLA "SpaceCP Script $SPACECP______" -H "accept:application/json" "$thisurl")
    dlurl=$(printf '%s' "$dljson" | grep -om1 '"url"[ ]*:[ ]*"[^"]\+"' \
            | head -n1 | sed -n 's/"url"[ ]*:[ ]*"\([^"]\+\)"/\1/p')
    dlhash=$(printf '%s' "$dljson" | grep -om1 '"checksum"[ ]*:[ ]*"[^"]\+"' \
             | head -n1 | sed -n 's/"checksum"[ ]*:[ ]*"\([^"]\+\)"/\1/p')
    [ -z "dlhash" ] || [ -z "$dlurl" ] && printf '\r[ERROR] \n %s\n' \
                                          "Could not find any recommended build for '$thisdl' under '$thisurl'." \
                                       && return 1
    curl -sLA "SpaceCP Script $SPACECP______" -o "$tmp/$thisbase" --create-dirs "$dlurl"
    [ -s "$tmp/$thisbase" ] || (printf '\r[ERROR] \n %s\n' "Could not fetch '$thisbase' from '$dlurl'." && exit 1) \
                            || return 1
    thishash=$(openssl sha1 "$tmp/$thisbase" | sed 's/.* //')
    if [ -z "$dlhash" ] || [ "$thishash" = "$dlhash" ]
    then mkdir -p $(dirname "$thisdl") && mv "$tmp/$thisbase" "$thisdl"
    else
      printf '\t[ERROR] \n %s\n' "Wrong hash '$thishash', should be '$dlhash'."
      return 1
    fi
  else
    printf '\r[ERROR] \n %s\n' "Could not find '$thisdl'. Please install it first."
    return 1
  fi
  printf '\r%s\n' "[OK]    "


  printf '%s' "[     ] SpaceCP Libraries..."
  libver=$(sed -n '/^libraries:$/,/^[^ ]\+/s/^  version: \([0-9]\+\)/\1/p' "$SPACECP_CONFFILE")
  libjson=$(curl -sLA "SpaceCP Script $SPACECP______" "$SPACECP_DLAPIURL/software/spacecp_libraries?channel=rec")
  newliburl=$(printf '%s' "$libjson" \
              | grep -om1 '"url"[ ]*:[ ]*"[^"]*"' \
              | head -n1 | sed -n 's/"url"[ ]*:[ ]*"\([^"]*\)"/\1/p')
  newlibver=$(printf '%s' "$libjson" \
              | grep -om1 '"createdAt"[ ]*:[ ]*[0-9]\+' \
              | head -n1 | sed -n 's/"createdAt"[ ]*:[ ]*\([0-9]\+\)/\1/p')
  newlibhash=$(printf '%s' "$libjson" \
               | grep -om1 '"hash"[ ]*:[ ]*"[a-fA-F0-9]\+"' \
               | head -n1 | sed -n 's/"hash"[ ]*:[ ]*"\([a-fA-F0-9]\+\)"/\1/p')
  if [ -n "$newliburl" ] && [ -n "$newlibver" ]
  then
    if [ -n "$1" ] || [ -z "$libver" ] || [ "$libver" -lt "$newlibver" ]
    then
      curl -sLA "SpaceCP Script $SPACECP______" -o "$tmp/spacecp_libraries.zip" --create-dirs "$newliburl"
      if [ -s "$tmp/spacecp_libraries.zip" ]
      then
        thishash=$(openssl sha1 "$tmp/spacecp_libraries.zip" | sed 's/.* //')
        if [ -z "$dlhash" ] || [ "$thishash" = "$newlibhash" ]
        then
          if [ -n "$1" ]
          then unzip -o "$tmp/spacecp_libraries.zip" >$o
          else unzip -uo "$tmp/spacecp_libraries.zip" >$o
          fi
          if grep '^libraries:$' "$SPACECP_CONFFILE" >$o
          then
            if grep '^  version:' "$SPACECP_CONFFILE" >$o
            then
              sed -i '/^libraries:$/,/^[^ ]\+/s/^  version:.*$/  version: '"$newlibver"'/' "$SPACECP_CONFFILE" >$o
            else sed -i '/^libraries:$/a\
  version: '"$newlibver" "$SPACECP_CONFFILE" >$o
            fi
            if grep '^  hash:' "$SPACECP_CONFFILE" >$o
            then
              sed -i '/^libraries:$/,/^[^ ]\+/s/^  hash:.*$/  hash: '"$thishash"'/' "$SPACECP_CONFFILE" >$o
            else sed -i '/^libraries:$/a\
  hash: '"$thishash" "$SPACECP_CONFFILE" >$o
            fi
          else
            printf '\n' >> "$SPACECP_CONFFILE"
            printf '%s\n' "libraries:" "  version: $newlibver" "  hash: $thishash" >> "$SPACECP_CONFFILE"
          fi
        else printf '\r[ERROR] \n %s\n' "Wrong hash '$thishash', should be '$newlibhash'." && return 1
        fi
      else printf '\r[ERROR] \n %s\n' "Could not fetch the SpaceCP Libraries from '$newliburl'." && return 1
      fi
    fi
  else
    printf '\r[ERROR] \n %s\n' "Could not find any SpaceCP Libraries on SpaceDL under\
 '$SPACECP_DLAPIURL/software/spacecp_libraries?channel=rec'."
    return 1
  fi
  printf '\r%s\n' "[OK]    "


  printf '%s' "[     ] Removing temporary files..."
  if rm -r "$tmp"
  then printf '\r%s\n' "[OK]    "
  fi


  return 0

}

update_spacecp () {

  tmp=$(TMPDIR=$(pwd) mktemp -d 'spacecptmp_XXXXXXXXXX')
  [ "$force_update" -eq 1 ] && set 1


  thisdl="$SPACECP_RTKJAR"
  thischannel=$(sed -n '/^wrapper:$/,/^[^ ]\+/s/^  channel: \([a-zA-Z]\+\)/\1/p' "$SPACECP_CONFFILE")
  case "$thischannel" in
  development) thisurl="$SPACECP_DLAPIURL/software/remotetoolkit?channel=dev";;
  recommended) thisurl="$SPACECP_DLAPIURL/software/remotetoolkit?channel=rec";;
  *) thisurl="$SPACECP_DLAPIURL/software/remotetoolkit";;
  esac
  thisbase=$(basename "$thisdl")
  thisstat=$(stat -c '%Y' "$thisdl" 2>$o)
  printf '%s' "[     ] $thisdl..."
  dljson=$(curl -sLA "SpaceCP Script $SPACECP______" -H "accept:application/json" "$thisurl")
  dlurl=$(printf '%s' "$dljson" | grep -om1 '"url"[ ]*:[ ]*"[^"]\+"' \
          | head -n1 | sed -n 's/"url"[ ]*:[ ]*"\([^"]\+\)"/\1/p')
  dlhash=$(printf '%s' "$dljson" | grep -om1 '"hash"[ ]*:[ ]*"[^"]\+"' \
           | head -n1 | sed -n 's/"hash"[ ]*:[ ]*"\([^"]\+\)"/\1/p')
  dlstat=$(printf '%s' "$dljson" | grep -om1 '"createdAt"[ ]*:[ ]*[0-9]\+' \
           | head -n1 | sed -n 's/"createdAt"[ ]*:[ ]*\([0-9]\+\)/\1/p')
  if [ -n "dlhash" ] && [ -n "$dlurl" ] && [ -n "$dlstat" ]
  then
    if [ -n "$1" ] || ! [ -s "$thisdl" ] || [ "$dlstat" -gt "$thisstat" ]
    then
      curl -sLA "SpaceCP Script $SPACECP______" -o "$tmp/$thisbase" --create-dirs "$dlurl"
      if [ -s "$tmp/$thisbase" ]
      then
        thishash=$(openssl sha1 "$tmp/$thisbase" | sed 's/.* //')
        if [ -z "$dlhash" ] || [ "$thishash" = "$dlhash" ]
        then
          if mkdir -p $(dirname "$thisdl") && mv "$tmp/$thisbase" "$thisdl"
          then printf '\r%s\n' "[OK]    $thisdl updated!"
          fi
        else printf '\t[ERROR] \n %s\n' "Wrong hash '$thishash', should be '$dlhash'."
        fi
      else printf '\r[ERROR] \n %s\n' "Could not fetch '$thisbase' from '$dlurl'."
      fi
    else printf   "\r[OK]    $thisdl already up to date.\n"
    fi
  else printf '\r[ERROR] \n %s\n' "Could not find any $thischannel build for '$thisdl' under '$thisurl'."
  fi


  thisdl="$SPACECP_RPJAR"
  thischannel=$(sed -n '/^wrapper:$/,/^[^ ]\+/s/^  channel: \([a-zA-Z]\+\)/\1/p' "$SPACECP_CONFFILE")
  case "$thischannel" in
  development) thisurl="$SPACECP_DLAPIURL/software/remotetoolkitplugin?channel=dev";;
  recommended) thisurl="$SPACECP_DLAPIURL/software/remotetoolkitplugin?channel=rec";;
  *) thisurl="$SPACECP_DLAPIURL/software/remotetoolkitplugin";;
  esac
  thisbase=$(basename "$thisdl")
  thisstat=$(stat -c '%Y' "$thisdl" 2>$o)
  printf '%s' "[     ] $thisdl..."
  dljson=$(curl -sLA "SpaceCP Script $SPACECP______" -H "accept:application/json" "$thisurl")
  dlurl=$(printf '%s' "$dljson" | grep -om1 '"url"[ ]*:[ ]*"[^"]\+"' \
          | head -n1 | sed -n 's/"url"[ ]*:[ ]*"\([^"]\+\)"/\1/p')
  dlhash=$(printf '%s' "$dljson" | grep -om1 '"hash"[ ]*:[ ]*"[^"]\+"' \
           | head -n1 | sed -n 's/"hash"[ ]*:[ ]*"\([^"]\+\)"/\1/p')
  dlstat=$(printf '%s' "$dljson" | grep -om1 '"createdAt"[ ]*:[ ]*[0-9]\+' \
           | head -n1 | sed -n 's/"createdAt"[ ]*:[ ]*\([0-9]\+\)/\1/p')
  if [ -n "dlhash" ] && [ -n "$dlurl" ] && [ -n "$dlstat" ]
  then
    if [ -n "$1" ] || ! [ -s "$thisdl" ] || [ "$dlstat" -gt "$thisstat" ]
    then
      curl -sLA "SpaceCP Script $SPACECP______" -o "$tmp/$thisbase" --create-dirs "$dlurl"
      if [ -s "$tmp/$thisbase" ]
      then
        thishash=$(openssl sha1 "$tmp/$thisbase" | sed 's/.* //')
        if [ -z "$dlhash" ] || [ "$thishash" = "$dlhash" ]
        then
          if mkdir -p $(dirname "$thisdl") && mv "$tmp/$thisbase" "$thisdl"
          then printf '\r%s\n' "[OK]    $thisdl updated!"
          fi
        else printf '\t[ERROR] \n %s\n' "Wrong hash '$thishash', should be '$dlhash'."
        fi
      else printf '\r[ERROR] \n %s\n' "Could not fetch '$thisbase' from '$dlurl'."
      fi
    else printf   "\r[OK]    $thisdl already up to date.\n"
    fi
   else printf '\r[ERROR] \n %s\n' "Could not find any $thischannel build for '$thisdl' under '$thisurl'."
   fi


  thisdl="$SPACECP_SMJAR"
  thischannel=$(sed -n '/^spacecp:$/,/^[^ ]\+/s/^  channel: \([a-zA-Z]\+\)/\1/p' "$SPACECP_CONFFILE")
  case "$thischannel" in
  development) thisurl="$SPACECP_DLAPIURL/software/spacecp_module?channel=dev";;
  release|recommended) thisurl="$SPACECP_DLAPIURL/software/spacecp_module?channel=rec";;
  *) thisurl="$SPACECP_DLAPIURL/software/spacecp_module";;
  esac
  thisbase=$(basename "$thisdl")
  thisstat=$(stat -c '%Y' "$thisdl" 2>$o)
  printf '%s' "[     ] $thisdl..."
  dljson=$(curl -sLA "SpaceCP Script $SPACECP______" -H "accept:application/json" "$thisurl")
  dlurl=$(printf '%s' "$dljson" | grep -om1 '"url"[ ]*:[ ]*"[^"]\+"' \
          | head -n1 | sed -n 's/"url"[ ]*:[ ]*"\([^"]\+\)"/\1/p')
  dlhash=$(printf '%s' "$dljson" | grep -om1 '"hash"[ ]*:[ ]*"[^"]\+"' \
           | head -n1 | sed -n 's/"hash"[ ]*:[ ]*"\([^"]\+\)"/\1/p')
  dlstat=$(printf '%s' "$dljson" | grep -om1 '"createdAt"[ ]*:[ ]*[0-9]\+' \
           | head -n1 | sed -n 's/"createdAt"[ ]*:[ ]*\([0-9]\+\)/\1/p')
  [ -z "dlhash" ] || [ -z "$dlurl" ] || [ -z "$dlstat" ] \
    && printf '\r[ERROR] \n %s\n' "Could not find any $thischannel build for '$thisdl' under '$thisurl'."
  if [ -n "$1" ] || ! [ -s "$thisdl" ] || [ "$dlstat" -gt "$thisstat" ]
  then
    curl -sLA "SpaceCP Script $SPACECP______" -o "$tmp/$thisbase" --create-dirs "$dlurl"
    if [ -s "$tmp/$thisbase" ]
    then
      thishash=$(openssl sha1 "$tmp/$thisbase" | sed 's/.* //')
      if [ -z "$dlhash" ] || [ "$thishash" = "$dlhash" ]
      then
        if mkdir -p $(dirname "$thisdl") && mv "$tmp/$thisbase" "$thisdl"
        then printf '\r%s\n' "[OK]    $thisdl updated!"
        fi
      else printf '\t[ERROR] \n %s\n' "Wrong hash '$thishash', should be '$dlhash'."
      fi
    else printf '\r[ERROR] \n %s\n' "Could not fetch '$thisbase' from '$dlurl'."
    fi
  else printf   "\r[OK]    $thisdl already up to date.\n"
  fi


  printf '%s' "[     ] SpaceCP Libraries..."
  libver=$(sed -n '/^libraries:$/,/^[^ ]\+/s/^  version: \([0-9]\+\)/\1/p' "$SPACECP_CONFFILE")
  libjson=$(curl -sLA "SpaceCP Script $SPACECP______" "$SPACECP_DLAPIURL/software/spacecp_libraries?channel=rec")
  newliburl=$(printf '%s' "$libjson" \
              | grep -om1 '"url"[ ]*:[ ]*"[^"]*"' \
              | head -n1 | sed -n 's/"url"[ ]*:[ ]*"\([^"]*\)"/\1/p')
  newlibver=$(printf '%s' "$libjson" \
              | grep -om1 '"createdAt"[ ]*:[ ]*[0-9]\+' \
              | head -n1 | sed -n 's/"createdAt"[ ]*:[ ]*\([0-9]\+\)/\1/p')
  newlibhash=$(printf '%s' "$libjson" \
               | grep -om1 '"hash"[ ]*:[ ]*"[a-fA-F0-9]\+"' \
               | head -n1 | sed -n 's/"hash"[ ]*:[ ]*"\([a-fA-F0-9]\+\)"/\1/p')
  if [ -n "$newliburl" ] && [ -n "$newlibver" ]
  then
    if [ -n "$1" ] || [ -z "$libver" ] || [ "$libver" -lt "$newlibver" ]
    then
      curl -sLA "SpaceCP Script $SPACECP______" -o "$tmp/spacecp_libraries.zip" --create-dirs "$newliburl"
      if [ -s "$tmp/spacecp_libraries.zip" ]
      then
        thishash=$(openssl sha1 "$tmp/spacecp_libraries.zip" | sed 's/.* //')
        if [ -z "$dlhash" ] || [ "$thishash" = "$newlibhash" ]
        then
          if [ -n "$1" ]
          then
            if unzip -o "$tmp/spacecp_libraries.zip" >$o
            then printf '\r[OK]    SpaceCP Libraries updated!\n'
            fi
          else
            if unzip -uo "$tmp/spacecp_libraries.zip" >$o
            then printf '\r[OK]    SpaceCP Libraries updated!\n'
            fi
          fi
          if grep '^libraries:$' "$SPACECP_CONFFILE" >$o
          then
            if grep '^  version:' "$SPACECP_CONFFILE" >$o
            then
              sed -i '/^libraries:$/,/^[^ ]\+/s/^  version:.*$/  version: '"$newlibver"'/' "$SPACECP_CONFFILE" >$o
            else sed -i '/^libraries:$/a\
  version: '"$newlibver" "$SPACECP_CONFFILE" >$o
            fi
            if grep '^  hash:' "$SPACECP_CONFFILE" >$o
            then
              sed -i '/^libraries:$/,/^[^ ]\+/s/^  hash:.*$/  hash: '"$thishash"'/' "$SPACECP_CONFFILE" >$o
            else sed -i '/^libraries:$/a\
  hash: '"$thishash" "$SPACECP_CONFFILE" >$o
            fi
          else
            printf '\n' >> "$SPACECP_CONFFILE"
            printf '%s\n' "libraries:" "  version: $newlibver" "  hash: $thishash" >> "$SPACECP_CONFFILE"
          fi
        else printf '\r[ERROR] \n %s\n' "Wrong hash '$thishash', should be '$newlibhash'."
        fi
      else printf '\r[ERROR] \n %s\n' "Could not fetch the SpaceCP Libraries from '$newliburl'."
      fi
    else printf '\r[OK]    SpaceCP Libraries already up to date.\n'
    fi
  else
    printf '\r[ERROR] \n %s\n' "Could not find any SpaceCP Libraries on SpaceDL under\
 '$SPACECP_DLAPIURL/software/spacecp_libraries?channel=rec'."
    return 1
  fi


  printf '%s' "[     ] Removing temporary files..."
  if rm -r "$tmp"
  then printf '\r%s\n' "[OK]    "
  fi
}

start_spacecp () {
  printf '%s' "[     ] Starting SpaceCP..."
  ## Actually starting RTK now and checking the exit status.
  ## It is EXTREMELY important for the starting command to automatically fork itself into the background,
  ##  or else we can't correctly check if it started to begin with, and more importantly,
  ##  cannot send a POST request to the SpaceCP servers to notify them that the server started!
  if eval "$SPACECP_STARTCOMMAND" "$SPACECP_STARTPRE" \
          "$SPACECP_JAVABIN" "$SPACECP_JAVAARGS" \
          "$SPACECP_RTKJAR" "$SPACECP_RTKARGS" "$SPACECP_STARTSU"
  then
    printf '\r%s\n' "[OK]    Starting SpaceCP... [$SPACECP_STARTCOMMAND]"
    curl -sLA "SpaceCP Script $SPACECP______" -X POST \
    "$SPACECP_URL/api/serverStarted?key=$SPACECP_APIKEY&serverid=$SPACECP_SERVID" -o $o
  else printf '\r[ERROR]\n %s\n' "Could not start\
 '$SPACECP_STARTCOMMAND $SPACECP_STARTPRE $SPACECP_JAVABIN\
 $SPACECP_JAVAARGS $SPACECP_RTKJAR $SPACECP_RTKARGS $SPACECP_STARTSU'."
  fi
}

if [ -z "$SPACECP_APIKEY" ] && [ -s "$SPACECP_CONFFILE" ]
then SPACECP_APIKEY=$(sed -n '/^spacecp:$/,/^[^ ]\+/s/^  apikey: \([a-fA-F0-9]\+\)$/\1/p' "$SPACECP_CONFFILE")
fi
if [ -z "$SPACECP_SERVID" ] && [ -s "$SPACECP_CONFFILE" ]
then SPACECP_SERVID=$(sed -n '/^spacecp:$/,/^[^ ]\+/s/^  serverid: \([a-fA-F0-9]\+\)$/\1/p' "$SPACECP_CONFFILE")
fi
if [ -z "$SPACECP_APIKEY" ]
then
  printf '%s\n' "No API Key, exiting."
  [ -n "$sourced" ] && return 1 || exit 1
fi
if [ -z "$SPACECP_SERVID" ]
then
  printf '%s\n' "No Server ID, exiting."
  [ -n "$sourced" ] && return 1 || exit 1
fi

if /bin/ls | grep "^spacecptmp_[0-9a-zA-Z]\{10\}$" >$o
then
  oldtmp=$(/bin/ls|grep -om1 '^spacecptmp_[0-9a-zA-Z]\{10\}$')
  printf '%s\n' "Old temporary folder found, please delete it first ($oldtmp)"
  printf '%s\n' \
  "Delete all newly installed files or use -I/--install to force an installation if the last was unsuccesfull."
  printf '%s' "Delete old temporary folder '$oldtmp' [Y/n]? "
  read yn
  yn=$(printf "$yn"|awk '{if(!match($1,/^y/)){print "no"}}')
  [ -z "$yn" ] && rm -r "$oldtmp"
  [ -n "$sourced" ] && return 1 || exit 1
fi

if [ -s "$SPACECP_CONFFILE" ] && [ "$force_update" -ne 2 ]
then
  if ! update_spacecp
  then # Already installed but couldn't successfully update
    if ask "Could not update SpaceCP. Start anyway?"
    then
      if ! start_spacecp
      then # Already installed but couldn't successfully start
        printf '%s\n' "Could not start SpaceCP."
        [ -n "$sourced" ] && return 1 || exit 1
      fi
    fi
  else # Already installed and updated successfully
    if ! start_spacecp
    then # Already installed and updated but couldn't successfully start
      printf '%s\n' "Could not start SpaceCP."
      [ -n "$sourced" ] && return 1 || exit 1
    fi
  fi
else
  if ask "No SpaceCP configuration found. Install SpaceCP?"
  then
    if install_spacecp
    then # Successfully installed
      printf '%s\n' "SpaceCP installation succesfull. Starting SpaceCP for the first time."
      if ! start_spacecp
      then # Successfully installed but not successfully started
        printf '%s\n' "Could not start SpaceCP."
        [ -n "$sourced" ] && return 1 || exit 1
      fi
    else # Not successfully installed
      printf '%s\n' "Could not install SpaceCP."
      [ -n "$sourced" ] && return 1 || exit 1
    fi
  fi
fi
