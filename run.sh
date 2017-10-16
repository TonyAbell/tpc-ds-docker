#!/bin/bash
child=$1
baseDir=/data
echo -e "\n\n"
echo -e "Scale:\t\t\t"$scale  
echo -e "Parallel:\t\t"$parallel
echo -e "Child:\t\t\t"$child
echo -e "Storage Account Name\t"$storageAccountName
echo -e "Container:\t\t"$container
echo -e "Stoarge Account Key:\n\t"$storageAccountKey
echo -e "\n"
cd /tpc

if [ ! -d $baseDir ]
then
    mkdir $baseDir
fi

tables=("call_center" "catalog_page" "catalog_sales" "customer" "customer_address" "customer_demographics" "date_dim" "household_demographics" "income_band" "inventory" "item" "promotion" "reason" "ship_mode" "store" "store_sales" "time_dim" "warehouse" "web_page" "web_sales" "web_site" )

echo -e "Generating Data\n"
for t in "${tables[@]}"
do
    tableDir=$baseDir/$t
    if [ ! -d $tableDir ]
    then	
	mkdir $tableDir
    fi
    if ! find "$tableDir" -mindepth 1 -print -quit | grep -q .; then
	echo -e "Table: \t"$t 
	./dsdgen -dir $tableDir -table $t -scale $scale -parallel $parallel -child $child -force -quiet       
    fi
done

echo -e "Moving 'Returns' data to their own folder\n"
tableReturns=("catalog_returns" "store_returns" "web_returns")
for t in "${tableReturns[@]}"
do      
    file=$(find $baseDir -name "$t*.dat")
    if [ ! $file == "" ] && [ -f $file ]
    then	
      tableDir=$baseDir/$t
      echo -e "\tMoving\n\t\t"$file"\n\t\tto\n\t\t"$tableDir  
      if [ ! -d $tableDir ]
      then
	    mkdir $tableDir
      fi
      mv $file $tableDir
    fi 
done

echo -e "\n\nCopy Data To Azure Blob Store\n"
tablesToCopy=("${tables[@]}" "${tableReturns[@]}" )
for t in "${tablesToCopy[@]}" 
do
    tableDir=$baseDir/$t
    if [ -d $tableDir ] && [ "$(ls -A $tableDir)" ]
    then
        echo -e "\t"$t
        destUrl=$(echo -e "https://"$storageAccountName".blob.core.windows.net/"$container"/"$t)
        echo -e "\t\tDestination Url:" $destUrl "\n"
        azcopy --exclude-older --quiet --source $tableDir --destination $destUrl --dest-key $storageAccountKey --include "*.dat"
        echo -e "\n\n"
    fi
done
exit 0