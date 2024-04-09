/****************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "httpd.h"

int getTestCgiMain(char *value, int bufSize){
    int ret = -1;
	char *buf;
    int status = 0;   
	cJSON *test_obj = cJSON_CreateObject();
		
	if (test_obj){
		//Body Start
		
		cJSON_AddStringToObject(test_obj,"test1",acosNvramConfig_get("nvram_test1"));
		cJSON_AddNumberToObject(test_obj,"test2",atoi(acosNvramConfig_get("nvram_test2")));
		cJSON_AddItemToObject(test_obj,"test3",convertNvramToBoolean("nvram_test3")?cJSON_CreateTrue():cJSON_CreateFalse());
		char tmp_nvram[64];
		cJSON *test_array_obj = cJSON_CreateArray();
		int i,test_array_len=atoi(acosNvramConfig_get("test_arr_count"));
		for (i=0 ; i < test_array_len ;i++) {
			cJSON *test_array_item_obj=NULL;
			cJSON_AddItemToArray(test_array_obj, test_array_item_obj = cJSON_CreateObject());
			memset(tmp_nvram,0,sizeof(tmp_nvram));
			snprintf(tmp_nvram,sizeof(tmp_nvram),"test_arr_Enable_%d",i);
			cJSON_AddItemToObject(test_array_item_obj,"Enable",convertNvramToBoolean(tmp_nvram)?cJSON_CreateTrue():cJSON_CreateFalse());
			memset(tmp_nvram,0,sizeof(tmp_nvram));
			snprintf(tmp_nvram,sizeof(tmp_nvram),"test_arr_id_%d",i);
			cJSON_AddNumberToObject(test_array_item_obj,"id",atoi(acosNvramConfig_get(tmp_nvram)));
			memset(tmp_nvram,0,sizeof(tmp_nvram));
			snprintf(tmp_nvram,sizeof(tmp_nvram),"test_arr_name_%d",i);
			cJSON_AddStringToObject(test_array_item_obj,"name",acosNvramConfig_get(tmp_nvram));
			memset(tmp_nvram,0,sizeof(tmp_nvram));
			snprintf(tmp_nvram,sizeof(tmp_nvram),"test_arr_ip_%d",i);
			cJSON_AddStringToObject(test_array_item_obj,"ip",acosNvramConfig_get(tmp_nvram));
			memset(tmp_nvram,0,sizeof(tmp_nvram));
			snprintf(tmp_nvram,sizeof(tmp_nvram),"test_arr_mac_%d",i);
			cJSON_AddStringToObject(test_array_item_obj,"mac",acosNvramConfig_get(tmp_nvram));
		}
		if(test_array_len>0)
			cJSON_AddItemToObject(test_obj, "test_array" ,test_array_obj );
		//Body End
		buf = cJSON_PrintUnformatted(test_obj);
		
		if (buf) {
			strlcpy(value, buf, bufSize);
			ret = strlen (value);
			free (buf);
		} else {
			ret = -1;
		}
		cJSON_Delete (test_obj);

	} else {
			ret = -1;
	}
	
	return ret;	
}

STATUS setTestCgiMain(char *content, int out)
{
 	int ret = 200;
	printf ("%s: %s\n", __func__,content);
	cJSON *test_obj = cJSON_Parse(content);
	cJSON *name=NULL;
	
	if (test_obj){
		
		name=cJSON_GetObjectItem(test_obj,"test1");
		if(name){
		acosNvramConfig_set("nvram_test1",name->valuestring);
		} else{
		ret=400;
		}
		name=cJSON_GetObjectItem(test_obj,"test2");
		if(name){
		char test2_str[64]={0};
		snprintf(test2_str,sizeof(test2_str),"%d",name->valueint);
		acosNvramConfig_set("nvram_test2",test2_str);
		} else{
		ret=400;
		}
		name=cJSON_GetObjectItem(test_obj,"test4");
		if(name){
		char test4_str[64]={0};
		snprintf(test4_str,sizeof(test4_str),"%f",name->valuedouble);
		acosNvramConfig_set("nvram_test4",test4_str);
		} else{
		ret=400;
		}
		cJSON* test_array_arrObj = cJSON_GetObjectItem(test_obj,"test_array");
		int i,array_size = cJSON_GetArraySize (test_array_arrObj);
		char tmp_nvram[64]={0};
		snprintf(tmp_nvram,sizeof(tmp_nvram),"%d",array_size);
		acosNvramConfig_set("test_arr_count",tmp_nvram);
		for ( i=0 ;i < array_size ;i++) {
			cJSON* test_array_arr_item= cJSON_GetArrayItem(test_array_arrObj,i);
		
			memset (tmp_nvram,0 ,sizeof(tmp_nvram));
			snprintf (tmp_nvram,sizeof(tmp_nvram),"test_arr_Enable_%d",i);
		
			cJSON* Enable_itemObj = cJSON_GetObjectItem(test_array_arr_item,"Enable");
			if (Enable_itemObj){
				acosNvramConfig_set(tmp_nvram,"Enable");
			}
			
			memset (tmp_nvram,0 ,sizeof(tmp_nvram));
			snprintf (tmp_nvram,sizeof(tmp_nvram),"test_arr_id_%d",i);
		
			cJSON* id_itemObj = cJSON_GetObjectItem(test_array_arr_item,"id");
			if (id_itemObj){
				char test_arr_id_str[64]={0};
				snprintf(test_arr_id_str,sizeof(test_arr_id_str),"%d",id_itemObj->valueint);
				acosNvramConfig_set(tmp_nvram,test_arr_id_str);
			}
			
			memset (tmp_nvram,0 ,sizeof(tmp_nvram));
			snprintf (tmp_nvram,sizeof(tmp_nvram),"test_arr_name_%d",i);
		
			cJSON* name_itemObj = cJSON_GetObjectItem(test_array_arr_item,"name");
			if (name_itemObj){
			acosNvramConfig_set(tmp_nvram,name_itemObj->valuestring);
			}
			
			memset (tmp_nvram,0 ,sizeof(tmp_nvram));
			snprintf (tmp_nvram,sizeof(tmp_nvram),"test_arr_ip_%d",i);
		
			cJSON* ip_itemObj = cJSON_GetObjectItem(test_array_arr_item,"ip");
			if (ip_itemObj){
			acosNvramConfig_set(tmp_nvram,ip_itemObj->valuestring);
			}
			
			memset (tmp_nvram,0 ,sizeof(tmp_nvram));
			snprintf (tmp_nvram,sizeof(tmp_nvram),"test_arr_mac_%d",i);
		
			cJSON* mac_itemObj = cJSON_GetObjectItem(test_array_arr_item,"mac");
			if (mac_itemObj){
			acosNvramConfig_set(tmp_nvram,mac_itemObj->valuestring);
			}
		
		}
		cJSON_Delete(test_obj);
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

