-- =============================================================================
-- PatriumHub — ÚNICO archivo de instalación
-- BD: patriumhub · utf8mb4 / utf8mb4_unicode_ci
-- Schema version: 0.8.8
--
-- Importar SOLO este archivo en phpMyAdmin (Importar → Ejecutar).
-- Crea la BD, todas las tablas, índices, FKs y seed mínimo.
-- No hace falta ningún patch adicional.
--
-- Incluye: patrimonio, presupuestos, snapshots, integraciones WC/MP,
--          saved_views, company_financial_plans (servicios/productos),
--          person_financial_plans (proyección personal),
--          financial_goals (metas personalizadas; milestones viven en app + settings),
--          companies.business_model, user_entity_access (permisos),
--          company_clients (fichas de cliente para empresas de servicios),
--          documents con related_type company_client_contract | company_client_file,
--          asset_owners (co-titulares de activos personales),
--          account_owners (co-titulares de cuentas personales),
--          receivables.status con 'paid'.
--
-- Reglas de app (no son columnas extra; el motor las aplica):
--   · budget_templates / budget_items: category_id opcional (mismos
--     transaction_categories que movimientos); al pagar se copia al egreso.
--     Editar la plantilla reaplica monto/nombre/moneda/vencimiento/categoría sobre sus
--     ítems con status='pending' y period_ym >= mes actual (BudgetService::syncPendingItems);
--     paid/skipped intactos. ensurePeriod() hace lo mismo por período
--     (syncPendingItemsForPeriod): el total del período = total de Presupuestos por grupos.
--     Los períodos pasados no se tocan (pendiente atrasado = deuda como se facturó):
--     un cambio de precio por inflación rige del mes actual en adelante.
--     Los gastos se crean solo desde Presupuestos por grupos (no hay ítem suelto de un mes).
--     Totales del mes usan COALESCE(paid_amount, amount) y filtran currency_code;
--     Presupuestos por grupos totaliza budget_templates activas por moneda (no las mezcla).
--     Meses futuros se pueden generar al navegar Presupuestos, pero NO bajan el neto
--     hasta que llega ese mes (Y-m del servidor).
--   · Proyecciones consolidadas (/proyecciones) leen person_financial_plans +
--     company_financial_plans (solo lectura; la carga es por ficha).
--   · Insight «promedio mensual» = disponible neto anual / 12 (persona y /proyecciones).
--   · Gasto diario máximo = disponible neto del mes / días de ese mes (12 cards + gráfico);
--     disponible neto = balance − ahorro; referencia = promedio mensual ÷ 30.
--   · Carga de egresos (persona, empresa y /proyecciones) = egresos planilla / ingresos:
--       anillo del año (egresos + ahorro + disponible neto), mes a mes apilado
--       (rojo ≥50% / gris <50% egresos, celeste ahorro, verde disponible neto),
--       ranking por entidad (barras horizontales) y personas vs empresas (solo consolidado).
--     En ficha persona y empresa (Estados y proyección): además desglose por categoría
--       (nombre de cada línea de egreso × % ingreso) + gasto diario máximo.
--     Meta de ahorro (%): solo sobre saldo mensual positivo; no usa budget_templates.
--     La UI de flujo no incluye doughnut de «composición».
--   · Año activo en planillas (persona + empresa):
--       al abrir, el año por defecto = año calendario del servidor (o el más cercano);
--       en empresa, Comparativa por año y Detalle del año comparten el mismo índice
--       (cambiar el select o la pestaña actualiza ambos); «+ Año» agrega el siguiente
--       año numérico sin prompt (doble clic en la pestaña para renombrar).
--   · Inicio / Dashboard: segunda fila de KPIs = cada métrica como % de total_assets
--     (partial stat_pct_of_assets; sin columnas nuevas).
--   · Objetivos (/objetivos · «Objetivos fundamentales»):
--       Milestones 01–03 (cards full-width, Cumplidos N/N):
--         01 fondo ARS 1.200.000 — juntado en settings goals.ramsey.emergency_*;
--         02 deudas = pasivos abiertos de entities.type=person;
--         03 meta auto = 15% ingreso neto personas del año en curso;
--            ahorrado manual settings goals.ramsey.ms03_saved_{año}_{moneda}.
--       Metas personalizadas: tabla financial_goals; listado en /objetivos;
--       alta en /objetivos/nuevo (también Cumplidos N/N).
--   · Resumen persona: bloque Proyección usa la hoja del año calendario
--     (no el activeYear guardado); si no hay hoja, la más cercana.
--   · Activos varios: DELETE vía POST /activos/{id}/eliminar (borra asset_owners + assets).
--   · Movimientos: DELETE vía POST /movimientos/{id}/eliminar (revierte saldos; si estaba
--     ligado a budget_items paid, el ítem vuelve a pending). Sin columnas nuevas.
--   · Acciones de tablas (UI): iconos .btn-icon — Eliminar = danger (rojo);
--     Pagar/Cobrar = warn (amarillo). Helpers ui_icon / icon_action_* en helpers.php.
--   · Tema claro/oscuro: solo UI (html[data-theme] + localStorage patrium-theme).
--     Evento JS patrium:theme redibuja Chart.js (ticks/leyendas) sin recargar.
--     Cards accent y thead usan tokens de superficie (--navy / --table-head).
--   · Botones Eliminar de la UI usan clase btn / btn-icon danger (rojo) en toda la app.
--   · Vista /gastos: análisis de egresos (transactions expense/payment) +
--     presupuesto del mes de cierre del rango + proyección prorrateada del año;
--     filtros entity_id (vacío=todas | people | companies | id), currency,
--     preset/from/to. Sin tablas nuevas.
--     Gráfico categoría × mes: siempre los 12 meses del año de cierre del filtro
--     (ene–dic; ceros si no hay datos); barras horizontales apiladas top 10 + Otros;
--     tooltip = monto y % del total del mes (ExpenseAnalysisService::byCategoryMonth).
--   · Categorías de movimiento (seed + Catalog::ensureTransactionCategories): además
--     de las base, Comida, Salidas, Suscripciones, Limpieza, Higiene personal,
--     Kiosco, Librería, Auto, Arreglos, Celular, Alquiler/es,
--     Medicación & Farmacia (kind expense).
--   · Nav admin: Inicio → Dashboard → Objetivos → Proyecciones → Presupuestos →
--     Gastos → Movimientos → Patrimonio (último, accent ámbar).
--   · Volver arriba: botón fijo en el layout (aparece al scrollear); no hay columna.

--   · Cobrables (receivables): listado /cobrables y pestaña en persona/empresa con
--       cabeceras ordenables (cliente); ficha entidad muestra due_date (Vence);
--       alta/edición/cobro desde ficha usa return_to seguro (safe_return_path) y
--       vuelve a la entidad, no al listado general.
--
-- No incluye: datos de producción ni credenciales de integraciones.
--
-- Login seed: admin@patriumhub.local / admin123  (cambiar tras el primer login)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS patriumhub
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE patriumhub;

SET NAMES utf8mb4;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET time_zone = '+00:00';
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `settings`;
DROP TABLE IF EXISTS `audit_log`;
DROP TABLE IF EXISTS `documents`;
DROP TABLE IF EXISTS `entity_tags`;
DROP TABLE IF EXISTS `tags`;
DROP TABLE IF EXISTS `saved_views`;
DROP TABLE IF EXISTS `net_worth_snapshots`;
DROP TABLE IF EXISTS `sales_metrics`;
DROP TABLE IF EXISTS `financial_goals`;
DROP TABLE IF EXISTS `sync_cursors`;
DROP TABLE IF EXISTS `sync_runs`;
DROP TABLE IF EXISTS `integration_credentials`;
DROP TABLE IF EXISTS `integrations`;
DROP TABLE IF EXISTS `company_clients`;
DROP TABLE IF EXISTS `person_financial_plans`;
DROP TABLE IF EXISTS `company_financial_plans`;
DROP TABLE IF EXISTS `budget_items`;
DROP TABLE IF EXISTS `budget_templates`;
DROP TABLE IF EXISTS `transactions`;
DROP TABLE IF EXISTS `transaction_categories`;
DROP TABLE IF EXISTS `inventory_snapshots`;
DROP TABLE IF EXISTS `inventories`;
DROP TABLE IF EXISTS `liabilities`;
DROP TABLE IF EXISTS `receivables`;
DROP TABLE IF EXISTS `properties`;
DROP TABLE IF EXISTS `account_owners`;
DROP TABLE IF EXISTS `asset_owners`;
DROP TABLE IF EXISTS `assets`;
DROP TABLE IF EXISTS `account_balances`;
DROP TABLE IF EXISTS `accounts`;
DROP TABLE IF EXISTS `business_valuations`;
DROP TABLE IF EXISTS `ownerships`;
DROP TABLE IF EXISTS `user_entity_access`;
DROP TABLE IF EXISTS `companies`;
DROP TABLE IF EXISTS `people`;
DROP TABLE IF EXISTS `entities`;
DROP TABLE IF EXISTS `currencies`;
DROP TABLE IF EXISTS `users`;

--
-- Tabla `users`
--
CREATE TABLE `users` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','viewer') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'admin',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `currencies`
--
CREATE TABLE `currencies` (
  `code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `symbol` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `decimals` tinyint UNSIGNED NOT NULL DEFAULT '2',
  `is_active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `entities`
--
CREATE TABLE `entities` (
  `id` int UNSIGNED NOT NULL,
  `type` enum('person','company') COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(180) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `people`
--
CREATE TABLE `people` (
  `entity_id` int UNSIGNED NOT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `document_id` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `birth_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `companies`
--
CREATE TABLE `companies` (
  `entity_id` int UNSIGNED NOT NULL,
  `legal_name` varchar(220) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_id` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `industry` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `business_model` enum('services','products') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'services',
  `website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `user_entity_access`
--
CREATE TABLE `user_entity_access` (
  `user_id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `ownerships`
--
CREATE TABLE `ownerships` (
  `id` int UNSIGNED NOT NULL,
  `owner_entity_id` int UNSIGNED NOT NULL,
  `company_entity_id` int UNSIGNED NOT NULL,
  `ownership_pct` decimal(7,4) NOT NULL DEFAULT '100.0000',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `business_valuations`
--
CREATE TABLE `business_valuations` (
  `id` int UNSIGNED NOT NULL,
  `company_entity_id` int UNSIGNED NOT NULL,
  `valued_at` date NOT NULL,
  `currency_code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ARS',
  `total_value` decimal(18,2) NOT NULL DEFAULT '0.00',
  `method` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'manual',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_by` int UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `accounts`
--
CREATE TABLE `accounts` (
  `id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('bank','checking','savings','wallet','mercadopago','cash','broker','virtual','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'bank',
  `currency_code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ARS',
  `balance` decimal(18,2) NOT NULL DEFAULT '0.00',
  `balance_held` decimal(18,2) NOT NULL DEFAULT '0.00',
  `provider` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `origin` enum('manual','integration') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'manual',
  `integration_id` int UNSIGNED DEFAULT NULL,
  `include_in_net_worth` tinyint(1) NOT NULL DEFAULT '1',
  `status` enum('active','closed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `last_synced_at` datetime DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `account_balances`
--
CREATE TABLE `account_balances` (
  `id` bigint UNSIGNED NOT NULL,
  `account_id` int UNSIGNED NOT NULL,
  `captured_at` datetime NOT NULL,
  `balance` decimal(18,2) NOT NULL DEFAULT '0.00',
  `balance_held` decimal(18,2) NOT NULL DEFAULT '0.00',
  `source` enum('manual','integration','system') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'manual',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `account_owners` (co-titulares personas; empresas usan solo accounts.entity_id)
--
CREATE TABLE `account_owners` (
  `id` int UNSIGNED NOT NULL,
  `account_id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `ownership_pct` decimal(7,4) NOT NULL DEFAULT '100.0000',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `account_owners` (co-titulares personas; empresas usan solo accounts.entity_id)
--
CREATE TABLE `account_owners` (
  `id` int UNSIGNED NOT NULL,
  `account_id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `ownership_pct` decimal(7,4) NOT NULL DEFAULT '100.0000',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `assets`
--
CREATE TABLE `assets` (
  `id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `account_id` int UNSIGNED DEFAULT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('vehicle','equipment','machinery','investment','intangible','crypto','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'other',
  `currency_code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ARS',
  `current_value` decimal(18,2) NOT NULL DEFAULT '0.00',
  `ownership_pct` decimal(7,4) NOT NULL DEFAULT '100.0000',
  `valuation_method` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `valued_at` date DEFAULT NULL,
  `include_in_net_worth` tinyint(1) NOT NULL DEFAULT '1',
  `status` enum('active','sold','archived') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `asset_owners` (co-titulares personas; empresas usan solo assets.entity_id)
--
CREATE TABLE `asset_owners` (
  `id` int UNSIGNED NOT NULL,
  `asset_id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `ownership_pct` decimal(7,4) NOT NULL DEFAULT '100.0000',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `properties`
--
CREATE TABLE `properties` (
  `id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `property_type` enum('house','apartment','local','warehouse','land','office','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'other',
  `location_text` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ownership_pct` decimal(7,4) NOT NULL DEFAULT '100.0000',
  `currency_code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USD',
  `current_value` decimal(18,2) NOT NULL DEFAULT '0.00',
  `valuation_method` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `valued_at` date DEFAULT NULL,
  `linked_liability_id` int UNSIGNED DEFAULT NULL,
  `include_in_net_worth` tinyint(1) NOT NULL DEFAULT '1',
  `status` enum('active','sold','archived') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `receivables`
-- Cuentas por cobrar (quién debe, a qué entidad, monto, due_date, status incl. paid).
-- UI: orden por cabeceras; en ficha persona/empresa se muestra Vence; return_to al
--     crear/cobrar desde la ficha (helpers.safe_return_path).
--
CREATE TABLE `receivables` (
  `id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `debtor_name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `debtor_entity_id` int UNSIGNED DEFAULT NULL,
  `currency_code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ARS',
  `original_amount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `outstanding_amount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `due_date` date DEFAULT NULL,
  `status` enum('current','overdue','uncollectible','cancelled','paid') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'current',
  `collection_probability` decimal(5,2) DEFAULT NULL,
  `include_in_net_worth` tinyint(1) NOT NULL DEFAULT '1',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `liabilities`
--
CREATE TABLE `liabilities` (
  `id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `liability_type` enum('credit_card','loan','mortgage','supplier','tax','overdraft','internal','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'other',
  `creditor_name` varchar(180) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `creditor_entity_id` int UNSIGNED DEFAULT NULL,
  `currency_code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ARS',
  `original_amount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `outstanding_amount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `due_date` date DEFAULT NULL,
  `status` enum('open','paid','defaulted','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `include_in_net_worth` tinyint(1) NOT NULL DEFAULT '1',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `inventories`
--
CREATE TABLE `inventories` (
  `id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Inventario',
  `source` enum('manual','woocommerce','dolibarr','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'manual',
  `integration_id` int UNSIGNED DEFAULT NULL,
  `currency_code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ARS',
  `stock_value` decimal(18,2) NOT NULL DEFAULT '0.00',
  `units_total` decimal(18,3) NOT NULL DEFAULT '0.000',
  `products_count` int UNSIGNED NOT NULL DEFAULT '0',
  `variations_count` int UNSIGNED NOT NULL DEFAULT '0',
  `out_of_stock_count` int UNSIGNED NOT NULL DEFAULT '0',
  `low_stock_count` int UNSIGNED NOT NULL DEFAULT '0',
  `valued_at` datetime DEFAULT NULL,
  `include_in_net_worth` tinyint(1) NOT NULL DEFAULT '1',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `inventory_snapshots`
--
CREATE TABLE `inventory_snapshots` (
  `id` bigint UNSIGNED NOT NULL,
  `inventory_id` int UNSIGNED NOT NULL,
  `captured_at` datetime NOT NULL,
  `stock_value` decimal(18,2) NOT NULL DEFAULT '0.00',
  `units_total` decimal(18,3) NOT NULL DEFAULT '0.000',
  `products_count` int UNSIGNED NOT NULL DEFAULT '0',
  `source` enum('manual','integration','system') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'manual',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `transaction_categories`
--
CREATE TABLE `transaction_categories` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `kind` enum('income','expense','transfer','adjustment','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'other',
  `is_system` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `transactions`
--
CREATE TABLE `transactions` (
  `id` bigint UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `account_id` int UNSIGNED DEFAULT NULL,
  `counterparty_account_id` int UNSIGNED DEFAULT NULL,
  `category_id` int UNSIGNED DEFAULT NULL,
  `type` enum('income','expense','transfer','adjustment','asset_change','loan','collection','payment','integration') COLLATE utf8mb4_unicode_ci NOT NULL,
  `occurred_at` datetime NOT NULL,
  `currency_code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ARS',
  `amount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `origin` enum('manual','integration','system') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'manual',
  `integration_id` int UNSIGNED DEFAULT NULL,
  `external_id` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `metadata_json` json DEFAULT NULL,
  `created_by` int UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `budget_templates`
--
CREATE TABLE `budget_templates` (
  `id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `currency_code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ARS',
  `frequency` enum('monthly') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'monthly',
  `due_day` tinyint UNSIGNED NOT NULL DEFAULT '1',
  `category_id` int UNSIGNED DEFAULT NULL,
  `suggested_account_id` int UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `include_in_net_worth` tinyint(1) NOT NULL DEFAULT '1',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `budget_items`
-- Instancia mensual de un gasto_templates.
-- period_ym = 'YYYY-MM'. Solo pending con period_ym <= mes actual cuentan como pasivo
-- (ver PatrimonioService / LiabilityController). Meses adelantados no impactan el neto.
--
CREATE TABLE `budget_items` (
  `id` int UNSIGNED NOT NULL,
  `template_id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `period_ym` char(7) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `currency_code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ARS',
  `due_date` date NOT NULL,
  `status` enum('pending','paid','skipped') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `include_in_net_worth` tinyint(1) NOT NULL DEFAULT '1',
  `category_id` int UNSIGNED DEFAULT NULL,
  `account_id` int UNSIGNED DEFAULT NULL,
  `transaction_id` bigint UNSIGNED DEFAULT NULL,
  `paid_amount` decimal(18,2) DEFAULT NULL,
  `paid_at` datetime DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `company_clients` (fichas — solo empresas de servicios)
--
CREATE TABLE `company_clients` (
  `id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_name` varchar(180) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(180) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contract_notes` text COLLATE utf8mb4_unicode_ci,
  `value_annual` decimal(18,2) NOT NULL DEFAULT '0.00',
  `value_total` decimal(18,2) NOT NULL DEFAULT '0.00',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `company_financial_plans`
-- workbook_json: hojas por año (ingresos/egresos, % ahorro). Alimenta Estados y proyección
-- y la vista consolidada /proyecciones.
-- Ahorro = meta % solo sobre balance mensual positivo; disponible neto = balance − ahorro.
-- UI (financial-plan.js): Comparativa + Detalle sincronizados; año default = calendario;
--   carga de egresos + gasto diario al pie; «+ Año» = siguiente año sin prompt.
--
CREATE TABLE `company_financial_plans` (
  `id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `workbook_json` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `person_financial_plans`
-- Proyección personal (ingresos/egresos/ahorro por año en workbook_json).
-- Pestaña Persona → Proyecciones; también entra en /proyecciones consolidado.
-- UI: año default = calendario; promedio mensual = disponible neto/12;
--     gasto diario = neto del mes/días (ref ÷30);
--     neto = balance − ahorro (meta % solo si balance > 0);
--     carga = egresos + ahorro + disponible neto (anillo, mes, por categoría = nombre línea);
--     «+ Año» = siguiente año numérico (doble clic en pestaña para renombrar).
--
CREATE TABLE `person_financial_plans` (
  `id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `workbook_json` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `financial_goals`
-- Metas personalizadas (menú Objetivos → Tus objetivos / /objetivos/nuevo).
-- Milestones 01–03 NO viven acá: se calculan en FinancialGoalsService
-- (settings para juntado MS01/MS03; liabilities de personas para MS02).
--
CREATE TABLE `financial_goals` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_amount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `current_amount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `currency_code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ARS',
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `status` enum('active','completed','archived') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `integrations`
--
CREATE TABLE `integrations` (
  `id` int UNSIGNED NOT NULL,
  `provider` enum('mercadopago','woocommerce','dolibarr') COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('active','error','revoked','disabled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `config_json` json DEFAULT NULL,
  `account_id` int UNSIGNED DEFAULT NULL,
  `last_sync_at` datetime DEFAULT NULL,
  `last_error` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `integration_credentials`
--
CREATE TABLE `integration_credentials` (
  `id` int UNSIGNED NOT NULL,
  `integration_id` int UNSIGNED NOT NULL,
  `key_name` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value_encrypted` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `sync_runs`
--
CREATE TABLE `sync_runs` (
  `id` bigint UNSIGNED NOT NULL,
  `integration_id` int UNSIGNED NOT NULL,
  `started_at` datetime NOT NULL,
  `finished_at` datetime DEFAULT NULL,
  `status` enum('running','success','failed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'running',
  `records_read` int UNSIGNED NOT NULL DEFAULT '0',
  `records_upserted` int UNSIGNED NOT NULL DEFAULT '0',
  `message` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `sync_cursors`
--
CREATE TABLE `sync_cursors` (
  `id` int UNSIGNED NOT NULL,
  `integration_id` int UNSIGNED NOT NULL,
  `cursor_key` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cursor_value` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `sales_metrics`
--
CREATE TABLE `sales_metrics` (
  `id` bigint UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `integration_id` int UNSIGNED DEFAULT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `currency_code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ARS',
  `orders_count` int UNSIGNED NOT NULL DEFAULT '0',
  `sales_total` decimal(18,2) NOT NULL DEFAULT '0.00',
  `refunds_total` decimal(18,2) NOT NULL DEFAULT '0.00',
  `customers_count` int UNSIGNED NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `net_worth_snapshots`
--
CREATE TABLE `net_worth_snapshots` (
  `id` bigint UNSIGNED NOT NULL,
  `scope` enum('entity','personal','consolidated') COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` int UNSIGNED DEFAULT NULL,
  `currency_code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ARS',
  `captured_at` datetime NOT NULL,
  `accounts` decimal(18,2) NOT NULL DEFAULT '0.00',
  `assets` decimal(18,2) NOT NULL DEFAULT '0.00',
  `properties` decimal(18,2) NOT NULL DEFAULT '0.00',
  `receivables` decimal(18,2) NOT NULL DEFAULT '0.00',
  `inventories` decimal(18,2) NOT NULL DEFAULT '0.00',
  `participations` decimal(18,2) NOT NULL DEFAULT '0.00',
  `liabilities` decimal(18,2) NOT NULL DEFAULT '0.00',
  `internal_netting` decimal(18,2) NOT NULL DEFAULT '0.00',
  `total_assets` decimal(18,2) NOT NULL DEFAULT '0.00',
  `net_worth` decimal(18,2) NOT NULL DEFAULT '0.00',
  `payload_json` json DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `saved_views`
--
CREATE TABLE `saved_views` (
  `id` int UNSIGNED NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `context` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'dashboard',
  `filters_json` json NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `tags`
--
CREATE TABLE `tags` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `color` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `entity_tags`
--
CREATE TABLE `entity_tags` (
  `entity_id` int UNSIGNED NOT NULL,
  `tag_id` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `documents`
-- related_type actuales: company_client_contract, company_client_file
-- (related_id = company_clients.id). Archivos fuera de BD (storage/uploads).
--
CREATE TABLE `documents` (
  `id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED DEFAULT NULL,
  `related_type` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `related_id` int UNSIGNED DEFAULT NULL,
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mime_type` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uploaded_by` int UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `audit_log`
--
CREATE TABLE `audit_log` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` int UNSIGNED DEFAULT NULL,
  `action` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entity_id` int UNSIGNED DEFAULT NULL,
  `summary` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `before_json` json DEFAULT NULL,
  `after_json` json DEFAULT NULL,
  `ip` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabla `settings`
--
CREATE TABLE `settings` (
  `setting_key` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `setting_value` text COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Índices
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_accounts_entity` (`entity_id`),
  ADD KEY `idx_accounts_type` (`type`),
  ADD KEY `idx_accounts_status` (`status`),
  ADD KEY `fk_accounts_currency` (`currency_code`),
  ADD KEY `fk_accounts_integration` (`integration_id`);

ALTER TABLE `account_balances`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ab_account_date` (`account_id`,`captured_at`);

ALTER TABLE `account_owners`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_account_owner` (`account_id`,`entity_id`),
  ADD KEY `idx_acco_entity` (`entity_id`);

ALTER TABLE `assets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_assets_entity` (`entity_id`),
  ADD KEY `idx_assets_account` (`account_id`),
  ADD KEY `fk_assets_currency` (`currency_code`);

ALTER TABLE `asset_owners`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_asset_owner` (`asset_id`,`entity_id`),
  ADD KEY `idx_ao_entity` (`entity_id`);

ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_user` (`user_id`),
  ADD KEY `idx_audit_entity` (`entity_type`,`entity_id`),
  ADD KEY `idx_audit_created` (`created_at`);

ALTER TABLE `budget_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_budget_item_period` (`template_id`,`period_ym`),
  ADD KEY `idx_bi_entity_period` (`entity_id`,`period_ym`),
  ADD KEY `idx_bi_status` (`status`),
  ADD KEY `idx_bi_due` (`due_date`),
  ADD KEY `fk_bi_currency` (`currency_code`),
  ADD KEY `fk_bi_category` (`category_id`),
  ADD KEY `fk_bi_account` (`account_id`),
  ADD KEY `fk_bi_tx` (`transaction_id`);

ALTER TABLE `budget_templates`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_bt_entity` (`entity_id`),
  ADD KEY `idx_bt_active` (`is_active`),
  ADD KEY `fk_bt_currency` (`currency_code`),
  ADD KEY `fk_bt_category` (`category_id`),
  ADD KEY `fk_bt_account` (`suggested_account_id`);

ALTER TABLE `business_valuations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_bv_company_date` (`company_entity_id`,`valued_at`),
  ADD KEY `fk_bv_currency` (`currency_code`),
  ADD KEY `fk_bv_user` (`created_by`);

ALTER TABLE `companies`
  ADD PRIMARY KEY (`entity_id`);

ALTER TABLE `user_entity_access`
  ADD PRIMARY KEY (`user_id`,`entity_id`),
  ADD KEY `idx_uea_entity` (`entity_id`);

ALTER TABLE `currencies`
  ADD PRIMARY KEY (`code`);

ALTER TABLE `documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_docs_entity` (`entity_id`),
  ADD KEY `idx_docs_related` (`related_type`,`related_id`),
  ADD KEY `fk_docs_user` (`uploaded_by`);

ALTER TABLE `entities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_entities_type` (`type`),
  ADD KEY `idx_entities_active` (`is_active`);

ALTER TABLE `entity_tags`
  ADD PRIMARY KEY (`entity_id`,`tag_id`),
  ADD KEY `fk_et_tag` (`tag_id`);

ALTER TABLE `integrations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_int_provider` (`provider`),
  ADD KEY `idx_int_entity` (`entity_id`),
  ADD KEY `idx_int_status` (`status`),
  ADD KEY `fk_int_account` (`account_id`);

ALTER TABLE `integration_credentials`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_int_cred` (`integration_id`,`key_name`);

ALTER TABLE `inventories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_inv_entity` (`entity_id`),
  ADD KEY `fk_inv_currency` (`currency_code`),
  ADD KEY `fk_inv_integration` (`integration_id`);

ALTER TABLE `inventory_snapshots`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_inv_snap` (`inventory_id`,`captured_at`);

ALTER TABLE `liabilities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_liab_entity` (`entity_id`),
  ADD KEY `idx_liab_status` (`status`),
  ADD KEY `fk_liab_creditor_entity` (`creditor_entity_id`),
  ADD KEY `fk_liab_currency` (`currency_code`);

ALTER TABLE `net_worth_snapshots`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_nws_scope_date` (`scope`,`captured_at`),
  ADD KEY `idx_nws_entity_date` (`entity_id`,`captured_at`),
  ADD KEY `fk_nws_currency` (`currency_code`);

ALTER TABLE `ownerships`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_ownership` (`owner_entity_id`,`company_entity_id`),
  ADD KEY `fk_own_company` (`company_entity_id`);

ALTER TABLE `people`
  ADD PRIMARY KEY (`entity_id`);

ALTER TABLE `properties`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_properties_entity` (`entity_id`),
  ADD KEY `fk_properties_currency` (`currency_code`),
  ADD KEY `fk_properties_liability` (`linked_liability_id`);

ALTER TABLE `receivables`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_recv_entity` (`entity_id`),
  ADD KEY `idx_recv_status` (`status`),
  ADD KEY `fk_recv_debtor_entity` (`debtor_entity_id`),
  ADD KEY `fk_recv_currency` (`currency_code`);

ALTER TABLE `sales_metrics`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_sales_period` (`entity_id`,`integration_id`,`period_start`,`period_end`),
  ADD KEY `fk_sales_currency` (`currency_code`),
  ADD KEY `fk_sales_integration` (`integration_id`);

ALTER TABLE `saved_views`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_saved_view` (`user_id`,`context`,`name`);

ALTER TABLE `settings`
  ADD PRIMARY KEY (`setting_key`);

ALTER TABLE `sync_cursors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_sync_cursor` (`integration_id`,`cursor_key`);

ALTER TABLE `sync_runs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sync_int` (`integration_id`,`started_at`);

ALTER TABLE `tags`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_tags_name` (`name`);

ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tx_entity_date` (`entity_id`,`occurred_at`),
  ADD KEY `idx_tx_account_date` (`account_id`,`occurred_at`),
  ADD KEY `idx_tx_external` (`integration_id`,`external_id`),
  ADD KEY `fk_tx_counter_account` (`counterparty_account_id`),
  ADD KEY `fk_tx_category` (`category_id`),
  ADD KEY `fk_tx_currency` (`currency_code`),
  ADD KEY `fk_tx_user` (`created_by`);

ALTER TABLE `transaction_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_tx_cat_name` (`name`);

ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_users_email` (`email`);

ALTER TABLE `company_financial_plans`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_cfp_entity` (`entity_id`);

ALTER TABLE `person_financial_plans`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pfp_entity` (`entity_id`);

ALTER TABLE `financial_goals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_fg_status` (`status`),
  ADD KEY `idx_fg_currency` (`currency_code`),
  ADD KEY `idx_fg_dates` (`starts_on`,`ends_on`);

ALTER TABLE `company_clients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cc_entity` (`entity_id`),
  ADD KEY `idx_cc_name` (`entity_id`,`name`);

--
-- AUTO_INCREMENT
--
ALTER TABLE `accounts`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `account_balances`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `account_owners`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `assets`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `asset_owners`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `audit_log`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `budget_items`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `budget_templates`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `business_valuations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `documents`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `entities`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `integrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `integration_credentials`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `inventories`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `inventory_snapshots`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `liabilities`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `net_worth_snapshots`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `ownerships`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `properties`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `receivables`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `sales_metrics`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `saved_views`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `sync_cursors`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `sync_runs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `tags`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `transactions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `transaction_categories`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `users`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `company_financial_plans`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `person_financial_plans`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `financial_goals`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `company_clients`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

SET FOREIGN_KEY_CHECKS = 0;

--
-- Foreign keys
--
ALTER TABLE `accounts`
  ADD CONSTRAINT `fk_accounts_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_accounts_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_accounts_integration` FOREIGN KEY (`integration_id`) REFERENCES `integrations` (`id`) ON DELETE SET NULL;

ALTER TABLE `account_balances`
  ADD CONSTRAINT `fk_ab_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE;

ALTER TABLE `account_owners`
  ADD CONSTRAINT `fk_acco_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_acco_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

ALTER TABLE `assets`
  ADD CONSTRAINT `fk_assets_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_assets_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_assets_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

ALTER TABLE `asset_owners`
  ADD CONSTRAINT `fk_ao_asset` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ao_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

ALTER TABLE `audit_log`
  ADD CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

ALTER TABLE `budget_items`
  ADD CONSTRAINT `fk_bi_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_bi_category` FOREIGN KEY (`category_id`) REFERENCES `transaction_categories` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_bi_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_bi_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_bi_template` FOREIGN KEY (`template_id`) REFERENCES `budget_templates` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_bi_tx` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`) ON DELETE SET NULL;

ALTER TABLE `budget_templates`
  ADD CONSTRAINT `fk_bt_account` FOREIGN KEY (`suggested_account_id`) REFERENCES `accounts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_bt_category` FOREIGN KEY (`category_id`) REFERENCES `transaction_categories` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_bt_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_bt_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

ALTER TABLE `business_valuations`
  ADD CONSTRAINT `fk_bv_company` FOREIGN KEY (`company_entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_bv_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_bv_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

ALTER TABLE `companies`
  ADD CONSTRAINT `fk_companies_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

ALTER TABLE `user_entity_access`
  ADD CONSTRAINT `fk_uea_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_uea_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

ALTER TABLE `documents`
  ADD CONSTRAINT `fk_docs_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_docs_user` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

ALTER TABLE `entity_tags`
  ADD CONSTRAINT `fk_et_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_et_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE;

ALTER TABLE `integrations`
  ADD CONSTRAINT `fk_int_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_int_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

ALTER TABLE `integration_credentials`
  ADD CONSTRAINT `fk_int_cred` FOREIGN KEY (`integration_id`) REFERENCES `integrations` (`id`) ON DELETE CASCADE;

ALTER TABLE `inventories`
  ADD CONSTRAINT `fk_inv_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_inv_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_inv_integration` FOREIGN KEY (`integration_id`) REFERENCES `integrations` (`id`) ON DELETE SET NULL;

ALTER TABLE `inventory_snapshots`
  ADD CONSTRAINT `fk_inv_snap` FOREIGN KEY (`inventory_id`) REFERENCES `inventories` (`id`) ON DELETE CASCADE;

ALTER TABLE `liabilities`
  ADD CONSTRAINT `fk_liab_creditor_entity` FOREIGN KEY (`creditor_entity_id`) REFERENCES `entities` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_liab_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_liab_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

ALTER TABLE `net_worth_snapshots`
  ADD CONSTRAINT `fk_nws_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_nws_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE SET NULL;

ALTER TABLE `ownerships`
  ADD CONSTRAINT `fk_own_company` FOREIGN KEY (`company_entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_own_owner` FOREIGN KEY (`owner_entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

ALTER TABLE `people`
  ADD CONSTRAINT `fk_people_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

ALTER TABLE `properties`
  ADD CONSTRAINT `fk_properties_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_properties_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_properties_liability` FOREIGN KEY (`linked_liability_id`) REFERENCES `liabilities` (`id`) ON DELETE SET NULL;

ALTER TABLE `receivables`
  ADD CONSTRAINT `fk_recv_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_recv_debtor_entity` FOREIGN KEY (`debtor_entity_id`) REFERENCES `entities` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_recv_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

ALTER TABLE `sales_metrics`
  ADD CONSTRAINT `fk_sales_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_sales_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_sales_integration` FOREIGN KEY (`integration_id`) REFERENCES `integrations` (`id`) ON DELETE SET NULL;

ALTER TABLE `saved_views`
  ADD CONSTRAINT `fk_sv_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

ALTER TABLE `sync_cursors`
  ADD CONSTRAINT `fk_sync_cursor` FOREIGN KEY (`integration_id`) REFERENCES `integrations` (`id`) ON DELETE CASCADE;

ALTER TABLE `sync_runs`
  ADD CONSTRAINT `fk_sync_int` FOREIGN KEY (`integration_id`) REFERENCES `integrations` (`id`) ON DELETE CASCADE;

ALTER TABLE `transactions`
  ADD CONSTRAINT `fk_tx_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tx_category` FOREIGN KEY (`category_id`) REFERENCES `transaction_categories` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tx_counter_account` FOREIGN KEY (`counterparty_account_id`) REFERENCES `accounts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tx_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_tx_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tx_integration` FOREIGN KEY (`integration_id`) REFERENCES `integrations` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tx_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

ALTER TABLE `company_financial_plans`
  ADD CONSTRAINT `fk_cfp_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

ALTER TABLE `person_financial_plans`
  ADD CONSTRAINT `fk_pfp_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

ALTER TABLE `financial_goals`
  ADD CONSTRAINT `fk_fg_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`);

ALTER TABLE `company_clients`
  ADD CONSTRAINT `fk_cc_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- Seed mínimo
-- =============================================================================

INSERT INTO `currencies` (`code`, `name`, `symbol`, `decimals`, `is_active`) VALUES
('ARS', 'Peso argentino', '$', 2, 1),
('USD', 'Dólar estadounidense', 'US$', 2, 1),
('EUR', 'Euro', '€', 2, 1);

INSERT INTO `transaction_categories` (`id`, `name`, `kind`, `is_system`) VALUES
(1, 'Ingreso general', 'income', 1),
(2, 'Egreso general', 'expense', 1),
(3, 'Transferencia', 'transfer', 1),
(4, 'Ajuste de saldo', 'adjustment', 1),
(6, 'Venta WooCommerce', 'income', 1),
(7, 'Sueldos', 'expense', 1),
(8, 'Honorarios', 'expense', 1),
(9, 'Impuestos', 'expense', 1),
(10, 'Servicios', 'expense', 1),
(11, 'Comida', 'expense', 1),
(12, 'Salidas', 'expense', 1),
(13, 'Suscripciones', 'expense', 1),
(14, 'Limpieza', 'expense', 1),
(15, 'Higiene personal', 'expense', 1),
(16, 'Kiosco', 'expense', 1),
(17, 'Librería', 'expense', 1),
(18, 'Auto', 'expense', 1),
(19, 'Arreglos', 'expense', 1),
(20, 'Celular', 'expense', 1),
(21, 'Alquiler/es', 'expense', 1),
(22, 'Medicación & Farmacia', 'expense', 1);

-- Password: admin123  (cambiar tras el primer login)
INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `role`, `is_active`, `last_login_at`, `created_at`, `updated_at`) VALUES
(1, 'Administrador', 'admin@patriumhub.local',
 '$2y$10$kNqlt0SsxU8z0QD4OqRfOuGc8orvPLFrtLHUpoyPxQnmMFhTRmmvS',
 'admin', 1, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO `settings` (`setting_key`, `setting_value`, `updated_at`) VALUES
('app.name', 'PatriumHub', CURRENT_TIMESTAMP),
('schema.version', '0.8.8', CURRENT_TIMESTAMP),
('ui.hide_amounts', '0', CURRENT_TIMESTAMP);

-- Fin instalación PatriumHub
