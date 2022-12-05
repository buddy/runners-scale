#! /bin/sh

set -e

# env validation
[ -n "$MAX_SLOTS" ] && [ "$MAX_SLOTS" -eq "$MAX_SLOTS" ] 2>/dev/null
if [ $? -ne 0 ]; then
  echo "Env \$MAX_SLOTS ($MAX_SLOTS) is not a number"
  exit 1
fi
if [ "$MAX_SLOTS" -le 0 ]; then
  echo "Env \$MAX_SLOTS ($MAX_SLOTS) must be greater than 0"
  exit 1
fi
[ -n "$WORKER_SLOTS" ] && [ "$WORKER_SLOTS" -eq "$WORKER_SLOTS" ] 2>/dev/null
if [ $? -ne 0 ]; then
  echo "Env \$WORKER_SLOTS ($WORKER_SLOTS) is not a number"
  exit 1
fi
if [ "$WORKER_SLOTS" -le 0 ]; then
  echo "Env \$WORKER_SLOTS ($WORKER_SLOTS) must be greater than 0"
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
if [ -n "$WORKER_TAG" ]; then
  tmp="BUDDY_WORKERS_FREESLOTS_$WORKER_TAG"
  FREE_SLOTS=${!tmp}
  tmp="BUDDY_WORKERS_COUNT_$WORKER_TAG"
  WORKERS=${!tmp}
else
  FREE_SLOTS=$BUDDY_WORKERS_FREE_SLOTS_NOT_TAGGED
  WORKERS=$BUDDY_WORKERS_COUNT_NOT_TAGGED
fi
[ -n "$FREE_SLOTS" ] && [ "$FREE_SLOTS" -eq "$FREE_SLOTS" ] 2>/dev/null
if [ $? -ne 0 ]; then
   echo "Env \$FREE_SLOTS ($FREE_SLOTS) is not a number. \$WORKER_TAG ($WORKER_TAG) has wrong value"
   exit 1
fi
[ -n "$WORKERS" ] && [ "$WORKERS" -eq "$WORKERS" ] 2>/dev/null
if [ $? -ne 0 ]; then
   echo "Env \$WORKERS ($WORKERS) is not a number. \$WORKER_TAG ($WORKER_TAG) has wrong value"
   exit 1
fi
echo "\$MAX_SLOTS: $MAX_SLOTS"
echo "\$FREE_SLOTS: $FREE_SLOTS"
echo "\$WORKER_SLOTS: $WORKER_SLOTS"
echo "\$MIN_FREE_SLOTS: $MIN_FREE_SLOTS"
echo "\$WORKERS: $WORKERS"
REAL_WORKER_SLOTS=$((WORKERS * WORKER_SLOTS))
REAL_FREE_SLOTS=$((FREE_SLOTS - MIN_FREE_SLOTS))
if [ "$FREE_SLOTS" -lt "$MIN_FREE_SLOTS" ] && [ "$REAL_WORKER_SLOTS" -lt "$MAX_SLOTS" ]; then
  export WORKERS=$((WORKERS + 1))
elif [ "$REAL_FREE_SLOTS" -ge "$WORKER_SLOTS" ] && [ "$WORKERS" -gt 0 ]; then
  export WORKERS=$((WORKERS - 1))
fi
echo "New \$WORKERS: $WORKERS"

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  exit 0
fi

export TF_VAR_AWS_REGION=$AWS_REGION
export TF_VAR_AWS_AZ=$AWS_AZ
export TF_VAR_WORKERS=$WORKERS
export TF_VAR_INSTANCE_AMI_ID=$INSTANCE_AMI_ID
export TF_VAR_INSTANCE_TYPE=$INSTANCE_TYPE
export TF_VAR_INSTANCE_KEY=$INSTANCE_KEY
export TF_VAR_INSTANCE_VOLUME_SIZE=$INSTANCE_VOLUME_SIZE
export TF_VAR_INSTANCE_VOLUME_THROUGHPUT=$INSTANCE_VOLUME_THROUGHPUT
export TF_VAR_INSTANCE_VOLUME_IOPS=$INSTANCE_VOLUME_IOPS
export TF_VAR_INSTANCE_PUBLIC_KEY=$INSTANCE_PUBLIC_KEY
echo "$INSTANCE_PRIVATE_KEY" > key.pem

cp install.tmpl.sh install.sh
sed -i "s/STANDALONE_TOKEN/$STANDALONE_TOKEN/g" install.sh
sed -i "s/STANDALONE_HOST/$STANDALONE_HOST/g" install.sh
sed -i "s/WORKER_TAG/$WORKER_TAG/g" install.sh
sed -i "s/WORKER_SLOTS/$WORKER_SLOTS/g" install.sh

terraform init -migrate-state -upgrade -input=false
echo "PWD: $(pwd)"
ls -la
echo ".state: "
ls -la .state
echo ".terraform: "
ls -la .terraform

terraform apply -auto-approve -input=false
#terraform plan -input=false
#terraform destroy -auto-approve -input=false

rm key.pem