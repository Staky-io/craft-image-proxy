# syntax=docker/dockerfile:1.4
FROM --platform="linux/arm64" cgr.dev/chainguard/go:latest as build
LABEL maintainer="Will Norris <will@willnorris.com>"

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .

ARG TARGETOS
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -v ./cmd/imageproxy

FROM cgr.dev/chainguard/static:latest

COPY --from=build /app/imageproxy /app/imageproxy

CMD ["-addr", "0.0.0.0:8080", "-cache", "s3://eu-central-1/elasticbeanstalk-eu-central-1-657659270578/cache/"]
ENTRYPOINT ["/app/imageproxy"]

EXPOSE 8080
