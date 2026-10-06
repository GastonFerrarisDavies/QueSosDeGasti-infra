# api_image y frontend_image los reescriben los CI de cada repo en cada push a main.
# Siempre por digest: el tag (sha-xxxxxxx) es solo informativo, Docker usa el @sha256.
db_image       = "pgvector/pgvector:pg15@sha256:47af0b65960b14f1c6945aa4ccae37836c632e9a6fe0eea9160936e616e5b2e9"
api_image      = "ghcr.io/gastonferrarisdavies/quesosdegasti-backend:sha-576a720@sha256:930ee22ced5c68e5ec1c3c0d9f973ba46f1f92b1ffaf7a0ca89c3eb84d7079ad"
frontend_image = ""
