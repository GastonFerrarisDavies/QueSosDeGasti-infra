# api_image y frontend_image los reescriben los CI de cada repo en cada push a main.
# Siempre por digest: el tag (sha-xxxxxxx) es solo informativo, Docker usa el @sha256.
db_image       = "pgvector/pgvector:pg15@sha256:47af0b65960b14f1c6945aa4ccae37836c632e9a6fe0eea9160936e616e5b2e9"
api_image      = ""
frontend_image = ""
