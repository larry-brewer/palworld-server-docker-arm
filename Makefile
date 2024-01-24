PHONY: .build .build-arm

build:
	docker build -t palworld:dev .

build-arm:
	docker build -t palworld:dev -f Dockerfile.arm64 .
