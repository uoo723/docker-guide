# Docker Guide (사용법)

설치법은 [여기](https://github.com/uoo723/docker-guide)

## 1. 목적

공용서버 등과 같이 여러 사람들이 공용으로 리소스를 사용하는 환경에서는 각자가 연구 개발한 코드의 의존성이
다양하기 때문에 사용하는 패키지 등의 버전이 충돌할 수 있다. Python을 사용한다면 conda와 같은 프로그램을
사용하여 Python 버전 및 패키지 버전을 python 가상환경을 구성하여 관리할 수 있지만, 그 외에 cuda와 같이
다양한 버전을 관리할 수 있는 매커니즘을 제공하지 않은 경우 불가피하게 기존 버전을 제거하고 새로운 버전의
패키지를 설치해야 하는 번거로움이 발생하게 되게 된다. 또한 이전 버전에서 돌려야 하는 코드가 설치된 버전의
의존성에 대해 동작하지 않을 수 있다.

따라서 이러한 문제를 피하기 위해 os level의 가상환경 구성이 요구된다. 따라서 이를 가능하도록 하는
Docker를 이용하여 각자의 코드 환경이 독립적으로 구성할 수 있도록 한다.

## 2. Docker Hub

[Docker Hub](https://hub.docker.com/)는 docker image를 공유할 수 있는 repository이고,
기존의 image를 사용하여 미리 만들어진 환경을 그대로 사용할 수 있으며, 자신이 만든 docker image를
올릴 수도 있다. 이번 튜토리얼에서는 기존 official image로도 충분히 원하는 환경을 구성할 수 있으므로
Docker image를 생상하는 방법은 생략한다.

## 3. Tensorflow

tensorflow에서 제공하는 official [image](https://hub.docker.com/r/tensorflow/tensorflow)를
사용하여 tensorflow 코드 동작 환경을 구성하는 방법.

### 3-1. TL;DR

```bash
$ docker run \
--rm \  # automatically remove container when it is stopped
-it \  # enable interactive mode
--gpus all \  # enable gpu
-v $(pwd):/src \  # Mount host directory
-w /src \  # workding directory in container
--name [your-container-name] \  # name of container
tensorflow/tensorflow:2.0.0-gpu-py3 \  # image name
[python tf-tutorial.py]  # command to be exected in container
```

### 3-2. 명령어 구성

* `docker run` [options] [image] [command]
* command가 생략되면 container의 shell로 진입함.

#### 3-2-1. 옵션 설명

* `--rm`: 도커 컨테이너 생성 후 실행이 완료되면 컨테이너 삭제
* `-it`: 컨테이너와의 interactive 모드 활성 (키보드 입력)
* `--gpus` [all | num-of-gpu]: 컨테이너에서 사용할 gpu 갯수를 지정 all이면 모든 gpu 사용
* `-v` [src]:[dst]: 컨테이너 내에서 작성한 코드에 접근하기 위해 호스트의 src위치와 컨테이너의 dst의
  위치를 맵핑하여야 한다.
* `-w` [working-dir]: 컨테이너의 working directory 지정
* `--name` [container-name]: 컨테이너 이름을 지정

#### 3-2-2. 올바른 버전의 image 선택

\[image_name]:[tag]

* `image_name`은 tensorflow/tensorflow
* `tag`는 image 버전 등을 표기하기 위한 용도로, 제공하는 image마다 tag를 다는 규칙은 다르다.
* `tensorflow`이미지  같은 경우 [version][|-gpu][|-py3]로 구성되며 전체 사용가능 `tag`
  리스트는 [다음](https://hub.docker.com/r/tensorflow/tensorflow/tags)에서 확인 가능하다.

## 4. Pytorch

pytorch에서 제공하는 official [image](https://hub.docker.com/r/tensorflow/tensorflow)를
사용하여 pytorch 코드 동작 환경을 구성하는 방법.

### 4-1. TL;DR

```bash
$ docker run \
--rm \  # automatically remove container when it is stopped
-it \  # enable interactive mode
--gpus all \  # enable gpu
-v $(pwd):/src \  # Mount host directory
-w /src \  # workding directory in container
--ipc=host \  # Use the host system's IPC namespace.
pytorch/pytorch:1.2-cuda10.0-cudnn7-runtime \  # image name
[python pytorch-tutorial.py]  # command to be exected in container
```

* `--ipc=host`: `torch.nn.Dataparallel`를 사용하기 위해서 ipc모드를 host로 변경 
* 나머지 옵션 설명은 [3. Tensorflow](#3.-Tensorflow)와 동일

### 5. 기타 의존성 python 패키지 설치

코드 실행시 부가적으로 필요한 python 패키지는 `requirements.txt` 파일에 명시하여 docker 컨테이너
실행시 자동으로 설치하도록 한다.

#### requirements.txt

```txt
torchvision==0.5.0
openpyxl==3.0.3
```

#### python 패키지 설치 후에 코드 실행

```bash
$ docker run \
--rm \
-it \
--gpus all -v $(pwd):/src -w /src pytorch/pytorch:1.2-cuda10.0-cudnn7-runtime /bin/bash -c 'pip install -r requirements.txt && python pytorch-tutorial.py'
```

매번 코드 수정 후 테스트하게 될 때 (code development cycle) 위의 명령을 다시 실행하는 경우 처음부터 패키지를
다운받아 설치하는 과정을 거치는데, 패키지의 사이즈가 큰 경우에는 다운로드 받는 시간으로 인해 낭비되는 시간이 생기므로 
pip cache directory를 호스트 시스템에 마운트하여 다운받는 시간을 단축한다.

#### Docker volume 생성하기

```bash
$ docker volume create pip_cache
$ docker volume ls  # volume 리스트 확인
```

#### Docker container 실행시 pip cache directory 마운트

```bash
$ docker run --rm -it --gpus all \
-v $(pwd):/src \
-v pip_cache:/pip_cache \
-w /src \
pytorch/pytorch:1.2-cuda10.0-cudnn7-runtime \
/bin/bash -c \
'pip install --cache-dir /pip_cache -r requirements.txt && python pytorch-tutorial.py'
```

다음 실행시에는 disk에 cache된 패키지를 설치하게 된다.
