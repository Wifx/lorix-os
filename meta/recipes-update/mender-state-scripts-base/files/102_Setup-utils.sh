#!/bin/sh

VERSION_GUARD_PATH=/data/mender/upgrade/version-guard.sh
SEMVER_PATH=/data/mender/upgrade/semver

cat << 'EOF' > $VERSION_GUARD_PATH
#!/bin/sh

source /data/mender/upgrade/semver

if [[ -z "$MIGRATION_CONDITION" ]]; then
    if [[ ! -z "$VERSION_MAX" ]]; then
        MIGRATION_CONDITION="<$VERSION_MAX"
    fi

    if [[ ! -z "$VERSION_MIN" ]]; then
        MIGRATION_CONDITION+=" >=$VERSION_MIN"
    fi
fi

if [[ ! -z "$MIGRATION_CONDITION" ]]; then
    log "$PREFIX" "Checking if origin release (${ORIGIN_VERSION}) is in range for migration ($MIGRATION_CONDITION)"

    VALID=$(semver_match_constraints "${ORIGIN_VERSION}" "$MIGRATION_CONDITION")

    if [ "${VALID}" = "1" ]; then
        log "$PREFIX" "Origin release (${ORIGIN_VERSION}) is in range ($MIGRATION_CONDITION)"
    else
        log "$PREFIX" "Migration not applied, origin release (${ORIGIN_VERSION}) conditions not met (${MIGRATION_CONDITION})"
        exit 0
    fi
else
    log "$PREFIX" "No migration condition given"
fi

log "$PREFIX" "Applying migration..."
EOF

cat << 'EOF' >> $SEMVER_FILE_PATH
#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# https://github.com/fsaintjacques/semver-tool

set -o errexit -o nounset -o pipefail

SEMVER_NAT='0|[1-9][0-9]*'
SEMVER_ALPHANUM='[0-9]*[A-Za-z-][0-9A-Za-z-]*'
SEMVER_IDENT="$SEMVER_NAT|$SEMVER_ALPHANUM"
SEMVER_FIELD='[0-9A-Za-z-]+'

SEMVER_REGEX="\
^[vV]?\
($SEMVER_NAT)\\.($SEMVER_NAT)\\.($SEMVER_NAT)\
(\\-(${SEMVER_IDENT})(\\.(${SEMVER_IDENT}))*)?\
(\\+${SEMVER_FIELD}(\\.${SEMVER_FIELD})*)?$"

function semver_error {
  echo -e "$1" >&2
  exit 1
}

function semver_validate_version {
  local version=$1
  if [[ "$version" =~ $SEMVER_REGEX ]]; then
    # if a second argument is passed, store the result in var named by $2
    if [ "$#" -eq "2" ]; then
      local major=${BASH_REMATCH[1]}
      local minor=${BASH_REMATCH[2]}
      local patch=${BASH_REMATCH[3]}
      local prere=${BASH_REMATCH[4]}
      local build=${BASH_REMATCH[8]}
      eval "$2=(\"$major\" \"$minor\" \"$patch\" \"$prere\" \"$build\")"
    else
      echo "$version"
    fi
  else
    semver_error "version $version does not match the semver scheme 'X.Y.Z(-PRERELEASE)(+BUILD)'. See help for more information."
  fi
}

function semver_is_nat {
    [[ "$1" =~ ^($SEMVER_NAT)$ ]]
}

function semver_is_null {
    [ -z "$1" ]
}

function order_nat {
    [ "$1" -lt "$2" ] && { echo -1 ; return ; }
    [ "$1" -gt "$2" ] && { echo 1 ; return ; }
    echo 0
}

function order_string {
    [[ $1 < $2 ]] && { echo -1 ; return ; }
    [[ $1 > $2 ]] && { echo 1 ; return ; }
    echo 0
}

# given two (named) arrays containing SEMVER_NAT and/or SEMVER_ALPHANUM fields, compare them
# one by one according to semver 2.0.0 spec. Return -1, 0, 1 if left array ($1)
# is less-than, equal, or greater-than the right array ($2).  The longer array
# is considered greater-than the shorter if the shorter is a prefix of the longer.
#
function semver_compare_fields {
    local l="$1[@]"
    local r="$2[@]"
    local leftfield=( "${!l}" )
    local rightfield=( "${!r}" )
    local left
    local right

    local i=$(( -1 ))
    local order=$(( 0 ))
    
    while true
    do
        [ $order -ne 0 ] && { echo $order ; return ; }

        : $(( i++ ))

        # Check if we have reached the end of both arrays
        [ $i -ge ${#leftfield[@]} ] && [ $i -ge ${#rightfield[@]} ] && { echo 0 ; return ; }

        left="${leftfield[$i]}"
        right="${rightfield[$i]}"

        semver_is_null "$left" && semver_is_null "$right" && { echo 0  ; return ; }
        semver_is_null "$left"                     && { echo -1 ; return ; }
                           semver_is_null "$right" && { echo 1  ; return ; }

        semver_is_nat "$left" &&  semver_is_nat "$right" && { order=$(order_nat "$left" "$right") ; continue ; }
        semver_is_nat "$left"                     && { echo -1 ; return ; }
                           semver_is_nat "$right" && { echo 1  ; return ; }
                                              { order=$(order_string "$left" "$right") ; continue ; }
    done
}

# shellcheck disable=SC2206     # checked by "validate"; ok to expand prerel id's into array

# Function: semver_compare_version
# Compare two version strings according to the Semantic Versioning 2.0.0 spec.
# Return -1, 0, 1 if left version is less-than, equal, or greater-than right version.
function semver_compare_version {
  local order
  semver_validate_version "$1" V
  semver_validate_version "$2" V_

  # compare major, minor, patch

  local left=( "${V[0]}" "${V[1]}" "${V[2]}" )
  local right=( "${V_[0]}" "${V_[1]}" "${V_[2]}" )

  order=$(semver_compare_fields left right)
  [ "$order" -ne 0 ] && { echo "$order" ; return ; }

  # compare pre-release ids when M.m.p are equal

  local prerel="${V[3]:1}"
  local prerel_="${V_[3]:1}"
  local left=( ${prerel//./ } )
  local right=( ${prerel_//./ } )

  # if left and right have no pre-release part, then left equals right
  # if only one of left/right has pre-release part, that one is less than simple M.m.p

  [ -z "$prerel" ] && [ -z "$prerel_" ] && { echo 0  ; return ; }
  [ -z "$prerel" ]                      && { echo 1  ; return ; }
                      [ -z "$prerel_" ] && { echo -1 ; return ; }

  # otherwise, compare the pre-release id's

  semver_compare_fields left right
}

function log {
  echo -e "$1" >&2
}

# Function: semver_match_constraints
# Compare a version string to a range constraint according to the Semantic Versioning 2.0.0 spec.
# Return 1 if the version satisfies the constraint, 0 otherwise.
# Example: semver_match_constraints "1.2.3" ">=1.2.0 <1.3.0"
function semver_match_constraints {
  local version=$1
  local constraints=$2
  local op
  local version_
  local constraints_
  local constraint_op
  local constraint_version
  local order

  semver_validate_version "$version" version_

  # split the constraints using space delimiter
  IFS=' ' read -r -a constraints_ <<< "$constraints"
  
  # Validate each constraint
  for constraint in "${constraints_[@]}"
  do

    # split the constraint into operator and version
    op="${constraint:0:2}"
    if [ "$op" == "<=" ] || [ "$op" == ">=" ] || [ "$op" == "!=" ]; then
      constraint_op="${constraint:0:2}"
      constraint_version="${constraint:2}"
    else
      op="${constraint:0:1}"
      if [ "$op" == "<" ] || [ "$op" == ">" ] || [ "$op" == "=" ]; then
        constraint_op="${constraint:0:1}"
        constraint_version="${constraint:1}"
      else
        semver_error "invalid operator: $op"
      fi
    fi

    semver_validate_version "$constraint_version" V_

    # compare the version to the constraints
    order=$(semver_compare_version "$version" "$constraint_version")

    case "$constraint_op" in
      "<")  [ "$order" -ne -1 ] && { echo 0 ; return; } ;;
      "<=") [ "$order" -eq  1 ] && { echo 0 ; return; } ;;
      ">")  [ "$order" -ne  1 ] && { echo 0 ; return; } ;;
      ">=") [ "$order" -eq -1 ] && { echo 0 ; return; } ;;
      "=")  [ "$order" -ne  0 ] && { echo 0 ; return; } ;;
      "!=") [ "$order" -eq  0 ] && { echo 0 ; return; } ;;
      *) semver_error "invalid operator: $constraint_op" ;;
    esac

  done

  echo 1
}

function semver_test {
  tests=(
    "1.2.3;>=1.2.0 <1.3.0;1"
    "1.3.3;>=1.2.0 <1.3.0;0"
    "1.3.3;=1.3.3;1"
    "1.3.3;!=1.3.3;0"
    "1.3.3-alpha.2;=1.3.3-alpha.2;1"
    "1.3.3-alpha.2;=1.3.3-alpha.3;0"
    "1.3.3-alpha.2;>1.3.3-alpha.3;0"
    "1.3.3-alpha.2;<1.3.3-alpha.3;1"
    "1.3.3-alpha.3;>1.3.3-alpha.2;1"
    "1.3.3-alpha.3;<1.3.3-alpha.2;0"
    "1.3.3-alpha.3;<1.3.3-beta.1;1"
    "2.0.0;>1.99.99 <2.1.0 >0.0.0 <100.0.0 =2.0.0;1"
    "1.5.2;>1.5.2-alpha.12;1"
    "1.5.2;<1.5.2-alpha.12;0"
    "1.5.1-alpha.12;>1.5.1-alpha.12;0"
    "1.5.1;<1.5.1-alpha.12;0"
  )

  for test in "${tests[@]}"
  do
    IFS=';' read -r -a test <<< "$test"
    version="${test[0]}"
    constraints="${test[1]}"
    expected="${test[2]}"
    result=$(semver_match_constraints "$version" "$constraints")

    if [ "$result" -eq "$expected" ]; then
      echo "PASSED : $version [$constraints] = $result"
    else
      echo "FAILED : $version [$constraints] = $result (expected $expected)"
    fi
  done
}
