# databases — PatriumHub

## Archivo de instalación

| Archivo | Uso |
|---------|-----|
| **`patriumhub.sql`** | **Único SQL de instalación.** Crea la BD, todas las tablas, índices, FKs y seed mínimo. |

Schema version: **0.8.0**

### Cómo importar

1. Abrí phpMyAdmin.
2. Importar → elegí `patriumhub.sql` → Ejecutar.
3. Verificá:

```sql
USE patriumhub;
SHOW TABLES;
SELECT email, role FROM users;
SELECT setting_value FROM settings WHERE setting_key = 'schema.version';
```

Usuario seed:

| Campo | Valor |
|-------|-------|
| Email | `admin@patriumhub.local` |
| Password | `admin123` |

### Qué incluye el seed

- Monedas: ARS, USD, EUR  
- Categorías de movimiento (sistema)  
- Usuario admin  
- Settings (`app.name`, `schema.version` 0.8.0, `ui.hide_amounts`)  

**No incluye** datos de negocio ni tokens de WooCommerce / Mercado Pago.

### Novedades 0.8.0

- `companies.business_model` (`services` \| `products`) — plantilla de Estados y proyección  
- `user_entity_access` — qué personas/empresas puede ver cada usuario no-admin  

### Tablas principales (resumen)

Patrimonio: `entities`, `people`, `companies`, `ownerships`, `accounts`, `assets`, `properties`, `receivables`, `liabilities`, `inventories`, `transactions`, `budget_*`, `business_valuations`, `net_worth_snapshots`, `company_financial_plans`  

Acceso: `users`, `user_entity_access`  

Integraciones: `integrations`, `integration_credentials`, `sync_runs`, `sync_cursors`, `sales_metrics`  

Soporte: `settings`, `audit_log`, `saved_views`, `currencies`, `transaction_categories`

## Otros archivos

| Archivo | Nota |
|---------|------|
| `patch_estados_proyeccion.sql` | Histórico — absorbido |
| `build_install_sql.py` | Regenera install limpio desde dump phpMyAdmin |
| `archives/` | Dumps históricos con datos (no usar para instalar) |

## BD ya desplegada

Si la app ya corre, podés migrar en caliente (sin reimportar):

`/patrium/scripts/migrate_v08.php?key=patrium-migrate-v08`
