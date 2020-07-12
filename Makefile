NAME = multiarch
VENDOR = seagullsailors
REGISTRY = dev.seagullsailors.com:5000

.PHONY: deploy
deploy: build docker.build docker.push

.PHONY: purge
purge: clean docker.clean

# GO lang

.PHONY: build
build:
	GOOS=linux GOARCH=amd64 go build -o ${NAME}_amd64.exe
	GOOS=linux GOARCH=arm64 go build -o ${NAME}_arm64.exe

.PHONY: clean
clean:
	- rm -rf \
		${NAME}_amd64.exe \
		${NAME}_arm64.exe

# Docker

.PHONY: docker.build
docker.build:
	docker build -t ${REGISTRY}/${VENDOR}/${NAME}:amd64 --no-cache --build-arg EXE=${NAME}_amd64.exe .
	docker build -t ${REGISTRY}/${VENDOR}/${NAME}:arm64 --no-cache --build-arg EXE=${NAME}_arm64.exe .

.PHONY: docker.login
docker.login:
	docker login ${REGISTRY}

# #see https://github.com/docker/cli/issues/954
.PHONY: docker.push
docker.push:
	docker push ${REGISTRY}/${VENDOR}/${NAME}:amd64
	docker push ${REGISTRY}/${VENDOR}/${NAME}:arm64
	docker manifest create \
		${REGISTRY}/${VENDOR}/${NAME}:latest \
		--amend ${REGISTRY}/${VENDOR}/${NAME}:amd64 \
		--amend ${REGISTRY}/${VENDOR}/${NAME}:arm64
	docker manifest annotate ${REGISTRY}/${VENDOR}/${NAME}:latest ${REGISTRY}/${VENDOR}/${NAME}:arm64 --variant v8 --arch arm64
	docker manifest push --purge ${REGISTRY}/${VENDOR}/${NAME}:latest
	docker pull ${REGISTRY}/${VENDOR}/${NAME}:latest

.PHONY: docker.pull
docker.pull:
	docker pull ${REGISTRY}/${VENDOR}/${NAME}:latest
	docker pull ${REGISTRY}/${VENDOR}/${NAME}:amd64
	docker pull ${REGISTRY}/${VENDOR}/${NAME}:arm64

.PHONY: docker.clean
docker.clean:
	- docker rmi \
		${REGISTRY}/${VENDOR}/${NAME}:latest \
		${REGISTRY}/${VENDOR}/${NAME}:amd64 \
		${REGISTRY}/${VENDOR}/${NAME}:arm64

.PHONY: docker.run
docker.run:
	docker run --rm ${REGISTRY}/${VENDOR}/${NAME}:latest

.PHONY: docker.image
docker.image:
	docker manifest inspect ${REGISTRY}/${VENDOR}/${NAME}:latest
