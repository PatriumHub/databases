-- =============================================================================
-- PatriumHub — único SQL de instalación
-- Importar este archivo en phpMyAdmin y listo (crea BD + tablas + usuario admin).
-- Charset: utf8mb4 / utf8mb4_unicode_ci
-- Login seed: admin@patriumhub.local / admin123
-- Sin tokens MP/WC (van por el menú Integraciones).
-- =============================================================================

CREATE DATABASE IF NOT EXISTS patriumhub
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE patriumhub;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- Identity
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(180) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'viewer') NOT NULL DEFAULT 'admin',
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    last_login_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_users_email (email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS currencies (
    code CHAR(3) NOT NULL PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    symbol VARCHAR(8) NOT NULL DEFAULT '',
    decimals TINYINT UNSIGNED NOT NULL DEFAULT 2,
    is_active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS entities (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type ENUM('person', 'company') NOT NULL,
    name VARCHAR(180) NOT NULL,
    display_name VARCHAR(180) NULL,
    country VARCHAR(80) NULL,
    notes TEXT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_entities_type (type),
    INDEX idx_entities_active (is_active)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS people (
    entity_id INT UNSIGNED NOT NULL PRIMARY KEY,
    first_name VARCHAR(100) NULL,
    last_name VARCHAR(100) NULL,
    document_id VARCHAR(80) NULL,
    birth_date DATE NULL,
    CONSTRAINT fk_people_entity FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS companies (
    entity_id INT UNSIGNED NOT NULL PRIMARY KEY,
    legal_name VARCHAR(220) NULL,
    tax_id VARCHAR(80) NULL,
    industry VARCHAR(120) NULL,
    website VARCHAR(255) NULL,
    CONSTRAINT fk_companies_entity FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ownerships (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    owner_entity_id INT UNSIGNED NOT NULL,
    company_entity_id INT UNSIGNED NOT NULL,
    ownership_pct DECIMAL(7,4) NOT NULL DEFAULT 100.0000,
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_ownership (owner_entity_id, company_entity_id),
    CONSTRAINT fk_own_owner FOREIGN KEY (owner_entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    CONSTRAINT fk_own_company FOREIGN KEY (company_entity_id) REFERENCES entities(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS business_valuations (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_entity_id INT UNSIGNED NOT NULL,
    valued_at DATE NOT NULL,
    currency_code CHAR(3) NOT NULL DEFAULT 'ARS',
    total_value DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    method VARCHAR(80) NOT NULL DEFAULT 'manual',
    notes TEXT NULL,
    created_by INT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_bv_company_date (company_entity_id, valued_at),
    CONSTRAINT fk_bv_company FOREIGN KEY (company_entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    CONSTRAINT fk_bv_currency FOREIGN KEY (currency_code) REFERENCES currencies(code),
    CONSTRAINT fk_bv_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- Wealth
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS accounts (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    entity_id INT UNSIGNED NOT NULL,
    name VARCHAR(180) NOT NULL,
    type ENUM('bank','checking','savings','wallet','mercadopago','cash','broker','virtual','other') NOT NULL DEFAULT 'bank',
    currency_code CHAR(3) NOT NULL DEFAULT 'ARS',
    balance DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    balance_held DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    provider VARCHAR(80) NULL,
    origin ENUM('manual','integration') NOT NULL DEFAULT 'manual',
    integration_id INT UNSIGNED NULL,
    include_in_net_worth TINYINT(1) NOT NULL DEFAULT 1,
    status ENUM('active','closed') NOT NULL DEFAULT 'active',
    last_synced_at DATETIME NULL,
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_accounts_entity (entity_id),
    INDEX idx_accounts_type (type),
    INDEX idx_accounts_status (status),
    CONSTRAINT fk_accounts_entity FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    CONSTRAINT fk_accounts_currency FOREIGN KEY (currency_code) REFERENCES currencies(code)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS account_balances (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_id INT UNSIGNED NOT NULL,
    captured_at DATETIME NOT NULL,
    balance DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    balance_held DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    source ENUM('manual','integration','system') NOT NULL DEFAULT 'manual',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ab_account_date (account_id, captured_at),
    CONSTRAINT fk_ab_account FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS assets (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    entity_id INT UNSIGNED NOT NULL,
    account_id INT UNSIGNED NULL,
    name VARCHAR(180) NOT NULL,
    category ENUM('vehicle','equipment','machinery','investment','intangible','crypto','other') NOT NULL DEFAULT 'other',
    currency_code CHAR(3) NOT NULL DEFAULT 'ARS',
    current_value DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    ownership_pct DECIMAL(7,4) NOT NULL DEFAULT 100.0000,
    valuation_method VARCHAR(80) NULL,
    valued_at DATE NULL,
    include_in_net_worth TINYINT(1) NOT NULL DEFAULT 1,
    status ENUM('active','sold','archived') NOT NULL DEFAULT 'active',
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_assets_entity (entity_id),
    INDEX idx_assets_account (account_id),
    CONSTRAINT fk_assets_entity FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    CONSTRAINT fk_assets_account FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE SET NULL,
    CONSTRAINT fk_assets_currency FOREIGN KEY (currency_code) REFERENCES currencies(code)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS properties (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    entity_id INT UNSIGNED NOT NULL,
    name VARCHAR(180) NOT NULL,
    property_type ENUM('house','apartment','local','warehouse','land','office','other') NOT NULL DEFAULT 'other',
    location_text VARCHAR(255) NULL,
    ownership_pct DECIMAL(7,4) NOT NULL DEFAULT 100.0000,
    currency_code CHAR(3) NOT NULL DEFAULT 'USD',
    current_value DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    valuation_method VARCHAR(80) NULL,
    valued_at DATE NULL,
    linked_liability_id INT UNSIGNED NULL,
    include_in_net_worth TINYINT(1) NOT NULL DEFAULT 1,
    status ENUM('active','sold','archived') NOT NULL DEFAULT 'active',
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_properties_entity (entity_id),
    CONSTRAINT fk_properties_entity FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    CONSTRAINT fk_properties_currency FOREIGN KEY (currency_code) REFERENCES currencies(code)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS receivables (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    entity_id INT UNSIGNED NOT NULL,
    debtor_name VARCHAR(180) NOT NULL,
    debtor_entity_id INT UNSIGNED NULL,
    currency_code CHAR(3) NOT NULL DEFAULT 'ARS',
    original_amount DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    outstanding_amount DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    due_date DATE NULL,
    status ENUM('current','overdue','uncollectible','cancelled') NOT NULL DEFAULT 'current',
    collection_probability DECIMAL(5,2) NULL,
    include_in_net_worth TINYINT(1) NOT NULL DEFAULT 1,
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_recv_entity (entity_id),
    INDEX idx_recv_status (status),
    CONSTRAINT fk_recv_entity FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    CONSTRAINT fk_recv_debtor_entity FOREIGN KEY (debtor_entity_id) REFERENCES entities(id) ON DELETE SET NULL,
    CONSTRAINT fk_recv_currency FOREIGN KEY (currency_code) REFERENCES currencies(code)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS liabilities (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    entity_id INT UNSIGNED NOT NULL,
    name VARCHAR(180) NOT NULL,
    liability_type ENUM('credit_card','loan','mortgage','supplier','tax','overdraft','internal','other') NOT NULL DEFAULT 'other',
    creditor_name VARCHAR(180) NULL,
    creditor_entity_id INT UNSIGNED NULL,
    currency_code CHAR(3) NOT NULL DEFAULT 'ARS',
    original_amount DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    outstanding_amount DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    due_date DATE NULL,
    status ENUM('open','paid','defaulted','cancelled') NOT NULL DEFAULT 'open',
    include_in_net_worth TINYINT(1) NOT NULL DEFAULT 1,
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_liab_entity (entity_id),
    INDEX idx_liab_status (status),
    CONSTRAINT fk_liab_entity FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    CONSTRAINT fk_liab_creditor_entity FOREIGN KEY (creditor_entity_id) REFERENCES entities(id) ON DELETE SET NULL,
    CONSTRAINT fk_liab_currency FOREIGN KEY (currency_code) REFERENCES currencies(code)
) ENGINE=InnoDB;

ALTER TABLE properties
    ADD CONSTRAINT fk_properties_liability
    FOREIGN KEY (linked_liability_id) REFERENCES liabilities(id) ON DELETE SET NULL;

-- -----------------------------------------------------------------------------
-- Inventory / business metrics
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS inventories (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    entity_id INT UNSIGNED NOT NULL,
    name VARCHAR(180) NOT NULL DEFAULT 'Inventario',
    source ENUM('manual','woocommerce','dolibarr','other') NOT NULL DEFAULT 'manual',
    integration_id INT UNSIGNED NULL,
    currency_code CHAR(3) NOT NULL DEFAULT 'ARS',
    stock_value DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    units_total DECIMAL(18,3) NOT NULL DEFAULT 0.000,
    products_count INT UNSIGNED NOT NULL DEFAULT 0,
    variations_count INT UNSIGNED NOT NULL DEFAULT 0,
    out_of_stock_count INT UNSIGNED NOT NULL DEFAULT 0,
    low_stock_count INT UNSIGNED NOT NULL DEFAULT 0,
    valued_at DATETIME NULL,
    include_in_net_worth TINYINT(1) NOT NULL DEFAULT 1,
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_inv_entity (entity_id),
    CONSTRAINT fk_inv_entity FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    CONSTRAINT fk_inv_currency FOREIGN KEY (currency_code) REFERENCES currencies(code)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS inventory_snapshots (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    inventory_id INT UNSIGNED NOT NULL,
    captured_at DATETIME NOT NULL,
    stock_value DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    units_total DECIMAL(18,3) NOT NULL DEFAULT 0.000,
    products_count INT UNSIGNED NOT NULL DEFAULT 0,
    source ENUM('manual','integration','system') NOT NULL DEFAULT 'manual',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_inv_snap (inventory_id, captured_at),
    CONSTRAINT fk_inv_snap FOREIGN KEY (inventory_id) REFERENCES inventories(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sales_metrics (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    entity_id INT UNSIGNED NOT NULL,
    integration_id INT UNSIGNED NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    currency_code CHAR(3) NOT NULL DEFAULT 'ARS',
    orders_count INT UNSIGNED NOT NULL DEFAULT 0,
    sales_total DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    refunds_total DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    customers_count INT UNSIGNED NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_sales_period (entity_id, integration_id, period_start, period_end),
    CONSTRAINT fk_sales_entity FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    CONSTRAINT fk_sales_currency FOREIGN KEY (currency_code) REFERENCES currencies(code)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- Transactions
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS transaction_categories (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    kind ENUM('income','expense','transfer','adjustment','other') NOT NULL DEFAULT 'other',
    is_system TINYINT(1) NOT NULL DEFAULT 0,
    UNIQUE KEY uk_tx_cat_name (name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS transactions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    entity_id INT UNSIGNED NOT NULL,
    account_id INT UNSIGNED NULL,
    counterparty_account_id INT UNSIGNED NULL,
    category_id INT UNSIGNED NULL,
    type ENUM('income','expense','transfer','adjustment','asset_change','loan','collection','payment','integration') NOT NULL,
    occurred_at DATETIME NOT NULL,
    currency_code CHAR(3) NOT NULL DEFAULT 'ARS',
    amount DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    description VARCHAR(255) NULL,
    origin ENUM('manual','integration','system') NOT NULL DEFAULT 'manual',
    integration_id INT UNSIGNED NULL,
    external_id VARCHAR(120) NULL,
    metadata_json JSON NULL,
    created_by INT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tx_entity_date (entity_id, occurred_at),
    INDEX idx_tx_account_date (account_id, occurred_at),
    INDEX idx_tx_external (integration_id, external_id),
    CONSTRAINT fk_tx_entity FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    CONSTRAINT fk_tx_account FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE SET NULL,
    CONSTRAINT fk_tx_counter_account FOREIGN KEY (counterparty_account_id) REFERENCES accounts(id) ON DELETE SET NULL,
    CONSTRAINT fk_tx_category FOREIGN KEY (category_id) REFERENCES transaction_categories(id) ON DELETE SET NULL,
    CONSTRAINT fk_tx_currency FOREIGN KEY (currency_code) REFERENCES currencies(code),
    CONSTRAINT fk_tx_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- Integrations (credentials via UI, encrypted at rest)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS integrations (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    provider ENUM('mercadopago','woocommerce','dolibarr') NOT NULL,
    entity_id INT UNSIGNED NOT NULL,
    name VARCHAR(180) NOT NULL,
    status ENUM('active','error','revoked','disabled') NOT NULL DEFAULT 'active',
    config_json JSON NULL,
    account_id INT UNSIGNED NULL,
    last_sync_at DATETIME NULL,
    last_error TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_int_provider (provider),
    INDEX idx_int_entity (entity_id),
    INDEX idx_int_status (status),
    CONSTRAINT fk_int_entity FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    CONSTRAINT fk_int_account FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE SET NULL
) ENGINE=InnoDB;

ALTER TABLE accounts
    ADD CONSTRAINT fk_accounts_integration
    FOREIGN KEY (integration_id) REFERENCES integrations(id) ON DELETE SET NULL;

ALTER TABLE inventories
    ADD CONSTRAINT fk_inv_integration
    FOREIGN KEY (integration_id) REFERENCES integrations(id) ON DELETE SET NULL;

ALTER TABLE sales_metrics
    ADD CONSTRAINT fk_sales_integration
    FOREIGN KEY (integration_id) REFERENCES integrations(id) ON DELETE SET NULL;

ALTER TABLE transactions
    ADD CONSTRAINT fk_tx_integration
    FOREIGN KEY (integration_id) REFERENCES integrations(id) ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS integration_credentials (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    integration_id INT UNSIGNED NOT NULL,
    key_name VARCHAR(80) NOT NULL,
    value_encrypted TEXT NOT NULL,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_int_cred (integration_id, key_name),
    CONSTRAINT fk_int_cred FOREIGN KEY (integration_id) REFERENCES integrations(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sync_runs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    integration_id INT UNSIGNED NOT NULL,
    started_at DATETIME NOT NULL,
    finished_at DATETIME NULL,
    status ENUM('running','success','failed') NOT NULL DEFAULT 'running',
    records_read INT UNSIGNED NOT NULL DEFAULT 0,
    records_upserted INT UNSIGNED NOT NULL DEFAULT 0,
    message TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sync_int (integration_id, started_at),
    CONSTRAINT fk_sync_int FOREIGN KEY (integration_id) REFERENCES integrations(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sync_cursors (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    integration_id INT UNSIGNED NOT NULL,
    cursor_key VARCHAR(80) NOT NULL,
    cursor_value VARCHAR(255) NULL,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_sync_cursor (integration_id, cursor_key),
    CONSTRAINT fk_sync_cursor FOREIGN KEY (integration_id) REFERENCES integrations(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- Support
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tags (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    color VARCHAR(20) NULL,
    UNIQUE KEY uk_tags_name (name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS entity_tags (
    entity_id INT UNSIGNED NOT NULL,
    tag_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (entity_id, tag_id),
    CONSTRAINT fk_et_entity FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    CONSTRAINT fk_et_tag FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS documents (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    entity_id INT UNSIGNED NULL,
    related_type VARCHAR(60) NULL,
    related_id INT UNSIGNED NULL,
    title VARCHAR(180) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    mime_type VARCHAR(120) NULL,
    uploaded_by INT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_docs_entity (entity_id),
    INDEX idx_docs_related (related_type, related_id),
    CONSTRAINT fk_docs_entity FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE SET NULL,
    CONSTRAINT fk_docs_user FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_log (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NULL,
    action VARCHAR(80) NOT NULL,
    entity_type VARCHAR(80) NULL,
    entity_id INT UNSIGNED NULL,
    summary VARCHAR(255) NULL,
    before_json JSON NULL,
    after_json JSON NULL,
    ip VARCHAR(45) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_audit_user (user_id),
    INDEX idx_audit_entity (entity_type, entity_id),
    INDEX idx_audit_created (created_at),
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS settings (
    setting_key VARCHAR(120) NOT NULL PRIMARY KEY,
    setting_value TEXT NULL,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS net_worth_snapshots (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    scope ENUM('entity', 'personal', 'consolidated') NOT NULL,
    entity_id INT UNSIGNED NULL,
    currency_code CHAR(3) NOT NULL DEFAULT 'ARS',
    captured_at DATETIME NOT NULL,
    accounts DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    assets DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    properties DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    receivables DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    inventories DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    participations DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    liabilities DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    internal_netting DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    total_assets DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    net_worth DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    payload_json JSON NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_nws_scope_date (scope, captured_at),
    INDEX idx_nws_entity_date (entity_id, captured_at),
    CONSTRAINT fk_nws_entity FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE SET NULL,
    CONSTRAINT fk_nws_currency FOREIGN KEY (currency_code) REFERENCES currencies(code)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS saved_views (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    name VARCHAR(120) NOT NULL,
    context VARCHAR(60) NOT NULL DEFAULT 'dashboard',
    filters_json JSON NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_saved_view (user_id, context, name),
    CONSTRAINT fk_sv_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Seeds mínimos (sin secretos de integraciones)
-- Password admin: admin123  (cambiar en producción)
-- -----------------------------------------------------------------------------

INSERT INTO currencies (code, name, symbol, decimals) VALUES
    ('ARS', 'Peso argentino', '$', 2),
    ('USD', 'Dólar estadounidense', 'US$', 2),
    ('EUR', 'Euro', '€', 2)
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO transaction_categories (name, kind, is_system) VALUES
    ('Ingreso general', 'income', 1),
    ('Egreso general', 'expense', 1),
    ('Transferencia', 'transfer', 1),
    ('Ajuste de saldo', 'adjustment', 1),
    ('Comisión Mercado Pago', 'expense', 1),
    ('Venta WooCommerce', 'income', 1)
ON DUPLICATE KEY UPDATE kind = VALUES(kind);

INSERT INTO users (name, email, password_hash, role, is_active)
VALUES (
    'Administrador',
    'admin@patriumhub.local',
    '$2y$10$kNqlt0SsxU8z0QD4OqRfOuGc8orvPLFrtLHUpoyPxQnmMFhTRmmvS',
    'admin',
    1
)
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO settings (setting_key, setting_value) VALUES
    ('app.name', 'PatriumHub'),
    ('ui.hide_amounts', '0'),
    ('schema.version', '0.5.0')
ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value);
