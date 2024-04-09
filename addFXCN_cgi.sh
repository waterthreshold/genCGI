#!/bin/sh

die (){
	msg=$1
	echo $msg
	exit 127
}

GenSetCGI(){
CONFIG_FILE="$1"
#SETCGIFILE="SetTest.json"
SETCGIFILE="$2"

[ ! -e "$CONFIG_FILE" ] && die "File not exist !!"
echo "{}" > $SETCGIFILE
for key in  `jq  ".set | keys[]" $CONFIG_FILE`; do
	TYPE=`jq -r ".set.${key}.type" $CONFIG_FILE`
	if [ "$TYPE" == "string" ]; then 
		VALUE=`jq ".set.${key}.default_value" ${CONFIG_FILE}`
		#echo $VALUE
		jq ". += {${key}:${VALUE}}" ${SETCGIFILE} > tmp.json
		mv tmp.json $SETCGIFILE
	elif [ "$TYPE" == "array" ]; then 
		ARRAY_LEN=`jq -r ".set.$key.default_value | length" $CONFIG_FILE`
		ARRAY_LEN=$(( ARRAY_LEN - 1 ))
		jq ".$key += []" $SETCGIFILE > tmp.json
		mv tmp.json $SETCGIFILE	
		for i in `seq 0 $ARRAY_LEN`; do	
			jq ".$key += [{}]" $SETCGIFILE > tmp.json
			mv tmp.json  $SETCGIFILE	
			for array_key in `jq -r ".set.$key.default_value[${i}] | keys[]" $CONFIG_FILE`; do
				VALUE=`jq -r ".set.$key.default_value[${i}].$array_key" $CONFIG_FILE`
				TYPEINARR=`jq -r ".set.$key.item[] | select (.name == \"$array_key\") | .type" $CONFIG_FILE`
				echo $TYPEINARR

				if [ "$TYPEINARR" == "string" ] ; then
					jq ".$key[$i] +={\"$array_key\":\"$VALUE\"}" $SETCGIFILE > tmp.json
				else
					jq ".$key[$i] +={\"$array_key\":$VALUE}" $SETCGIFILE > tmp.json
				fi
				mv tmp.json $SETCGIFILE
			done  
		done
	elif [ "$TYPE" == "number" -o  "$TYPE" == "boolean" -o "$TYPE" == "float" ]; then  	
		VALUE=`jq -r ".set.${key}.default_value" ${CONFIG_FILE}`
		#echo $VALUE
		jq ". += {${key}:${VALUE}}" ${SETCGIFILE} > tmp.json
		mv tmp.json $SETCGIFILE
	fi
done
}

addGetCgiInList (){
	[ -e "$2" ] && echo $1 >> $2
}

genServicefile (){
#qsdkj acos 
HTTPD_DIR=httpd_mt
[  "$#" -ne 2 ] && die "Must contain a cgi name. for example. devname" 
[ ! -e "$HTTPD_DIR" ] && die "Cannot find http directory"

CONFIG_FILE=$2
FILENAME_NOMENCLATURE="${1,}Cgi"
FUNCTION_NAME="${1^}CgiMain"
CGI_NAME="${1^}"
echo "${FILENAME_NOMENCLATURE} ${FUNCTION_NAME}"
echo $CONFIG_FILE
MAKEFILEPATH=$HTTPD_DIR/Makefile
MAKEFILECGITEXT="${FILENAME_NOMENCLATURE}.o"
sed -i "/#ADDHERE/i OBJS += \$\(CGI_DIR\)\/${FILENAME_NOMENCLATURE}.o" $MAKEFILEPATH


ASPFILEPATH=$HTTPD_DIR/httpd_asp.c
ASPGETCGITEXT="{\"Get${1}.cgi\", get${FUNCTION_NAME}},"
ASPGETCGITEXT="{\"Set${1}.cgi\", set${FUNCTION_NAME}},"
sed -i "/\s*\/\/ADDSETCGIABOVEHERE/i \ \ \ \ {\"Set${CGI_NAME}.cgi\", set${FUNCTION_NAME}}," $ASPFILEPATH
sed -i "/\s*\/\/ADDGETCGIABOVEHERE/i \ \ \ \ {\"Get${CGI_NAME}.cgi\", get${FUNCTION_NAME}}," $ASPFILEPATH

HTTPDH_PATH=$HTTPD_DIR/httpd.h
HTTPD_TEXT="#include \"cgi/${FILENAME_NOMENCLATURE}.h\""
sed -i "/\/\/HTTPDHERE/i $HTTPD_TEXT" $HTTPDH_PATH

CGI_PATH=$HTTPD_DIR/cgi
CGICPATH=${CGI_PATH}/${FILENAME_NOMENCLATURE}.c
CGIHPATH=${CGI_PATH}/${FILENAME_NOMENCLATURE}.h
GETBODY_C_CONTENT=""
for key in `jq -r ".get | keys[]" $CONFIG_FILE`; do
	echo $key
	TYPE=`jq -r ".get.$key.type" $CONFIG_FILE`
	NVRAM=`jq -r ".get.$key.nvramName" $CONFIG_FILE`
	if [ "$TYPE" == "string" ]; then
		GETBODY_C_CONTENT=`echo -e "${GETBODY_C_CONTENT}\n\tcJSON_AddStringToObject(${1}_obj,\"$key\",acosNvramConfig_get(\"$NVRAM\"));"`
	elif [ "$TYPE" == "number" ]; then
		GETBODY_C_CONTENT=`echo -e "${GETBODY_C_CONTENT}\n\tcJSON_AddNumberToObject(${1}_obj,\"$key\",atoi(acosNvramConfig_get(\"$NVRAM\")));"`
	elif [ "$TYPE" == "boolean" ]; then
		GETBODY_C_CONTENT=`echo -e "${GETBODY_C_CONTENT}\n\tcJSON_AddItemToObject(${1}_obj,\"$key\",convertNvramToBoolean(\"$NVRAM\")?cJSON_CreateTrue():cJSON_CreateFalse());"`
	elif [ "$TYPE" == "array" ]; then
		NVRAM_PREFIX=`jq -r ".get.${key}.nvram_prefix" $CONFIG_FILE`
		GETBODY_C_CONTENT=`echo -e "${GETBODY_C_CONTENT}\n\tchar tmp_nvram[64];\n\tcJSON *${key}_obj = cJSON_CreateArray();\n\tint i,${key}_len=atoi(acosNvramConfig_get(\"${NVRAM_PREFIX}_count\"));\n\tfor (i=0 ; i < ${key}_len ;i++) {\n\t\tcJSON *${key}_item_obj=NULL;\n\t\tcJSON_AddItemToArray(${key}_obj, ${key}_item_obj = cJSON_CreateObject());"`
		NUM_OF_ITEM=`jq -r ".get.$key.item | length" $CONFIG_FILE`
		NUM_OF_ITEM=$(( NUM_OF_ITEM - 1 ))
		echo $NUM_OF_ITEM
		for i in `seq 0 ${NUM_OF_ITEM}`; do
			NAME=`jq -r ".get.$key.item[$i].name" $CONFIG_FILE`
			arr_type=`jq -r ".get.$key.item[$i].type" $CONFIG_FILE`
			if [ "$arr_type" == "string" ]; then
				GETBODY_C_CONTENT=`echo -e "${GETBODY_C_CONTENT}\n\t\tmemset(tmp_nvram,0,sizeof(tmp_nvram));\n\t\tsnprintf(tmp_nvram,sizeof(tmp_nvram),\"${NVRAM_PREFIX}_${NAME}_%d\",i);\n\t\tcJSON_AddStringToObject(${key}_item_obj,\"$NAME\",acosNvramConfig_get(tmp_nvram));"`
			elif [ "$arr_type" == "number" ]; then
				GETBODY_C_CONTENT=`echo -e "${GETBODY_C_CONTENT}\n\t\tmemset(tmp_nvram,0,sizeof(tmp_nvram));\n\t\tsnprintf(tmp_nvram,sizeof(tmp_nvram),\"${NVRAM_PREFIX}_${NAME}_%d\",i);\n\t\tcJSON_AddNumberToObject(${key}_item_obj,\"$NAME\",atoi(acosNvramConfig_get(tmp_nvram)));"`
			elif [ "$arr_type" == "boolean" ]; then
				GETBODY_C_CONTENT=`echo -e "${GETBODY_C_CONTENT}\n\t\tmemset(tmp_nvram,0,sizeof(tmp_nvram));\n\t\tsnprintf(tmp_nvram,sizeof(tmp_nvram),\"${NVRAM_PREFIX}_${NAME}_%d\",i);\n\t\tcJSON_AddItemToObject(${key}_item_obj,\"$NAME\",convertNvramToBoolean(tmp_nvram)?cJSON_CreateTrue():cJSON_CreateFalse());"`
			fi
		done 
		GETBODY_C_CONTENT=`echo -e "$GETBODY_C_CONTENT\n\t}"`
		GETBODY_C_CONTENT=`echo -e "$GETBODY_C_CONTENT\n\tif(${key}_len>0)\n\t\tcJSON_AddItemToObject(${1}_obj, \"${key}\" ,${key}_obj );"`
	fi
done
#echo "$GETBODY_C_CONTENT"
SETBODY_C_CONTENT=""
for key in `jq -r ".set | keys[]" $CONFIG_FILE`; do
	TYPE=`jq -r ".set.${key}.type" $CONFIG_FILE`
	NVRAM=`jq -r ".set.${key}.nvramName" $CONFIG_FILE`
	if [ "$TYPE" == "string" ]; then
		SETBODY_C_CONTENT=`echo -e "${SETBODY_C_CONTENT}\n\t\tname=cJSON_GetObjectItem(${1}_obj,\"$key\");\n\t\tif(name){\n\t\tacosNvramConfig_set(\"$NVRAM\",name->valuestring);\n\t\t} else{\n\t\tret=400;\n\t\t}"`
	elif [ "$TYPE" == "number" ]; then
		SETBODY_C_CONTENT=`echo -e "${SETBODY_C_CONTENT}\n\t\tname=cJSON_GetObjectItem(${1}_obj,\"$key\");\n\t\tif(name){\n\t\tchar ${key}_str[64]={0};\n\t\tsnprintf(${key}_str,sizeof(${key}_str),\"%d\",name->valueint);\n\t\tacosNvramConfig_set(\"$NVRAM\",${key}_str);\n\t\t} else{\n\t\tret=400;\n\t\t}"`
	elif [ "$TYPE" == "float" ]; then
		SETBODY_C_CONTENT=`echo -e "${SETBODY_C_CONTENT}\n\t\tname=cJSON_GetObjectItem(${1}_obj,\"$key\");\n\t\tif(name){\n\t\tchar ${key}_str[64]={0};\n\t\tsnprintf(${key}_str,sizeof(${key}_str),\"%f\",name->valuedouble);\n\t\tacosNvramConfig_set(\"$NVRAM\",${key}_str);\n\t\t} else{\n\t\tret=400;\n\t\t}"`
	elif [ "$TYPE" == "boolean" ]; then
		SETBODY_C_CONTENT=`echo -e "${SETBODY_C_CONTENT}\n\t\tname=cJSON_GetObjectItem(${1}_obj,\"${key}\");\n\t\tif(name){\n\t\t	acosNvramConfig_set(\"$NVRAM\",cJSON_IsTrue(name)?\"Enable\":\"Disable\");\n\t\t} else{\n\t\t	ret=400;\n\t\t}"`
	elif [ "$TYPE" == "array" ]; then
		NVRAM_PREFIX=`jq -r ".set.${key}.nvram_prefix" $CONFIG_FILE`
		SETBODY_C_CONTENT=`echo -e "${SETBODY_C_CONTENT}\n\t\tcJSON* ${key}_arrObj = cJSON_GetObjectItem(${1}_obj,\"$key\");\n\t\tint i,array_size = cJSON_GetArraySize (${key}_arrObj);\n\t\tchar tmp_nvram[64]={0};\n\t\tsnprintf(tmp_nvram,sizeof(tmp_nvram),\"%d\",array_size);\n\t\tacosNvramConfig_set(\"${NVRAM_PREFIX}_count\",tmp_nvram);\n\t\tfor ( i=0 ;i < array_size ;i++) {\n\t	cJSON* ${key}_arr_item= cJSON_GetArrayItem(${key}_arrObj,i);\n\t"`
		ARR_SIZE=`jq -r ".set.${key}.item | length" $CONFIG_FILE`
		ARR_SIZE=$(( ARR_SIZE - 1 ))
		
		for i in `seq 0 ${ARR_SIZE}`; do
			
			arr_name=`jq -r ".set.${key}.item[${i}].name" $CONFIG_FILE`
			arr_type=`jq -r  ".set.${key}.item[${i}].type" $CONFIG_FILE`
			arr_nvram=`jq -r  ".set.${key}.item[${i}].nvramName" $CONFIG_FILE`
			CJSON_OBJ_DECLARE="${arr_name}_itemObj"
		SETBODY_C_CONTENT=`echo -e "${SETBODY_C_CONTENT}\n\t\tmemset (tmp_nvram,0 ,sizeof(tmp_nvram));\n\t\tsnprintf (tmp_nvram,sizeof(tmp_nvram),\"${arr_nvram}_%d\",i);\n\t"`
		if [ "$arr_type" == "string" ]; then
			SETBODY_C_CONTENT=`echo -e "${SETBODY_C_CONTENT}\n\t\tcJSON* ${CJSON_OBJ_DECLARE} = cJSON_GetObjectItem(${key}_arr_item,\"$arr_name\");\n\t\tif (${CJSON_OBJ_DECLARE}){\n\t\tacosNvramConfig_set(tmp_nvram,${CJSON_OBJ_DECLARE}->valuestring);\n\t\t}\n\t\t"`
		elif [ "$arr_type" == "number" ]; then
			SETBODY_C_CONTENT=`echo -e "${SETBODY_C_CONTENT}\n\t\tcJSON* ${CJSON_OBJ_DECLARE} = cJSON_GetObjectItem(${key}_arr_item,\"$arr_name\");\n\t\tif (${CJSON_OBJ_DECLARE}){\n\t\tchar ${arr_nvram}_str[64]={0};\n\t	snprintf(${arr_nvram}_str,sizeof(${arr_nvram}_str),\"%d\",${CJSON_OBJ_DECLARE}->valueint);\n\t\tacosNvramConfig_set(tmp_nvram,${arr_nvram}_str);\n\t\t}\n\t\t"`
		elif [ "$arr_type" == "float" ]; then
			SETBODY_C_CONTENT=`echo -e "${SETBODY_C_CONTENT}\n\t\tcJSON* ${CJSON_OBJ_DECLARE} = cJSON_GetObjectItem(${key}_arr_item,\"$arr_name\");\n\t\tif (${CJSON_OBJ_DECLARE}){\n\t\tchar ${arr_nvram}_str[64]={0};\n\t	snprintf(${arr_nvram}_str,sizeof(${arr_nvram}_str),\"%f\",${CJSON_OBJ_DECLARE}->valuedouble);\n\t\tacosNvramConfig_set(tmp_nvram,${arr_nvram}_str);\n\t\t}\n\t\t"`
		elif [ "$arr_type" == "boolean" ]; then
			SETBODY_C_CONTENT=`echo -e "${SETBODY_C_CONTENT}\n\t\tcJSON* ${CJSON_OBJ_DECLARE} = cJSON_GetObjectItem(${key}_arr_item,\"$arr_name\");\n\t\tif (${CJSON_OBJ_DECLARE}){\n\t\tacosNvramConfig_set(tmp_nvram,\"Enable\");\n\t\t}\n\t\t"` 
		fi
		done 
		SETBODY_C_CONTENT=`echo -e "$SETBODY_C_CONTENT\n\t\t}"`
	fi 
done
echo "${SETBODY_C_CONTENT}"

cat > $CGICPATH  << C_TEMPLATE
/****************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "httpd.h"

int get${FUNCTION_NAME}(char *value, int bufSize){
    int ret = -1;
	char *buf;
    int status = 0;   
	cJSON *${1}_obj = cJSON_CreateObject();
		
	if (${1}_obj){
		//Body Start
		${GETBODY_C_CONTENT}
		//Body End
		buf = cJSON_PrintUnformatted(${1}_obj);
		
		if (buf) {
			strlcpy(value, buf, bufSize);
			ret = strlen (value);
			free (buf);
		} else {
			ret = -1;
		}
		cJSON_Delete (${1}_obj);

	} else {
			ret = -1;
	}
	
	return ret;	
}

STATUS set${FUNCTION_NAME}(char *content, int out)
{
 	int ret = 200;
	printf ("%s: %s\n", __func__,content);
	cJSON *${1}_obj = cJSON_Parse(content);
	cJSON *name=NULL;
	
	if (${1}_obj){
		${SETBODY_C_CONTENT}
		cJSON_Delete(${1}_obj);
	}
	
	cJSON *result_obj = cJSON_CreateObject();
	char *buf ;

	if (result_obj){
		cJSON_AddNumberToObject(result_obj, "result" , ret);
		buf = cJSON_PrintUnformatted(result_obj);
		if (buf) {
			sendDataWithSpecificHeader2Client(HTTP_STATUS_200_OK, "text/html", buf, strlen(buf), out);  //acos_shared
			free (buf);
		}
			
		cJSON_Delete (result_obj);

	}
	if (ret == 200 ){
		acosNvramConfig_save();
	}
	return ret;
}

C_TEMPLATE

cat > $CGIHPATH  << H_TEMPLATE
#ifndef _${1^^}_CGI_H
#define _${1^^}_CGI_H

#include "shared_lib_httpd.h"
int get${FUNCTION_NAME}(char *value, int bufSize);
STATUS set${FUNCTION_NAME}(char *content, int out);
#endif
H_TEMPLATE
}

#MAKEFILE
gen(){
	[  -e "$GETCGILISTPATH" ] && rm "$GETCGILISTPATH"
	touch ${GETCGILISTPATH}
	rm "${SETJSONPATH}"/*
	for entry in "${CONFIG_CGIPATH}"/*
	do
	
		CGIName=`jq -r '.cgiName' ${entry}`
		GETCGIName="Get${CGIName^}.cgi"
		SETCGIName="Set${CGIName^}.cgi"
		echo "CONFIG_FILE=${entry}, GET=${GETCGIName}, SET=${SETCGIName}"
		
		[ -n "`jq -e 'select ( has(\"set\"))' ${entry}`" ] && GenSetCGI ${entry}  "${SETJSONPATH}/${SETCGIName}"
		[  -n "`jq -e 'select ( has(\"get\"))' ${entry}`"  ] && addGetCgiInList "${GETCGIName}" ${GETCGILISTPATH}
	done
	exit 0
}

# main
SETJSONPATH="${HOME}/addFXCN/CGI/set"
GETCGILISTPATH="${HOME}/addFXCN/CGI/GetCgi.list"
CONFIG_CGIPATH="${HOME}/addFXCN/config"

[ ! -d "$SETJSONPATH" ] && mkdir -p $SETJSONPATH
[ ! -d "$CONFIG_CGIPATH" ] && mkdir -p  $CONFIG_CGIPATH

[ "$1" == "-g" ]  && gen

CGIName=`jq -r '.cgiName' ${1}`
GETCGIName="Get${CGIName^}.cgi"
SETCGIName="Set${CGIName^}.cgi"

#genServicefile ${CGIName} ${1}
GenSetCGI ${1}  "${SETJSONPATH}/${SETCGIName}"
addGetCgiInList "${GETCGIName}" ${GETCGILISTPATH}
#main end
