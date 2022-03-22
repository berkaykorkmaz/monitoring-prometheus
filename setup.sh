#!/bin/bash
prometheus_version="2.34.0"            # check latest version https://github.com/prometheus/prometheus/releases
node_exporter_version="1.3.1"          # check latest version https://github.com/prometheus/node_exporter/releases
mysqld_exporter_version="0.12.1"       # check latest version https://github.com/prometheus/mysqld_exporter/releases
redis_exporter_version="1.19.0"        # check latest version https://github.com/oliver006/redis_exporter/releases
nginx_exporter_version="0.8.0"         # check latest version https://github.com/nginxinc/nginx-prometheus-exporter/releases
phpfpm_exporter_version="0.5.0"        # check latest version https://github.com/Lusitaniae/phpfpm_exporter/releases
mongodb_exporter_version="0.20.3"      # check latest version https://github.com/percona/mongodb_exporter/releases/
rabbitmq_exporter_version="v1.0.0-RC8" #check latest version https://github.com/kbudde/rabbitmq_exporter/releases
mysql_username="deneme"
mysql_password="deme"
mysql_host="127.0.0.1"
RED='\033[0;31m'
NC='\033[0m'
YELLOW='\033[1;33m'
install_dir="/data/prometheus"

ARCH=amd64 # amd64 or arm64
prometheus_url="https://github.com/prometheus/prometheus/releases/download/v${prometheus_version}/prometheus-${prometheus_version}.linux-${ARCH}.tar.gz"
node_exporter_url="https://github.com/prometheus/node_exporter/releases/download/v${node_exporter_version}/node_exporter-${node_exporter_version}.linux-${ARCH}.tar.gz"
mysqld_exporter_url="https://github.com/prometheus/mysqld_exporter/releases/download/v${mysqld_exporter_version}/mysqld_exporter-${mysqld_exporter_version}.linux-${ARCH}.tar.gz"
redis_exporter_url="https://github.com/oliver006/redis_exporter/releases/download/v${redis_exporter_version}/redis_exporter-v${redis_exporter_version}.linux-${ARCH}.tar.gz"
nginx_exporter_url="https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v${nginx_exporter_version}/nginx-prometheus-exporter-${nginx_exporter_version}-linux-${ARCH}.tar.gz"
phpfpm_exporter_url="https://github.com/Lusitaniae/phpfpm_exporter/releases/download/v${phpfpm_exporter_version}/phpfpm_exporter-${phpfpm_exporter_version}.linux-${ARCH}.tar.gz"
mongodb_exporter_url="https://github.com/percona/mongodb_exporter/releases/download/v${mongodb_exporter_version}/mongodb_exporter-${mongodb_exporter_version}.linux-${ARCH}.tar.gz"
rabbitmq_exporter_url="https://github.com/kbudde/rabbitmq_exporter/releases/download/v${rabbitmq_exporter_version}/rabbitmq_exporter-${rabbitmq_exporter_version}.linux-${ARCH}.tar.gz"
whileint="1"
while [ $whileint -eq 1 ]; do
    karar='n'
    printf "${RED} Welcome the installation\n "
    printf "Please select which you want to install\n "
    printf "1- Prometheus Server\n 2- Node Exporter\n 3- MySQL Exporter\n 4- Redis Exporter\n 5- Nginx Exporter\n 6- php-fpm exporter \n 7- mongodb exporter \n 8- RabbitMQ exporter \n 9- Grafana Install \n 0- Exit\n "
    printf "Selection: ${YELLOW} " && read select
    printf "${NC}"

    function_userprometheus() {
        getent passwd prometheus >/dev/null
        if [[ $? -ne 0 ]]; then
            useradd --no-create-home --shell /bin/false prometheus
        fi
    }
    function_usernodeusr() {
        getent passwd nodeusr >/dev/null
        if [[ $? -ne 0 ]]; then
            useradd -rs /bin/false nodeusr
        fi
    }
    function_checkapp() {
        if ! command -v $1 &>/dev/null; then
            printf "${YELLOW} $1 could not be found ${NC} \n"
            exit 0
        fi
    }
    function_checkfolder() {
        if [[ -d "$install_dir" ]]; then
            echo "$install_dir found, installation continue..."
        else
            echo "$install_dir not found, will be create..."
            mkdir -p $install_dir
        fi
    }
    function_giveowner() {
        arg1=$1
        arg2=$2
        chown $arg1:$arg1 $arg2
    }
    function_giveowner_install_directory() {

        chown $1:$1 ${install_dir}/*

    }
    function_prometheus_todo() {
        echo "prometheus"
    }

    function_node_exporter_todo() {
        printf "${RED}You don't forget change your prometheus config file.\n ${YELLOW}"
        printf "Node exporter port: 9901/TCP ${NC}\n"
    }

    function_mysqld_exporter_todo() {
        printf "${RED}You should be check the /etc/.my.cnf ${NC} "
        printf "${RED}You don't forget change your prometheus config file.\n ${YELLOW}"
        printf "Mysqld exporter port: 9905/TCP ${NC}\n"
    }
    function_rabbitmq_exporter_todo() {
        printf "${RED}You don't forget change your prometheus config file.\n ${YELLOW}"
        printf "RabbitMQ exporter port: 9907/TCP ${NC}\n"
    }
    function_redis_exporter_todo() {
        printf "${RED}You don't forget change your prometheus config file.\n ${YELLOW}"
        printf "Redis exporter port: 9902/TCP ${NC}\n"
    }

    function_mongodb_exporter_todo() {
        printf "${RED}You don't forget change your prometheus config file.\n ${YELLOW}"
        printf "Mongodb exporter port: 9903/TCP ${NC}\n"
    }

    function_nginx_exporter_todo() {
        printf "${RED}You don't forget change your prometheus config file.\n ${YELLOW}"
        printf "Nginx exporter port: 9906/TCP ${NC}\n"
        printf "You should be add below nginx conf your nginx."
        cat <<EOF
server {
listen 8080;
server_name substatus;
location /stub_status {
stub_status on;
access_log off;
allow 127.0.0.1;
deny all;
}
}
EOF
    }

    function_phpfpm_exporter_todo() {
        printf "${RED}You don't forget change your prometheus config file.\n ${YELLOW}"
        printf "phpfpm exporter port: 9904/TCP ${NC}\n"
        printf "${YELLOW}You should be enable 'pm.status_path = /status' your php-fpm conf${NC}"
    }

    function_prometheus_install() {
        printf " ${RED} UYARI: Kurulum $install_dir altina yapılacaktır. Eger path yoksa oluşturulacaktır. ${NC}\n"
        function_checkfolder
        function_userprometheus
        wget $prometheus_url
        sleep 3
        tar -xzf prometheus-*.tar.gz
        #rm -rf prometheus*.tar.gz
        if [[ "$(ls -A ${install_dir}/)" ]]; then
            printf "${RED} $install_dir is not empty \n"
        else
            mv prometheus-${prometheus_version}*/* $install_dir/
            mv ${install_dir}/prometheus /usr/local/bin/
            mv ${install_dir}/promtool /usr/local/bin/
        fi
        rm -rf prometheus-${prometheus_version}*
        function_giveowner prometheus /usr/local/bin/prometheus
        function_giveowner prometheus /usr/local/bin/promtool
        function_giveowner_install_directory prometheus
        data_dir=${install_dir}/data
        mkdir -p $data_dir
        function_giveowner prometheus ${data_dir}
        function_service_prometheus
        systemctl enable prometheus --now
        rm -rf wget-log*
        printf "${RED} Installation succeed\n ${NC}"
        #### PROMETHEUS.YML DOSYASI ve SERVICE DOSYASI ####
    }
    function_node_exporter_install() {
        wget -b $node_exporter_url
        sleep 3
        function_usernodeusr
        tar -xzf node_exporter-*.tar.gz
        rm -rf node_exporter-*.tar.gz
        mv node_exporter*/node_exporter /usr/local/bin
        rm -rf node_exporter*
        function_service_node
        systemctl enable node_exporter --now
        rm -rf wget-log*
        printf "${RED} Installation succeed\n ${NC}"
        function_node_exporter_todo
    }
    function_mysqld_exporter_install() {
        wget -b $mysqld_exporter_url
        sleep 3
        function_usernodeusr
        tar -xzf mysqld_exporter-*.tar.gz
        rm -rf mysqld_exporter-*.tar.gz
        mv mysqld_exporter*/mysqld_exporter /usr/local/bin
        echo "[client]" >/etc/.my.cnf
        echo "user=$mysql_username" >>/etc/.my.cnf
        echo "password=$mysql_password" >>/etc/.my.cnf
        echo "host=$mysql_host" >>/etc/.my.cnf
        function_service_mysqld
        rm -rf mysqld_exporter*
        systemctl enable mysqld_exporter --now
        rm -rf wget-log*
        printf "${RED} Installation succeed\n ${NC}"
        function_mysqld_exporter_todo
    }
    function_redis_exporter_install() {
        wget -b $redis_exporter_url
        sleep 3
        function_usernodeusr
        tar -xzf redis_exporter-*.tar.gz
        rm -rf redis_exporter-*.tar.gz
        mv redis_exporter*/redis_exporter /usr/local/bin
        rm -rf redis_exporter*
        function_service_redis
        systemctl enable redis_exporter.service --now
        rm -rf wget-log*
        printf "${RED} Installation succeed\n ${NC}"
        function_redis_exporter_todo
    }
    function_nginx_exporter_install() {
        wget -b $nginx_exporter_url
        sleep 3
        function_usernodeusr
        tar -xzf nginx-prometheus-exporter-*.tar.gz
        rm -rf nginx-prometheus-exporter-*.tar.gz
        mv nginx-prometheus-exporter /usr/local/bin/nginx_exporter
        function_service_nginx
        systemctl enable nginx_exporter.service --now
        rm -rf wget-log*
        printf "${RED} Installation succeed\n ${NC}"
        function_nginx_exporter_todo
    }
    function_phpfpm_exporter_install() {
        wget -b $phpfpm_exporter_url
        sleep 3
        function_usernodeusr
        tar -xzf phpfpm_exporter-*.tar.gz
        rm -rf phpfpm_exporter-*.tar.gz
        mv phpfpm_exporter*/phpfpm_exporter /usr/local/bin
        rm -rf phpfpm_exporter*
        function_service_phpfpm
        systemctl enable phpfpm_exporter.service --now
        rm -rf wget-log*
        printf "${RED} Installation succeed\n ${NC}"
        function_phpfpm_exporter_todo
    }
    function_grafana_install() {
        wget -b https://dl.grafana.com/oss/release/grafana-7.3.6-1.x86_64.rpm
        sleep 3
        yum install grafana-7.3.6-1.x86_64.rpm -y
        systemctl enable grafana-server --now
    }

    function_mongodb_exporter_install() {
        wget -b $mongodb_exporter_url
        sleep 3
        function_usernodeusr
        tar -xzf mongodb_exporter-*.tar.gz
        rm -rf mongodb_exporter-*.tar.gz CHANGELOG.md README.md LICENSE
        mv mongodb_exporter /usr/local/bin
        function_service_mongodb
        systemctl enable mongodb_exporter.service --now
        rm -rf wget-log*
        printf "${RED} Installation succeed\n ${NC}"
        function_mongodb_exporter_todo
    }
    function_rabbitmq_exporter_install() {
        wget -b $rabbitmq_exporter_url
        sleep 3
        function_usernodeusr
        tar -xzf rabbitmq_exporter-*.tar.gz
        rm -rf rabbitmq_exporter-*.tar.gz
        mv rabbitmq_exporter*/rabbitmq_exporter /usr/local/bin
        function_service_rabbitmq
        function_conf_rabbitmq
        rm -rf rabbitmq_exporter*
        systemctl enable rabbitmq_exporter --now
        rm -rf wget-log*
        printf "${RED} Installation succeed\n ${NC}"
        function_rabbitmq_exporter_todo
    }
    function_service_prometheus() {
        cat >/etc/systemd/system/prometheus.service <<-EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
            --config.file /data/prometheus/prometheus.yml \
            --storage.tsdb.path /data/prometheus/data \
            --web.console.templates=/data/prometheus/consoles \
            --web.console.libraries=/data/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF
    }
    function_service_node() {
        cat >/etc/systemd/system/node_exporter.service <<-EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=nodeusr
Group=nodeusr
Type=simple
ExecStart=/usr/local/bin/node_exporter --collector.supervisord --web.listen-address=:9901

[Install]
WantedBy=multi-user.target
EOF
    }

    function_service_mongodb() {
        cat >/etc/systemd/system/mongodb_exporter.service <<-EOF
[Unit]
Description=MongoDB Exporter
User=nodeusr

[Service]
Type=simple
Restart=always
ExecStart=/usr/local/bin/mongodb_exporter --web.listen-address=:9903

[Install]
WantedBy=multi-user.target
EOF
    }

    function_service_mysqld() {
        cat >/etc/systemd/system/mysqld_exporter.service <<-EOF
[Unit]
Description=MySQL Exporter Service
Wants=network.target
After=network.target

[Service]
User=nodeusr
Group=nodeusr
Type=simple
Restart=always
ExecStart=/usr/local/bin/mysqld_exporter --config.my-cnf /etc/.my.cnf --web.listen-address=:9905
[Install]
WantedBy=multi-user.target
EOF
    }
    function_service_redis() {
        cat >/etc/systemd/system/redis_exporter.service <<-EOF
[Unit]
Description=Redis Exporter
After=network.target

[Service]
Type=simple
User=nodeusr
Group=nodeusr
ExecStart=/usr/local/bin/redis_exporter  --log-format=txt  --namespace=redis  --web.listen-address=:9902  --web.telemetry-path=/metrics

[Install]
WantedBy=multi-user.target

EOF
    }
    function_service_nginx() {
        cat >/etc/systemd/system/nginx_exporter.service <<-EOF
[Unit]
Description=Nginx Exporter
After=network.target

[Service]
User=nodeusr
Group=nodeusr
Type=simple
ExecStart=/usr/local/bin/nginx_exporter -nginx.scrape-uri http://127.0.0.1:8080/stub_status --web.listen-address=:9906

[Install]
WantedBy=multi-user.target
EOF
    }
    function_service_phpfpm() {
        cat >/etc/systemd/system/phpfpm_exporter.service <<-EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/local/bin/phpfpm_exporter --phpfpm.socket-paths /run/php-fpm/www.sock --web.listen-address=:9904

[Install]
WantedBy=multi-user.target
EOF
    }
    function_service_rabbitmq() {
        cat >/etc/systemd/system/rabbitmq_exporter.service <<-EOF
[Unit]
Description=RabbitMQ Exporter Service
Wants=network.target
After=network.target

[Service]
User=nodeusr
Group=nodeusr
Type=simple
Restart=always
ExecStart=/usr/local/bin/rabbitmq_exporter -config-file /etc/rabbitmq-exporter-conf.json
[Install]
WantedBy=multi-user.target
EOF
    }
    function_conf_rabbitmq() {
        cat >/etc/rabbitmq-exporter-conf.json <<-EOF
{
    "rabbit_url": "http://127.0.0.1:15672",
    "rabbit_user": "guest",
    "rabbit_pass": "guest",
    "publish_port": "9907",
    "publish_addr": "",
    "output_format": "TTY",
    "insecure_skip_verify": true,
    "exlude_metrics": [],
    "include_queues": ".*",
    "skip_queues": "^$",
    "skip_vhost": "^$",
    "include_vhost": ".*",
    "rabbit_capabilities": "no_sort,bert",
    "enabled_exporters": [
            "exchange",
            "node",
            "overview",
            "queue"
    ],
    "timeout": 30,
    "max_queues": 0
}
EOF
    }
    function_prometheus_config() {
        cat >${install_dir}/prometheus.yml <<-EOF
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus_master'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
EOF
    }

    #Check app install status
    applist=(wget tar)
    for i in ${applist[@]}; do
        function_checkapp $i
    done

    if [[ $select -eq 1 ]]; then
        function_prometheus_install
    elif [[ $select -eq 2 ]]; then
        function_node_exporter_install
    elif [[ $select -eq 3 ]]; then
        function_mysqld_exporter_install
    elif [[ $select -eq 4 ]]; then
        function_redis_exporter_install
    elif [[ $select -eq 5 ]]; then
        function_nginx_exporter_install
    elif [[ $select -eq 6 ]]; then
        function_phpfpm_exporter_install
    elif [[ $select -eq 7 ]]; then
        function_mongodb_exporter_install
    elif [[ $select -eq 8 ]]; then
        function_rabbitmq_exporter_install
    elif [[ $select -eq 9 ]]; then
        function_grafana_install
    elif [[ $select -eq 0 ]]; then
        exit 0
    else
        printf "${RED} Your chose is wrong, please re run this script."
    fi


    printf "${RED} Do you want another installation ? ${YELLOW}(Y/n) ${NC}\n"
    read karar
    if [ "$karar" = "n" ] || [ "$karar" = "N" ]; then
        exit 0
    fi

done

