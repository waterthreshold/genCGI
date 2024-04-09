#!/bin/sh
USERNAME="admin"
PASSWORD=${PASSWORD-"password"}
IP="192.168.1.1"
PORT="80"
SET_COOKIE=$(curl --head -s  http://${USERNAME}:${PASSWORD}@${IP}:${PORT}/UPG_upgrade.htm | grep "Set-Cookie")
SET_COOKIE=${SET_COOKIE%%;*}
SET_COOKIE=${SET_COOKIE##*:}
echo $SET_COOKIE

GET_TOKEN (){
		CSRF_TOKEN=$(curl -s  http://${USERNAME}:${PASSWORD}@${IP}:${PORT}/UPG_upgrade.htm --header "Cookie:${SET_COOKIE}"| grep -oP 'id=\K.*?(?=")') #cannot have any space in Cookie header 
		echo $CSRF_TOKEN
}
Die ()
{
	msg=$1
	echo $msg
	exit 127
}

GET ()
{
CGI_ARRAY=("GetVer.cgi" \
 	"GetDevName.cgi" \
 	"GetDashboard.cgi" \
 	"GetLan.cgi" \
 	"Getupnp.cgi" \
 	 "GetIpv6.cgi" \
 	 "GetWireless.cgi" \
 	 "GetBasether.cgi" \
 	 "GetVlanIptv.cgi" \
 	 "GetPortfowarding.cgi" \
 	 "GetWirelessAdv.cgi" \
	 "GetWifiManagement.cgi" \
	 "GetHotspot.cgi" \
     "GetSystemLog.cgi"  \
	 "GetBasEtherPppoe.cgi" \
	 "GetTest.cgi" \
	 "GetRouterMode.cgi"
	)
	
	[ ! -d "CGI_GET/" ] && mkdir -p 
for CGI in "${CGI_ARRAY[@]}"; do
	echo "$CGI ..."
	curl -s  http://${USERNAME}:${PASSWORD}@${IP}:${PORT}/${CGI} --header "Cookie:${SET_COOKIE}" | jq -e .  #cannot have any space in Cookie header 
done

}

GET2 ()
{
	[ ! -d "${HOME}/addFXCN/CGI/get" ] && mkdir -p  ${HOME}/addFXCN/CGI/get
	if [ ! -e "${HOME}/addFXCN/CGI/GetCgi.list" ]; then   
		echo "File Not Exist!!"
		GET
		exit 127
	else 
		while read -r CGI; do
			echo "$CGI ..."
			curl -s  http://${USERNAME}:${PASSWORD}@${IP}:${PORT}/${CGI} --header "Cookie:${SET_COOKIE}" | jq -e .| tee ${HOME}/addFXCN/CGI/get/${CGI} #cannot have any space in Cookie header 
		done  < "${HOME}/addFXCN/CGI/GetCgi.list"
	fi
}
setCGI(){
	# CGI=~
	SETJSONPATH="${HOME}/addFXCN/CGI/set"
	for JSON in "$SETJSONPATH"/*
	do
		
		CGI="${JSON##*\/}"
		echo "send file content ${JSON} to ${CGI}"
		curl -X POST -s  http://${USERNAME}:${PASSWORD}@${IP}:${PORT}/${CGI}  --header "Cookie:${SET_COOKIE}" -d @${JSON} | jq -e .
	done
}
UPGRADE (){
	id=`GET_TOKEN`
	echo "id=$id"
	[ -z "$1" ] && Die "please input firmware filename"  || FIRMWARE=$1
	curl -X POST  "http://${USERNAME}:${PASSWORD}@${IP}:${PORT}/upgrade_check.cgi?=id=${id}"  -F ""mtenFWUpload=@${FIRMWARE}"" --header "Cookie:${SET_COOKIE}"  
	
}
usage ()
{	echo "Method:"
	echo -e "\tupgrade: upgrade firmware "
	echo -e "\tget: traverse all router CGI "
	echo -e "\tset: setting all router CGI "
}


case "$1" in 
	"upgrade")
		shift 
		UPGRADE $1
		;;
	"get")
		GET2
		;;
	"set")
		setCGI
		;;
	*)
		shift 
		[ -z "$1" ] && usage || GET $1
		;;
esac


