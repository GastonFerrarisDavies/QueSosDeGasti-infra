# QueSosDeGasti — Infra

Terraform de Azure: una sola VM (`Standard_A1_v2`, Ubuntu 24.04) con Docker donde conviven las 3 imágenes:

| Servicio | Imagen | Puerto público |
|---|---|---|
| `frontend` | `ghcr.io/gastonferrarisdavies/quesosdegasti-frontend` (nginx, export estático) | 80 |
| `api` | `ghcr.io/gastonferrarisdavies/quesosdegasti-backend` (Go) | 8080 |
| `db` | `pgvector/pgvector:pg15` | — (solo red interna de Docker) |

## Flujo

```
push a backend/frontend ──► CI: test ─► build + push a GHCR ─► commit en images.auto.tfvars (repo infra)
                                                                        │
push a infra (*.tf, *.tfvars, templates/) ◄─────────────────────────────┘
        │
        └─► CD: terraform plan ─► apply ─► Run Command en la VM: docker compose pull && up -d && seed
```

- Las imágenes se fijan **por digest** (`repo:sha-abc1234@sha256:…`); el tag es solo informativo.
- `main.tf` crea la red, la IP estática con DNS y la VM. `cloud-init` solo instala Docker.
- `deploy.tf` es un `azurerm_virtual_machine_run_command`: cualquier cambio en el script (digest nuevo, compose, variables) lo re-ejecuta en la VM **sin recrearla**.
- Hasta que `api_image` y `frontend_image` tengan valor, solo se crea la infraestructura.
- La base solo contiene lo que carga el seed, que corre en cada despliegue. Si la VM se recrea, se vuelve a poblar sola.

## Archivos

```
versions.tf             provider + backend remoto (nombres en backend.hcl)
variables.tf            variables (los secretos llegan por TF_VAR_* desde GitHub)
images.auto.tfvars      digests de las imágenes (lo edita el CI)
main.tf                 RG, VNet, NSG, IP pública, VM
deploy.tf               despliegue de los contenedores (Run Command)
templates/              cloud-init, docker-compose.yml y script de despliegue
files/init.sql          copia de db/init.sql del backend (mantener sincronizada)
```

## Uso local

```bash
az login
terraform init -backend-config=backend.hcl
terraform plan -var-file=prod.secret.tfvars   # ssh_public_key, postgres_password, openai_api_key
```

Tu usuario necesita el rol `Storage Blob Data Contributor` en el Storage Account del estado.

## Operación

- **Forzar redeploy** sin cambios: Actions → CD → Run workflow → `force_redeploy`.
- **Logs**: `ssh gasti@<fqdn>` y `cd /opt/quesosdegasti && sudo docker compose logs -f`.
- **No editar `templates/cloud-init.yaml`** salvo que quieras recrear la VM (cambia la IP privada y reinstala todo; la IP pública y el DNS se mantienen).
