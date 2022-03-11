#!
i=0
while [ $i != 4 ]
do
    let j=i+1
    time "./$1" -t $j -l 10000000
    ((i++))
   
done