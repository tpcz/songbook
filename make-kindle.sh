#!/bin/bash

FOLDER=pisnicky-kindle
HTML_NAME=zpevnik-kindle.html
MOBI_NAME=zpevnik-kindle.mobi

rm -fr $FOLDER

cp -r pisnicky $FOLDER
cd $FOLDER

# convert tex syntax to html
for f in *.tex; do
   # remove extension from file name
   ff=`basename $f .tex`
   mv $f $ff

   # name of song
   sed -i 's#\\beginsong{\([^}]*\)}#<a name="'$ff'"><h3>\1</h3></a>\n#g' $ff
   sed -i 's#\\endsong##g' $ff
   # author
   sed -i 's#\[by={\([^}]*\)}\]#<h4>\1</h4>#g' $ff
   # verses
   sed -i 's#\\beginverse#<pre>#g' $ff
   sed -i 's#\\endverse#</pre>#g' $ff
   # choruses
   sed -i 's#\\beginchorus#<pre><i>#g' $ff
   sed -i 's#\\endchorus#</i></pre>#g' $ff
   # chords
   sed -i 's$\\\[\([a-zA-Z0-9#+, ()/]*\)]$<sup>\1</sup>$g' $ff

   # add link to the song index at the end of each song
   echo '<a href="#'$ff'_obsah">Zpět na obsah</a>' >> $ff
done;

cd ..

# create html song index
grep --no-filename "<h3>" $FOLDER/* > list.html
sed -i 's/name="\([a-zA-Z0-9_]*\)"/name="\1_obsah" href="#\1"/g' list.html

# make whole html songbook

cat > zpevnik-kindle.html <<EOL
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>Martin Hejtmánek -- Zpěvník</title>
      <!--<link rel="stylesheet" href="" type="text/css"> -->
</head>
EOL

echo '<body>' >> $HTML_NAME

cat list.html >> $HTML_NAME
cat $FOLDER/* >> $HTML_NAME

echo '</body>' >> $HTML_NAME
echo '</html>' >> $HTML_NAME

# make mobi file for kindle
kindlegen $HTML_NAME -o $MOBI_NAME

