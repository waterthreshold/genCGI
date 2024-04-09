VERSION="1.0"
DATESTR=`date +'%Y%m%d'`
DOC_NAME="httpd_${VERSION}_${DATESTR}.tex"

cat > $DOC_NAME << "LATEX_DOC"
\documentclass[12pt,a4paper]{article}
\usepackage[utf8]{inputenc}
\usepackage{babel}
\usepackage{rest-api}
\makeindex

\title{acos httpd JSON api format}
\author{Jeff Chiang}

\begin{document}

\maketitle

\section{Introduction}
In this document show the JSON API for acos httpd  use

\section{Usage}
%GETCGI

%SETCGI
LATEX_DOC

genGetContentWithConfig(){
CONFIG_FILE="$1"
CGINAME=`jq -r ".cgiName" ${CONFIG_FILE}` 
GET_CGINAME="Get${CGINAME^}.cgi"
SET_CGINAME="Set${CGINAME^}.cgi"
CGI_GET_CONTENT=`cat CGI/get/${GET_CGINAME}` 
CGI_GET_DESCRIPTION=`jq -r ".get_description" ${CONFIG_FILE}`
if [ ! -e "CGI/get/${GET_CGINAME}" ];then 
	echo "" > tmp.txt
	return
fi

CGI_GET_ITEMDESCRPTION=""
for item in `jq -r ".get | keys[]" ${CONFIG_FILE}`; do 
	item_sub=${item//_/\\_}
	#echo $item_sub
	item_description=`jq -r ".get.${item}.description" ${CONFIG_FILE}`
	#echo $item_description
	CGI_GET_ITEMDESCRPTION=`echo -e "${CGI_GET_ITEMDESCRPTION}\n\t"`
	CGI_GET_ITEMDESCRPTION="${CGI_GET_ITEMDESCRPTION}\\routeParamItem{${item_sub}}{${item_description}}"
#	echo -e "${CGI_GET_ITEMDESCRPTION}\\routeParamItem{${item}}{${item_description}}"
done
#echo   "${CGI_GET_ITEMDESCRPTION}"

#echo ${CGI_GET_DESCRIPTION}
#echo ${CGI_GET_CONTENT}
cat > tmp.txt << API_HERE
\begin{apiRoute}{get}{/${GET_CGINAME}}{${CGI_GET_DESCRIPTION}}
	
	\begin{routeParameter}
	${CGI_GET_ITEMDESCRPTION}
	\end{routeParameter}
	\begin{routeResponse}{application/json}
		\begin{routeResponseItem}{200}{ok}
			\begin{routeResponseItemBody}
${CGI_GET_CONTENT}
			\end{routeResponseItemBody}
		\end{routeResponseItem}
	\end{routeResponse}
	
\end{apiRoute}
API_HERE
}
genSetContentWithConfig(){
CONFIG_FILE="$1"
CGINAME=`jq -r ".cgiName" ${CONFIG_FILE}` 
SET_CGINAME="Set${CGINAME^}.cgi"
CGI_SET_DESCRIPTION=`jq -r ".set_description" ${CONFIG_FILE}`
CGI_SET_REQUEST=`cat CGI/set/${SET_CGINAME}`
if [ ! -e "CGI/set/${SET_CGINAME}" ];then 
	echo "" > tmp_set.txt
	return
fi
CGI_SET_ITEMDESCRIPTION=""
for item in `jq -r ".set | keys[]" ${CONFIG_FILE}`; do
		echo "set item :$item"
	item_sub=${item//_/\\_}
	item_description=`jq -r ".set.${item}.description" ${CONFIG_FILE}`
	echo "Descripion:$item_description"
	CGI_SET_ITEMDESCRIPTION=`echo -e "${CGI_SET_ITEMDESCRIPTION}\n\t"`
	CGI_SET_ITEMDESCRIPTION="${CGI_SET_ITEMDESCRIPTION}\\routeParamItem{${item_sub}}{${item_description}}"
done 
echo "$CGI_SET_ITEMDESCRIPTION"
cat > tmp_set.txt << SETDOCHERE
\begin{apiRoute}{post}{/${SET_CGINAME}}{${CGI_SET_DESCRIPTION}}
	\begin{routeParameter}
	${CGI_SET_ITEMDESCRIPTION}
	\end{routeParameter}
	\begin{routeRequest}{application/json}
		\begin{routeRequestBody}
${CGI_SET_REQUEST}
		\end{routeRequestBody}
	\end{routeRequest}
	\begin{routeResponse}{application/json}
		\begin{routeResponseItem}{200}{ok}
			\begin{routeResponseItemBody}
{     
	"result:200
}
			\end{routeResponseItemBody}
		\end{routeResponseItem}
	\end{routeResponse}
\end{apiRoute}
SETDOCHERE
#cat tmp.txt
}
#declare -a ARRAY
#ARRAY=( config/devNameConfig.json config/hotspotConfig.json )
for file in "${HOME}/addFXCN/config"/* ; do
	echo $file
	genGetContentWithConfig "$file"
	genSetContentWithConfig "$file"
	mv ${DOC_NAME} tmp2.txt
	cat tmp2.txt tmp.txt  tmp_set.txt > ${DOC_NAME} 
	rm tmp.txt tmp_set.txt
done
#exit
echo  '\end{document}' >> ${DOC_NAME}
sed -i 's/\r/\\r/g' ${DOC_NAME}
pdflatex ${DOC_NAME}
#sed -i "/%GETCGI/i ${GETCONTENT}" ${DOC_NAME}
