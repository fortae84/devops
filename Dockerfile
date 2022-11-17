# 경량화 OS 기반
FROM alpine:latest

# OS 업데이트
RUN apk update && apk upgrade

# 필요 패키지 설치
RUN apk add git openjdk11 fontconfig ttf-opensans tzdata

# 서버 시간 설정
RUN echo 'Asia/Seoul' > /etc/timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# 폴더 구조화
RUN mkdir -p /sw/app/ && mkdir -p /sw/logs/ && mkdir -p /sw/sol/ && mkdir -p /.m2/repository
RUN chmod o+wr -R /sw/app/ && chmod o+wr -R /sw/logs/ && chmod o+wr -R /sw/sol/ && chmod o+wr -R /.m2/repository

WORKDIR /sw/sol/java
RUN mkdir -p /sw/sol/java && ln -s /usr/lib/jvm/java-11-openjdk /sw/sol/java/jdk1.11

# 서버 환경변수 설정
ENV LANG='UTF-8 ko_KR.UTF-8' LANGUAGE='ko_KR.UTF-8' LC_ALL='ko_KR.UTF-8'
ENV MAVEN_HOME=/sw/sol/apache-maven-3.8.6
ENV JAVA_HOME=/sw/sol/java/jdk1.11
ENV PATH=$MAVEN_HOME/bin:$JAVA_HOME/bin:$PATH

# 사용자 변경
USER nobody

# MAVEN 설치
WORKDIR /sw/sol
RUN wget https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz && tar zxvf ./apache-maven-3.8.6-bin.tar.gz && rm -f apache-maven-3.8.6-bin.tar.gz

# 어플리케이션 설치
WORKDIR /sw/app
RUN git clone https://github.com/fortae84/devops.git

# 어플리케이션 빌드
WORKDIR /sw/app/devops

RUN mvn package

# JAVA jvm 설정
ENV JVMARG="-Xms512m -Xmx512m -Djava.security.egd=file:/dev/./urandom -Dfile.encoding=utf-8 -Dclient.encoding.override=utf-8 -server"

# Scouter APM Agent
ENV SCOUTERARG="-Dobj_name=devops -Dnet_collector_ip=svc-scouter.ns-scouter.svc.cluster.local -javaagent:lib/scouter-agent-java-2.17.1.jar"

########### 사용자 지정 #################
# 서버 포트  지정
ENV PORT=8080
# 배포 구분: dev, stg, prod
ENV DTYPE=dev
#####################################

# 포트 오픈
EXPOSE ${PORT}

# 어플리케이션 실행
CMD java ${JVMARG} -Dspring.profiles.active=${DTYPE} -Dserver.port=${PORT} ${SCOUTERARG} -jar ./target/project-0.0.1-SNAPSHOT.jar
 
