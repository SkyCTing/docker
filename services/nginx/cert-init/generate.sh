#!/bin/sh
# nginx-cert-init: 启动时检查 localhost 证书是否存在，缺失则用 host 的 mkcert CA 签发。
# 浏览器信任的前提：宿主机已 `mkcert -install` 装好 CA（本机已装）。
set -eu

CERT_DIR="${SSL_DIR:-/ssl}"
CERT_NAME="${CERT_NAME:-_wildcard.localhost.com+1}"
CERT_FILE="$CERT_DIR/$CERT_NAME.pem"
KEY_FILE="$CERT_DIR/$CERT_NAME-key.pem"

# 1) 已存在且非空 -> 跳过
if [ -s "$CERT_FILE" ] && [ -s "$KEY_FILE" ]; then
    echo "[cert-init] $CERT_FILE 已存在，跳过生成。"
    exit 0
fi

# 2) 必须挂载了 host 的 mkcert CA
if [ ! -s "${CAROOT}/rootCA.pem" ] || [ ! -s "${CAROOT}/rootCA-key.pem" ]; then
    echo "[cert-init] 错误：CAROOT($CAROOT) 下没有 rootCA.pem / rootCA-key.pem。"
    echo "[cert-init] 请在宿主机执行 \`mkcert -install\`，并把 CAROOT 挂载到 \$CAROOT。"
    exit 1
fi

mkdir -p "$CERT_DIR"

# 3) 用 host CA 签发（mkcert 读取 CAROOT 环境变量定位 CA）
echo "[cert-init] 生成证书 -> $CERT_FILE （domains: ${CERT_DOMAINS}）"
# shellcheck disable=SC2086
mkcert -cert-file "$CERT_FILE" -key-file "$KEY_FILE" $CERT_DOMAINS

echo "[cert-init] 完成。"
