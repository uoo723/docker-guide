# Docker 가이드

## 설치

1. `apt` 패키지 인덱스 업데이트

    ```sh
    $ sudo apt update
    ```

2. HTTPS를 통해 `apt`가 외부 repository를 사용할 수 있게 하기 위해 필요한 패키지 설치

    ```sh
    $ sudo apt install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common
    ```

3. Docker official GPG key 추가

    ```sh
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    ```

4. stable 버전 repository 추가

    ```sh
    $ sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
    ```

5. `apt` 패키지 인덱스 업데이트

    ```sh
    $ sudo apt update
    ```

6. 최선 버전 Docker 설치

    ```sh
    $ sudo apt install docker-ce docker-ce-cli containerd.io
    ```

7. docker 그룹 추가 (Optional)  
docker command는 root 권한을 요구하므로 매번 docker command를 입력하려면 sudo 명령으로
실행해야 함. 이를 완화하기 위해 docker command를 사용하는 user를 docker 그룹에 포함시켜 sudo
명령을 생략할 수 있게 함. (이후 설명할 docker command는 sudo 명령어를 생략함.)

    ```sh
    $ sudo usermod -aG docker [your-user]
    ```

    실행 후 logout한 다음 (shell에서 exit) 다시 로그인 하여 확인  
    tmux와 같은 terminal multiplexer를 사용한다면 모든 session을 종료해야 함.

    ```sh
    $ id # uid 및 gid 확인
    $ docker run hello-world # test run 정상적으로 실행되는지 확인
    ```

8. docker-compose 설치하기  
`docker-compose`는 [multi-container](#Container) Docker application을 정의하고
실행하는 툴인데 단일 [container](#Container)를 실행하고 관리하기에도 매우 유용하다.
사용법은 [docker-compose](#docker-compose) section에서 다루도록 한다. 

    ```sh
    $ sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose # docker-compose 다운로드
    $ sudo chmod +x /usr/local/bin/docker-compose # 실행권한 부여
    $ docker-compose --version # 버전 확인
    ```

## Docker 용어 설명

### Image

이미지는 이것이다.

### Container

컨테이너는 커

## Docker 기본 명령

## docker-compose
