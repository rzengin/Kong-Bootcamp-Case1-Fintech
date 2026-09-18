# Konnect Developer Portal Setup Guide

Para la demostración del Developer Portal (Paso 8 del Checklist), sigue estos pasos desde la interfaz web de Konnect, ya que el Developer Portal es una característica de nivel empresarial diseñada para ser administrada como "Productos".

## 1. Habilitar el Portal (¡Automatizado!)
¡Buenas noticias! El Developer Portal (`RZE-FinTech-Portal`) ya ha sido creado y habilitado automáticamente utilizando Terraform (`konnect_portal`).

1. Entra a **Konnect**.
2. Ve al menú **Developer Portal**.
3. Selecciona tu portal `RZE-FinTech-Portal` (debería estar en Status `Published`).
4. En **Appearance**, puedes personalizar el logo de la FinTech para el efecto "Wow".

## 2. Publicar Productos (API Specs)
Los archivos OpenAPI (Swagger) de los servicios ya existen en la carpeta `gitops-monorepo/api-specs/openapi-specs/`. 

Para publicarlos en el portal:
1. En Konnect, ve al menú **API Products**.
2. Haz clic en **Add API Product** y llámalo `Accounts API`.
3. Selecciona el servicio desde el Control Plane `RZE-Core Banking` (este aparecerá después de hacer el `deck sync`).
4. Haz clic en **Add Version** (ej. `v1`).
5. En **API Specification**, sube el archivo `gitops-monorepo/api-specs/openapi-specs/accounts-api.yaml`.
6. En **Publishing**, publica este API Product en tu Developer Portal.

Repite este proceso para la `Transactions API` (usando el Control Plane de Credit Cards y el archivo `transactions-api.yaml`).

## 3. Demostración al Evaluador
- Muestra el portal público navegando a su URL.
- Haz clic en `Accounts API` y muestra cómo los endpoints se han documentado automáticamente.
- Demuestra el "Try It Out" incrustado en el portal para generar solicitudes a las rutas configuradas en el Data Plane.
