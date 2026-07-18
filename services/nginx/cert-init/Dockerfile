# nginx-cert-init: 一次性容器，启动时若 localhost 证书缺失则用 host 的 mkcert CA 签发。
# 不用 docker hub 上的 mkcert 镜像（不可靠/不存在），自己下官方 release 二进制。
FROM alpine:3.20

ARG MKCERT_VERSION=1.4.4
RUN apk add --no-cache ca-certificates curl libressl && \
    case "$(uname -m)" in \
        x86_64)  asset="mkcert-v${MKCERT_VERSION}-linux-amd64" ;; \
        aarch64) asset="mkcert-v${MKCERT_VERSION}-linux-arm64" ;; \
        *) echo "unsupported arch: $(uname -m)"; exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/FiloSottile/mkcert/releases/download/v${MKCERT_VERSION}/${asset}" \
        -o /usr/local/bin/mkcert && \
    chmod +x /usr/local/bin/mkcert && \
    mkcert -version

COPY generate.sh /generate.sh
RUN chmod +x /generate.sh

# CAROOT=mkcert CA 目录(由 compose 挂载), SSL_DIR=证书输出目录, CERT_DOMAINS=签发域名
ENTRYPOINT ["/generate.sh"]
