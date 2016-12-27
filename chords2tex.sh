#!/bin/bash

IN=chordlist.txt
OUT=`basename $IN .txt`.tex

i=0
cols=12

echo -n "\\begin{longtable}{">$OUT
for c in `seq 1 $cols`; do echo -n "c">>$OUT; done
echo "}">>$OUT

# for line in `cat $IN`; do
while read line; do
   chName=`echo $line | cut -d" " -f1 | sed 's/\#/\\\#/g'` 
   simpleCode=`echo $line | cut -d"[" -f2 | cut -d"]" -f1`
   chCode=`echo $simpleCode | sed 's/\<0\>/o/g'  | sed 's/ /,/g' | sed 's/^\([0-9]\+\)/p{\1}/g' |  sed 's/,\([0-9]\+\)/,p{\1}/g'`

   minFret=100
   maxFret=0
   for string in $simpleCode; do 
       if [ $string != "x" ]; then # played string
           if [ $string -gt 0 ]; then # only for non-empty strings
               if [ $string -lt $minFret ]; then # find minimum
                   minFret=$string
               fi
               if [ $string -gt $maxFret ]; then # find minimum
                   maxFret=$string
               fi
           fi
       fi
   done

   fret=t
   if [ $minFret -gt 2 -a $minFret -ne 100 ]; then # shift only if more than 3rd fret
       fret=$(($minFret-1))
       chCode=""
       for string in $simpleCode; do 
           if [ $string != "x" ]; then # played string
               if [ $string -ne 0 ]; then # only for non-empty strings
                   chCode="$chCode,p{$(($string-$minFret+1))}"
               else
                   chCode="$chCode,o"
               fi
           else
               chCode="$chCode,x"
           fi
       done
       chCode=`echo $chCode | cut -d, -f2-`
   fi

   chTeX="{\\chord{$fret}{$chCode}{$chName}}"
   # if [ $(($i%$cols)) == 0 ];            then echo -n "\\chords{ " >> $OUT ; fi
   if [ $(($maxFret-$minFret)) -lt 5  ]; then echo -n "$chTeX"      >> $OUT ; fi 
   if [ $(($i%$cols)) != $(($cols-1)) ]; then echo -n " & "         >> $OUT ; fi
   if [ $(($i%$cols)) == $(($cols-1)) ]; then echo    " \\\\"       >> $OUT ; fi
   i=$(($i+1))
done < $IN
while [ $(($i%$cols)) != $(($cols-1)) ]; do # complete last row of table
   echo -n " & "   >> $OUT
   i=$(($i+1))
done


echo " ">>$OUT
echo "\\end{longtable}">>$OUT
