-- ABSORBIDO en patriumhub.sql (schema 0.7.0).
-- Conservado solo como referencia histórica.

-- PatriumHub — Estados y proyección (planilla por empresa)
USE patriumhub;

CREATE TABLE IF NOT EXISTS company_financial_plans (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    entity_id INT UNSIGNED NOT NULL,
    workbook_json LONGTEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_cfp_entity (entity_id),
    CONSTRAINT fk_cfp_entity FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
