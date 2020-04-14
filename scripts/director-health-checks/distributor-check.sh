#!/bin/bash

## Run common health check tests

# Specify test name
test_name=distributor-check
echo $test_name

sed -e 's/generateName: app-check/generateName: distributor-check/g' \
-e 's/app: app-litmus/app: distributor-check-litmus/g' \
-e 's/value: test-name/value: distributor-check/g' \
-e 's/value: default /value: default/g' \
-e 's/value: pod-name/value: distributor/g' oep-e2e/litmus/director/common-checks/run_litmus_test.yml \
> oep-e2e/litmus/director/common-checks/distributor_run_litmus_test.yml

cat oep-e2e/litmus/director/common-checks/distributor_run_litmus_test.yml

# Run common health check litmus job
kubectl create -f oep-e2e/litmus/director/common-checks/distributor_run_litmus_test.yml

sleep 2;

# Get common health check job's pod name
litmus_pod=$(kubectl get po -n litmus | grep $test_name  | awk {'print $1'} | tail -n 1)
echo $litmus_pod

# Check common health check job status
job_status=$(kubectl get po  $litmus_pod -n litmus | awk {'print $3'} | tail -n 1)
while [[ "$job_status" != "Completed" ]]
do 
    job_status=$(kubectl get po  $litmus_pod -n litmus | awk {'print $3'} | tail -n 1)
    sleep 6
done

# Print common health check job logs
kubectl logs -f $litmus_pod -n litmus

# Check common health check job result
testResult=$(kubectl get litmusresult ${test_name} --no-headers -o custom-columns=:spec.testStatus.result)
echo $testResult

# Flush test result in result.txt
echo "$test_name: $testResult" >> result.txt;