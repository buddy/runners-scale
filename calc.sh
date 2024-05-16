#! /bin/bash

set -e
set +x

echo "\$RUNNER_SLOTS: $RUNNER_SLOTS"
echo "\$MAX_RUNNERS: $MAX_RUNNERS"
echo "\$MIN_FREE_SLOTS: $MIN_FREE_SLOTS"

# env validation
[ -n "$RUNNER_SLOTS" ] && [ "$RUNNER_SLOTS" -eq "$RUNNER_SLOTS" ] 2>/dev/null
if [ $? -ne 0 ]; then
  echo "Env \$RUNNER_SLOTS ($RUNNER_SLOTS) is not a number"
  exit 1
fi
if [ "$RUNNER_SLOTS" -le 0 ]; then
  echo "Env \$RUNNER_SLOTS ($RUNNER_SLOTS) must be greater than 0"
  exit 1
fi
[ -n "$MAX_RUNNERS" ] && [ "$MAX_RUNNERS" -eq "$MAX_RUNNERS" ] 2>/dev/null
if [ $? -ne 0 ]; then
  MAX_RUNNERS=$((((BUDDY_RUNNERS_CONCURRENT_SLOTS - 1) / RUNNER_SLOTS) + (((BUDDY_RUNNERS_CONCURRENT_SLOTS - 1) % RUNNER_SLOTS) > 0)))
fi
if [ "$MAX_RUNNERS" -le 0 ]; then
  echo "Env \$MAX_RUNNERS ($MAX_RUNNERS) must be greater than 0"
  exit 1
fi
MAX_SLOTS=$((MAX_RUNNERS * RUNNER_SLOTS))
if [ "$MAX_SLOTS" -gt "$BUDDY_RUNNERS_CONCURRENT_SLOTS" ]; then
  echo "Env \$MAX_RUNNERS ($MAX_RUNNERS) is too large (cannot add $MAX_RUNNERS runners with $RUNNER_SLOTS slots each than concurrent slots from license - $BUDDY_RUNNERS_CONCURRENT_SLOTS)"
  exit 1
fi

[ -n "$MIN_FREE_SLOTS" ] && [ "$MIN_FREE_SLOTS" -eq "$MIN_FREE_SLOTS" ] 2>/dev/null
if [ $? -ne 0 ]; then
   echo "Env \$MIN_FREE_SLOTS ($MIN_FREE_SLOTS) is not a number"
   exit 1
fi
if [ "$MIN_FREE_SLOTS" -lt 1 ]; then
  echo "Env \$MIN_FREE_SLOTS ($MIN_FREE_SLOTS) must be greater or equal 1"
  exit 1
fi
if [ -n "$RUNNER_TAG" ]; then
  tmp="BUDDY_RUNNERS_FREE_SLOTS_${RUNNER_TAG^^}"
  FREE_SLOTS=${!tmp}
  tmp="BUDDY_RUNNERS_COUNT_${RUNNER_TAG^^}"
  RUNNERS=${!tmp}
else
  FREE_SLOTS=$BUDDY_RUNNERS_FREE_SLOTS_NOT_TAGGED
  RUNNERS=$BUDDY_RUNNERS_COUNT_NOT_TAGGED
fi
[ -n "$FREE_SLOTS" ] && [ "$FREE_SLOTS" -eq "$FREE_SLOTS" ] 2>/dev/null
if [ $? -ne 0 ]; then
   echo "Env \$FREE_SLOTS ($FREE_SLOTS) is not a number. \$RUNNER_TAG ($RUNNER_TAG) has wrong value"
   exit 1
fi
[ -n "$RUNNERS" ] && [ "$RUNNERS" -eq "$RUNNERS" ] 2>/dev/null
if [ $? -ne 0 ]; then
   echo "Env \$RUNNERS ($RUNNERS) is not a number. \$RUNNER_TAG ($RUNNER_TAG) has wrong value"
   exit 1
fi
USED_SLOTS=$((RUNNERS * RUNNER_SLOTS))
echo "\$MAX_SLOTS: $MAX_SLOTS"
echo "\$FREE_SLOTS: $FREE_SLOTS"
echo "\$USED_SLOTS: $USED_SLOTS"
echo "\$RUNNERS: $RUNNERS"
REAL_RUNNER_SLOTS=$((RUNNERS * RUNNER_SLOTS))
REAL_FREE_SLOTS=$((FREE_SLOTS - MIN_FREE_SLOTS))
if [ "$FREE_SLOTS" -lt "$MIN_FREE_SLOTS" ] && [ "$REAL_RUNNER_SLOTS" -lt "$MAX_SLOTS" ]; then
  export RUNNERS=$((RUNNERS + 1))
elif [ "$REAL_FREE_SLOTS" -ge "$RUNNER_SLOTS" ] && [ "$RUNNERS" -gt 0 ]; then
  export RUNNERS=$((RUNNERS - 1))
fi
echo "New \$RUNNERS: $RUNNERS"
export RUNNERS="$RUNNERS"
