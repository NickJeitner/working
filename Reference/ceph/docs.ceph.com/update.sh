#!/bin/sh

[ ${#} -ne 1 ] && echo "No URL specified" && exit
SITE=${1:-"https://www.icinga.com/docs/icinga2/latest"}
LEVEL=10

URLS="url-list.txt"
[[ ! -e ${URLS} ]] && touch ${URLS}
PAGES=$( wc -l ${URLS} | awk '{print $1}' )

NAME=$( echo ${SITE} | awk -F/ '{print $3}' )

#if [[ $( fgrep -c ${NAME} ${URLS} ) -ne ${PAGES} ]]
#then
   echo > ${URLS}
   echo "Generating page list"
   wget --spider --force-html -nv -r -l${LEVEL} ${SITE} 2>&1 | \
      awk '/_(static)|(download)|(images)/ { next }; \
      $3 ~ /URL:http.*\/$/ {sub("URL:",""); sub(/\/$/,"",$3); print $3 }' | uniq > ${URLS}
   printf "1,\$s/\/$//\nw\n" | ed -s ${URLS}
   PAGES=$( wc -l ${URLS} | awk '{print $1}' )
#fi

echo "Converting pages.."
while read i
do
  wkhtmltopdf ${i} $(echo ${i} | awk '{gsub("/","-"); printf("./pdf/%s.pdf\n",substr($0,8))}') 2>/dev/null
  echo -ne "\033[2K \033[20D ${cnt:-1}/${PAGES}" && ((cnt++))
done < ${URLS}

echo "Merging document"
awk -v name=${NAME} '{gsub("/","-"); printf("./pdf/%s.pdf\n",substr($0,8))}; \
                     END {printf("%s.pdf\n", name)}' ${URLS} | xargs pdfunite

#gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=merged-output.pdf $(ls -1 *.pdf)
