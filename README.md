# ELK  7.10.0部署-docker-compose

> install & config ELK with docker 
>
> 设置密码并配置安全ssl

## set vm.max_map_count

1. modify  sysctl.conf

```shell
vim /etc/sysctl.conf 
# add content: vm.max_map_count = 262144 
```

2. 临时生效

```shell
sysctl -w vm.max_map_count=262144
```

## 1 pull image

> image 版本要和.env文件中的版本一致

```shell
cd /home
git clone https://github.com/loululin/elk-docker.git
cd elk-docker
./pullImage.sh 7.10.0
chmod 777 elasticsearch  kibana  logstash
```

## 2 get  file **elastic-stack-ca.p12**

1. start temp container

```shell
docker run --name es -d -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.10.0
```

2. generator **elastic-stack-ca.p12**

```shell
docker exec -it es /bin/bash
./bin/elasticsearch-certutil ca
exit
```

3. copy **elastic-stack-ca.p12** to host dir

```shell
cd /home/elk-docker
docker cp es:/usr/share/elasticsearch/elastic-stack-ca.p12 .
chmod 777 elastic-stack-ca.p12
```

4. remove temp container

```shell
docker rm -f es
```

## 3 generate passwd

1. start container

```she
docker-compose up -d es01 es02 es03
docker-compose logs -f es01
```

2. enter container

> 自动生成密码用auto或自己设置用 `interactive`

```shell
docker exec -it es01 /bin/bash
./bin/elasticsearch-setup-passwords interactive
# 123456
```

3. restart container

```shell
docker-compose restart es01 es02 es03
```

4. verify

```shell
access http://ip:9200/_cat/nodes  with elastic/123456
and you will see:
192.168.16.4 54 28 18 0.19 0.31 0.69 cdhilmrstw - es02
192.168.16.2 65 28 18 0.19 0.31 0.69 cdhilmrstw * es03
192.168.16.3 14 28 18 0.19 0.31 0.69 cdhilmrstw - es01
```

## 4 confirm kibana and logstash authentication info

> 如果密码为纯数字，需要加上双引号

```properties
logstash/config/logstash.yml 
logstash/pipeline/logstash.conf 
kibana/config/kibana.yml
```

## 5 start kibana

```shell
docker-compose up -d kibana
docker-compose logs -f kibana
```

## 6 start logstash

```shell
docker-compose up -d logstash
docker-compose logs -f logstash
```

## 7 restart service

```shell
docker-compose restart
```

## 8 look services status

```shell
[root@localhost elk-docker]# docker-compose ps
  Name                Command               State                                               Ports                                             
--------------------------------------------------------------------------------------------------------------------------------------------------
es01       /tini -- /usr/local/bin/do ...   Up      0.0.0.0:9200->9200/tcp, 0.0.0.0:9300->9300/tcp                                                
es02       /tini -- /usr/local/bin/do ...   Up      9200/tcp, 9300/tcp                                                                            
es03       /tini -- /usr/local/bin/do ...   Up      9200/tcp, 9300/tcp                                                                            
kibana     /usr/local/bin/dumb-init - ...   Up      0.0.0.0:5601->5601/tcp                                                                        
logstash   /usr/local/bin/docker-entr ...   Up      0.0.0.0:5000->5000/tcp, 0.0.0.0:5000->5000/udp, 0.0.0.0:5044->5044/tcp, 0.0.0.0:9600->9600/tcp
```

## 9 access kibana

> http://host-ip:5601/

## 10 midify passwd

1. enter es container

```shell
docker exec -it es01 /bin/bash
```

2. create temp superadmin user : ryan

> 至少6位

```shell
./bin/elasticsearch-users useradd ryan -r superuser
```

3. modify elastic's passwd

```shell
curl -XPUT -u ryan:ryan123 http://localhost:9200/_xpack/security/user/elastic/_password -H "Content-Type: application/json" -d '
{
  "password": "q5f2qNfUJQyvZPIz57MZ"
}'
```

## 11 curator

> 定期删除ES索引，比如删除3天前的索引

### 11.1 build image

```shell
cd extensions/curator
docker build -t curator:comm .
docker images
```

### 11.2 start curator

```shell
docker-compose up -d curator

docker-compose ps

docker exec -it curator /bin/bash
```

### 11.3 log

```shell
cd extensions/curator/logs/

tail -f run.log
```

### 11.4 modify delete_log_files_curator.yml-添加删除策略

> no need restart curator container

```shell
cd extensions/curator/config

vim delete_log_files_curator.yml

cd extensions/curator/logs/

tail -f run.log

```


### 11.5 modify crontab-修改定时执行策略

> linux crontab online tool:https://tool.lu/crontab
>
> need restart curator container
> for example:     0 1 * * *


```shell
cd extensions/curator/cron

vim crontab

cd ../../..

docker-compose restart curator

cd extensions/curator/logs/

tail -f run.log
```


