-- phpMyAdmin SQL Dump
-- version 5.2.1deb3
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 05-08-2026 a las 16:49:59
-- Versión del servidor: 8.0.46-0ubuntu0.24.04.3
-- Versión de PHP: 8.3.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `patriumhub`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `accounts`
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
-- Volcado de datos para la tabla `accounts`
--

INSERT INTO `accounts` (`id`, `entity_id`, `name`, `type`, `currency_code`, `balance`, `balance_held`, `provider`, `origin`, `integration_id`, `include_in_net_worth`, `status`, `last_synced_at`, `notes`, `created_at`, `updated_at`) VALUES
(1, 1, 'BBVA - Sueldos fijos', 'bank', 'ARS', 0.00, 0.00, NULL, 'manual', NULL, 1, 'active', NULL, NULL, '2026-08-05 10:42:28', '2026-08-05 13:45:46'),
(2, 2, 'MP HomeSpot', 'mercadopago', 'ARS', 48919.74, 0.00, NULL, 'manual', NULL, 1, 'active', NULL, 'En reserva', '2026-08-05 11:02:56', '2026-08-05 13:13:39'),
(3, 3, 'MP Puestito', 'mercadopago', 'ARS', 0.00, 0.00, NULL, 'manual', NULL, 1, 'active', NULL, NULL, '2026-08-05 11:03:49', '2026-08-05 11:08:08'),
(4, 1, 'MP Personal', 'mercadopago', 'ARS', 0.00, 0.00, 'Mercado Pago', 'manual', NULL, 1, 'active', NULL, NULL, '2026-08-05 11:04:05', '2026-08-05 11:04:05'),
(5, 2, 'ICBC - Cuenta principal', 'bank', 'ARS', 16158.00, 0.00, NULL, 'manual', NULL, 1, 'active', NULL, NULL, '2026-08-05 11:08:37', '2026-08-05 11:52:45'),
(6, 2, 'ICBC - Ahorro', 'bank', 'ARS', 0.00, 0.00, NULL, 'manual', NULL, 1, 'active', NULL, NULL, '2026-08-05 11:08:50', '2026-08-05 11:08:50'),
(7, 4, 'Supervielle', 'bank', 'ARS', 0.00, 0.00, NULL, 'manual', NULL, 1, 'active', NULL, NULL, '2026-08-05 11:10:55', '2026-08-05 11:22:12'),
(8, 1, 'Banco Patagonia - Cuenta compartida de casa', 'bank', 'ARS', 890.00, 0.00, NULL, 'manual', NULL, 1, 'active', NULL, NULL, '2026-08-05 11:23:37', '2026-08-05 11:23:37');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `account_balances`
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
-- Volcado de datos para la tabla `account_balances`
--

INSERT INTO `account_balances` (`id`, `account_id`, `captured_at`, `balance`, `balance_held`, `source`, `created_at`) VALUES
(1, 1, '2026-08-05 10:42:28', 0.00, 0.00, 'manual', '2026-08-05 10:42:28'),
(2, 2, '2026-08-05 11:02:56', 4088.00, 0.00, 'manual', '2026-08-05 11:02:56'),
(3, 3, '2026-08-05 11:03:49', 0.00, 0.00, 'manual', '2026-08-05 11:03:49'),
(4, 4, '2026-08-05 11:04:05', 0.00, 0.00, 'manual', '2026-08-05 11:04:05'),
(5, 5, '2026-08-05 11:08:37', 0.00, 0.00, 'manual', '2026-08-05 11:08:37'),
(6, 6, '2026-08-05 11:08:50', 0.00, 0.00, 'manual', '2026-08-05 11:08:50'),
(7, 7, '2026-08-05 11:10:55', 0.00, 0.00, 'manual', '2026-08-05 11:10:55'),
(8, 7, '2026-08-05 11:13:08', 2.00, 0.00, 'system', '2026-08-05 11:13:08'),
(9, 7, '2026-08-05 11:14:21', 0.00, 0.00, 'system', '2026-08-05 11:14:21'),
(10, 7, '2026-08-05 11:20:38', 2.00, 0.00, 'system', '2026-08-05 11:20:38'),
(11, 7, '2026-08-05 11:22:12', 0.00, 0.00, 'system', '2026-08-05 11:22:12'),
(12, 8, '2026-08-05 11:23:37', 890.00, 0.00, 'manual', '2026-08-05 11:23:37'),
(13, 2, '2026-08-05 11:39:29', 48919.74, 0.00, 'manual', '2026-08-05 11:39:29'),
(14, 1, '2026-08-05 13:03:00', 2318698.71, 0.00, 'system', '2026-08-05 13:03:00'),
(15, 1, '2026-08-05 13:05:05', 441290.71, 0.00, 'system', '2026-08-05 13:05:05'),
(16, 2, '2026-08-05 13:05:29', 745919.74, 0.00, 'system', '2026-08-05 13:05:29'),
(17, 2, '2026-08-05 13:13:39', 48919.74, 0.00, 'system', '2026-08-05 13:13:39'),
(19, 1, '2026-08-05 13:39:17', 329290.71, 0.00, 'system', '2026-08-05 13:39:17'),
(20, 1, '2026-08-05 13:42:21', 279290.71, 0.00, 'system', '2026-08-05 13:42:21'),
(21, 1, '2026-08-05 13:44:00', 0.00, 0.00, 'system', '2026-08-05 13:44:00'),
(22, 1, '2026-08-05 13:45:24', -2318698.71, 0.00, 'system', '2026-08-05 13:45:24'),
(23, 1, '2026-08-05 13:45:24', 0.00, 0.00, 'system', '2026-08-05 13:45:24'),
(24, 1, '2026-08-05 13:45:46', -2318698.71, 0.00, 'system', '2026-08-05 13:45:46'),
(25, 1, '2026-08-05 13:45:46', 0.00, 0.00, 'system', '2026-08-05 13:45:46');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `assets`
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
-- Volcado de datos para la tabla `assets`
--

INSERT INTO `assets` (`id`, `entity_id`, `account_id`, `name`, `category`, `currency_code`, `current_value`, `ownership_pct`, `valuation_method`, `valued_at`, `include_in_net_worth`, `status`, `notes`, `created_at`, `updated_at`) VALUES
(1, 2, 6, 'Plazo fijo - Ahorro general', 'other', 'ARS', 73603.44, 100.0000, 'manual', '2026-08-05', 1, 'active', NULL, '2026-08-05 11:10:01', '2026-08-05 11:10:01'),
(2, 4, 7, 'Fondo Contraciclico', 'other', 'ARS', 364094.45, 100.0000, 'manual', '2026-08-05', 1, 'active', NULL, '2026-08-05 11:12:16', '2026-08-05 11:30:39'),
(3, 1, 8, 'Plazo fijo - Ahorro general', 'other', 'ARS', 481901.37, 100.0000, 'manual', '2026-08-05', 1, 'active', NULL, '2026-08-05 11:24:03', '2026-08-05 11:24:03');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `audit_log`
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
-- Volcado de datos para la tabla `audit_log`
--

INSERT INTO `audit_log` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `summary`, `before_json`, `after_json`, `ip`, `created_at`) VALUES
(1, 1, 'create', 'person', 1, 'Alta persona: Juan Pablo Romano', NULL, NULL, '192.168.100.46', '2026-08-05 10:42:14'),
(2, 1, 'create', 'account', 1, 'Alta cuenta: BBVA - Sueldos fijos', NULL, NULL, '192.168.100.46', '2026-08-05 10:42:28'),
(3, 1, 'create', 'company', 2, 'Alta empresa: HomeSpot', NULL, NULL, '192.168.100.46', '2026-08-05 10:42:59'),
(4, 1, 'create', 'integration', 1, 'Alta WooCommerce: WMC Homespot', NULL, NULL, '192.168.100.46', '2026-08-05 10:45:58'),
(5, 1, 'sync', 'integration', 1, 'OK: Sync WooCommerce OK. Stock valorado: ARS 4.275.398,49. Meses de ventas: 3. Leídos: 261.', NULL, NULL, '192.168.100.46', '2026-08-05 10:46:10'),
(6, 1, 'create', 'account', 2, 'Alta cuenta: MP HomeSpot', NULL, NULL, '192.168.100.46', '2026-08-05 11:02:56'),
(7, 1, 'create', 'company', 3, 'Alta empresa: Puestito', NULL, NULL, '192.168.100.46', '2026-08-05 11:03:34'),
(8, 1, 'create', 'account', 3, 'Alta cuenta: MP Puestito', NULL, NULL, '192.168.100.46', '2026-08-05 11:03:49'),
(9, 1, 'create', 'account', 4, 'Alta cuenta: MP Personal', NULL, NULL, '192.168.100.46', '2026-08-05 11:04:05'),
(10, 1, 'create', 'company', 4, 'Alta empresa: Soup IT', NULL, NULL, '192.168.100.46', '2026-08-05 11:06:34'),
(11, 1, 'create', 'company', 5, 'Alta empresa: Mate Gestión', NULL, NULL, '192.168.100.46', '2026-08-05 11:07:09'),
(12, 1, 'update', 'account', 3, 'Edición cuenta: MP Puestito', '{\"id\": 3, \"name\": \"MP Puestito\", \"type\": \"mercadopago\", \"notes\": null, \"origin\": \"manual\", \"status\": \"active\", \"balance\": \"0.00\", \"provider\": \"Mercado Pago\", \"entity_id\": 3, \"created_at\": \"2026-08-05 11:03:49\", \"updated_at\": \"2026-08-05 11:03:49\", \"balance_held\": \"0.00\", \"currency_code\": \"ARS\", \"integration_id\": null, \"last_synced_at\": null, \"include_in_net_worth\": 1}', '{\"id\": 3, \"name\": \"MP Puestito\", \"type\": \"mercadopago\", \"notes\": null, \"origin\": \"manual\", \"status\": \"active\", \"balance\": \"0.00\", \"provider\": null, \"entity_id\": 3, \"created_at\": \"2026-08-05 11:03:49\", \"updated_at\": \"2026-08-05 11:08:08\", \"balance_held\": \"0.00\", \"currency_code\": \"ARS\", \"integration_id\": null, \"last_synced_at\": null, \"include_in_net_worth\": 1}', '192.168.100.46', '2026-08-05 11:08:08'),
(13, 1, 'create', 'account', 5, 'Alta cuenta: ICBC - Cuenta principal', NULL, NULL, '192.168.100.46', '2026-08-05 11:08:37'),
(14, 1, 'create', 'account', 6, 'Alta cuenta: ICBC - Ahorro', NULL, NULL, '192.168.100.46', '2026-08-05 11:08:50'),
(15, 1, 'create', 'asset', 1, 'Alta activo: Plazo fijo - Ahorro general', NULL, NULL, '192.168.100.46', '2026-08-05 11:10:01'),
(16, 1, 'create', 'account', 7, 'Alta cuenta: Supervielle', NULL, NULL, '192.168.100.46', '2026-08-05 11:10:55'),
(17, 1, 'create', 'asset', 2, 'Alta activo: Fondo Contraciclico', NULL, NULL, '192.168.100.46', '2026-08-05 11:12:16'),
(18, 1, 'create', 'transaction', 1, 'Movimiento income: 2', NULL, NULL, '192.168.100.46', '2026-08-05 11:13:08'),
(19, 1, 'create', 'transaction', 2, 'Movimiento expense: 2', NULL, NULL, '192.168.100.46', '2026-08-05 11:14:21'),
(20, 1, 'create', 'transaction', 3, 'Movimiento income: 2', NULL, NULL, '192.168.100.46', '2026-08-05 11:20:38'),
(21, 1, 'create', 'transaction', 4, 'Movimiento expense: 2', NULL, NULL, '192.168.100.46', '2026-08-05 11:22:12'),
(22, 1, 'create', 'account', 8, 'Alta cuenta: Banco Patagonia - Cuenta compartida de casa', NULL, NULL, '192.168.100.46', '2026-08-05 11:23:37'),
(23, 1, 'create', 'asset', 3, 'Alta activo: Plazo fijo - Ahorro general', NULL, NULL, '192.168.100.46', '2026-08-05 11:24:03'),
(24, 1, 'update', 'account', 2, 'Edición cuenta: MP HomeSpot', '{\"id\": 2, \"name\": \"MP HomeSpot\", \"type\": \"mercadopago\", \"notes\": null, \"origin\": \"manual\", \"status\": \"active\", \"balance\": \"4088.00\", \"provider\": \"Mercado Pago\", \"entity_id\": 2, \"created_at\": \"2026-08-05 11:02:56\", \"updated_at\": \"2026-08-05 11:02:56\", \"balance_held\": \"0.00\", \"currency_code\": \"ARS\", \"integration_id\": null, \"last_synced_at\": null, \"include_in_net_worth\": 1}', '{\"id\": 2, \"name\": \"MP HomeSpot\", \"type\": \"mercadopago\", \"notes\": \"En reserva\", \"origin\": \"manual\", \"status\": \"active\", \"balance\": \"48919.74\", \"provider\": null, \"entity_id\": 2, \"created_at\": \"2026-08-05 11:02:56\", \"updated_at\": \"2026-08-05 11:39:29\", \"balance_held\": \"0.00\", \"currency_code\": \"ARS\", \"integration_id\": null, \"last_synced_at\": null, \"include_in_net_worth\": 1}', '192.168.100.46', '2026-08-05 11:39:29'),
(25, 1, 'create', 'transaction', 5, 'En caja · ingreso 16158', NULL, NULL, '192.168.100.46', '2026-08-05 11:52:45'),
(26, 1, 'update', 'settings', NULL, 'Ocultar cifras: on', NULL, NULL, '192.168.100.46', '2026-08-05 12:03:55'),
(27, 1, 'update', 'settings', NULL, 'Ocultar cifras: off', NULL, NULL, '192.168.100.46', '2026-08-05 12:03:57'),
(28, 1, 'create', 'budget_template', 1, 'Alta plantilla: Alquiler', NULL, NULL, '192.168.100.46', '2026-08-05 12:44:07'),
(29, 1, 'create', 'budget_template', 2, 'Alta plantilla: Alquiler', NULL, NULL, '192.168.100.46', '2026-08-05 12:44:54'),
(30, 1, 'create', 'budget_template', 3, 'Alta plantilla: Luz', NULL, NULL, '192.168.100.46', '2026-08-05 12:45:19'),
(31, 1, 'create', 'budget_template', 4, 'Alta plantilla: Internet', NULL, NULL, '192.168.100.46', '2026-08-05 12:45:38'),
(32, 1, 'create', 'budget_template', 5, 'Alta gasto: Expensas', NULL, NULL, '192.168.100.46', '2026-08-05 12:52:28'),
(33, 1, 'create', 'budget_template', 6, 'Alta gasto: Luz', NULL, NULL, '192.168.100.46', '2026-08-05 12:52:44'),
(34, 1, 'create', 'budget_template', 7, 'Alta gasto: Gas', NULL, NULL, '192.168.100.46', '2026-08-05 12:52:52'),
(35, 1, 'create', 'budget_template', 8, 'Alta gasto: AySA', NULL, NULL, '192.168.100.46', '2026-08-05 12:53:01'),
(36, 1, 'create', 'budget_template', 9, 'Alta gasto: Internet', NULL, NULL, '192.168.100.46', '2026-08-05 12:53:18'),
(37, 1, 'create', 'transaction', 6, 'Movimiento income: 2318698.71', NULL, NULL, '192.168.100.46', '2026-08-05 13:03:00'),
(38, 1, 'update', 'budget_item', 1, 'Pagado: 1180408', '{\"id\": 1, \"name\": \"Alquiler\", \"notes\": null, \"amount\": \"1180408.00\", \"status\": \"pending\", \"paid_at\": null, \"due_date\": \"2026-08-10\", \"entity_id\": 1, \"period_ym\": \"2026-08\", \"account_id\": 1, \"created_at\": \"2026-08-05 12:44:07\", \"updated_at\": \"2026-08-05 12:44:07\", \"paid_amount\": null, \"template_id\": 1, \"currency_code\": \"ARS\", \"transaction_id\": null, \"include_in_net_worth\": 1}', '{\"id\": 1, \"name\": \"Alquiler\", \"notes\": null, \"amount\": \"1180408.00\", \"status\": \"paid\", \"paid_at\": \"2026-08-05 13:03:00\", \"due_date\": \"2026-08-10\", \"entity_id\": 1, \"period_ym\": \"2026-08\", \"account_id\": 1, \"created_at\": \"2026-08-05 12:44:07\", \"updated_at\": \"2026-08-05 13:03:43\", \"paid_amount\": \"1180408.00\", \"template_id\": 1, \"currency_code\": \"ARS\", \"transaction_id\": 7, \"include_in_net_worth\": 1}', '192.168.100.46', '2026-08-05 13:03:43'),
(39, 1, 'create', 'transaction', 8, 'Movimiento expense: 697000', NULL, NULL, '192.168.100.46', '2026-08-05 13:05:05'),
(40, 1, 'create', 'transaction', 9, 'Movimiento income: 697000', NULL, NULL, '192.168.100.46', '2026-08-05 13:05:29'),
(41, 1, 'update', 'budget_item', 2, 'Pagado: 346000', '{\"id\": 2, \"name\": \"Alquiler\", \"notes\": null, \"amount\": \"346000.00\", \"status\": \"pending\", \"paid_at\": null, \"due_date\": \"2026-08-10\", \"entity_id\": 2, \"period_ym\": \"2026-08\", \"account_id\": 5, \"created_at\": \"2026-08-05 12:44:54\", \"updated_at\": \"2026-08-05 12:44:54\", \"paid_amount\": null, \"template_id\": 2, \"currency_code\": \"ARS\", \"transaction_id\": null, \"include_in_net_worth\": 1}', '{\"id\": 2, \"name\": \"Alquiler\", \"notes\": null, \"amount\": \"346000.00\", \"status\": \"paid\", \"paid_at\": \"2026-08-05 13:05:00\", \"due_date\": \"2026-08-10\", \"entity_id\": 2, \"period_ym\": \"2026-08\", \"account_id\": 2, \"created_at\": \"2026-08-05 12:44:54\", \"updated_at\": \"2026-08-05 13:05:50\", \"paid_amount\": \"346000.00\", \"template_id\": 2, \"currency_code\": \"ARS\", \"transaction_id\": 10, \"include_in_net_worth\": 1}', '192.168.100.46', '2026-08-05 13:05:50'),
(42, 1, 'create', 'budget_template', 10, 'Alta gasto: Edenor atrasado', NULL, NULL, '192.168.100.46', '2026-08-05 13:06:15'),
(43, 1, 'update', 'budget_item', 10, 'Pagado: 351000', '{\"id\": 10, \"name\": \"Edenor atrasado\", \"notes\": null, \"amount\": \"351000.00\", \"status\": \"pending\", \"paid_at\": null, \"due_date\": \"2026-08-10\", \"entity_id\": 2, \"period_ym\": \"2026-08\", \"account_id\": 2, \"created_at\": \"2026-08-05 13:06:15\", \"updated_at\": \"2026-08-05 13:06:15\", \"paid_amount\": null, \"template_id\": 10, \"currency_code\": \"ARS\", \"transaction_id\": null, \"include_in_net_worth\": 1}', '{\"id\": 10, \"name\": \"Edenor atrasado\", \"notes\": null, \"amount\": \"351000.00\", \"status\": \"paid\", \"paid_at\": \"2026-08-05 13:06:00\", \"due_date\": \"2026-08-10\", \"entity_id\": 2, \"period_ym\": \"2026-08\", \"account_id\": 2, \"created_at\": \"2026-08-05 13:06:15\", \"updated_at\": \"2026-08-05 13:06:20\", \"paid_amount\": \"351000.00\", \"template_id\": 10, \"currency_code\": \"ARS\", \"transaction_id\": 11, \"include_in_net_worth\": 1}', '192.168.100.46', '2026-08-05 13:06:20'),
(44, 1, 'delete', 'budget_template', 10, 'Gasto eliminado del grupo', '{\"id\": 10, \"name\": \"Edenor atrasado\", \"notes\": null, \"amount\": \"351000.00\", \"due_day\": 10, \"entity_id\": 2, \"frequency\": \"monthly\", \"is_active\": 1, \"created_at\": \"2026-08-05 13:06:15\", \"updated_at\": \"2026-08-05 13:06:15\", \"currency_code\": \"ARS\", \"include_in_net_worth\": 1, \"suggested_account_id\": 2}', NULL, '192.168.100.46', '2026-08-05 13:11:50'),
(45, 1, 'update', 'budget_item', 10, 'Pago revertido', '{\"id\": 10, \"name\": \"Edenor atrasado\", \"notes\": null, \"amount\": \"351000.00\", \"status\": \"paid\", \"paid_at\": \"2026-08-05 13:06:00\", \"due_date\": \"2026-08-10\", \"entity_id\": 2, \"period_ym\": \"2026-08\", \"account_id\": 2, \"created_at\": \"2026-08-05 13:06:15\", \"updated_at\": \"2026-08-05 13:06:20\", \"paid_amount\": \"351000.00\", \"template_id\": 10, \"currency_code\": \"ARS\", \"transaction_id\": 11, \"include_in_net_worth\": 1}', '{\"id\": 10, \"name\": \"Edenor atrasado\", \"notes\": null, \"amount\": \"351000.00\", \"status\": \"pending\", \"paid_at\": null, \"due_date\": \"2026-08-10\", \"entity_id\": 2, \"period_ym\": \"2026-08\", \"account_id\": 2, \"created_at\": \"2026-08-05 13:06:15\", \"updated_at\": \"2026-08-05 13:12:08\", \"paid_amount\": null, \"template_id\": 10, \"currency_code\": \"ARS\", \"transaction_id\": null, \"include_in_net_worth\": 1}', '192.168.100.46', '2026-08-05 13:12:08'),
(46, 1, 'delete', 'budget_item', 10, 'Eliminado del mes; gasto desactivado', '{\"id\": 10, \"name\": \"Edenor atrasado\", \"notes\": null, \"amount\": \"351000.00\", \"status\": \"pending\", \"paid_at\": null, \"due_date\": \"2026-08-10\", \"entity_id\": 2, \"period_ym\": \"2026-08\", \"account_id\": 2, \"created_at\": \"2026-08-05 13:06:15\", \"updated_at\": \"2026-08-05 13:12:08\", \"paid_amount\": null, \"template_id\": 10, \"currency_code\": \"ARS\", \"transaction_id\": null, \"include_in_net_worth\": 1}', NULL, '192.168.100.46', '2026-08-05 13:12:08'),
(47, 1, 'update', 'budget_item', 2, 'Pago revertido', '{\"id\": 2, \"name\": \"Alquiler\", \"notes\": null, \"amount\": \"346000.00\", \"status\": \"paid\", \"paid_at\": \"2026-08-05 13:05:00\", \"due_date\": \"2026-08-10\", \"entity_id\": 2, \"period_ym\": \"2026-08\", \"account_id\": 2, \"created_at\": \"2026-08-05 12:44:54\", \"updated_at\": \"2026-08-05 13:05:50\", \"paid_amount\": \"346000.00\", \"template_id\": 2, \"currency_code\": \"ARS\", \"transaction_id\": 10, \"include_in_net_worth\": 1}', '{\"id\": 2, \"name\": \"Alquiler\", \"notes\": null, \"amount\": \"346000.00\", \"status\": \"pending\", \"paid_at\": null, \"due_date\": \"2026-08-10\", \"entity_id\": 2, \"period_ym\": \"2026-08\", \"account_id\": 2, \"created_at\": \"2026-08-05 12:44:54\", \"updated_at\": \"2026-08-05 13:12:12\", \"paid_amount\": null, \"template_id\": 2, \"currency_code\": \"ARS\", \"transaction_id\": null, \"include_in_net_worth\": 1}', '192.168.100.46', '2026-08-05 13:12:12'),
(48, 1, 'delete', 'budget_item', 2, 'Eliminado del mes; gasto desactivado', '{\"id\": 2, \"name\": \"Alquiler\", \"notes\": null, \"amount\": \"346000.00\", \"status\": \"pending\", \"paid_at\": null, \"due_date\": \"2026-08-10\", \"entity_id\": 2, \"period_ym\": \"2026-08\", \"account_id\": 2, \"created_at\": \"2026-08-05 12:44:54\", \"updated_at\": \"2026-08-05 13:12:12\", \"paid_amount\": null, \"template_id\": 2, \"currency_code\": \"ARS\", \"transaction_id\": null, \"include_in_net_worth\": 1}', NULL, '192.168.100.46', '2026-08-05 13:12:12'),
(49, 1, 'create', 'transaction', 12, 'Movimiento expense: 697000', NULL, NULL, '192.168.100.46', '2026-08-05 13:13:39'),
(50, 1, 'create', 'budget_template', 11, 'Alta gasto: Alquiler', NULL, NULL, '192.168.100.46', '2026-08-05 13:14:15'),
(51, 1, 'create', 'account', 9, 'Alta cuenta: Banco Patagonia - Caja de ahorro en USD', NULL, NULL, '192.168.100.46', '2026-08-05 13:32:07'),
(52, 1, 'delete', 'account', 9, 'Eliminación cuenta: Banco Patagonia - Caja de ahorro en USD', '{\"id\": 9, \"name\": \"Banco Patagonia - Caja de ahorro en USD\", \"type\": \"bank\", \"notes\": null, \"origin\": \"manual\", \"status\": \"active\", \"balance\": \"0.00\", \"provider\": null, \"entity_id\": 1, \"created_at\": \"2026-08-05 13:32:07\", \"updated_at\": \"2026-08-05 13:32:07\", \"balance_held\": \"0.00\", \"currency_code\": \"USD\", \"integration_id\": null, \"last_synced_at\": null, \"include_in_net_worth\": 1}', NULL, '192.168.100.46', '2026-08-05 13:34:15'),
(53, 1, 'create', 'net_worth_snapshot', 1, 'Snapshot consolidated', NULL, NULL, '192.168.100.46', '2026-08-05 13:34:49'),
(54, 1, 'create', 'net_worth_snapshot', 2, 'Snapshot consolidated', NULL, NULL, '192.168.100.46', '2026-08-05 13:35:57'),
(55, 1, 'create', 'net_worth_snapshot', 3, 'Snapshot consolidated', NULL, NULL, '192.168.100.46', '2026-08-05 13:36:01'),
(56, 1, 'create', 'net_worth_snapshot', 4, 'Snapshot consolidated', NULL, NULL, '192.168.100.46', '2026-08-05 13:36:04'),
(57, 1, 'create', 'net_worth_snapshot', 5, 'Snapshot consolidated', NULL, NULL, '192.168.100.46', '2026-08-05 13:36:08'),
(58, 1, 'create', 'net_worth_snapshot', 6, 'Snapshot diario: 7 filas', NULL, NULL, '192.168.100.46', '2026-08-05 13:38:00'),
(59, 1, 'create', 'transaction', 13, 'Movimiento expense: 112000', NULL, NULL, '192.168.100.46', '2026-08-05 13:39:17'),
(60, 1, 'create', 'transaction', 14, 'Movimiento expense: 50000', NULL, NULL, '192.168.100.46', '2026-08-05 13:42:21'),
(61, 1, 'create', 'transaction', 15, 'Movimiento expense: 279290.71', NULL, NULL, '192.168.100.46', '2026-08-05 13:44:00'),
(62, 1, 'update', 'transaction', 6, 'Edición movimiento', '{\"id\": 6, \"type\": \"income\", \"amount\": \"2318698.71\", \"origin\": \"manual\", \"entity_id\": 1, \"account_id\": 1, \"created_at\": \"2026-08-05 13:03:00\", \"created_by\": 1, \"updated_at\": \"2026-08-05 13:03:00\", \"category_id\": 7, \"description\": \"Salario Agosto - Hybrid Bee Technology\", \"external_id\": null, \"occurred_at\": \"2026-08-05 13:02:00\", \"currency_code\": \"ARS\", \"metadata_json\": null, \"integration_id\": null, \"counterparty_account_id\": null}', '{\"id\": 6, \"type\": \"income\", \"amount\": \"2318698.71\", \"origin\": \"manual\", \"entity_id\": 1, \"account_id\": 1, \"created_at\": \"2026-08-05 13:03:00\", \"created_by\": 1, \"updated_at\": \"2026-08-05 13:45:24\", \"category_id\": 7, \"description\": \"Salario Agosto - Hybrid Bee Technology\", \"external_id\": null, \"occurred_at\": \"2026-07-31 14:30:00\", \"currency_code\": \"ARS\", \"metadata_json\": null, \"integration_id\": null, \"counterparty_account_id\": null}', '192.168.100.46', '2026-08-05 13:45:24'),
(63, 1, 'update', 'transaction', 6, 'Edición movimiento', '{\"id\": 6, \"type\": \"income\", \"amount\": \"2318698.71\", \"origin\": \"manual\", \"entity_id\": 1, \"account_id\": 1, \"created_at\": \"2026-08-05 13:03:00\", \"created_by\": 1, \"updated_at\": \"2026-08-05 13:45:24\", \"category_id\": 7, \"description\": \"Salario Agosto - Hybrid Bee Technology\", \"external_id\": null, \"occurred_at\": \"2026-07-31 14:30:00\", \"currency_code\": \"ARS\", \"metadata_json\": null, \"integration_id\": null, \"counterparty_account_id\": null}', '{\"id\": 6, \"type\": \"income\", \"amount\": \"2318698.71\", \"origin\": \"manual\", \"entity_id\": 1, \"account_id\": 1, \"created_at\": \"2026-08-05 13:03:00\", \"created_by\": 1, \"updated_at\": \"2026-08-05 13:45:46\", \"category_id\": 7, \"description\": \"Salario Agosto - Hybrid Bee Technology\", \"external_id\": null, \"occurred_at\": \"2026-07-31 02:30:00\", \"currency_code\": \"ARS\", \"metadata_json\": null, \"integration_id\": null, \"counterparty_account_id\": null}', '192.168.100.46', '2026-08-05 13:45:46');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `budget_items`
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
  `account_id` int UNSIGNED DEFAULT NULL,
  `transaction_id` bigint UNSIGNED DEFAULT NULL,
  `paid_amount` decimal(18,2) DEFAULT NULL,
  `paid_at` datetime DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `budget_items`
--

INSERT INTO `budget_items` (`id`, `template_id`, `entity_id`, `period_ym`, `name`, `amount`, `currency_code`, `due_date`, `status`, `include_in_net_worth`, `account_id`, `transaction_id`, `paid_amount`, `paid_at`, `notes`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-08', 'Alquiler', 1180408.00, 'ARS', '2026-08-10', 'paid', 1, 1, 7, 1180408.00, '2026-08-05 13:03:00', NULL, '2026-08-05 12:44:07', '2026-08-05 13:03:43'),
(3, 3, 2, '2026-08', 'Luz', 43900.00, 'ARS', '2026-08-10', 'pending', 1, 5, NULL, NULL, NULL, NULL, '2026-08-05 12:45:19', '2026-08-05 12:45:19'),
(4, 4, 2, '2026-08', 'Internet', 46000.00, 'ARS', '2026-08-10', 'pending', 1, 5, NULL, NULL, NULL, NULL, '2026-08-05 12:45:38', '2026-08-05 12:45:38'),
(5, 5, 1, '2026-08', 'Expensas', 0.00, 'ARS', '2026-08-10', 'pending', 1, 1, NULL, NULL, NULL, NULL, '2026-08-05 12:52:28', '2026-08-05 12:52:28'),
(6, 6, 1, '2026-08', 'Luz', 0.00, 'ARS', '2026-08-10', 'pending', 1, NULL, NULL, NULL, NULL, NULL, '2026-08-05 12:52:44', '2026-08-05 12:52:44'),
(7, 7, 1, '2026-08', 'Gas', 0.00, 'ARS', '2026-08-10', 'pending', 1, NULL, NULL, NULL, NULL, NULL, '2026-08-05 12:52:52', '2026-08-05 12:52:52'),
(8, 8, 1, '2026-08', 'AySA', 0.00, 'ARS', '2026-08-10', 'pending', 1, NULL, NULL, NULL, NULL, NULL, '2026-08-05 12:53:01', '2026-08-05 12:53:01'),
(9, 9, 1, '2026-08', 'Internet', 0.00, 'ARS', '2026-08-10', 'pending', 1, NULL, NULL, NULL, NULL, NULL, '2026-08-05 12:53:18', '2026-08-05 12:53:18'),
(11, 11, 2, '2026-08', 'Alquiler', 346000.00, 'ARS', '2026-08-10', 'pending', 1, 5, NULL, NULL, NULL, NULL, '2026-08-05 13:14:15', '2026-08-05 13:14:15');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `budget_templates`
--

CREATE TABLE `budget_templates` (
  `id` int UNSIGNED NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `currency_code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ARS',
  `frequency` enum('monthly') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'monthly',
  `due_day` tinyint UNSIGNED NOT NULL DEFAULT '1',
  `suggested_account_id` int UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `include_in_net_worth` tinyint(1) NOT NULL DEFAULT '1',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `budget_templates`
--

INSERT INTO `budget_templates` (`id`, `entity_id`, `name`, `amount`, `currency_code`, `frequency`, `due_day`, `suggested_account_id`, `is_active`, `include_in_net_worth`, `notes`, `created_at`, `updated_at`) VALUES
(1, 1, 'Alquiler', 1180408.00, 'ARS', 'monthly', 10, 1, 1, 1, NULL, '2026-08-05 12:44:07', '2026-08-05 12:44:07'),
(2, 2, 'Alquiler', 346000.00, 'ARS', 'monthly', 10, 5, 0, 1, NULL, '2026-08-05 12:44:54', '2026-08-05 13:12:12'),
(3, 2, 'Luz', 43900.00, 'ARS', 'monthly', 10, 5, 1, 1, NULL, '2026-08-05 12:45:19', '2026-08-05 12:45:19'),
(4, 2, 'Internet', 46000.00, 'ARS', 'monthly', 10, 5, 1, 1, NULL, '2026-08-05 12:45:38', '2026-08-05 12:45:38'),
(5, 1, 'Expensas', 0.00, 'ARS', 'monthly', 10, 1, 1, 1, NULL, '2026-08-05 12:52:28', '2026-08-05 12:52:28'),
(6, 1, 'Luz', 0.00, 'ARS', 'monthly', 10, NULL, 1, 1, NULL, '2026-08-05 12:52:44', '2026-08-05 12:52:44'),
(7, 1, 'Gas', 0.00, 'ARS', 'monthly', 10, NULL, 1, 1, NULL, '2026-08-05 12:52:52', '2026-08-05 12:52:52'),
(8, 1, 'AySA', 0.00, 'ARS', 'monthly', 10, NULL, 1, 1, NULL, '2026-08-05 12:53:01', '2026-08-05 12:53:01'),
(9, 1, 'Internet', 0.00, 'ARS', 'monthly', 10, NULL, 1, 1, NULL, '2026-08-05 12:53:18', '2026-08-05 12:53:18'),
(10, 2, 'Edenor atrasado', 351000.00, 'ARS', 'monthly', 10, 2, 0, 1, NULL, '2026-08-05 13:06:15', '2026-08-05 13:12:08'),
(11, 2, 'Alquiler', 346000.00, 'ARS', 'monthly', 10, 5, 1, 1, NULL, '2026-08-05 13:14:15', '2026-08-05 13:14:15');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `business_valuations`
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
-- Volcado de datos para la tabla `business_valuations`
--

INSERT INTO `business_valuations` (`id`, `company_entity_id`, `valued_at`, `currency_code`, `total_value`, `method`, `notes`, `created_by`, `created_at`) VALUES
(1, 2, '2026-08-05', 'ARS', 3978179.67, 'patrimonio_neto', 'Actualizada automáticamente desde patrimonio neto', 1, '2026-08-05 10:42:59'),
(2, 3, '2026-08-05', 'ARS', 0.00, 'patrimonio_neto', 'Calculada automáticamente desde patrimonio neto', 1, '2026-08-05 11:03:34'),
(3, 4, '2026-08-05', 'ARS', 182047.23, 'patrimonio_neto', 'Actualizada automáticamente desde patrimonio neto', 1, '2026-08-05 11:06:34'),
(4, 5, '2026-08-05', 'ARS', 0.00, 'patrimonio_neto', 'Calculada automáticamente desde patrimonio neto', 1, '2026-08-05 11:07:09');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `companies`
--

CREATE TABLE `companies` (
  `entity_id` int UNSIGNED NOT NULL,
  `legal_name` varchar(220) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_id` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `industry` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `companies`
--

INSERT INTO `companies` (`entity_id`, `legal_name`, `tax_id`, `industry`, `website`) VALUES
(2, NULL, '20365013803', 'Cotillon y Libreria', NULL),
(3, NULL, '20365013803', 'E-Commerce', NULL),
(4, NULL, '2036501380', 'Consultoria IT', NULL),
(5, NULL, '20365013803', 'Sistema ERP y CRM', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `currencies`
--

CREATE TABLE `currencies` (
  `code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `symbol` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `decimals` tinyint UNSIGNED NOT NULL DEFAULT '2',
  `is_active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `currencies`
--

INSERT INTO `currencies` (`code`, `name`, `symbol`, `decimals`, `is_active`) VALUES
('ARS', 'Peso argentino', '$', 2, 1),
('EUR', 'Euro', '€', 2, 1),
('USD', 'Dólar estadounidense', 'US$', 2, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `documents`
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entities`
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
-- Volcado de datos para la tabla `entities`
--

INSERT INTO `entities` (`id`, `type`, `name`, `display_name`, `country`, `notes`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'person', 'Juan Pablo Romano', 'Juan Pablo Romano', 'Argentina', NULL, 1, '2026-08-05 10:42:14', '2026-08-05 10:42:14'),
(2, 'company', 'HomeSpot', 'HomeSpot', 'Argentina', NULL, 1, '2026-08-05 10:42:59', '2026-08-05 10:42:59'),
(3, 'company', 'Puestito', 'Puestito', 'Argentina', NULL, 1, '2026-08-05 11:03:34', '2026-08-05 11:03:34'),
(4, 'company', 'Soup IT', 'Soup IT', 'Argentina', NULL, 1, '2026-08-05 11:06:34', '2026-08-05 11:06:34'),
(5, 'company', 'Mate Gestión', 'Mate Gestión', 'Argentina', NULL, 1, '2026-08-05 11:07:09', '2026-08-05 11:07:09');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entity_tags`
--

CREATE TABLE `entity_tags` (
  `entity_id` int UNSIGNED NOT NULL,
  `tag_id` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `integrations`
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
-- Volcado de datos para la tabla `integrations`
--

INSERT INTO `integrations` (`id`, `provider`, `entity_id`, `name`, `status`, `config_json`, `account_id`, `last_sync_at`, `last_error`, `created_at`, `updated_at`) VALUES
(1, 'woocommerce', 2, 'WMC Homespot', 'active', '{\"store_url\": \"https://homespot.com.ar\", \"sync_auto\": true, \"api_version\": \"wc/v3\", \"sync_orders\": true, \"currency_code\": \"ARS\", \"sync_products\": true, \"low_stock_threshold\": 5}', NULL, '2026-08-05 10:46:10', NULL, '2026-08-05 10:45:58', '2026-08-05 10:46:10');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `integration_credentials`
--

CREATE TABLE `integration_credentials` (
  `id` int UNSIGNED NOT NULL,
  `integration_id` int UNSIGNED NOT NULL,
  `key_name` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value_encrypted` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `integration_credentials`
--

INSERT INTO `integration_credentials` (`id`, `integration_id`, `key_name`, `value_encrypted`, `updated_at`) VALUES
(1, 1, 'consumer_key', 'v1:NL3OMvhPnPW7fuyScpo9RTkYRKRqQhxlzk7blsksu4ENZVFeVCwiHPtA+eYQKdOtQrr5zpumzrl+qtZYmbAtVn4QbdnNGzk=', '2026-08-05 10:45:58'),
(2, 1, 'consumer_secret', 'v1:J9vUFssa0U1/ozuMb6882RYvIz9hZ6RlVkanQl6YHc57OK74VhPFJ39USvwO93rD6LocQTZuHQ1IAR0Zb2iah2SjRRRbo/I=', '2026-08-05 10:45:58');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inventories`
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
-- Volcado de datos para la tabla `inventories`
--

INSERT INTO `inventories` (`id`, `entity_id`, `name`, `source`, `integration_id`, `currency_code`, `stock_value`, `units_total`, `products_count`, `variations_count`, `out_of_stock_count`, `low_stock_count`, `valued_at`, `include_in_net_worth`, `notes`, `created_at`, `updated_at`) VALUES
(1, 2, 'Inventario WooCommerce', 'woocommerce', 1, 'ARS', 4275398.49, 4981.000, 253, 0, 62, 81, '2026-08-05 10:46:08', 1, NULL, '2026-08-05 10:46:08', '2026-08-05 10:46:08');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inventory_snapshots`
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
-- Volcado de datos para la tabla `inventory_snapshots`
--

INSERT INTO `inventory_snapshots` (`id`, `inventory_id`, `captured_at`, `stock_value`, `units_total`, `products_count`, `source`, `created_at`) VALUES
(1, 1, '2026-08-05 10:46:08', 4275398.49, 4981.000, 253, 'integration', '2026-08-05 10:46:08');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `liabilities`
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `net_worth_snapshots`
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
-- Volcado de datos para la tabla `net_worth_snapshots`
--

INSERT INTO `net_worth_snapshots` (`id`, `scope`, `entity_id`, `currency_code`, `captured_at`, `accounts`, `assets`, `properties`, `receivables`, `inventories`, `participations`, `liabilities`, `internal_netting`, `total_assets`, `net_worth`, `payload_json`, `created_at`) VALUES
(1, 'consolidated', NULL, 'ARS', '2026-08-05 13:34:49', 507258.45, 919599.26, 0.00, 0.00, 4275398.49, 0.00, 435900.00, 0.00, 5702256.20, 5266356.20, '{\"mode\": \"consolidated\", \"by_entity_count\": 5}', '2026-08-05 13:34:49'),
(2, 'consolidated', NULL, 'ARS', '2026-08-05 13:35:57', 507258.45, 919599.26, 0.00, 0.00, 4275398.49, 0.00, 435900.00, 0.00, 5702256.20, 5266356.20, '{\"mode\": \"consolidated\", \"by_entity_count\": 5}', '2026-08-05 13:35:57'),
(3, 'consolidated', NULL, 'ARS', '2026-08-05 13:36:01', 507258.45, 919599.26, 0.00, 0.00, 4275398.49, 0.00, 435900.00, 0.00, 5702256.20, 5266356.20, '{\"mode\": \"consolidated\", \"by_entity_count\": 5}', '2026-08-05 13:36:01'),
(4, 'consolidated', NULL, 'ARS', '2026-08-05 13:36:04', 507258.45, 919599.26, 0.00, 0.00, 4275398.49, 0.00, 435900.00, 0.00, 5702256.20, 5266356.20, '{\"mode\": \"consolidated\", \"by_entity_count\": 5}', '2026-08-05 13:36:04'),
(5, 'consolidated', NULL, 'ARS', '2026-08-05 13:36:08', 507258.45, 919599.26, 0.00, 0.00, 4275398.49, 0.00, 435900.00, 0.00, 5702256.20, 5266356.20, '{\"mode\": \"consolidated\", \"by_entity_count\": 5}', '2026-08-05 13:36:08'),
(6, 'consolidated', NULL, 'ARS', '2026-08-05 13:38:00', 507258.45, 919599.26, 0.00, 0.00, 4275398.49, 0.00, 435900.00, 0.00, 5702256.20, 5266356.20, '{\"mode\": \"consolidated\", \"by_entity_count\": 5}', '2026-08-05 13:38:00'),
(7, 'personal', NULL, 'ARS', '2026-08-05 13:38:00', 442180.71, 481901.37, 0.00, 0.00, 0.00, 4160226.90, 0.00, 0.00, 5084308.98, 5084308.98, '{\"mode\": \"personal\", \"by_entity_count\": 1}', '2026-08-05 13:38:00'),
(8, 'personal', 1, 'ARS', '2026-08-05 13:38:00', 442180.71, 481901.37, 0.00, 0.00, 0.00, 4160226.90, 0.00, 0.00, 5084308.98, 5084308.98, '{\"mode\": \"personal\", \"by_entity_count\": 0}', '2026-08-05 13:38:00'),
(9, 'entity', 2, 'ARS', '2026-08-05 13:38:00', 65077.74, 73603.44, 0.00, 0.00, 4275398.49, 0.00, 435900.00, 0.00, 4414079.67, 3978179.67, '{\"mode\": \"entity\", \"by_entity_count\": 0}', '2026-08-05 13:38:00'),
(10, 'entity', 3, 'ARS', '2026-08-05 13:38:00', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '{\"mode\": \"entity\", \"by_entity_count\": 0}', '2026-08-05 13:38:00'),
(11, 'entity', 4, 'ARS', '2026-08-05 13:38:00', 0.00, 364094.45, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 364094.45, 364094.45, '{\"mode\": \"entity\", \"by_entity_count\": 0}', '2026-08-05 13:38:00'),
(12, 'entity', 5, 'ARS', '2026-08-05 13:38:00', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '{\"mode\": \"entity\", \"by_entity_count\": 0}', '2026-08-05 13:38:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ownerships`
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
-- Volcado de datos para la tabla `ownerships`
--

INSERT INTO `ownerships` (`id`, `owner_entity_id`, `company_entity_id`, `ownership_pct`, `notes`, `created_at`, `updated_at`) VALUES
(1, 1, 2, 100.0000, NULL, '2026-08-05 10:42:59', '2026-08-05 10:42:59'),
(2, 1, 3, 50.0000, NULL, '2026-08-05 11:03:34', '2026-08-05 11:03:34'),
(3, 1, 4, 50.0000, NULL, '2026-08-05 11:06:34', '2026-08-05 11:06:34'),
(4, 1, 5, 50.0000, NULL, '2026-08-05 11:07:09', '2026-08-05 11:07:09');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `people`
--

CREATE TABLE `people` (
  `entity_id` int UNSIGNED NOT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `document_id` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `birth_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `people`
--

INSERT INTO `people` (`entity_id`, `first_name`, `last_name`, `document_id`, `birth_date`) VALUES
(1, 'Juan Pablo', 'Romano', '36501380', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `properties`
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `receivables`
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
  `status` enum('current','overdue','uncollectible','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'current',
  `collection_probability` decimal(5,2) DEFAULT NULL,
  `include_in_net_worth` tinyint(1) NOT NULL DEFAULT '1',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sales_metrics`
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
-- Volcado de datos para la tabla `sales_metrics`
--

INSERT INTO `sales_metrics` (`id`, `entity_id`, `integration_id`, `period_start`, `period_end`, `currency_code`, `orders_count`, `sales_total`, `refunds_total`, `customers_count`, `created_at`, `updated_at`) VALUES
(1, 2, 1, '2026-02-01', '2026-02-28', 'ARS', 1, 24800.00, 0.00, 0, '2026-08-05 10:46:10', '2026-08-05 10:46:10'),
(2, 2, 1, '2025-12-01', '2025-12-31', 'ARS', 1, 1072150.00, 0.00, 0, '2026-08-05 10:46:10', '2026-08-05 10:46:10'),
(3, 2, 1, '2025-10-01', '2025-10-31', 'ARS', 5, 1429224.50, 0.00, 1, '2026-08-05 10:46:10', '2026-08-05 10:46:10');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `saved_views`
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `settings`
--

CREATE TABLE `settings` (
  `setting_key` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `setting_value` text COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `settings`
--

INSERT INTO `settings` (`setting_key`, `setting_value`, `updated_at`) VALUES
('app.name', 'PatriumHub', '2026-08-05 13:40:45'),
('schema.version', '0.6.0', '2026-08-05 15:41:33'),
('ui.hide_amounts', '0', '2026-08-05 12:03:57');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sync_cursors`
--

CREATE TABLE `sync_cursors` (
  `id` int UNSIGNED NOT NULL,
  `integration_id` int UNSIGNED NOT NULL,
  `cursor_key` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cursor_value` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sync_runs`
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
-- Volcado de datos para la tabla `sync_runs`
--

INSERT INTO `sync_runs` (`id`, `integration_id`, `started_at`, `finished_at`, `status`, `records_read`, `records_upserted`, `message`, `created_at`) VALUES
(1, 1, '2026-08-05 10:46:01', '2026-08-05 10:46:10', 'success', 261, 4, 'Sync WooCommerce OK. Stock valorado: ARS 4.275.398,49. Meses de ventas: 3. Leídos: 261.', '2026-08-05 10:46:01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tags`
--

CREATE TABLE `tags` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `color` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transactions`
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
-- Volcado de datos para la tabla `transactions`
--

INSERT INTO `transactions` (`id`, `entity_id`, `account_id`, `counterparty_account_id`, `category_id`, `type`, `occurred_at`, `currency_code`, `amount`, `description`, `origin`, `integration_id`, `external_id`, `metadata_json`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 4, 7, NULL, 1, 'income', '2026-08-05 11:12:00', 'ARS', 2.00, NULL, 'manual', NULL, NULL, NULL, 1, '2026-08-05 11:13:08', '2026-08-05 11:13:08'),
(2, 4, 7, NULL, 2, 'expense', '2026-08-05 11:14:00', 'ARS', 2.00, NULL, 'manual', NULL, NULL, NULL, 1, '2026-08-05 11:14:21', '2026-08-05 11:14:21'),
(3, 4, 7, NULL, 1, 'income', '2026-08-05 11:20:00', 'ARS', 2.00, NULL, 'manual', NULL, NULL, NULL, 1, '2026-08-05 11:20:38', '2026-08-05 11:20:38'),
(4, 4, 7, NULL, 2, 'expense', '2026-08-05 11:22:00', 'ARS', 2.00, NULL, 'manual', NULL, NULL, NULL, 1, '2026-08-05 11:22:12', '2026-08-05 11:22:12'),
(5, 2, 5, NULL, NULL, 'income', '2026-08-04 11:51:00', 'ARS', 16158.00, 'En caja · ingreso', 'manual', NULL, NULL, '{\"en_caja\": true}', 1, '2026-08-05 11:52:45', '2026-08-05 11:52:45'),
(6, 1, 1, NULL, 7, 'income', '2026-07-31 02:30:00', 'ARS', 2318698.71, 'Salario Agosto - Hybrid Bee Technology', 'manual', NULL, NULL, NULL, 1, '2026-08-05 13:03:00', '2026-08-05 13:45:46'),
(7, 1, 1, NULL, NULL, 'expense', '2026-08-05 13:03:00', 'ARS', 1180408.00, 'Presupuesto: Alquiler', 'manual', NULL, NULL, '{\"period_ym\": \"2026-08\", \"budget_item_id\": 1, \"budget_template_id\": 1}', 1, '2026-08-05 13:03:43', '2026-08-05 13:03:43'),
(8, 1, 1, NULL, 3, 'expense', '2026-08-05 13:04:00', 'ARS', 697000.00, 'Alquiler y Edenor atrasado de HomeSpot', 'manual', NULL, NULL, NULL, 1, '2026-08-05 13:05:05', '2026-08-05 13:05:05'),
(9, 2, 2, NULL, 1, 'income', '2026-08-05 13:05:00', 'ARS', 697000.00, NULL, 'manual', NULL, NULL, NULL, 1, '2026-08-05 13:05:29', '2026-08-05 13:05:29'),
(12, 2, 2, NULL, 3, 'expense', '2026-07-31 13:13:00', 'ARS', 697000.00, 'Alquiler de Julio + Edenor atrasado', 'manual', NULL, NULL, NULL, 1, '2026-08-05 13:13:39', '2026-08-05 13:13:39'),
(13, 1, 1, NULL, 3, 'expense', '2026-07-31 13:38:00', 'ARS', 112000.00, 'Cena - Los chanchitos', 'manual', NULL, NULL, NULL, 1, '2026-08-05 13:39:17', '2026-08-05 13:39:17'),
(14, 1, 1, NULL, 2, 'expense', '2026-07-31 13:41:00', 'ARS', 50000.00, 'Devolución a Lean', 'manual', NULL, NULL, NULL, 1, '2026-08-05 13:42:21', '2026-08-05 13:42:21'),
(15, 1, 1, NULL, 2, 'expense', '2026-08-03 13:43:00', 'ARS', 279290.71, 'Gastos fin de semana 01/08 - 02/08', 'manual', NULL, NULL, NULL, 1, '2026-08-05 13:44:00', '2026-08-05 13:44:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transaction_categories`
--

CREATE TABLE `transaction_categories` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `kind` enum('income','expense','transfer','adjustment','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'other',
  `is_system` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `transaction_categories`
--

INSERT INTO `transaction_categories` (`id`, `name`, `kind`, `is_system`) VALUES
(1, 'Ingreso general', 'income', 1),
(2, 'Egreso general', 'expense', 1),
(3, 'Transferencia', 'transfer', 1),
(4, 'Ajuste de saldo', 'adjustment', 1),
(6, 'Venta WooCommerce', 'income', 1),
(7, 'Sueldos', 'expense', 1),
(8, 'Honorarios', 'expense', 1),
(9, 'Impuestos', 'expense', 1),
(10, 'Servicios', 'expense', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
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
-- Volcado de datos para la tabla `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `role`, `is_active`, `last_login_at`, `created_at`, `updated_at`) VALUES
(1, 'Administrador', 'admin@patriumhub.local', '$2y$10$kNqlt0SsxU8z0QD4OqRfOuGc8orvPLFrtLHUpoyPxQnmMFhTRmmvS', 'admin', 1, '2026-08-05 12:42:14', '2026-08-05 13:40:45', '2026-08-05 12:42:14');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_accounts_entity` (`entity_id`),
  ADD KEY `idx_accounts_type` (`type`),
  ADD KEY `idx_accounts_status` (`status`),
  ADD KEY `fk_accounts_currency` (`currency_code`),
  ADD KEY `fk_accounts_integration` (`integration_id`);

--
-- Indices de la tabla `account_balances`
--
ALTER TABLE `account_balances`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ab_account_date` (`account_id`,`captured_at`);

--
-- Indices de la tabla `assets`
--
ALTER TABLE `assets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_assets_entity` (`entity_id`),
  ADD KEY `idx_assets_account` (`account_id`),
  ADD KEY `fk_assets_currency` (`currency_code`);

--
-- Indices de la tabla `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_user` (`user_id`),
  ADD KEY `idx_audit_entity` (`entity_type`,`entity_id`),
  ADD KEY `idx_audit_created` (`created_at`);

--
-- Indices de la tabla `budget_items`
--
ALTER TABLE `budget_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_budget_item_period` (`template_id`,`period_ym`),
  ADD KEY `idx_bi_entity_period` (`entity_id`,`period_ym`),
  ADD KEY `idx_bi_status` (`status`),
  ADD KEY `idx_bi_due` (`due_date`),
  ADD KEY `fk_bi_currency` (`currency_code`),
  ADD KEY `fk_bi_account` (`account_id`),
  ADD KEY `fk_bi_tx` (`transaction_id`);

--
-- Indices de la tabla `budget_templates`
--
ALTER TABLE `budget_templates`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_bt_entity` (`entity_id`),
  ADD KEY `idx_bt_active` (`is_active`),
  ADD KEY `fk_bt_currency` (`currency_code`),
  ADD KEY `fk_bt_account` (`suggested_account_id`);

--
-- Indices de la tabla `business_valuations`
--
ALTER TABLE `business_valuations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_bv_company_date` (`company_entity_id`,`valued_at`),
  ADD KEY `fk_bv_currency` (`currency_code`),
  ADD KEY `fk_bv_user` (`created_by`);

--
-- Indices de la tabla `companies`
--
ALTER TABLE `companies`
  ADD PRIMARY KEY (`entity_id`);

--
-- Indices de la tabla `currencies`
--
ALTER TABLE `currencies`
  ADD PRIMARY KEY (`code`);

--
-- Indices de la tabla `documents`
--
ALTER TABLE `documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_docs_entity` (`entity_id`),
  ADD KEY `idx_docs_related` (`related_type`,`related_id`),
  ADD KEY `fk_docs_user` (`uploaded_by`);

--
-- Indices de la tabla `entities`
--
ALTER TABLE `entities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_entities_type` (`type`),
  ADD KEY `idx_entities_active` (`is_active`);

--
-- Indices de la tabla `entity_tags`
--
ALTER TABLE `entity_tags`
  ADD PRIMARY KEY (`entity_id`,`tag_id`),
  ADD KEY `fk_et_tag` (`tag_id`);

--
-- Indices de la tabla `integrations`
--
ALTER TABLE `integrations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_int_provider` (`provider`),
  ADD KEY `idx_int_entity` (`entity_id`),
  ADD KEY `idx_int_status` (`status`),
  ADD KEY `fk_int_account` (`account_id`);

--
-- Indices de la tabla `integration_credentials`
--
ALTER TABLE `integration_credentials`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_int_cred` (`integration_id`,`key_name`);

--
-- Indices de la tabla `inventories`
--
ALTER TABLE `inventories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_inv_entity` (`entity_id`),
  ADD KEY `fk_inv_currency` (`currency_code`),
  ADD KEY `fk_inv_integration` (`integration_id`);

--
-- Indices de la tabla `inventory_snapshots`
--
ALTER TABLE `inventory_snapshots`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_inv_snap` (`inventory_id`,`captured_at`);

--
-- Indices de la tabla `liabilities`
--
ALTER TABLE `liabilities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_liab_entity` (`entity_id`),
  ADD KEY `idx_liab_status` (`status`),
  ADD KEY `fk_liab_creditor_entity` (`creditor_entity_id`),
  ADD KEY `fk_liab_currency` (`currency_code`);

--
-- Indices de la tabla `net_worth_snapshots`
--
ALTER TABLE `net_worth_snapshots`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_nws_scope_date` (`scope`,`captured_at`),
  ADD KEY `idx_nws_entity_date` (`entity_id`,`captured_at`),
  ADD KEY `fk_nws_currency` (`currency_code`);

--
-- Indices de la tabla `ownerships`
--
ALTER TABLE `ownerships`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_ownership` (`owner_entity_id`,`company_entity_id`),
  ADD KEY `fk_own_company` (`company_entity_id`);

--
-- Indices de la tabla `people`
--
ALTER TABLE `people`
  ADD PRIMARY KEY (`entity_id`);

--
-- Indices de la tabla `properties`
--
ALTER TABLE `properties`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_properties_entity` (`entity_id`),
  ADD KEY `fk_properties_currency` (`currency_code`),
  ADD KEY `fk_properties_liability` (`linked_liability_id`);

--
-- Indices de la tabla `receivables`
--
ALTER TABLE `receivables`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_recv_entity` (`entity_id`),
  ADD KEY `idx_recv_status` (`status`),
  ADD KEY `fk_recv_debtor_entity` (`debtor_entity_id`),
  ADD KEY `fk_recv_currency` (`currency_code`);

--
-- Indices de la tabla `sales_metrics`
--
ALTER TABLE `sales_metrics`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_sales_period` (`entity_id`,`integration_id`,`period_start`,`period_end`),
  ADD KEY `fk_sales_currency` (`currency_code`),
  ADD KEY `fk_sales_integration` (`integration_id`);

--
-- Indices de la tabla `saved_views`
--
ALTER TABLE `saved_views`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_saved_view` (`user_id`,`context`,`name`);

--
-- Indices de la tabla `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`setting_key`);

--
-- Indices de la tabla `sync_cursors`
--
ALTER TABLE `sync_cursors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_sync_cursor` (`integration_id`,`cursor_key`);

--
-- Indices de la tabla `sync_runs`
--
ALTER TABLE `sync_runs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sync_int` (`integration_id`,`started_at`);

--
-- Indices de la tabla `tags`
--
ALTER TABLE `tags`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_tags_name` (`name`);

--
-- Indices de la tabla `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tx_entity_date` (`entity_id`,`occurred_at`),
  ADD KEY `idx_tx_account_date` (`account_id`,`occurred_at`),
  ADD KEY `idx_tx_external` (`integration_id`,`external_id`),
  ADD KEY `fk_tx_counter_account` (`counterparty_account_id`),
  ADD KEY `fk_tx_category` (`category_id`),
  ADD KEY `fk_tx_currency` (`currency_code`),
  ADD KEY `fk_tx_user` (`created_by`);

--
-- Indices de la tabla `transaction_categories`
--
ALTER TABLE `transaction_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_tx_cat_name` (`name`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_users_email` (`email`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `accounts`
--
ALTER TABLE `accounts`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `account_balances`
--
ALTER TABLE `account_balances`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT de la tabla `assets`
--
ALTER TABLE `assets`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT de la tabla `budget_items`
--
ALTER TABLE `budget_items`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `budget_templates`
--
ALTER TABLE `budget_templates`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `business_valuations`
--
ALTER TABLE `business_valuations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `documents`
--
ALTER TABLE `documents`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `entities`
--
ALTER TABLE `entities`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `integrations`
--
ALTER TABLE `integrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `integration_credentials`
--
ALTER TABLE `integration_credentials`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `inventories`
--
ALTER TABLE `inventories`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `inventory_snapshots`
--
ALTER TABLE `inventory_snapshots`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `liabilities`
--
ALTER TABLE `liabilities`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `net_worth_snapshots`
--
ALTER TABLE `net_worth_snapshots`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `ownerships`
--
ALTER TABLE `ownerships`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `properties`
--
ALTER TABLE `properties`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `receivables`
--
ALTER TABLE `receivables`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `sales_metrics`
--
ALTER TABLE `sales_metrics`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `saved_views`
--
ALTER TABLE `saved_views`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `sync_cursors`
--
ALTER TABLE `sync_cursors`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `sync_runs`
--
ALTER TABLE `sync_runs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `tags`
--
ALTER TABLE `tags`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `transaction_categories`
--
ALTER TABLE `transaction_categories`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `accounts`
--
ALTER TABLE `accounts`
  ADD CONSTRAINT `fk_accounts_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_accounts_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_accounts_integration` FOREIGN KEY (`integration_id`) REFERENCES `integrations` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `account_balances`
--
ALTER TABLE `account_balances`
  ADD CONSTRAINT `fk_ab_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `assets`
--
ALTER TABLE `assets`
  ADD CONSTRAINT `fk_assets_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_assets_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_assets_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `audit_log`
--
ALTER TABLE `audit_log`
  ADD CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `budget_items`
--
ALTER TABLE `budget_items`
  ADD CONSTRAINT `fk_bi_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_bi_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_bi_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_bi_template` FOREIGN KEY (`template_id`) REFERENCES `budget_templates` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_bi_tx` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `budget_templates`
--
ALTER TABLE `budget_templates`
  ADD CONSTRAINT `fk_bt_account` FOREIGN KEY (`suggested_account_id`) REFERENCES `accounts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_bt_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_bt_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `business_valuations`
--
ALTER TABLE `business_valuations`
  ADD CONSTRAINT `fk_bv_company` FOREIGN KEY (`company_entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_bv_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_bv_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `companies`
--
ALTER TABLE `companies`
  ADD CONSTRAINT `fk_companies_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `documents`
--
ALTER TABLE `documents`
  ADD CONSTRAINT `fk_docs_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_docs_user` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `entity_tags`
--
ALTER TABLE `entity_tags`
  ADD CONSTRAINT `fk_et_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_et_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `integrations`
--
ALTER TABLE `integrations`
  ADD CONSTRAINT `fk_int_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_int_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `integration_credentials`
--
ALTER TABLE `integration_credentials`
  ADD CONSTRAINT `fk_int_cred` FOREIGN KEY (`integration_id`) REFERENCES `integrations` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `inventories`
--
ALTER TABLE `inventories`
  ADD CONSTRAINT `fk_inv_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_inv_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_inv_integration` FOREIGN KEY (`integration_id`) REFERENCES `integrations` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `inventory_snapshots`
--
ALTER TABLE `inventory_snapshots`
  ADD CONSTRAINT `fk_inv_snap` FOREIGN KEY (`inventory_id`) REFERENCES `inventories` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `liabilities`
--
ALTER TABLE `liabilities`
  ADD CONSTRAINT `fk_liab_creditor_entity` FOREIGN KEY (`creditor_entity_id`) REFERENCES `entities` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_liab_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_liab_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `net_worth_snapshots`
--
ALTER TABLE `net_worth_snapshots`
  ADD CONSTRAINT `fk_nws_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_nws_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `ownerships`
--
ALTER TABLE `ownerships`
  ADD CONSTRAINT `fk_own_company` FOREIGN KEY (`company_entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_own_owner` FOREIGN KEY (`owner_entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `people`
--
ALTER TABLE `people`
  ADD CONSTRAINT `fk_people_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `properties`
--
ALTER TABLE `properties`
  ADD CONSTRAINT `fk_properties_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_properties_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_properties_liability` FOREIGN KEY (`linked_liability_id`) REFERENCES `liabilities` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `receivables`
--
ALTER TABLE `receivables`
  ADD CONSTRAINT `fk_recv_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_recv_debtor_entity` FOREIGN KEY (`debtor_entity_id`) REFERENCES `entities` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_recv_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `sales_metrics`
--
ALTER TABLE `sales_metrics`
  ADD CONSTRAINT `fk_sales_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_sales_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_sales_integration` FOREIGN KEY (`integration_id`) REFERENCES `integrations` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `saved_views`
--
ALTER TABLE `saved_views`
  ADD CONSTRAINT `fk_sv_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `sync_cursors`
--
ALTER TABLE `sync_cursors`
  ADD CONSTRAINT `fk_sync_cursor` FOREIGN KEY (`integration_id`) REFERENCES `integrations` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `sync_runs`
--
ALTER TABLE `sync_runs`
  ADD CONSTRAINT `fk_sync_int` FOREIGN KEY (`integration_id`) REFERENCES `integrations` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `fk_tx_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tx_category` FOREIGN KEY (`category_id`) REFERENCES `transaction_categories` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tx_counter_account` FOREIGN KEY (`counterparty_account_id`) REFERENCES `accounts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tx_currency` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`code`),
  ADD CONSTRAINT `fk_tx_entity` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tx_integration` FOREIGN KEY (`integration_id`) REFERENCES `integrations` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tx_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
