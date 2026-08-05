# Importar en phpMyAdmin

1. Abrí **phpMyAdmin** → **Importar**.
2. Elegí `patriumhub.sql`.
3. Ejecutá.

Verificación:

```sql
USE patriumhub;
SHOW TABLES;
SELECT email, role FROM users;
```

Login de la app: `admin@patriumhub.local` / `admin123`.
