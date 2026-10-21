# bootstrap-tls

> [!IMPORTANT]
> `ca/ca.key` и все `server.key` файлы должны быть зашифрованы с помощью ansible-vault перед коммитом.

## CA

Перевыпуск CA проводится только при потере/компрометации ключа.
Срок сертификата — 10 лет.

```bash
cd bootstrap-tls

openssl genrsa -out ca/ca.key 4096
openssl req -x509 -new -nodes \
  -key ca/ca.key \
  -sha256 -days 3650 \
  -out ca/ca.crt \
  -subj "/CN=vault-internal-ca"
```

## Выпуск сертификата для Vault-ноды

Ключ:
```bash
openssl genrsa -out <vault-domain>/server.key 4096
```

CSR:
```bash
openssl req -new \
  -key <vault-domain>/server.key \
  -out <vault-domain>/server.csr \
  -config <vault-domain>/cert.cnf
```

Пример cert конфига:
```ini
[ req ]
default_bits       = 4096
distinguished_name = req_distinguished_name
req_extensions     = req_ext
prompt = no
[ req_distinguished_name ]
CN = <vault-domain>
[ req_ext ]
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = <vault-domain>
DNS.2 = <another-domain>
IP.1  = <vault-node-ip>
```

Подпись:
```bash
openssl x509 -req \
  -in <vault-domain>/server.csr \
  -CA ca/ca.crt \
  -CAkey ca/ca.key \
  -CAcreateserial \
  -out <vault-domain>/server.crt \
  -days 825 \
  -sha256 \
  -extensions req_ext \
  -extfile <vault-domain>/cert.cnf
```

Проверка SAN:
```bash
openssl x509 -in <vault-domain>/server.crt -noout -text | grep -A1 "Subject Alternative"
```

## Продление сертификата

```bash
cd bootstrap-tls/<vault-domain>

openssl req -new \
  -key server.key \
  -out server.csr \
  -config cert.cnf

openssl x509 -req \
  -in server.csr \
  -CA ../ca/ca.crt \
  -CAkey ../ca/ca.key \
  -CAcreateserial \
  -out server.crt \
  -days 825 \
  -sha256 \
  -extensions req_ext \
  -extfile cert.cnf
```
