# Deploy na AWS e Observabilidade

## Infraestrutura de Produção
* **Provedor:** AWS EC2 (`t3.small`, Ubuntu, 2 GiB Swap) na região **São Paulo (`sa-east-1`)** para conformidade com a LGPD (dados de saúde mantidos em território nacional).
* **Orquestração:** Docker Compose (`docker-compose.yml`) executando:
  * `software-brava` (Nginx `:8080` + FastAPI `:8000` + PostgreSQL `:5432`)
  * `prometheus` (`127.0.0.1:9090`)
  * `grafana` (`127.0.0.1:3000`)
* **Exposição Pública HTTPS:** container `cloudflared` (Cloudflare Tunnel) conectado ao domínio **`https://bravasamu.com.br`** com DNS gerenciado na Cloudflare. Nenhuma porta HTTP/HTTPS fica aberta no Security Group da AWS.

---

## Procedimento de Deploy e Rollback

### Atualizar a versão em produção
```bash
cd ~/Software_brava
git pull
docker compose up -d --build software-brava
```
*(Quando houver apenas alterações em `Backend/*.py` sem novas dependências no `requirements.txt`, `docker compose restart software-brava` aplica em segundos.)*

### Rollback para versão anterior
```bash
git log --oneline -n 5
git checkout <HASH_ESTAVEL>
docker compose up -d --build software-brava
```

### Backup Diário do PostgreSQL
Agendado via `cron` na EC2 (`~/backups/`), gerando dump compactado diário com `pg_dump` + `gzip` do volume persistente `brava_pgdata`.

---

## Observabilidade (Prometheus + Grafana)

1. **Coleta de Métricas:** o FastAPI expõe `/metrics` via `prometheus-fastapi-instrumentator==8.1.0` apenas na porta interna `8000` (bloqueada da internet pelo Nginx).
2. **Scraping:** `monitoring/prometheus.yml` coleta `software-brava:8000/metrics` a cada `15s`.
3. **Acesso Seguro:** o Prometheus e o Grafana ficam restritos a `127.0.0.1` na EC2 e são acessados exclusivamente por **túnel SSH** autenticado com chave `.pem`:
   ```powershell
   ssh -i .\software-brava-key.pem -L 3000:127.0.0.1:3000 -L 9091:127.0.0.1:9090 ubuntu@15.229.118.44
   ```
4. **Indicadores Monitorados:** taxa de requisições por rota/status (`2xx`, `4xx`, `5xx`), latência média e percentis p95/p99 (`http_request_duration_seconds_bucket`), exceções e uso de memória/GC do processo Python.
