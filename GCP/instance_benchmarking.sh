#!/bin/bash
request=(10000 20000 30000 40000 50000 60000 70000 80000 90000 100000)
concurrency=(500 1000 1500 2000 2500 3000 3500 4000 4500 5000)
#concurrency=(500)
for i in "${request[@]}"
do
  for j in "${concurrency[@]}"
  do
    echo "Now running test for $i request and concurrency level of $j" 
    echo "=========================================================================" 
    #echo ab -n $i -c $j -g data/$i$j.tsv -r http://34.105.221.31/index.html
    ab -n $i -c $j -g data/$i$j.tsv -r http://35.230.144.235/index.html >> data/logs/$i$j.txt  2>&1
    echo "===========================Completed====================================="
  done
done

