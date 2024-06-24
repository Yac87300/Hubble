#定义变量

ALL_SATEA_VARS="Eth_Rpc_Url,Op_Rrc_Url,FID"

Eth_Rpc_Url={{SATEA_VARS_Eth_Rpc_Url}}

Op_Rrc_Url={{SATEA_VARS_Op_Rrc_Url}}

FID={{SATEA_VARS_FID}}


function VadVars(){
     echo "$ALL_SATEA_VARS"
}


function Manual() {
   >.env.sh
   chmod +x .env.sh
   for i in `echo $ALL_SATEA_VARS | tr ',' '\n' `;do

   i_split=`echo $i |tr -d "{" | tr -d "}"`

   read  -p "$i_split ="  i_split_vars

   echo "$i_split=$i_split_vars" >>.env.sh

  done
}


function WgetPackages(){
curl -sSL https://download.thehubble.xyz/bootstrap.sh | bash
}

function Makeenvfile() {

cat <<EOL >> .env
FC_NETWORK_ID=1
STATSD_METRICS_SERVER=statsd:8125
# Set this to your L1 Mainnet ETH RPC URL
ETH_MAINNET_RPC_URL=your-ETH-mainnet-RPC-URL

# Set this to your L2 Optimism Mainnet RPC URL
OPTIMISM_L2_RPC_URL=your-L2-optimism-RPC-URL

# Set this to your Farcaster FID
HUB_OPERATOR_FID=your-fid
EOL

sed -i "s|your-ETH-mainnet-RPC-URL|$Eth_Rpc_Url|g" .env
sed -i "s|your-L2-optimism-RPC-URL|$Op_Rrc_Url|g" .env
sed -i "s|your-fid|$FID|g" .env

}

function mkdirDir() {
      mkdir /root/hubble
}


function stop() {
    cd /root/hubble;./hubble.sh down
}

function clean() {
     echo "WARN: This operation will result in data/node loss,start in 5s"
     sleep 5
     cd /root/hubble;./hubble.sh down;rm -rf /root/hubble
}


function resetData() {
     echo "WARN: This operation will result in data/node loss,start in 5s"
     sleep 5
     cd /root/hubble; rm -rf .rock
}

function upgrade() {
    cd /root/hubble; ./hubble.sh upgrade
}

function logs() {
    cd /root/hubble; ./hubble.sh logs
}


function check() {
    dokcer_num=`docker ps | grep hubble | wc -l`

    if [ $dokcer_num -eq 3 ]
    then
      echo "All hubble docker running (Status: ok )"
      else
        echo "some hubble docker Not running (Status: bad )"

      fi

}





case $1 in

install)

  if [ "$2" = "--auto" ]
  then
     echo "-> Automatic mode, please ensure that ALL SATEA_VARS(`VadVars`) have been replaced !"
     sleep 3

     mkdirDir
     Makeenvfile
     WgetPackages


    else
      echo "Unrecognized variable(`VadVars`) being replaced, manual mode"
#      Manual
#      . .env.sh

      mkdirDir
      WgetPackages

    fi
  ;;

check)
checkStarted_success
  ;;

vars)
VadVars
  ;;

clean)
  clean
  ;;

stop)
  stop
  ;;

resetData)
  resetData
  ;;

upgrade)

  upgrade

  ;;


**)
  echo "Flag:
  install              Install Hubble with manual mode,  If carrying the --auto parameter, start Automatic mode
  stop                 Stop all Hubble docker
  up                   Start all Hubble docker
  upgrade              Upgrade an existing installation of Hubble
  logs                 Show the logs of the Hubble service
  clean                Remove the Hubble from your server
  resetData            Reset rockData,This will cause a resynchronization"
  ;;
esac
