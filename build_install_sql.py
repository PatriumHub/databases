"""Build a single clean-install databases/patriumhub.sql.

Source: current phpMyAdmin dump (DDL + indexes + FKs) + patch company_financial_plans.
Output: schema + minimal seed (currencies, categories, admin, settings).
Live business data and integration credentials are NOT included.
"""
from __future__ import annotations

import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "patriumhub.sql"
BACKUP = ROOT / "archives" / "patriumhub.phpmyadmin-2026-08-05.sql"
OUT = ROOT / "patriumhub.sql"
PATCH = ROOT / "patch_estados_proyeccion.sql"

CFP_CREATE = """CREATE TABLE `company_financial_plans` (
  `id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `workbook_json` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"""

CFP_INDEX = """ALTER TABLE `company_financial_plans`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_cfp_entity` (`entity_id`);"""

CFP_AI = """ALTER TABLE `company_financial_plans`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;"""

CFP_FK = """ALTER TABLE `company_financial_plans`
  ADD CONSTRAINT `fk_cfp_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;"""


def extract_creates(sql: str) -> dict[str, str]:
    out = {}
    for m in re.finditer(
        r"CREATE TABLE `(?P<name>[^`]+)` \((?P<body>.*?)\) ENGINE=InnoDB[^;]*;",
        sql,
        flags=re.S,
    ):
        out[m.group("name")] = m.group(0).rstrip()
    return out


def extract_section_alters(sql: str, marker_start: str, marker_end: str | None) -> list[str]:
    start = sql.find(marker_start)
    if start < 0:
        return []
    chunk = sql[start:]
    if marker_end:
        end = chunk.find(marker_end)
        if end > 0:
            chunk = chunk[:end]
    alters = re.findall(r"ALTER TABLE `[^`]+`\s+.*?;", chunk, flags=re.S)
    return [a.strip() for a in alters]


def normalize_ai(stmt: str) -> str:
    return re.sub(r"AUTO_INCREMENT=\d+", "AUTO_INCREMENT=1", stmt)


def main() -> int:
    if not SRC.is_file():
        print("missing", SRC)
        return 1

    text = SRC.read_text(encoding="utf-8", errors="replace")
    is_dump = "phpMyAdmin" in text or "Volcado de datos" in text
    if is_dump:
        BACKUP.parent.mkdir(parents=True, exist_ok=True)
        if not BACKUP.is_file():
            shutil.copy2(SRC, BACKUP)
            print("archived dump ->", BACKUP)

    creates = extract_creates(text)
    print("CREATE TABLE count:", len(creates))
    if not creates:
        print("ERROR: no CREATE TABLE found")
        return 1

    # Index alters: from "Índices para tablas" until "AUTO_INCREMENT de"
    index_alters = extract_section_alters(
        text,
        "-- Índices para tablas volcadas",
        "-- AUTO_INCREMENT de las tablas volcadas",
    )
    if not index_alters:
        index_alters = extract_section_alters(
            text,
            "-- Índices para tablas volcadas",
            "-- AUTO_INCREMENT de la tabla",
        )
    # AUTO_INCREMENT modifies
    ai_alters = extract_section_alters(
        text,
        "-- AUTO_INCREMENT de las tablas volcadas",
        "-- Restricciones para tablas volcadas",
    )
    if not ai_alters:
        # dump uses per-table comments without the plural header sometimes
        ai_alters = []
        for m in re.finditer(
            r"ALTER TABLE `[^`]+`\s+MODIFY `id`[^;]+AUTO_INCREMENT[^;]*;",
            text,
            flags=re.S,
        ):
            ai_alters.append(normalize_ai(m.group(0).strip()))
    else:
        ai_alters = [normalize_ai(a) for a in ai_alters]

    fk_alters = extract_section_alters(
        text,
        "-- Restricciones para tablas volcadas",
        None,
    )
    # Also catch if header differs
    if not fk_alters:
        fk_alters = [
            a.strip()
            for a in re.findall(
                r"ALTER TABLE `[^`]+`\s+ADD CONSTRAINT.*?;",
                text,
                flags=re.S,
            )
        ]

    # Preferred create order (dependencies soft — FKs applied later)
    order = [
        "users",
        "currencies",
        "entities",
        "people",
        "companies",
        "ownerships",
        "business_valuations",
        "accounts",
        "account_balances",
        "assets",
        "properties",
        "receivables",
        "liabilities",
        "inventories",
        "inventory_snapshots",
        "transaction_categories",
        "transactions",
        "budget_templates",
        "budget_items",
        "company_financial_plans",
        "integrations",
        "integration_credentials",
        "sync_runs",
        "sync_cursors",
        "sales_metrics",
        "net_worth_snapshots",
        "saved_views",
        "tags",
        "entity_tags",
        "documents",
        "audit_log",
        "settings",
    ]

    # Append any dump tables not listed
    for name in sorted(creates):
        if name not in order:
            order.append(name)

    lines: list[str] = []
    lines += [
        "-- =============================================================================",
        "-- PatriumHub — instalación limpia (schema completo + seed mínimo)",
        "-- BD: patriumhub · utf8mb4 / utf8mb4_unicode_ci",
        "-- Schema version: 0.7.0",
        "--",
        "-- Incluye: patrimonio, presupuestos, snapshots, integraciones WC/MP,",
        "--          saved_views, company_financial_plans (Estados y proyección).",
        "-- No incluye: datos de producción ni credenciales de integraciones.",
        "--",
        "-- Importar en phpMyAdmin (crea la BD). Reemplaza dumps/patches previos.",
        "-- Generado por: databases/build_install_sql.py",
        "-- =============================================================================",
        "",
        "CREATE DATABASE IF NOT EXISTS patriumhub",
        "    CHARACTER SET utf8mb4",
        "    COLLATE utf8mb4_unicode_ci;",
        "",
        "USE patriumhub;",
        "",
        "SET NAMES utf8mb4;",
        "SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';",
        "SET time_zone = '+00:00';",
        "SET FOREIGN_KEY_CHECKS = 0;",
        "",
    ]

    for name in reversed(order):
        if name in creates or name == "company_financial_plans":
            lines.append(f"DROP TABLE IF EXISTS `{name}`;")
    lines.append("")

    for name in order:
        if name == "company_financial_plans":
            block = creates.get(name, CFP_CREATE)
        elif name in creates:
            block = creates[name]
        else:
            print("WARN skip missing", name)
            continue
        lines.append(f"--")
        lines.append(f"-- Tabla `{name}`")
        lines.append(f"--")
        lines.append(block)
        lines.append("")

    lines.append("--")
    lines.append("-- Índices")
    lines.append("--")
    for a in index_alters:
        m = re.search(r"ALTER TABLE `([^`]+)`", a)
        if m and m.group(1) not in creates and m.group(1) != "company_financial_plans":
            continue
        lines.append(a)
        lines.append("")
    if "company_financial_plans" not in creates:
        lines.append(CFP_INDEX)
        lines.append("")

    lines.append("--")
    lines.append("-- AUTO_INCREMENT")
    lines.append("--")
    seen_ai = set()
    for a in ai_alters:
        m = re.search(r"ALTER TABLE `([^`]+)`", a)
        if not m:
            continue
        t = m.group(1)
        if t in seen_ai:
            continue
        seen_ai.add(t)
        lines.append(normalize_ai(a))
        lines.append("")
    if "company_financial_plans" not in seen_ai:
        lines.append(CFP_AI)
        lines.append("")

    lines.append("SET FOREIGN_KEY_CHECKS = 0;")
    lines.append("")
    lines.append("--")
    lines.append("-- Foreign keys")
    lines.append("--")
    for a in fk_alters:
        m = re.search(r"ALTER TABLE `([^`]+)`", a)
        if m and m.group(1) not in creates and m.group(1) != "company_financial_plans":
            continue
        lines.append(a)
        lines.append("")
    if "company_financial_plans" not in creates:
        lines.append(CFP_FK)
        lines.append("")

    lines.append("SET FOREIGN_KEY_CHECKS = 1;")
    lines.append("")
    lines += [
        "-- =============================================================================",
        "-- Seed mínimo",
        "-- =============================================================================",
        "",
        "INSERT INTO `currencies` (`code`, `name`, `symbol`, `decimals`, `is_active`) VALUES",
        "('ARS', 'Peso argentino', '$', 2, 1),",
        "('USD', 'Dólar estadounidense', 'US$', 2, 1),",
        "('EUR', 'Euro', '€', 2, 1);",
        "",
        "INSERT INTO `transaction_categories` (`id`, `name`, `kind`, `is_system`) VALUES",
        "(1, 'Ingreso general', 'income', 1),",
        "(2, 'Egreso general', 'expense', 1),",
        "(3, 'Transferencia', 'transfer', 1),",
        "(4, 'Ajuste de saldo', 'adjustment', 1),",
        "(6, 'Venta WooCommerce', 'income', 1),",
        "(7, 'Sueldos', 'expense', 1),",
        "(8, 'Honorarios', 'expense', 1),",
        "(9, 'Impuestos', 'expense', 1),",
        "(10, 'Servicios', 'expense', 1);",
        "",
        "-- Password: admin123  (cambiar tras el primer login)",
        "INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `role`, `is_active`, `last_login_at`, `created_at`, `updated_at`) VALUES",
        "(1, 'Administrador', 'admin@patriumhub.local',",
        " '$2y$10$kNqlt0SsxU8z0QD4OqRfOuGc8orvPLFrtLHUpoyPxQnmMFhTRmmvS',",
        " 'admin', 1, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);",
        "",
        "INSERT INTO `settings` (`setting_key`, `setting_value`, `updated_at`) VALUES",
        "('app.name', 'PatriumHub', CURRENT_TIMESTAMP),",
        "('schema.version', '0.7.0', CURRENT_TIMESTAMP),",
        "('ui.hide_amounts', '0', CURRENT_TIMESTAMP);",
        "",
        "-- Fin instalación PatriumHub",
        "",
    ]

    OUT.write_text("\n".join(lines), encoding="utf-8")
    print("wrote", OUT, "bytes", OUT.stat().st_size)
    print("index_alters", len(index_alters), "ai", len(ai_alters), "fk", len(fk_alters))

    # Mark patch as absorbed
    if PATCH.is_file():
        note = PATCH.read_text(encoding="utf-8", errors="replace")
        if "ABSORBIDO" not in note:
            PATCH.write_text(
                "-- ABSORBIDO en patriumhub.sql (schema 0.7.0).\n"
                "-- Conservado solo como referencia histórica.\n\n" + note,
                encoding="utf-8",
            )
            print("annotated", PATCH.name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
