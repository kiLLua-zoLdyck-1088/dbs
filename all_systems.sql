-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 18, 2023 at 04:34 AM
-- Server version: 10.4.16-MariaDB
-- PHP Version: 7.4.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `all_systems`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`%` PROCEDURE `saadasd` ()  BEGIN
SELECT 
	SUM(CASE WHEN MONTHNAME(`date_created`) = 'September' THEN 1 ELSE 0 END) 'September',
	SUM(CASE WHEN MONTHNAME(`date_created`) = 'October' THEN 1 ELSE 0 END) 'October'
	
FROM tracks
WHERE id IN (
SELECT MAX(t.id) FROM tracks t
WHERE t.is_checked IS FALSE AND t.is_dropped IS FALSE
GROUP BY t.transaction_id 
)
AND YEAR(`date_created`) = 2022;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_transactions_dashboard` ()  BEGIN
  DROP TEMPORARY TABLE IF EXISTS TMP_TABLE ;
  CREATE TEMPORARY TABLE TMP_TABLE 
  SELECT 
    *
  FROM
    v_transactions ;
  SELECT 
    v1.a AS step, COUNT(v1.id) AS step_count 
  FROM
    TMP_TABLE AS v1 
  WHERE v1.id IN 
    (SELECT 
      MAX(v2.id) 
    FROM
      TMP_TABLE AS v2 
    GROUP BY v2.`transaction_id`) 
  
  GROUP BY v1.a ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_transactions_incoming` (IN `role` VARCHAR(20), IN `return_action_category` VARCHAR(20), IN `user_id` VARCHAR(50))  BEGIN
  DROP TEMPORARY TABLE IF EXISTS TMP_TABLE ;
  CREATE TEMPORARY TABLE TMP_TABLE 
  SELECT 
    * 
  FROM
    v_transactions ;
  if role = "admin" 
  then -- FETCH DATA
  SELECT 
    * 
  FROM
    TMP_TABLE AS TMP_TABLE_1 
  WHERE TMP_TABLE_1.id IN 
    (SELECT 
      MAX(TMP_TABLE_2.id) 
    FROM
      TMP_TABLE AS TMP_TABLE_2 
    WHERE TMP_TABLE_2.`receive_stat_sub_tracks` = 0 
      OR TMP_TABLE_2.`return_action_category` = return_action_category 
    GROUP BY TMP_TABLE_2.`transaction_id`) 
    AND TMP_TABLE_1.`received_stat` = 0;
  else -- FETCH DATA
  SELECT 
    * 
  FROM
    TMP_TABLE AS TMP_TABLE_1 
  WHERE TMP_TABLE_1.id IN 
    (SELECT 
      MAX(TMP_TABLE_2.id) 
    FROM
      TMP_TABLE AS TMP_TABLE_2 
    WHERE TMP_TABLE_2.`receive_stat_sub_tracks` = 0 
      OR TMP_TABLE_2.`return_action_category` = return_action_category 
    GROUP BY TMP_TABLE_2.`transaction_id`) 
    AND TMP_TABLE_1.`received_stat` = 0 
    and md5(TMP_TABLE_1.`user_id`) = user_id
    AND TMP_TABLE_1.`return_action_category` = return_action_category 
    ; 
  end if ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_transactions_ongoing` (IN `role` VARCHAR(20), IN `user_id` VARCHAR(50))  BEGIN
  DROP temporary TABLE IF EXISTS TMP_TABLE ;
  create TEMPORARY TABLE TMP_TABLE 
  SELECT 
    * 
  FROM
    v_transactions ;
  if role = "admin"
  then -- FETCH DATA
  SELECT 
    * 
  FROM
    TMP_TABLE AS v1 
  WHERE v1.id IN 
    (SELECT 
      MAX(v2.id) 
    FROM
      TMP_TABLE AS v2 
     
    GROUP BY v2.`transaction_id`) 
    AND v1.`received_stat` = 1 
  group by v1.transaction_id;
  else 
  SELECT 
    * 
  FROM
    TMP_TABLE as v1
  WHERE v1.id IN 
    (SELECT 
      MAX(id) 
    FROM
      TMP_TABLE v2
    GROUP BY v2.`transaction_id`) 
    AND sub_track_id IN 
    (SELECT 
      MAX(sub_track_id) 
    FROM
      TMP_TABLE v3
    GROUP BY v3.`transaction_id`) 
    AND v1.`received_stat` = 1 
    AND md5(v1.`user_id`) = user_id; 
    
    end if ;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `annotations`
--

CREATE TABLE `annotations` (
  `id` int(11) NOT NULL,
  `pr_id` bigint(20) NOT NULL,
  `annotations` text DEFAULT NULL,
  `annoted_by` varchar(100) DEFAULT NULL,
  `date_created` timestamp NOT NULL DEFAULT current_timestamp(),
  `transaction_id` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `annotations`
--

INSERT INTO `annotations` (`id`, `pr_id`, `annotations`, `annoted_by`, `date_created`, `transaction_id`) VALUES
(26, 1, 'bsdvbajsdgcjascasdc dhfvahukdf whfkahwdf wefawef', 'rmdsalamanca', '2022-10-24 00:25:12', '2022-10-0001'),
(27, 4, 'testing', 'rmdsalamanca', '2023-06-20 06:44:19', '2022-10-0004'),
(29, 10, 'This is a trial only Annotation. If you feel uneasy please see a doctor.', 'iyquinonesjr', '2023-08-23 07:13:49', ''),
(30, 10, 'Another one of those annotations. ', 'iyquinonesjr', '2023-08-23 07:15:44', ''),
(31, 12, 'Sample Annotations.', 'iyquinonesjr', '2023-09-06 07:13:38', '2023-09-0001'),
(32, 13, 'Revise PR', 'iyquinonesjr', '2023-09-26 06:58:16', '2023-09-0002');

-- --------------------------------------------------------

--
-- Table structure for table `divisions`
--

CREATE TABLE `divisions` (
  `id` int(11) NOT NULL,
  `division_name` varchar(100) DEFAULT NULL,
  `division_acronym` varchar(50) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `savedBy` int(11) DEFAULT NULL,
  `savedDate` datetime DEFAULT current_timestamp(),
  `updatedBy` int(11) DEFAULT NULL,
  `updatedDate` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `divisions`
--

INSERT INTO `divisions` (`id`, `division_name`, `division_acronym`, `is_active`, `savedBy`, `savedDate`, `updatedBy`, `updatedDate`) VALUES
(1, 'Human Resource Management Division', 'HRMD', 1, NULL, '2020-01-21 10:43:20', 1, '2020-02-18 08:14:50'),
(2, 'Policy and Plans Division', 'PPD', 1, NULL, '2020-01-21 10:56:40', 1, '2020-03-04 14:18:58'),
(3, 'Promotive and Services Division', 'PSD(Promotive and Services Division)', 1, NULL, '2020-01-28 14:17:29', 1, '2020-03-04 14:20:25'),
(4, 'Protective Services Division', 'PSD(Protective Services Division)', 1, 1, '2020-02-20 08:45:40', 1, '2020-03-04 14:19:46'),
(5, 'Disaster and Risk Management Division', 'DRMD', 1, 1, '2020-03-04 14:21:13', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `documents`
--

CREATE TABLE `documents` (
  `id` tinyint(20) NOT NULL,
  `document` varchar(50) NOT NULL,
  `dateSaved` timestamp NOT NULL DEFAULT current_timestamp(),
  `savedBy` tinyint(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `documents`
--

INSERT INTO `documents` (`id`, `document`, `dateSaved`, `savedBy`) VALUES
(1, 'PAYROLL', '2021-06-01 04:54:01', 0),
(2, 'PHIC(PS) (DV)', '2021-06-01 04:54:01', 0),
(3, 'PHIC(GS) (OB)', '2021-06-01 04:54:01', 0),
(4, 'PHIC(GS) (DV)', '2021-06-01 04:54:01', 0),
(5, 'HDMF 1(PS) (DV)', '2021-06-01 04:54:01', 0),
(6, 'HDMF 1(GS) (OB)', '2021-06-01 04:54:01', 0),
(7, 'HDMF 1(GS) (DV)', '2021-06-01 04:54:01', 0),
(8, 'HDMF 2', '2021-06-01 04:54:01', 0),
(9, 'HDMF (MPL)', '2021-06-01 04:54:01', 0),
(10, 'HDMF (CAL)', '2021-06-01 04:54:01', 0),
(11, 'HDMF (HOUSING)', '2021-06-01 04:54:01', 0),
(12, 'GSIS (GS)(OB)', '2021-06-01 04:54:01', 0),
(13, 'GSIS (GS)(DV)', '2021-06-01 04:54:01', 0),
(14, 'GSIS (PS)(DV)', '2021-06-01 04:54:01', 0),
(15, 'GSIS (CONSOLOAN)', '2021-06-01 04:54:01', 0),
(16, 'GSIS (EDUC. ASS.)', '2021-06-01 04:54:01', 0),
(17, 'GSIS (EMER. LOAN)', '2021-06-01 04:54:01', 0),
(18, 'GSIS (PLREG)', '2021-06-01 04:54:01', 0),
(19, 'GSIS HOUSING(REL)', '2021-06-01 04:54:01', 0),
(20, 'PLOPT', '2021-06-01 04:54:01', 0),
(21, 'CEAP', '2021-06-01 04:54:01', 0),
(22, 'GFAL', '2021-06-01 04:54:01', 0),
(23, 'MPL', '2021-06-01 04:54:01', 0),
(24, 'CPL', '2021-06-01 04:54:01', 0),
(25, 'LBP', '2021-06-01 04:54:01', 0),
(26, 'SSS', '2021-06-01 04:54:01', 0),
(27, 'SWEAP DUES', '2021-06-01 04:54:01', 0),
(28, 'PHILLIFE', '2021-06-01 04:54:01', 0),
(29, 'CBC', '2021-06-01 04:54:01', 0),
(30, 'MBA CONTRIBUTION', '2021-06-01 04:54:01', 0),
(31, 'MBA LOAN', '2021-06-01 04:54:01', 0);

-- --------------------------------------------------------

--
-- Table structure for table `dv_amounts`
--

CREATE TABLE `dv_amounts` (
  `id` int(20) NOT NULL,
  `tr_id` int(20) NOT NULL,
  `dv_amount1` decimal(10,2) NOT NULL,
  `dv_amount2` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `dv_amounts`
--

INSERT INTO `dv_amounts` (`id`, `tr_id`, `dv_amount1`, `dv_amount2`) VALUES
(7, 14, '121212.00', '0.00');

-- --------------------------------------------------------

--
-- Table structure for table `fund_sources`
--

CREATE TABLE `fund_sources` (
  `id` tinyint(11) NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `fund_source` varchar(500) DEFAULT NULL,
  `dateSaved` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `fund_sources`
--

INSERT INTO `fund_sources` (`id`, `category`, `fund_source`, `dateSaved`) VALUES
(1, 'DIRECT RELEASE', 'General Administration and Support Services', '2021-08-02 04:13:04'),
(2, 'DIRECT RELEASE', 'Provision of Services for center-based clients', '2021-08-02 04:13:04'),
(3, 'DIRECT RELEASE', 'Provision of technical/advisory assistance and other related support services', '2021-08-02 04:13:04'),
(4, 'DIRECT RELEASE', 'Supplementary Feeding Program', '2021-08-02 04:13:04'),
(5, 'DIRECT RELEASE', 'Poverty and Reintegration Progam for Trafficked Persons', '2021-08-02 04:13:04'),
(6, 'DIRECT RELEASE', 'Social Pension for Indigent Senior Citizens', '2021-08-02 04:13:04'),
(7, 'DIRECT RELEASE', 'Sustainable Livelihood Program', '2021-08-02 04:13:04'),
(8, 'DIRECT RELEASE', 'National Household Targeting System for Poverty Reduction', '2021-08-02 04:13:04'),
(9, 'CENTRALLY-MANAGED FUND', 'General Administration and Support Services', '2021-08-02 04:13:04'),
(10, 'CENTRALLY-MANAGED FUND', 'Information and Communication Technology Service Management', '2021-08-02 04:13:04'),
(11, 'CENTRALLY-MANAGED FUND', 'Social Marketing Services', '2021-08-02 04:13:04'),
(12, 'CENTRALLY-MANAGED FUND', 'Social Technology Development and Enhancement', '2021-08-02 04:13:04'),
(13, 'CENTRALLY-MANAGED FUND', 'Formulation and Development of Policies and Plans', '2021-08-02 04:13:04'),
(14, 'CENTRALLY-MANAGED FUND', 'EPAHP-NPMO', '2021-08-02 04:13:04'),
(15, 'CENTRALLY-MANAGED FUND', 'National Household Targeting System', '2021-08-02 04:13:04'),
(16, 'CENTRALLY-MANAGED FUND', 'Pantawid Pamilya', '2021-08-02 04:13:04'),
(17, 'CENTRALLY-MANAGED FUND', 'Sustainable Livelihood Program', '2021-08-02 04:13:04'),
(18, 'CENTRALLY-MANAGED FUND', 'KALAHI-CIDSS-NCDDP', '2021-08-02 04:13:04'),
(19, 'CENTRALLY-MANAGED FUND', 'KALAHI-CIDSS-KKB', '2021-08-02 04:13:04'),
(20, 'CENTRALLY-MANAGED FUND', 'Centers', '2021-08-02 04:13:04'),
(21, 'CENTRALLY-MANAGED FUND', 'Supplementary Feeding Program', '2021-08-02 04:13:04'),
(22, 'CENTRALLY-MANAGED FUND', 'Social Pension for Indigent Senior Citizens', '2021-08-02 04:13:04'),
(23, 'CENTRALLY-MANAGED FUND', 'Implementation of RA No. 10868 or the Centenarians Act of 2016', '2021-08-02 04:13:04'),
(24, 'CENTRALLY-MANAGED FUND', 'Protective Services for Individuals and Families in Difficult Circumstances', '2021-08-02 04:13:04'),
(25, 'CENTRALLY-MANAGED FUND', 'Assistance to Persons with Disability and Older Persons', '2021-08-02 04:13:04'),
(26, 'CENTRALLY-MANAGED FUND', 'Comprehensive Proj. for Street Children, Street Families & Ips - Esp. Badjaus', '2021-08-02 04:13:04'),
(27, 'CENTRALLY-MANAGED FUND', 'Bangsamoro Umpungan sa Nutrisyon (Bangun)', '2021-08-02 04:13:04'),
(28, 'CENTRALLY-MANAGED FUND', 'Tax Reform Cash Transfer Project', '2021-08-02 04:13:04'),
(29, 'CENTRALLY-MANAGED FUND', 'Services to Distressed Overseas Filipinos', '2021-08-02 04:13:04'),
(30, 'CENTRALLY-MANAGED FUND', 'Services to Displaced Persons (Deportees)', '2021-08-02 04:13:04'),
(31, 'CENTRALLY-MANAGED FUND', 'Poverty and Reintegration Progam for Trafficked Persons', '2021-08-02 04:13:04'),
(32, 'CENTRALLY-MANAGED FUND', '414080003 - Implementation of Various Prog./Proj. for LGUs', '2021-08-02 04:13:04'),
(33, 'CENTRALLY-MANAGED FUND', 'Disaster response and rehabilitation program', '2021-08-02 04:13:04'),
(34, 'CENTRALLY-MANAGED FUND', 'National Resource Operation', '2021-08-02 04:13:04'),
(35, 'CENTRALLY-MANAGED FUND', 'Quick Response Fund', '2021-08-02 04:13:04'),
(36, 'CENTRALLY-MANAGED FUND', 'Purchase of Mobile Community Kitchens', '2021-08-02 04:13:04'),
(37, 'CENTRALLY-MANAGED FUND', 'PAMANA - Peace & Development Fund', '2021-08-02 04:13:04'),
(38, 'CENTRALLY-MANAGED FUND', 'PAMANA - DSWD/LGU Led', '2021-08-02 04:13:04'),
(39, 'CENTRALLY-MANAGED FUND', 'Standards-setting, Licensing, accreditation and monitoring services', '2021-08-02 04:13:04'),
(40, 'CENTRALLY-MANAGED FUND', 'Provision of Capability Training Program', '2021-08-02 04:13:04');

-- --------------------------------------------------------

--
-- Table structure for table `hr_transactions`
--

CREATE TABLE `hr_transactions` (
  `id` int(20) NOT NULL,
  `track_id` varchar(50) DEFAULT NULL,
  `fund_source` tinyint(50) DEFAULT NULL,
  `document_type` tinyint(4) NOT NULL,
  `is_approved` bit(1) DEFAULT b'0',
  `is_finance_received` bit(1) DEFAULT b'0',
  `remarks` varchar(200) DEFAULT NULL,
  `dateSaved` timestamp NULL DEFAULT current_timestamp(),
  `savedBy` tinyint(11) DEFAULT NULL,
  `covered_date_from` date DEFAULT NULL,
  `covered_date_to` date DEFAULT NULL,
  `payee` tinyint(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `hr_transactions`
--

INSERT INTO `hr_transactions` (`id`, `track_id`, `fund_source`, `document_type`, `is_approved`, `is_finance_received`, `remarks`, `dateSaved`, `savedBy`, `covered_date_from`, `covered_date_to`, `payee`) VALUES
(13, '2021-0805-0001', 3, 1, b'1', b'0', NULL, '2021-08-05 03:25:59', 11, '2021-08-05', '2021-08-07', 11),
(14, '2021-0805-0001', 3, 17, b'1', b'0', NULL, '2021-08-05 03:25:59', 11, '2021-08-05', '2021-08-07', 11),
(15, '2021-0805-0002', 6, 1, b'0', b'0', NULL, '2021-08-05 04:17:17', 5, '2021-08-05', '2021-08-10', 1),
(16, '2021-0805-0002', 6, 19, b'0', b'0', NULL, '2021-08-05 04:17:17', 5, '2021-08-05', '2021-08-10', 1);

-- --------------------------------------------------------

--
-- Table structure for table `ob_amounts_count`
--

CREATE TABLE `ob_amounts_count` (
  `id` bigint(20) NOT NULL,
  `tr_id` bigint(20) NOT NULL,
  `ob_amount` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `ob_amounts_count`
--

INSERT INTO `ob_amounts_count` (`id`, `tr_id`, `ob_amount`) VALUES
(13, 13, '12345678.00'),
(14, 14, '1212.00'),
(15, 15, '121212.00'),
(16, 16, '121212.00');

-- --------------------------------------------------------

--
-- Table structure for table `payees`
--

CREATE TABLE `payees` (
  `id` bigint(20) NOT NULL,
  `fname` varchar(50) DEFAULT NULL,
  `mname` varchar(50) DEFAULT NULL,
  `lname` varchar(50) DEFAULT NULL,
  `full_name` varchar(200) DEFAULT NULL,
  `dateSaved` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `payees`
--

INSERT INTO `payees` (`id`, `fname`, `mname`, `lname`, `full_name`, `dateSaved`) VALUES
(1, 'test', 'test', 'test', 'test', '2021-05-28 07:33:48');

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `id` int(11) NOT NULL,
  `permission` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`id`, `permission`, `created_at`, `updated_at`) VALUES
(1, 'Manage User Roles', '2023-07-12 01:23:36', NULL),
(2, 'Manage User Accounts', '2023-07-12 02:49:27', NULL),
(3, 'Assign Roles', '2023-07-27 01:11:52', '2023-07-27 01:12:54'),
(4, 'Manage Permissions', '2023-07-27 01:14:21', '2023-07-27 01:14:32'),
(5, 'Manage Procurement Mode', '2023-07-27 00:56:23', NULL),
(6, 'Manage Procurement Action', '2023-07-27 00:56:54', NULL),
(7, 'Manage Request Type', '2023-07-27 00:58:50', NULL),
(10, 'Manage Item Remarks', '2023-08-14 06:46:25', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `procurement_modes`
--

CREATE TABLE `procurement_modes` (
  `id` int(11) NOT NULL,
  `procurement_mode` varchar(100) DEFAULT NULL,
  `dateSaved` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `procurement_modes`
--

INSERT INTO `procurement_modes` (`id`, `procurement_mode`, `dateSaved`) VALUES
(1, 'AGENCY TO AGENCY PROCUREMENT', '2022-07-07 06:50:37'),
(2, 'COMMUNITY PARTICIPATION', '2022-07-07 06:50:37'),
(3, 'DIRECT PAYMENT', '2022-07-07 06:50:37'),
(4, 'EMERGENCY PURCHASE', '2022-07-07 06:50:37'),
(5, 'PUBLIC BIDDING (P1,000,000.01 AND ABOVE)', '2022-07-07 06:50:37'),
(6, 'SHOPPING AND SMALL VALUE PROCUREMENT - NON-POSTING TO PHILGEPS (P50,000.00 AND BELOW)', '2022-07-07 06:50:37'),
(7, 'SHOPPING AND SMALL VALUE PROCUREMENT - FOR POSTING TO PHILGEPS (FROM P50,000.01 TO P1,000,000.00)', '2022-07-07 06:50:37'),
(8, 'REPEAT ORDER', '2022-07-07 06:50:37');

-- --------------------------------------------------------

--
-- Table structure for table `proc_actions`
--

CREATE TABLE `proc_actions` (
  `id` int(11) NOT NULL,
  `actions` varchar(150) DEFAULT NULL,
  `category` varchar(20) DEFAULT NULL,
  `date_create` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_checking` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `proc_actions`
--

INSERT INTO `proc_actions` (`id`, `actions`, `category`, `date_create`, `is_checking`) VALUES
(1, 'DONE - FILED', 'non-step', '2021-07-12 06:44:02', 0),
(2, 'DONE - SIGNED / APPROVED\r\n', 'non-step', '2021-07-12 06:44:06', 0),
(3, 'ENTRY OF INCOMING DOCUMENTS (FOR NON-NEW PR)\r\n', 'return0', '2021-07-12 06:44:08', 0),
(4, 'ENTRY OF OUTGOING DOCUMENTS\r\n', 'return1', '2021-07-12 06:44:11', 0),
(5, 'RECORDING OF IN CONFORMITY WITH THE APPROVED WFP, APP AND PPMP', 'steps', '2021-07-12 06:44:18', 0),
(6, 'RECORDING OF NEW APPROVED PURCHASE REQUEST (PR) FROM END-USER', 'steps', '2021-07-12 06:44:22', 0),
(7, 'PREPARATION OF RFQ & CANVASS FORM', 'steps', '2021-07-12 06:44:25', 0),
(8, 'RECORDING OF DATE OF POSTING TO PHILGEPS', 'steps', '2021-07-12 06:44:29', 0),
(9, 'RECORDING OF DATE OF CANVASSING', 'steps', '2021-07-12 06:44:32', 0),
(10, 'RECORDING OF DATE OF BAC OPENING / PUBLIC BIDDING', 'steps', '2021-07-12 06:44:35', 0),
(11, 'RECORDING OF FAILURE OF BIDDING', 'steps', '2021-07-12 06:44:38', 0),
(12, 'PREPARATION OF ABSTRACT, BAC RESO, EVALUATION REPORT, P.O, IAR (1 ATTACHMENT PER CONTROL NUMBER)', 'steps', '2021-07-12 06:44:41', 0),
(13, 'RECORDING OF DATE FORWARDED OF PURCHASE ORDER (PO) TO SUPPLY OFFICE FOR INSPECTION', 'steps-max', '2021-07-12 06:44:43', 0),
(14, 'CHECKING ROUTE', NULL, '2022-09-19 03:58:52', 1),
(15, 'PREPARATION OF NOTICE OF DELIVERY/SCHEDULE', NULL, '2022-09-29 02:38:46', 0),
(16, 'PREPARATION OF POST QUALIFICATION REPORT', NULL, '2023-08-18 02:09:41', 0),
(17, 'PREPARATION OF NOTICE OF AWARD, NOTICE TO PROCEED', NULL, '2023-08-18 02:10:32', 0),
(18, 'PREPARATION FOR OB/DV', NULL, '2023-10-03 01:31:20', 0);

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `barcode` char(13) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `description`, `barcode`) VALUES
(1, 'BOND PAPER', 'A+ PLUS A4 BONDPAPER 70GSM', '0000000000001'),
(2, 'PENCIL', 'MONGOL 2 YELLOW', '0000000000005'),
(3, 'LAPTOP', 'ASUS LAPTOP', '0000000000006'),
(4, 'INK', 'MAGENTA INK EPSON 003', '0000000000017'),
(5, 'INK', 'BLACK INK EPSON 664', '0000000000018'),
(6, 'INK', 'MAGENTA INK EPSON 664', '0000000000019'),
(7, 'TABLE', 'LONG TABLE', '0000000000002'),
(8, 'INK', 'BLACK INK CANON', '0000000000003'),
(9, 'PRINTER', 'EPSON L360 PRINTER', '0000000000004'),
(10, 'GLUE', 'ELMER\'S GLUE MULTI PURPOSE', '0000000000011'),
(11, 'HIGHLIGHTER', 'STABILO BOSS ORIGINAL HIGHLIGHTER', '0000000000012'),
(12, 'ALCOHOL', 'ISOPROPHYL ALCOHOL GREEN CROSS 500 ML 70 % DISINFECTANT', '0000000000007'),
(13, 'TISSUE', 'JADE BATHROOM TISSUE', '0000000000008'),
(14, 'BALLPEN', 'PILOT BLACK BALLPEN', '0000000000009'),
(15, 'FOLDER', 'GREEN LONG FOLDER PLASTIC', '0000000000010'),
(16, 'INK', 'CYAN INK CANON', '0000000000013'),
(17, 'INK', 'MAGENTA INK CANON', '0000000000014'),
(18, 'INK', 'BLACK INK EPSON 003', '0000000000015'),
(19, 'INK', 'CYAN INK EPSON 003', '0000000000016'),
(20, 'INK', 'YELLOW INK EPSON 664', '0000000000020'),
(21, 'BONDPAPER', 'A+ PLUS 8 1/2\" X 13\" LEGAL BONDPAPER 70GSM', '0000000000021'),
(22, 'BONDPAPER', 'A+ PLUS 8 1/2\" X 11\" LETTER BONDPAPER 70GSM', '0000000000022'),
(23, 'BONDPAPER', 'IK PLUS MULTIPUROSE PAPER 8 1/2\" X 13\" LEGAL BONDPAPER 80GSM', '0000000000023'),
(24, 'BONDPAPER', 'IK PLUS MULTIPUROSE PAPER 8 1/2\" X 11\" LETTER BONDPAPER 80GSM', '0000000000024'),
(25, 'BONDPAPER', 'HARDCOPY 8 1/2\" X 13\" LEGAL BONDPAPER 70GSM', '0000000000025'),
(26, 'BONDPAPER', 'HARDCOPY 8 1/2\" X 11\" LETTER BONDPAPER 70GSM', '0000000000026'),
(27, 'BONDPAPER', 'HARDCOPY A4 BONDPAPER 70GSM', '0000000000027'),
(28, 'TISSUE', 'FRESH ECONOROLL 2 PLY-300 SHEETS', '0000000000027'),
(29, 'BALLPEN', 'CELLO QUICK BLUE BALLPEN', '0000000000027'),
(30, 'BALLPEN', 'CELLO QUICK BLACK BALLPEN', '0000000000027'),
(31, 'BALLPEN', 'CELLO QUICK RED BALLPEN', '0000000000027'),
(32, 'PRINTER', 'EPSON L3110 PRINTER', '0000000000027'),
(33, 'CALCULATOR', 'CANON CALCULATOR', '0000000000027'),
(34, 'STICKY NOTES', 'RED STICKY NOTES', '0000000000027'),
(35, 'PAPER CLIP', 'RED PAPER CLIP', NULL),
(36, 'Wheelchair for Adult', 'Aluminum', '0000000000028'),
(37, 'TONER ', 'ECOSYS TK 1147', '0000000000029'),
(38, 'EXTERNAL HARDRIVE', '1TB, 2.5\'\'HDD,USB 3.0', '0000000000030'),
(39, 'SOAP', 'BATHROOM', '0000000000031'),
(40, 'BROOM', 'SOFT (TAMBO)', '0000000000032'),
(41, 'CLEANSER', 'POWDER CLEANSER', '0000000000033'),
(42, 'DETERGENT POWDER', 'ALL PURPOSE DETERGENT POWDER', '0000000000034'),
(43, 'DETERGENT BAR', 'DETERGENT BAR', '0000000000035'),
(44, 'DISINFECTANT SPRAY', 'DISINFECTANT SPRAY', '0000000000036'),
(45, 'DUST PAN', 'PLASTIC ,DETACHABLE HANDLE', '0000000000037'),
(46, 'FLOOR WAX', 'LIQUID FLOOR WAX', '0000000000038'),
(47, 'CLEANER', 'URINAL/TOILET BOWL CLEANER', '0000000000039'),
(48, 'DEODORANT CAKE', 'TOILET DEODORANT CAKE', '0000000000040'),
(49, 'TRASHBAG', 'BLACK,PLASTIC (XL) TRASHBAG', '0000000000041'),
(50, 'AIR FRESHENER', 'AIR FRESHENER IN CAN/BOTTLE', '0000000000042'),
(51, 'BOND PAPER', 'A4, MULTICOPY PAPER, SUBSTANCE 20', '0000000000043'),
(52, 'BONDPAPER', 'LEGAL, MULTICOPY PAPER, SUBSTANCE 20', '0000000000044'),
(53, 'FOLDER', 'BROWN, LONG, 100PCS/PACK', '0000000000045'),
(54, 'BALLPEN', 'BLACK, 50PCS/BOX', '0000000000046'),
(55, 'SIGNPEN', 'BLACK, 0.5, 12PCS/BOX', '0000000000047'),
(56, 'SIGNPEN', 'GREEN, 0.5, 12PCS/BOX', '0000000000048'),
(57, 'ENVELOPE', 'EXPANDING, KRAFT, LEGAL SIZE, 1000s/BOX', '0000000000049'),
(58, 'INK', 'EPSON REFILL INK, ORIGINAL T664 (BLACK)', '0000000000050'),
(59, 'INK', 'EPSON REFILL INK ORIGINAL T664 (C)', '0000000000051'),
(60, 'INK', 'EPSON REFILL INK, ORIGINAL T664 (M)', '0000000000052'),
(61, 'INK', 'EPSON REFILL, ORIGINAL INK T664 (Y)', '0000000000053'),
(62, 'CORRECTION TAPE', 'CORRECTION TAPE, 6METERS', '0000000000054'),
(63, 'STAPLER', 'HEAVY DUTY', '0000000000055'),
(64, 'FELT PAPER', 'ASSORTED COLOR', '0000000000056'),
(65, 'LINEN PAPER', 'COLORED LINEN PAPER, 10\'S, THICK', '0000000000057'),
(66, 'STAPLER', 'STAPLER W/ REMOVER', '0000000000058'),
(67, 'SCISSORS', 'BIG', '0000000000059'),
(68, 'SIGNING PEN', 'SIGNING PEN, 0.7', '0000000000060'),
(69, 'WHITE BOARD MARKER', 'WHITE BOARD MARKER, BLACK, FINE', '0000000000061'),
(70, 'RECORD BOOK', 'RECORD BOOK, 500 PAGES', '0000000000062'),
(71, 'RECORD BOOK', 'RECORD BOOK, 200 PAGES', '0000000000063'),
(397, NULL, 'ACETATE', '13111203-AC-F'),
(398, NULL, 'AIR FRESHENER', '47131812-AF-A'),
(399, NULL, 'ALCOHOL, Ethyl, 500ml', '12191601-AL-E'),
(400, NULL, 'ALCOHOL, ethyl, 68%-72%, 1 Gallon', '12191601-AL-E'),
(401, NULL, 'APRON (DOH SPECS)', '42131601-AP01'),
(402, NULL, 'BATTERY, dry cell, AAA', '26111702-BT-A'),
(403, NULL, 'BATTERY, dry Cell, size AA', '26111702-BT-A'),
(404, NULL, 'BATTERY, dry Cell, size D', '26111702-BT-A'),
(405, NULL, 'BINDING AND PUNCHING MACHINE, 50mm binding capacit', '44101602-PB-M'),
(406, NULL, 'BLADE, for general purpose cutter / utility knife', '44121612-BL-H'),
(407, NULL, 'BROOM, soft, tambo', '47131604-BR-S'),
(408, NULL, 'BROOM, stick, ting-ting', '47131604-BR-T'),
(409, NULL, 'CALCULATOR, compact', '44101807-CA-C'),
(410, NULL, 'CARBON FILM, A4', '13111201-CF-P'),
(411, NULL, 'CARBON FILM, legal', '13111201-CF-P'),
(412, NULL, 'CARTOLINA, assorted colors', '14111525-CA-A'),
(413, NULL, 'CHALK, molded, white, dustless', '44121710-CH-W'),
(414, NULL, 'CLEANER, toilet and urinal', '47131829-TB-C'),
(415, NULL, 'CLEANSER, scouring powder', '47131805-CL-P'),
(416, NULL, 'CLEARBOOK, 20 transparent pockets, A4', '60121413-CB-P'),
(417, NULL, 'CLEARBOOK, 20 transparent pockets, legal', '60121413-CB-P'),
(418, NULL, 'CLIP, backfold, 19mm', '44122105-BF-C'),
(419, NULL, 'CLIP, backfold, 25mm', '44122105-BF-C'),
(420, NULL, 'CLIP, backfold, 32mm', '44122105-BF-C'),
(421, NULL, 'CLIP, backfold, 50mm', '44122105-BF-C'),
(422, NULL, 'COMPUTER CONTINUOUS FORM, 1 ply, 280 X 241mm', '14111506-CF-L'),
(423, NULL, 'COMPUTER CONTINUOUS FORM, 1 ply, 280mm x 378mm', '14111506-CF-L'),
(424, NULL, 'COMPUTER CONTINUOUS FORM, 2 ply, 280 X 378mm', '14111506-CF-L'),
(425, NULL, 'COMPUTER CONTINUOUS FORM, 2 ply, 280mm x 241mm', '14111506-CF-L'),
(426, NULL, 'COMPUTER CONTINUOUS FORM, 3 ply, 280 X 241mm', '14111506-CF-L'),
(427, NULL, 'COMPUTER CONTINUOUS FORM, 3 ply, 280 X 378mm', '14111506-CF-L'),
(428, NULL, 'CORRECTION TAPE', '44121801-CT-R'),
(429, NULL, 'COVERALL, non-sterile, protective, medical grade', '46181503-CA-C'),
(430, NULL, 'CUTTER/UTILITY KNIFE, for general purpose', '44121612-CU-H'),
(431, NULL, 'DATA FILE BOX', '44111515-DF-B'),
(432, NULL, 'DATA FOLDER', '44122011-DF-F'),
(433, NULL, 'DATING AND STAMPING MACHINE', '44103202-DS-M'),
(434, NULL, 'DESKTOP FOR BASIC USERS', '43211507-DSK0'),
(435, NULL, 'DESKTOP FOR MID-RANGE USERS', '43211507-DSK0'),
(436, NULL, 'DETERGENT BAR, 140g', '47131811-DE-B'),
(437, NULL, 'DETERGENT POWDER, all-purpose, 1kg', '47131811-DE-P'),
(438, NULL, 'DIGITAL VOICE RECORDER', '52161535-DV-R'),
(439, NULL, 'DISINFECTANT SPRAY, aerosol, 400g (min)', '47131803-DS-A'),
(440, NULL, 'DOCUMENT CAMERA, 8 MP', '45121517-DO-C'),
(441, NULL, 'DRUM CART, BROTHER DR-3455, Black', '44103109-BR-D'),
(442, NULL, 'Drum Cart, Brother DR-451CL,high yield 30000 pages', '44103109-BR-D'),
(443, NULL, 'DUST PAN, non-rigid plastic', '47131601-DU-P'),
(444, NULL, 'ELECTRIC FAN, ceiling mount, orbit type', '40101604-EF-C'),
(445, NULL, 'ELECTRIC FAN, industrial, ground type', '40101604-EF-G'),
(446, NULL, 'ELECTRIC FAN, stand type', '40101604-EF-S'),
(447, NULL, 'ELECTRIC FAN, wall mount, plastic blade', '40101604-EF-W'),
(448, NULL, 'ENVELOPE, documentary, A4', '44121506-EN-D'),
(449, NULL, 'ENVELOPE, Documentary, Legal', '44121506-EN-D'),
(450, NULL, 'ENVELOPE, expanding, kraft, legal', '44121506-EN-X'),
(451, NULL, 'ENVELOPE, expanding, plastic', '44121506-EN-X'),
(452, NULL, 'ENVELOPE, Mailing, White', '44121506-EN-M'),
(453, NULL, 'ENVELOPE, mailing, with window', '44121504-EN-W'),
(454, NULL, 'ERASER, FELT, for blackboard/whiteboard', '44111912-ER-B'),
(455, NULL, 'ERASER, plastic/rubber', '60121534-ER-P'),
(456, NULL, 'EXTERNAL HARD DRIVE, 1 TB', '43201827-HD-X'),
(457, NULL, 'FACE SHIELD, direct splash protection', '46181702-FSH0'),
(458, NULL, 'FACSIMILE MACHINE', '44101714-FX-M'),
(459, NULL, 'FASTENER, metal', '44122118-FA-P'),
(460, NULL, 'FILE ORGANIZER, expanding, plastic, 12 pockets', '44111515-FO-X'),
(461, NULL, 'FILE TAB DIVIDER, bristol board, for A4', '44122018-FT-D'),
(462, NULL, 'FILE TAB DIVIDER, legal', '44122018-FT-D'),
(463, NULL, 'FIRE EXTINGUISHER, dry chemical', '46191601-FE-M'),
(464, NULL, 'FIRE EXTINGUISHER, pure HCFC', '46191601-FE-H'),
(465, NULL, 'FLASH DRIVE, 16 GB Capacity', '43202010-FD-U'),
(466, NULL, 'FLOOR WAX, paste type, red', '47131802-FW-P'),
(467, NULL, 'FOLDER with Tab, A4', '44122011-FO-T'),
(468, NULL, 'FOLDER with Tab, Legal', '44122011-FO-T'),
(469, NULL, 'FOLDER, fancy, with slide, A4', '44122011-FO-F'),
(470, NULL, 'FOLDER, fancy, with slide, legal', '44122011-FO-F'),
(471, NULL, 'FOLDER, L-type, A4', '44122011-FO-L'),
(472, NULL, 'FOLDER, L-type, plastic, legal', '44122011-FO-L'),
(473, NULL, 'FOLDER, pressboard', '44122027-FO-P'),
(474, NULL, 'FURNITURE CLEANER, aerosol type', '47131830-FC-A'),
(475, NULL, 'GLOVES, NITRILE', '42132203-MG-G'),
(476, NULL, 'GLUE, all purpose', '31201610-GL-J'),
(477, NULL, 'HANDBOOK (RA 9184), 8th edition', '55101524-RA-H'),
(478, NULL, 'HEAD COVER, disposable', '42131711-HC-H'),
(479, NULL, 'INDEX TAB', '44122008-IT-T'),
(480, NULL, 'INK CART, BROTHER LC67B, Black', '44103105-BR-B'),
(481, NULL, 'INK CART, BROTHER LC67HYBK, Black', '44103105-BR-B'),
(482, NULL, 'INK CART, CANON CL-741,Colored', '44103105-CA-C'),
(483, NULL, 'INK CART, CANON CL-811, Colored', '44103105-CA-C'),
(484, NULL, 'INK CART, CANON PG-740, Black', '44103105-CA-B'),
(485, NULL, 'INK CART, CANON PG-810, Black', '44103105-CA-B'),
(486, NULL, 'INK CART, EPSON C13T664100 (T6641), Black', '44103105-EP-B'),
(487, NULL, 'INK CART, EPSON C13T664200 (T6642), Cyan', '44103105-EP-C'),
(488, NULL, 'INK CART, EPSON C13T664300 (T6643), Magenta', '44103105-EP-M'),
(489, NULL, 'INK CART, EPSON C13T664400 (T6644), Yellow', '44103105-EP-Y'),
(490, NULL, 'INK CART, HP C9351AA, (HP21), Black', '44103105-HP-B'),
(491, NULL, 'INK CART, HP C9352AA, (HP22), Tri-color', '44103105-HP-T'),
(492, NULL, 'INK CART, HP CC640WA, (HP60), Black', '44103105-HP-B'),
(493, NULL, 'INK CART, HP CC643WA, (HP60), Tri-color', '44103105-HP-T'),
(494, NULL, 'INK CART, HP CD887AA, (HP703), Black', '44103105-HP-B'),
(495, NULL, 'INK CART, HP CD888AA, (HP703), Tri-color', '44103105-HP-T'),
(496, NULL, 'INK CART, HP CD972AA, (HP 920XL), Cyan', '44103105-HX-C'),
(497, NULL, 'INK CART, HP CD973AA, (HP 920XL), Magenta', '44103105-HX-M'),
(498, NULL, 'INK CART, HP CD974AA, (HP 920XL), Yellow,', '44103105-HX-Y'),
(499, NULL, 'INK CART, HP CD975AA, (HP 920XL), Black', '44103105-HX-B'),
(500, NULL, 'INK CART, HP CH561WA, (HP61), Black', '44103105-HP-B'),
(501, NULL, 'INK CART, HP CH562WA, (HP61), Tricolor', '44103105-HP-T'),
(502, NULL, 'INK CART, HP CN045AA, (HP950XL), Black', '44103105-HX-B'),
(503, NULL, 'INK CART, HP CN046AA, (HP951XL), Cyan', '44103105-HX-C'),
(504, NULL, 'INK CART, HP CN047AA, (HP951XL), Magenta', '44103105-HX-M'),
(505, NULL, 'INK CART, HP CN048AA, (HP951XL). Yellow', '44103105-HX-Y'),
(506, NULL, 'INK CART, HP CN692AA, (HP704), Black', '44103105-HP-B'),
(507, NULL, 'INK CART, HP CN693AA, (HP704), Tri-color', '44103105-HP-T'),
(508, NULL, 'INK CART, HP CZ107AA, (HP678), Black', '44103105-HP-B'),
(509, NULL, 'INK CART, HP CZ108AA, (HP678), Tricolor', '44103105-HP-T'),
(510, NULL, 'INK CART, HP CZ121A (HP685A), Black', '44103105-HP-B'),
(511, NULL, 'INK CART, HP CZ122A (HP685A), Cyan', '44103105-HP-C'),
(512, NULL, 'INK CART, HP CZ123A (HP685A), Magenta', '44103105-HP-M'),
(513, NULL, 'INK CART, HP CZ124A (HP685A), Yellow', '44103105-HP-Y'),
(514, NULL, 'Ink Cartridge, HP C2P04AA (HP62) Black', '44103105-HP-B'),
(515, NULL, 'Ink Cartridge, HP C2P06AA (HP62) Tri-color', '44103105-HP-T'),
(516, NULL, 'Ink Cartridge, HP C9397A (HP72) 69ml Photo Black', '44103105-HP-P'),
(517, NULL, 'Ink Cartridge, HP C9398A (HP72) 69ml Cyan', '44103105-HP-C'),
(518, NULL, 'Ink Cartridge, HP C9399A (HP72) 69ml Magenta', '44103105-HP-M'),
(519, NULL, 'Ink Cartridge, HP C9400A (HP72) 69ml Yellow', '44103105-HP-Y'),
(520, NULL, 'Ink Cartridge, HP C9401A (HP72) 69ml Gray', '44103105-HP-G'),
(521, NULL, 'Ink Cartridge, HP C9403A (HP72) 130ml Matte Black', '44103105-HP-B'),
(522, NULL, 'Ink Cartridge, HP CH565A (HP82) Black', '44103105-HP-B'),
(523, NULL, 'Ink Cartridge, HP CH566A (HP82) Cyan', '44103105-HP-C'),
(524, NULL, 'Ink Cartridge, HP CH567A (HP82) Magenta', '44103105-HP-M'),
(525, NULL, 'Ink Cartridge, HP CH568A (HP82) Yellow', '44103105-HP-Y'),
(526, NULL, 'Ink Cartridge, HP F6V26AA (HP680) Tri-color', '44103105-HP-T'),
(527, NULL, 'Ink Cartridge, HP F6V27AA (HP680) Black', '44103105-HP-B'),
(528, NULL, 'Ink Cartridge, HP L0S51AA (HP955) Cyan', '44103105-HP-C'),
(529, NULL, 'Ink Cartridge, HP L0S54AA (HP955) Magenta', '44103105-HP-M'),
(530, NULL, 'Ink Cartridge, HP L0S57AA (HP955) Yellow', '44103105-HP-Y'),
(531, NULL, 'Ink Cartridge, HP L0S60AA (HP955) Black', '44103105-HP-B'),
(532, NULL, 'Ink Cartridge, HP L0S63AA (HP955XL) Cyan', '44103105-HX-C'),
(533, NULL, 'Ink Cartridge, HP L0S66AA (HP955XL) Magenta', '44103105-HX-M'),
(534, NULL, 'Ink Cartridge, HP L0S69AA (HP955XL) Yellow', '44103105-HX-Y'),
(535, NULL, 'Ink Cartridge, HP L0S72AA (HP955XL) Black', '44103105-HX-B'),
(536, NULL, 'Ink Cartridge, HP T6L89AA (HP905) Cyan', '44103105-HP-C'),
(537, NULL, 'Ink Cartridge, HP T6L93AA (HP905) Magenta', '44103105-HP-M'),
(538, NULL, 'Ink Cartridge, HP T6L97AA (HP905) Yellow', '44103105-HP-Y'),
(539, NULL, 'Ink Cartridge, HP T6M01AA (HP905) Black', '44103105-HP-B'),
(540, NULL, 'INSECTICIDE, aerosol type', '10191509-IN-A'),
(541, NULL, 'KN95 FACE MASK', '46182008-KN-M'),
(542, NULL, 'LAPTOP, LIGHTWEIGHT', '43211503-LAP0'),
(543, NULL, 'LAPTOP, MID-RANGE', '43211503-LAP0'),
(544, NULL, 'LIGHT EMITTING DIODE (LED), Light Bulb', '39101628-LB-L'),
(545, NULL, 'LINEAR TUBE, Light Emitting Diode (LED), 18 watts', '39101628-LT-L'),
(546, NULL, 'LIQUID HAND SANITIZER, 500mL', '53131626-HS-S'),
(547, NULL, 'LIQUID HAND SOAP, 500mL', '73101612-HS-L'),
(548, NULL, 'LOOSELEAF COVER, legal', '14111609-LL-C'),
(549, NULL, 'MAGAZINE FILE BOX, large', '44111515-MF-B'),
(550, NULL, 'MARKER, fluorescent', '44121716-MA-F'),
(551, NULL, 'MARKER, permanent, felt tip, bullet type, BLACK', '44121708-MP-B'),
(552, NULL, 'MARKER, permanent, felt tip, bullet type, BLUE', '44121708-MP-B'),
(553, NULL, 'MARKER, permanent, felt tip, bullet type, RED', '44121708-MP-B'),
(554, NULL, 'MARKER, whiteboard, felt tip, bullet type, Black', '44121708-MW-B'),
(555, NULL, 'MARKER, whiteboard, felt tip, bullet type, Blue', '44121708-MW-B'),
(556, NULL, 'MARKER, whiteboard, felt tip, bullet type, Red', '44121708-MW-B'),
(557, NULL, 'MONOBLOC CHAIR, beige', '56101504-CM-B'),
(558, NULL, 'MONOBLOC CHAIR, white', '56101504-CM-W'),
(559, NULL, 'MONOBLOC TABLE, beige', '56101519-TM-S'),
(560, NULL, 'MONOBLOC TABLE, white', '56101519-TM-S'),
(561, NULL, 'MOP BUCKET, heavy duty, hard plastic', '47121804-MP-B'),
(562, NULL, 'MOPHANDLE, heavy duty, screw type', '47131613-MP-H'),
(563, NULL, 'MOPHEAD, made of rayon', '47131619-MP-R'),
(564, NULL, 'MOUSE, OPTICAL, USB connection type', '43211708-MO-O'),
(565, NULL, 'MULTIMEDIA PROJECTOR, 4000 min', '45111609-MM-P'),
(566, NULL, 'NOTE PAD, stick on, 3\" x 3\"', '14111514-NP-S'),
(567, NULL, 'NOTE PAD, stick on, 50mm x 76mm (2\" x 3\") min', '14111514-NP-S'),
(568, NULL, 'NOTE PAD, stick on, 76mm x 100mm (3\" x 4\") min', '14111514-NP-S'),
(569, NULL, 'NOTEBOOK, stenographer', '14111514-NB-S'),
(570, NULL, 'PAD PAPER, ruled', '14111531-PP-R'),
(571, NULL, 'PAPER CLIP, vinyl/plastic coated, 33mm', '44122104-PC-G'),
(572, NULL, 'PAPER CLIP, vinyl/plastic coated, 50mm', '44122104-PC-J'),
(573, NULL, 'PAPER SHREDDER', '44101603-PS-M'),
(574, NULL, 'PAPER TRIMMER / CUTTING MACHINE, table top', '44101601-PT-M'),
(575, NULL, 'PAPER, Multi-Purpose, A4', '14111507-PP-C'),
(576, NULL, 'PAPER, Multi-Purpose, A4', '14111507-PP-C'),
(577, NULL, 'PAPER, Multi-Purpose, A4', '14111507-PP-C'),
(578, NULL, 'PAPER, multi-purpose, legal, 70gsm', '14111507-PP-C'),
(579, NULL, 'PAPER, MULTICOPY, A4, 80 gsm', '14111507-PP-M'),
(580, NULL, 'PAPER, MULTICOPY, Legal, 80gsm', '14111507-PP-M'),
(581, NULL, 'PAPER, parchment', '14111503-PA-P'),
(582, NULL, 'PENCIL SHARPENER, manual', '44121619-PS-M'),
(583, NULL, 'PENCIL, lead, with eraser', '44121706-PE-L'),
(584, NULL, 'PHILIPPINE NATIONAL FLAG', '55121905-PH-F'),
(585, NULL, 'POLYETHYLENE APRON, 50g', '42131601-PA-A'),
(586, NULL, 'PRINTER, impact, dot matrix, 24 pins, 136 columns', '43212102-PR-D'),
(587, NULL, 'PRINTER, impact, dot matrix, 9 pins', '43212102-PR-D'),
(588, NULL, 'PRINTER, Laser, Monochrome', '43212105-PR-L'),
(589, NULL, 'PROTECTIVE SAFETY GOGGLES', '46181804-GG-G'),
(590, NULL, 'PUNCHER, paper, heavy duty', '44101602-PU-P'),
(591, NULL, 'RAGS, all cotton', '47131501-RG-C'),
(592, NULL, 'RECORD BOOK, 300 pages', '14111531-RE-B'),
(593, NULL, 'RECORD BOOK, 500 pages', '14111531-RE-B'),
(594, NULL, 'RIBBON CART, EPSON C13S015516 (#8750), Black', '44103112-EP-R'),
(595, NULL, 'RIBBON CART, EPSON C13S015531 (S015086), Black', '44103112-EP-R'),
(596, NULL, 'RIBBON CART, EPSON C13S015632, Black', '44103112-EP-R'),
(597, NULL, 'RING BINDER, 32mm', '44122037-RB-P'),
(598, NULL, 'RUBBER BAND, No. 18', '44122101-RU-B'),
(599, NULL, 'RULER, plastic, 450mm', '41111604-RU-P'),
(600, NULL, 'SCISSORS, symmetrical / assymetrical', '44121618-SS-S'),
(601, NULL, 'SCOURING PAD', '47131602-SC-N'),
(602, NULL, 'SHOE COVER, disposable', '42131609-SC-S'),
(603, NULL, 'SIGN PEN, black', '60121524-SP-G'),
(604, NULL, 'SIGN PEN, blue', '60121524-SP-G'),
(605, NULL, 'SIGN PEN, red', '60121524-SP-G'),
(606, NULL, 'STAMP PAD INK, purple or violet', '12171703-SI-P'),
(607, NULL, 'STAMP PAD, felt', '44121905-SP-F'),
(608, NULL, 'STAPLE REMOVER, plier-type', '44121613-SR-P'),
(609, NULL, 'STAPLE WIRE, heavy duty, binder type, 23/13', '31151804-SW-H'),
(610, NULL, 'STAPLE WIRE, standard', '31151804-SW-S'),
(611, NULL, 'STAPLER, heavy duty, binder type', '44121615-ST-B'),
(612, NULL, 'STAPLER, standard type', '44121615-ST-S'),
(613, NULL, 'SURGICAL GOWN', '42131612-MS-G'),
(614, NULL, 'SURGICAL MASK, 3 ply', '42131713-SM-M'),
(615, NULL, 'TAPE DISPENSER, Table Top, for 24mm width tape', '44121605-TD-T'),
(616, NULL, 'TAPE, electrical', '31201502-TA-E'),
(617, NULL, 'TAPE, masking, 24mm', '31201503-TA-M'),
(618, NULL, 'TAPE, MASKING, 48mm', '31201503-TA-M'),
(619, NULL, 'TAPE, packaging, 48mm', '31201517-TA-P'),
(620, NULL, 'TAPE, transparent, 24mm', '31201512-TA-T'),
(621, NULL, 'TAPE, transparent, 48mm', '31201512-TA-T'),
(622, NULL, 'THERMAL PAPER, 216mm', '14111818-TH-P'),
(623, NULL, 'THERMOGUN', '41112224-TG-T'),
(624, NULL, 'TOILET TISSUE PAPER, 2-ply, 100% recycled', '14111704-TT-P'),
(625, NULL, 'TOILET TISSUE PAPER, Interfolded Paper Towel', '14111704-TT-P'),
(626, NULL, 'TONER CART, BROTHER TN-2025, Black', '44103103-BR-B'),
(627, NULL, 'TONER CART, BROTHER TN-2130, Black', '44103103-BR-B'),
(628, NULL, 'TONER CART, BROTHER TN-2150, Black', '44103103-BR-B'),
(629, NULL, 'TONER CART, BROTHER TN-3320, Black', '44103103-BR-B'),
(630, NULL, 'TONER CART, BROTHER TN-3350, Black', '44103103-BR-B'),
(631, NULL, 'TONER CART, BROTHER TN-3478, Black', '44103103-BR-B'),
(632, NULL, 'Toner Cart, Brother TN-456 BLACK, high yield 6500', '44103103-BR-B'),
(633, NULL, 'Toner Cart, Brother TN-456 CYAN, high yield 6500', '44103103-BR-C'),
(634, NULL, 'Toner Cart, Brother TN-456 MAGENTA, high yield', '44103103-BR-M'),
(635, NULL, 'Toner Cart, Brother TN-456 YELLOW, high yield 6500', '44103103-BR-Y'),
(636, NULL, 'TONER CART, CANON CRG 324 II', '44103103-CA-B'),
(637, NULL, 'TONER CART, HP CB435A, Black', '44103103-HP-B'),
(638, NULL, 'TONER CART, HP CB540A, Black', '44103103-HP-B'),
(639, NULL, 'TONER CART, HP CE255A, Black', '44103103-HP-B'),
(640, NULL, 'TONER CART, HP CE278A, Black', '44103103-HP-B'),
(641, NULL, 'TONER CART, HP CE285A (HP85A), Black', '44103103-HP-B'),
(642, NULL, 'TONER CART, HP CE310A, Black', '44103103-HP-B'),
(643, NULL, 'TONER CART, HP CE311A, Cyan', '44103103-HP-C'),
(644, NULL, 'TONER CART, HP CE312A, Yellow', '44103103-HP-Y'),
(645, NULL, 'TONER CART, HP CE313A, Magenta', '44103103-HP-M'),
(646, NULL, 'TONER CART, HP CE320A, Black', '44103103-HP-B'),
(647, NULL, 'TONER CART, HP CE321A, Cyan', '44103103-HP-C'),
(648, NULL, 'TONER CART, HP CE322A, Yellow', '44103103-HP-Y'),
(649, NULL, 'TONER CART, HP CE323A, Magenta', '44103103-HP-M'),
(650, NULL, 'TONER CART, HP CE390A, Black', '44103103-HP-B'),
(651, NULL, 'TONER CART, HP CE400A, Black', '44103103-HP-B'),
(652, NULL, 'TONER CART, HP CE401A, Cyan', '44103103-HP-C'),
(653, NULL, 'TONER CART, HP CE402A, Yellow', '44103103-HP-Y'),
(654, NULL, 'TONER CART, HP CE403A, Magenta', '44103103-HP-M'),
(655, NULL, 'TONER CART, HP CE410A, (HP305), Black', '44103103-HP-B'),
(656, NULL, 'TONER CART, HP CE411A, (HP305), Cyan', '44103103-HP-C'),
(657, NULL, 'TONER CART, HP CE412A, (HP305), Yellow', '44103103-HP-Y'),
(658, NULL, 'TONER CART, HP CE413A, (HP305), Magenta', '44103103-HP-M'),
(659, NULL, 'TONER CART, HP CE505A, Black', '44103103-HP-B'),
(660, NULL, 'TONER CART, HP CE505X, Black, high cap', '44103103-HX-B'),
(661, NULL, 'TONER CART, HP CF280XC, Black', '44103103-HP-B'),
(662, NULL, 'TONER CART, HP Q2612A, Black', '44103103-HP-B'),
(663, NULL, 'TONER CART, HP Q7553A, Black', '44103103-HP-B'),
(664, NULL, 'TONER CART, SAMSUNG ML-D2850B, Black', '44103103-SA-B'),
(665, NULL, 'TONER CART, SAMSUNG MLT-D101S, Black', '44103103-SA-B'),
(666, NULL, 'TONER CART, SAMSUNG MLT-D103S, Black', '44103103-SA-B'),
(667, NULL, 'TONER CART, SAMSUNG MLT-D104S, Black', '44103103-SA-B'),
(668, NULL, 'TONER CART, SAMSUNG MLT-D105L, Black', '44103103-SA-B'),
(669, NULL, 'TONER CART, Samsung MLT-D108S, Black', '44103103-SA-B'),
(670, NULL, 'TONER CART, Samsung MLT-D203E, Black', '44103103-SA-B'),
(671, NULL, 'TONER CART, Samsung MLT-D203L, Black', '44103103-SA-B'),
(672, NULL, 'TONER CART, Samsung MLT-D203U, Black', '44103103-SA-B'),
(673, NULL, 'TONER CART, SAMSUNG MLT-D205E, Black', '44103103-SA-B'),
(674, NULL, 'TONER CART, SAMSUNG MLT-D205L, Black', '44103103-SA-B'),
(675, NULL, 'TONER CART, SAMSUNG SCX-D6555A, Black', '44103103-SA-B'),
(676, NULL, 'Toner Cartridge, HP CF217A (HP17A) Black Laser Jet', '44103103-HP-B'),
(677, NULL, 'Toner Cartridge, HP CF226A (HP26A) Black LaserJet', '44103103-HP-B'),
(678, NULL, 'Toner Cartridge, HP CF280A, LaserJet Pro M401/M425', '44103103-HP-B'),
(679, NULL, 'Toner Cartridge, HP CF281A (HP81A) Black LaserJet', '44103103-HP-B'),
(680, NULL, 'Toner Cartridge, HP CF283A (HP83A) LaserJet Black', '44103103-HP-B'),
(681, NULL, 'Toner Cartridge, HP CF283XC (HP83X) Black LJ', '44103103-HX-B'),
(682, NULL, 'Toner Cartridge, HP CF287A (HP87) Black', '44103103-HP-B'),
(683, NULL, 'Toner Cartridge, HP CF325XC (HP25X) Black LaserJet', '44103103-HX-B'),
(684, NULL, 'Toner Cartridge, HP CF350A Black LJ', '44103103-HP-B'),
(685, NULL, 'Toner Cartridge, HP CF351A Cyan LJ', '44103103-HP-C'),
(686, NULL, 'Toner Cartridge, HP CF352A Yellow LJ', '44103103-HP-Y'),
(687, NULL, 'Toner Cartridge, HP CF353A Magenta LJ', '44103103-HP-M'),
(688, NULL, 'Toner Cartridge, HP CF360A (HP508A) Black LaserJet', '44103103-HP-B'),
(689, NULL, 'Toner Cartridge, HP CF361A (HP508A) Cyan LaserJet', '44103103-HP-C'),
(690, NULL, 'Toner Cartridge, HP CF362A (HP508A) Yellow', '44103103-HP-Y'),
(691, NULL, 'Toner Cartridge, HP CF363A (HP508A) Magenta', '44103103-HP-M'),
(692, NULL, 'Toner Cartridge, HP CF400A (HP201A) Black', '44103103-HP-B'),
(693, NULL, 'Toner Cartridge, HP CF401A (HP201A) Cyan', '44103103-HP-C'),
(694, NULL, 'Toner Cartridge, HP CF402A (HP201A) Yellow', '44103103-HP-Y'),
(695, NULL, 'Toner Cartridge, HP CF403A (HP201A) Magenta', '44103103-HP-M'),
(696, NULL, 'Toner Cartridge, HP CF410A (HP410A) black', '44103103-HP-B'),
(697, NULL, 'Toner Cartridge, HP CF410XC (HP410XC) black', '44103103-HX-B'),
(698, NULL, 'Toner Cartridge, HP CF411A (HP410A) cyan', '44103103-HP-C'),
(699, NULL, 'Toner Cartridge, HP CF411XC (HP410XC) cyan', '44103103-HX-C'),
(700, NULL, 'Toner Cartridge, HP CF412A (HP410A) yellow', '44103103-HP-Y'),
(701, NULL, 'Toner Cartridge, HP CF412XC (HP410XC) yellow', '44103103-HX-Y'),
(702, NULL, 'Toner Cartridge, HP CF413A (HP410A) magenta', '44103103-HP-M'),
(703, NULL, 'Toner Cartridge, HP CF413XC (HP410XC) magenta', '44103103-HX-M'),
(704, NULL, 'TRASHBAG', '47121701-TB-P'),
(705, NULL, 'TWINE, plastic', '31151507-TW-P'),
(706, NULL, 'WASTEBASKET, non-rigid plastic', '47121702-WB-P'),
(707, NULL, 'WRAPPING PAPER, kraft', '60121124-WR-P'),
(708, NULL, 'CCTV Camera Color Vue', NULL),
(709, NULL, 'UTP Box', NULL),
(710, NULL, 'adobe subscription', NULL),
(711, NULL, 'adobe subscription Software Subscription for Adobe Premiere Pro for enterprise', NULL),
(712, NULL, 'Software Subscription for Adobe Photoshop for enterprise', NULL),
(713, NULL, 'test', NULL),
(714, NULL, 'testing again', NULL),
(715, NULL, 'test1', NULL),
(716, NULL, 'test123', NULL),
(717, NULL, 'fuel for generator (diesel)', NULL),
(718, NULL, 'RJ 45', NULL),
(719, NULL, 'rj45 box', NULL),
(720, NULL, 'rj45 box 1/2', NULL),
(721, NULL, 'rudy 1234', NULL),
(722, NULL, 'meow12', NULL),
(723, NULL, 'SWITCH WITH 16 PORTS', NULL),
(724, NULL, 'MOLDERS', NULL),
(725, NULL, 'CCTV COLOR VU', NULL),
(726, NULL, 'sfsdfv', NULL),
(727, NULL, 'Bluetooth Speaker', NULL),
(728, NULL, 'Headlamp Flashlight', NULL),
(729, NULL, 'Microsoft Office 2019 Pro Plus Genuine With License Key', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `purchase_datas`
--

CREATE TABLE `purchase_datas` (
  `id` int(11) NOT NULL,
  `pr_id` bigint(20) NOT NULL,
  `transaction_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `product_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `specs` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `quantity` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `unit_id` int(11) NOT NULL,
  `price_item` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `subtotal` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `type` tinyint(4) NOT NULL DEFAULT 1 COMMENT '1=Purchase Transaction, 0=Purchase Retur',
  `date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `bidders_specs` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `winner_bidders_price` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `second_bidders_price` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `third_bidders_price` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_updated_by` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date_updated` timestamp NULL DEFAULT NULL,
  `remarks` varchar(500) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remarks_items` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remarks_status` int(11) NOT NULL DEFAULT 0 COMMENT '0-no remarks;1-remarks added; 2-remarks addressed',
  `is_removed` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `purchase_datas`
--

INSERT INTO `purchase_datas` (`id`, `pr_id`, `transaction_id`, `product_id`, `specs`, `quantity`, `unit_id`, `price_item`, `subtotal`, `type`, `date`, `bidders_specs`, `winner_bidders_price`, `second_bidders_price`, `third_bidders_price`, `last_updated_by`, `date_updated`, `remarks`, `remarks_items`, `remarks_status`, `is_removed`) VALUES
(1, 1, '2022-10-0001', '38', '', '12', 3, '1500', '18000', 1, '2023-08-18 03:05:38', 'sample specs', '1200', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(2, 1, '2022-10-0001', '708', '', '15', 3, '3500', '52500', 1, '2023-08-18 03:05:38', 'sample specs2', '1300', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(3, 2, '2022-10-0002', '710', 'Software Subscription for Adobe Acrobat Pro DC for Enterprise Level Deatil: Level 2 10-49 Coverage: 12 months\n', '11', 1, '15101', '166111', 1, '2023-08-23 05:41:27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', 0, 0),
(4, 2, '2022-10-0002', '711', 'Software Subscription for Adobe Premiere Pro for Enterprise Level Deatil: Level 2 10-49 Coverage: 12 months\n', '4', 1, '36406', '145624', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(5, 2, '2022-10-0002', '712', 'Software Subscription for Adobe Photoshop for Enterprise Level Deatil: Level 2 10-49 Coverage: 12 months\n', '3', 1, '36406', '109218', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(6, 3, '2022-10-0003', '1', 'asdcasdc', '1', 2, '1', '1', 1, '2023-08-18 03:05:38', 'adcasd', '6', '6', '6', NULL, NULL, NULL, NULL, 0, 0),
(7, 3, '2022-10-0003', '710', 'asdcasdc', '2', 2, '323', '646', 1, '2023-08-18 03:05:38', 'cas zx zx czxc zx czxc', '5', '5', '5', NULL, NULL, NULL, NULL, 0, 0),
(8, 4, '2022-10-0004', '717', 'Offered Quantity should not be less than 1,200 liters', '1', 2, '110400', '110400', 1, '2023-08-23 02:39:22', NULL, NULL, NULL, NULL, NULL, NULL, 'Trial Remarks if you may', '', 0, 0),
(9, 5, '2023-06-0005', '709', 'utp box 300 meters', '6', 4, '2500', '15000', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(10, 5, '2023-06-0005', '719', '100 pcs per box', '10', 4, '300', '3000', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(11, 5, '2023-06-0005', '723', 'COMPATIBLE TO THE EXISTING NETWORK INFRA', '6', 3, '50000', '300000', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, 'This is a sample comment', '', 0, 0),
(12, 5, '2023-06-0005', '724', 'TO HOUSE THE NETWORK CABLE AND SECURE FROM DAMAGE', '15', 6, '2000', '30000', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', 0, 0),
(13, 6, '2023-06-0006', '22', 'ASDASDC', '1', 1, '200', '200', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(14, 7, '2023-07-0007', '38', 'asdcascd', '1', 1, '123', '123', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(15, 8, '2023-07-0008', '38', 'zsdfvsdsdf', '2', 3, '1200', '2400', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(16, 8, '2023-07-0008', '399', 'zsdfvsdsdf', '1', 4, '1212', '1212', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(17, 9, '2023-07-0009', '38', 'SSD para bibo', '2', 1, '123', '246', 1, '2023-08-23 08:48:12', NULL, NULL, NULL, NULL, 'etraining', NULL, NULL, 'Sample remarks', 2, 0),
(18, 9, '2023-07-0009', '21', 'sdfsdfv', '2', 1, '12', '24', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(19, 9, '2023-07-0009', '51', 'cdvsdfvsdf', '4', 1, '1', '4', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(20, 9, '2023-07-0009', '42', 'wsdsdfvsdfvs', '6', 1, '10', '60', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(21, 9, '2023-07-0009', '3', 'wsdsdfxc zxc vsdfvs II', '8', 1, '4', '32', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, 'etraining', NULL, NULL, '', 0, 0),
(22, 9, '2023-07-0009', '401', 'zxc ', '10', 1, '22', '220', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(23, 9, '2023-07-0009', '405', 'sdcsadsd', '12', 1, '20', '240', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(24, 9, '2023-07-0009', '407', 'Matigas', '14', 1, '2', '28', 1, '2023-08-23 03:20:25', NULL, NULL, NULL, NULL, 'etraining', NULL, NULL, '', 0, 0),
(25, 9, '2023-07-0009', '49', '21sdfvsd', '16', 1, '23', '368', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(26, 9, '2023-07-0009', '33', 'sdfvsdfvsdf', '36', 1, '4', '144', 1, '2023-08-18 03:05:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1),
(27, 10, NULL, '712', 'CS 5', '6', 3, '4100', '24600', 1, '2023-08-29 06:43:37', NULL, NULL, NULL, NULL, 'iyquinonesjr', NULL, NULL, '', 2, 1),
(28, 10, NULL, '614', 'KF94', '100', 4, '35', '3500', 1, '2023-08-29 08:12:27', NULL, NULL, NULL, NULL, 'etraining', NULL, NULL, NULL, 2, 0),
(29, 10, '10', '38', 'WD para chuy', '3', 3, '2300', '6900', 1, '2023-08-29 08:10:21', NULL, NULL, NULL, NULL, 'etraining', NULL, NULL, NULL, 0, 0),
(30, 10, '10', '710', 'one time subs only', '3', 1, '1850', '5550', 1, '2023-08-29 08:12:17', NULL, NULL, NULL, NULL, 'etraining', NULL, NULL, NULL, 0, 0),
(31, 10, '10', '1', 'DELETE ME CHOYYYY', '100', 4, '10', '1000', 1, '2023-08-29 08:20:15', NULL, NULL, NULL, NULL, 'etraining', NULL, NULL, NULL, 2, 1),
(36, 12, '2023-09-0001', '38', 'Heavy Duty, anti shock and water proof', '5', 3, '4200', '21000', 1, '2023-09-07 06:03:18', NULL, NULL, NULL, NULL, 'etraining', NULL, NULL, '', 0, 0),
(37, 12, '2023-09-0001', '397', 'Heavy Duty, anti shock and water proof', '3', 3, '2132.9', '6398.7', 1, '2023-09-07 06:03:18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(38, 12, '2023-09-0001', '710', 'Subscribe now', '2', 3, '845.99', '1691.98', 1, '2023-09-07 06:03:18', NULL, NULL, NULL, NULL, 'etraining', NULL, NULL, NULL, 0, 0),
(39, 13, '2023-09-0002', '728', 'Spot light/flood light', '1', 3, '1210', '1210', 1, '2023-09-26 07:03:04', NULL, NULL, NULL, NULL, 'etraining', NULL, NULL, '', 0, 0),
(40, 14, '2023-10-0001', '398', 'with antibac at 500ml', '3', 7, '100', '300', 1, '2023-10-03 01:28:15', NULL, NULL, NULL, NULL, 'ncdublin', NULL, NULL, '', 0, 0),
(41, 15, '2023-10-0002', '729', 'One time license key. Not yearly subscription', '100', 3, '874.29', '87429', 1, '2023-10-16 17:48:20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', 0, 0),
(42, 15, '2023-10-0002', '712', 'One time license key. Not yearly subscription', '20', 3, '125.99', '2519.8', 1, '2023-10-16 17:48:20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0),
(43, 15, '2023-10-0002', '711', 'One time license key. Not yearly subscription', '70', 3, '155.34', '10873.8', 1, '2023-10-16 17:48:20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `purchase_transactions`
--

CREATE TABLE `purchase_transactions` (
  `id` bigint(20) NOT NULL,
  `transaction_id` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `total_pr_price` decimal(10,2) NOT NULL,
  `total_item` int(11) NOT NULL,
  `purpose` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `request_type_id` int(11) DEFAULT NULL,
  `code_uacs_pap` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `procurement_mode_id` int(11) DEFAULT NULL,
  `fund_source_id` int(11) DEFAULT NULL,
  `control_date_pr` timestamp NULL DEFAULT current_timestamp(),
  `date_created_pr` date DEFAULT NULL,
  `is_finished` tinyint(1) DEFAULT 0,
  `current_step` int(1) DEFAULT NULL,
  `receive_stat` tinyint(1) DEFAULT 0,
  `creator_id` int(11) DEFAULT NULL,
  `incoming_outgoing` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `return_receive_stat` tinyint(1) DEFAULT NULL,
  `delivery_term` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `delivery_venue` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `entity_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_abstract_final` tinyint(1) DEFAULT 0,
  `is_dropped` tinyint(1) DEFAULT 0,
  `is_editable` tinyint(1) DEFAULT 1,
  `is_checked` tinyint(1) DEFAULT 0,
  `is_approved` tinyint(1) DEFAULT 0,
  `last_updated_by` int(11) DEFAULT NULL,
  `enable_edit_by` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remarks` varchar(500) COLLATE utf8_unicode_ci DEFAULT NULL,
  `checked_finalized_by` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `owner_user_id` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `disabled_edit_by` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date_approved` date DEFAULT NULL,
  `approved_by` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `abstract_date_of_opening` date DEFAULT NULL,
  `winner_bidder` varchar(300) COLLATE utf8_unicode_ci DEFAULT NULL,
  `second_lowest_bidder` varchar(300) COLLATE utf8_unicode_ci DEFAULT NULL,
  `third_lowest_bidder` varchar(300) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_winner_bidder` varchar(500) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_second_lowest_bidder` varchar(500) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_third_lowest_bidder` varchar(500) COLLATE utf8_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `purchase_transactions`
--

INSERT INTO `purchase_transactions` (`id`, `transaction_id`, `total_pr_price`, `total_item`, `purpose`, `request_type_id`, `code_uacs_pap`, `procurement_mode_id`, `fund_source_id`, `control_date_pr`, `date_created_pr`, `is_finished`, `current_step`, `receive_stat`, `creator_id`, `incoming_outgoing`, `return_receive_stat`, `delivery_term`, `delivery_venue`, `entity_name`, `is_abstract_final`, `is_dropped`, `is_editable`, `is_checked`, `is_approved`, `last_updated_by`, `enable_edit_by`, `remarks`, `checked_finalized_by`, `owner_user_id`, `disabled_edit_by`, `date_approved`, `approved_by`, `abstract_date_of_opening`, `winner_bidder`, `second_lowest_bidder`, `third_lowest_bidder`, `address_winner_bidder`, `address_second_lowest_bidder`, `address_third_lowest_bidder`) VALUES
(1, '2022-10-0001', '70500.00', 27, 'erwe', 1, '12345', 1, 1, '2022-10-24 00:23:29', '2022-10-24', 0, NULL, 0, NULL, NULL, NULL, 'As soon as Receipt Received', 'Koronadal City', NULL, 0, 0, 0, 1, 1, NULL, NULL, NULL, '356a192b7913b04c54574d18c28d46e6395428ab', 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, '2022-11-02', '356a192b7913b04c54574d18c28d46e6395428ab', NULL, 'asd', 'asdasd', 'asd', 'asd', 'asd', 'asd'),
(2, '2022-10-0002', '420953.00', 18, 'for the use of ICTMS for the convenience of DSWD staff when using software applications at DSWD Field Office XII City of Koronadal', 5, '200000100001000', 7, 10, '2022-10-26 01:22:45', '2022-10-06', 0, NULL, 0, NULL, NULL, NULL, 'within 30 CALENDAR DAYS FROM RECEIPTS OF PURC', 'DSWD FO XII Koronadal City', NULL, 0, 0, 0, 0, 0, NULL, NULL, NULL, NULL, '77de68daecd823babbb58edb1c8e14d7106e83bb', '356a192b7913b04c54574d18c28d46e6395428ab', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(3, '2022-10-0003', '647.00', 3, 'asdcasc', 1, '123', 1, 1, '2022-10-27 00:45:41', '2022-10-26', 0, NULL, 0, NULL, NULL, NULL, 'asdc', 'asdc', NULL, 0, 0, 0, 1, 1, NULL, NULL, NULL, '356a192b7913b04c54574d18c28d46e6395428ab', 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, '2023-08-23', '1b6453892473a467d07372d45eb05abc2031647a', NULL, 'dsdfvsdf', 'sdfvsdfv', 'sdfv', 'sdfv', 'fvsdfv', 'sdfvsd'),
(4, '2022-10-0004', '110400.00', 1, 'for the use of ICTMS for Generator at DWD Field Office XII City of Koronadal', 6, '200000100001000', 7, 10, '2022-10-27 06:07:23', '2022-10-17', 0, NULL, 0, NULL, NULL, NULL, 'as per schedule', 'DSWD FO XII Koronadal City', NULL, 0, 0, 1, 0, 0, NULL, NULL, NULL, NULL, '77de68daecd823babbb58edb1c8e14d7106e83bb', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(5, '2023-06-0005', '348000.00', 37, 'structured cabling for Old regional Office', 5, '123', 7, 10, '2023-06-20 08:53:41', '2023-06-20', 0, NULL, 0, NULL, NULL, NULL, 'within 30 days upon receipt of pr', 'koronadal city', NULL, 0, 0, 0, 1, 1, NULL, NULL, NULL, '356a192b7913b04c54574d18c28d46e6395428ab', 'da4b9237bacccdf19c0760cab7aec4a8359010b0', '356a192b7913b04c54574d18c28d46e6395428ab', '2023-06-20', '356a192b7913b04c54574d18c28d46e6395428ab', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(6, '2023-06-0006', '200.00', 1, 'SADASD', 1, '12213', 1, 1, '2023-06-20 09:02:19', '2023-06-20', 0, NULL, 0, NULL, NULL, NULL, 'ASD', 'ASDC', NULL, 0, 0, 1, 0, 0, NULL, NULL, NULL, NULL, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(7, '2023-07-0007', '123.00', 1, 'asdcascd', 1, '123', 1, 1, '2023-07-03 07:28:46', '2023-07-03', 0, NULL, 0, NULL, NULL, NULL, 'within 30 days upon receipt of pr', 'koronadal city', NULL, 0, 0, 1, 0, 0, NULL, NULL, NULL, NULL, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(8, '2023-07-0008', '3612.00', 3, 'test', 1, '12345', 1, 1, '2023-07-04 02:24:52', '2023-07-04', 0, NULL, 0, NULL, NULL, NULL, 'within 30 days upon receipt of pr', 'koronadal city', NULL, 0, 0, 1, 0, 0, NULL, NULL, NULL, NULL, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(9, '2023-07-0009', '1366.00', 110, 'sdfvsdfvs', 1, '12213', 1, 1, '2023-07-04 04:12:14', '2023-07-03', 0, NULL, 0, NULL, NULL, NULL, 'within 30 days upon receipt of pr', 'koronadal city', NULL, 0, 0, 1, 0, 0, NULL, NULL, NULL, NULL, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(10, '2023-08-0001', '0.00', 0, 'This is a trial PR only.', 1, '1', 6, 10, '2023-08-23 05:55:40', '2023-08-23', 0, NULL, 0, NULL, NULL, NULL, 'Within 30 days upon receipt of pr', 'Koronadal City', NULL, 0, 0, 1, 1, 0, 2, '1b6453892473a467d07372d45eb05abc2031647a', NULL, '1b6453892473a467d07372d45eb05abc2031647a', 'da4b9237bacccdf19c0760cab7aec4a8359010b0', '1b6453892473a467d07372d45eb05abc2031647a', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(12, '2023-09-0001', '27398.70', 8, 'Trial Purpose', 1, '5', 1, 1, '2023-09-06 06:07:22', '2023-09-06', 0, NULL, 0, NULL, NULL, NULL, 'As soon as possible', 'DSWD Koronadal', NULL, 0, 0, 0, 1, 1, 2, NULL, NULL, '1b6453892473a467d07372d45eb05abc2031647a', 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, '2023-09-07', '1b6453892473a467d07372d45eb05abc2031647a', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(13, '2023-09-0002', '1210.00', 1, 'To be used by DSWD regional Field Office 12 for additional and Repairing of ICT equipment.', 5, '22', 6, 10, '2023-09-26 06:56:16', '2023-09-26', 0, NULL, 0, NULL, NULL, NULL, '45 days upon receipt of purchase order', 'DSWD Region XII - Koronadal City', NULL, 0, 0, 0, 1, 0, NULL, NULL, NULL, '1b6453892473a467d07372d45eb05abc2031647a', 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(14, '2023-10-0001', '300.00', 3, 'For the use of Procurement Section', 18, '88789', 6, 1, '2023-10-03 01:17:36', '2023-10-03', 0, NULL, 0, NULL, NULL, NULL, '10 days', 'dswd fo 12', NULL, 0, 0, 0, 1, 0, NULL, NULL, NULL, '902ba3cda1883801594b6e1b452790cc53948fda', 'c1dfd96eea8cc2b62785275bca38ac261256e278', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(15, '2023-10-0002', '100822.60', 190, 'Software Subscription for all the Laptops of Region 12', 5, '205', 1, 10, '2023-10-16 15:33:51', '2023-10-16', 0, NULL, 0, NULL, NULL, NULL, 'As soon as product is available', 'DSWD Region 12', NULL, 0, 0, 0, 1, 0, NULL, NULL, NULL, '1b6453892473a467d07372d45eb05abc2031647a', 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `remarks`
--

CREATE TABLE `remarks` (
  `id` bigint(20) NOT NULL,
  `track_id` varchar(100) DEFAULT NULL,
  `document_type` varchar(200) DEFAULT NULL,
  `remark` varchar(500) DEFAULT NULL,
  `dateSaved` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `request_types`
--

CREATE TABLE `request_types` (
  `id` int(11) NOT NULL,
  `request_type` varchar(100) DEFAULT NULL,
  `dateSaved` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `request_types`
--

INSERT INTO `request_types` (`id`, `request_type`, `dateSaved`) VALUES
(1, 'ADVERTISING / PRINTING / VIDEO AND PHOTO EDITING / PHOTOGRAPHY SERVICES ', '2022-07-07 06:45:10'),
(2, 'APPLIANCES ', '2022-07-07 06:45:10'),
(3, 'CATERING SERVICES AND MEETING FACILITIES ', '2022-07-07 06:45:10'),
(4, 'CATERING SERVICES ONLY (DELIVERY/PICK-UP) ', '2022-07-07 06:45:10'),
(5, 'EQUIPMENT (COMMUNICATION/INFORMATION TECHNOLOGY/OFFICE) ', '2022-07-07 06:45:10'),
(6, 'FUEL AND LUBRICANTS ', '2022-07-07 06:45:10'),
(7, 'FOOD ITEMS ', '2022-07-07 06:45:10'),
(8, 'GENERAL REPAIRS AND MAINTENANCE SERVICES ', '2022-07-07 06:45:10'),
(9, 'HOTEL ACCOMMODATION AND MEETING FACILITIES ', '2022-07-07 06:45:10'),
(10, 'MANPOWER SERVICES (JANITORIAL/COURIER/SECURITY) ', '2022-07-07 06:45:10'),
(11, 'NON-FOOD ITEMS ', '2022-07-07 06:45:10'),
(12, 'OFFICE FURNITURES ', '2022-07-07 06:45:10'),
(13, 'PARTS AND ACCESSORIES (VEHICLE) ', '2022-07-07 06:45:10'),
(14, 'RENTAL SERVICES (OFFICE/VEHICLE/WAREHOUSE) ', '2022-07-07 06:45:10'),
(15, 'SUPPLIES (HARDWARE/ELECTRICAL) ', '2022-07-07 06:45:10'),
(16, 'SUPPLIES (JANITORIAL) ', '2022-07-07 06:45:10'),
(17, 'SUPPLIES (MEDICAL/HYGIENE) ', '2022-07-07 06:45:10'),
(18, 'SUPPLIES (OFFICE/TRAINING) ', '2022-07-07 06:45:10');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `role` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `role`, `created_at`, `updated_at`) VALUES
(1, 'Super Admin', '2023-07-12 01:20:26', NULL),
(2, 'Admin', '2023-07-12 02:22:29', NULL),
(3, 'User', '2023-07-12 02:30:27', NULL),
(5, 'Procurement Cheker', '2023-07-12 02:51:09', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `role_permissions`
--

CREATE TABLE `role_permissions` (
  `id` bigint(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `role_permissions`
--

INSERT INTO `role_permissions` (`id`, `role_id`, `permission_id`, `created_at`) VALUES
(1, 1, 1, '2023-07-12 01:31:30'),
(14, 1, 2, '2023-07-13 07:57:49'),
(15, 2, 2, '2023-07-14 01:01:05'),
(16, 1, 5, '2023-07-27 00:58:11'),
(17, 1, 6, '2023-07-27 00:58:11'),
(18, 1, 7, '2023-07-27 00:59:12'),
(19, 5, 5, '2023-07-27 00:59:56'),
(20, 5, 6, '2023-07-27 00:59:56'),
(21, 1, 3, '2023-07-27 01:13:14'),
(23, 1, 4, '2023-07-27 01:17:40'),
(24, 1, 10, '2023-08-14 06:46:37'),
(25, 5, 7, '2023-08-15 01:09:37'),
(26, 5, 10, '2023-08-15 01:09:37');

-- --------------------------------------------------------

--
-- Table structure for table `sections`
--

CREATE TABLE `sections` (
  `id` int(11) NOT NULL,
  `section_name` varchar(100) DEFAULT NULL,
  `section_acronym` varchar(10) DEFAULT NULL,
  `s_division_id` int(11) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `savedBy` int(11) DEFAULT NULL,
  `savedDate` datetime DEFAULT NULL,
  `updatedBy` int(11) DEFAULT NULL,
  `updatedDate` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `sections`
--

INSERT INTO `sections` (`id`, `section_name`, `section_acronym`, `s_division_id`, `is_active`, `savedBy`, `savedDate`, `updatedBy`, `updatedDate`) VALUES
(2, 'Plans Division', 'PPD', 1, 1, 1, '2020-02-18 08:12:14', NULL, NULL),
(3, 'Information and Communication Technology Managment Section', 'ICTMS', 2, 1, 1, '2020-03-04 14:24:05', NULL, NULL),
(4, 'Unconditional Cash Transfer', 'UCT', 2, 1, 1, '2020-03-04 14:24:44', NULL, NULL),
(5, 'Personnel Section', 'PS', 1, 1, 1, '2020-03-04 14:25:18', NULL, NULL),
(6, 'Learning and Development Section', 'LDS', 1, 1, 1, '2020-03-04 14:25:35', NULL, NULL),
(7, 'SUPPLEMENTARY FEEDING PROGRAM', 'SFP', 4, 1, 2, '2020-10-14 11:49:55', NULL, NULL),
(8, 'PERSON WITH DISABILTY SECTION', 'PWD', 4, 1, 2, '2020-10-14 12:02:20', NULL, NULL),
(9, 'CRISIS INTERVENTION SECTION', 'CIS', 4, 1, 2, '2020-10-14 14:56:55', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `sub_tracks`
--

CREATE TABLE `sub_tracks` (
  `id` int(11) NOT NULL,
  `action_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `track_id` int(11) DEFAULT NULL,
  `received_by` int(11) DEFAULT NULL,
  `receive_stat` tinyint(1) DEFAULT 0,
  `remarks` varchar(500) DEFAULT NULL,
  `date_created` timestamp NOT NULL DEFAULT current_timestamp(),
  `date_received` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `tracks`
--

CREATE TABLE `tracks` (
  `id` int(11) NOT NULL,
  `pr_id` bigint(20) NOT NULL,
  `transaction_id` varchar(50) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `action_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `receive_stat` tinyint(1) DEFAULT 0,
  `received_by` varchar(100) DEFAULT NULL,
  `stat` varchar(20) DEFAULT NULL,
  `return_stat` tinyint(1) DEFAULT NULL,
  `return_receive_stat` tinyint(1) DEFAULT NULL,
  `date_created` timestamp NOT NULL DEFAULT current_timestamp(),
  `date_received` datetime DEFAULT NULL,
  `remarks` varchar(2000) DEFAULT NULL,
  `sent_by` varchar(100) DEFAULT NULL,
  `checking_routes` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `tracks`
--

INSERT INTO `tracks` (`id`, `pr_id`, `transaction_id`, `status`, `action_id`, `user_id`, `receive_stat`, `received_by`, `stat`, `return_stat`, `return_receive_stat`, `date_created`, `date_received`, `remarks`, `sent_by`, `checking_routes`) VALUES
(1, 1, '2022-10-0001', 'CHECKING', 14, NULL, 1, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', 'CURRENT', NULL, NULL, '2022-10-24 00:25:01', '2022-10-24 02:25:53', NULL, '356a192b7913b04c54574d18c28d46e6395428ab', 1),
(2, 1, '2022-10-0001', 'CHECKING', 14, NULL, 1, '356a192b7913b04c54574d18c28d46e6395428ab', NULL, NULL, NULL, '2022-10-24 00:25:59', '2022-10-24 03:02:22', NULL, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', 1),
(3, 1, '2022-10-0001', 'QUEUING', 11, NULL, 1, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, NULL, NULL, '2022-10-26 05:54:42', '2022-10-26 07:55:35', NULL, '356a192b7913b04c54574d18c28d46e6395428ab', 0),
(4, 3, '2022-10-0003', 'CHECKING', 14, NULL, 1, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, NULL, NULL, '2022-10-27 02:28:38', '2022-10-27 04:29:20', NULL, '356a192b7913b04c54574d18c28d46e6395428ab', 1),
(5, 3, '2022-10-0003', 'CHECKING', 14, NULL, 1, '356a192b7913b04c54574d18c28d46e6395428ab', NULL, NULL, NULL, '2022-10-27 02:29:27', '2022-10-27 04:41:42', NULL, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', 1),
(6, 5, '2023-06-0005', 'CHECKING', 14, NULL, 1, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, NULL, NULL, '2023-06-20 09:04:00', '2023-06-20 11:04:36', NULL, '356a192b7913b04c54574d18c28d46e6395428ab', 1),
(7, 5, '2023-06-0005', 'CHECKING', 14, NULL, 0, '356a192b7913b04c54574d18c28d46e6395428ab', NULL, NULL, NULL, '2023-06-20 09:04:50', NULL, NULL, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', 1),
(8, 9, '2023-07-0009', 'CHECKING', 14, NULL, 1, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, NULL, NULL, '2023-07-04 05:09:53', '2023-08-14 09:02:58', NULL, '356a192b7913b04c54574d18c28d46e6395428ab', 0),
(9, 9, '2023-07-0009', 'CHECKING', 14, NULL, 0, '356a192b7913b04c54574d18c28d46e6395428ab', NULL, NULL, NULL, '2023-08-14 07:03:09', NULL, NULL, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', 0),
(10, 10, '2023-08-0001', 'CHECKING', 14, NULL, 1, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, NULL, NULL, '2023-08-23 06:51:38', '2023-08-23 09:19:02', NULL, '1b6453892473a467d07372d45eb05abc2031647a', 1),
(12, 12, '2023-09-0001', 'CHECKING', 14, NULL, 1, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, NULL, NULL, '2023-09-06 07:54:02', '2023-09-07 04:04:11', NULL, '1b6453892473a467d07372d45eb05abc2031647a', 1),
(13, 12, '2023-09-0001', 'CHECKING', 14, NULL, 1, '1b6453892473a467d07372d45eb05abc2031647a', NULL, NULL, NULL, '2023-09-07 02:45:52', '2023-09-07 05:19:10', NULL, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', 1),
(14, 12, '2023-09-0001', 'QUEUING', 1, NULL, 0, '356a192b7913b04c54574d18c28d46e6395428ab', NULL, NULL, NULL, '2023-09-07 06:23:52', NULL, NULL, '1b6453892473a467d07372d45eb05abc2031647a', 0),
(17, 13, '2023-09-0002', 'CHECKING', 14, NULL, 1, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, NULL, NULL, '2023-09-26 06:58:40', '2023-09-26 08:59:14', NULL, '1b6453892473a467d07372d45eb05abc2031647a', 1),
(18, 13, '2023-09-0002', 'CHECKING', 14, NULL, 1, '1b6453892473a467d07372d45eb05abc2031647a', NULL, NULL, NULL, '2023-09-26 07:00:30', '2023-09-26 09:01:34', NULL, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', 1),
(19, 13, '2023-09-0002', 'QUEUING', 5, NULL, 0, '356a192b7913b04c54574d18c28d46e6395428ab', NULL, NULL, NULL, '2023-09-26 07:25:28', NULL, NULL, '1b6453892473a467d07372d45eb05abc2031647a', 0),
(20, 14, '2023-10-0001', 'CHECKING', 14, NULL, 1, 'c1dfd96eea8cc2b62785275bca38ac261256e278', NULL, NULL, NULL, '2023-10-03 01:20:11', '2023-10-03 03:20:46', NULL, '902ba3cda1883801594b6e1b452790cc53948fda', 1),
(21, 14, '2023-10-0001', 'CHECKING', 14, NULL, 1, '902ba3cda1883801594b6e1b452790cc53948fda', NULL, NULL, NULL, '2023-10-03 01:27:26', '2023-10-03 03:27:35', NULL, 'c1dfd96eea8cc2b62785275bca38ac261256e278', 1),
(22, 15, '2023-10-0002', 'CHECKING', 14, NULL, 1, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, NULL, NULL, '2023-10-16 17:23:52', '2023-10-16 19:39:58', NULL, '1b6453892473a467d07372d45eb05abc2031647a', 1),
(23, 15, '2023-10-0002', 'CHECKING', 14, NULL, 1, '1b6453892473a467d07372d45eb05abc2031647a', NULL, NULL, NULL, '2023-10-16 17:44:07', '2023-10-16 19:44:25', NULL, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', 1),
(24, 15, '2023-10-0002', 'QUEUING', 18, NULL, 1, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', NULL, NULL, NULL, '2023-10-16 18:27:37', '2023-10-16 21:07:38', NULL, '1b6453892473a467d07372d45eb05abc2031647a', 0),
(25, 15, '2023-10-0002', 'QUEUING', 18, NULL, 0, '1b6453892473a467d07372d45eb05abc2031647a', NULL, NULL, NULL, '2023-10-16 19:08:02', NULL, NULL, 'da4b9237bacccdf19c0760cab7aec4a8359010b0', 0);

-- --------------------------------------------------------

--
-- Table structure for table `transaction_logs`
--

CREATE TABLE `transaction_logs` (
  `id` tinyint(20) NOT NULL,
  `transaction` varchar(200) DEFAULT NULL,
  `track_id` varchar(200) DEFAULT NULL,
  `document_type` varchar(200) DEFAULT NULL,
  `user_id` tinyint(11) DEFAULT NULL,
  `dateSaved` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `units`
--

CREATE TABLE `units` (
  `id` int(11) NOT NULL,
  `unit` varchar(45) NOT NULL,
  `unit_description` varchar(100) NOT NULL,
  `date_created` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `units`
--

INSERT INTO `units` (`id`, `unit`, `unit_description`, `date_created`) VALUES
(1, 'pack', 'pack na pack2', '2022-04-20 14:10:30'),
(2, 'Lot', 'Lot na Lot', '2022-04-20 14:21:52'),
(3, 'Pc', 'Pieces', '2022-06-22 03:17:18'),
(4, 'BOX', '', '2023-06-20 07:57:40'),
(5, 'box2', '', '2023-06-20 08:02:22'),
(6, 'ROLLS', '', '2023-06-20 08:48:28'),
(7, 'bottle', '', '2023-10-03 01:16:27');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) NOT NULL,
  `idnumber` varchar(50) DEFAULT NULL,
  `lastname` varchar(50) DEFAULT NULL,
  `middlename` varchar(50) DEFAULT NULL,
  `firstname` varchar(50) DEFAULT NULL,
  `division_id` int(11) DEFAULT NULL,
  `username` varchar(20) NOT NULL,
  `password` varchar(100) NOT NULL,
  `role` varchar(20) NOT NULL,
  `photo_profile` varchar(255) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `contact_number` varchar(45) DEFAULT NULL,
  `bday` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `idnumber`, `lastname`, `middlename`, `firstname`, `division_id`, `username`, `password`, `role`, `photo_profile`, `email`, `contact_number`, `bday`) VALUES
(1, NULL, 'Salamanca', 'D', 'Rudy Mel', 1, 'rmdsalamanca', '', 'admin', './uploads_profile/rmdsalamanca.png', 'dondon011310@gmail.com', '', '0000-00-00'),
(2, NULL, 'a', 'a', 'a', 1, 'etraining', '', 'user', './uploads_profile/etraining.png', 'aaa@aaa.com', '', '0000-00-00'),
(3, NULL, 'OJARLIZA', 'S', 'EUNICE LAE', 1, 'elsojarliza', '', 'user', NULL, 'elsojarliza.fo12@dswd.gov.ph', '', '0000-00-00'),
(4, NULL, 'Quinones Jr', '', 'Ildefonso', 1, 'iyquinonesjr', '', 'admin', NULL, '', '', '0000-00-00'),
(5, NULL, 'Quinones Jr', '', 'Ildefonso', 1, 'iyquinonesjrasd', '', 'user', NULL, NULL, '09123456789', '2023-09-07'),
(6, NULL, 'DUBLIN', 'C', 'NEIL', 3, 'ncdublin', '', 'user', NULL, 'ncdublin@dswd.gov.ph', '', '0000-00-00'),
(7, NULL, 'Barambangan', 'R', 'Abdulquddus', 1, 'arbarambangan', '', 'admin', NULL, 'arbarambangan.fo12@dswd.gov.ph', '09952378184', '1986-05-07'),
(8, NULL, 'Quinones Jr', '', 'Ildefonso', 2, 'iyquinonesjruser', '', 'user', NULL, 'iyquinonesjr.fo12@dswd.gov.ph', '', '0000-00-00');

-- --------------------------------------------------------

--
-- Table structure for table `users_logs`
--

CREATE TABLE `users_logs` (
  `id` int(11) NOT NULL,
  `username` varchar(50) DEFAULT NULL,
  `activity` text DEFAULT NULL,
  `datetime` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users_logs`
--

INSERT INTO `users_logs` (`id`, `username`, `activity`, `datetime`) VALUES
(1, 'rmdsalamanca', 'UPDATE `purchase_datas` SET `bidders_specs` = \'sample specs\', `bidders_price` = \'1200\'\nWHERE sha1(id) = \'356a192b7913b04c54574d18c28d46e6395428ab\'', '2022-10-26 05:46:37'),
(2, 'rmdsalamanca', 'UPDATE `purchase_datas` SET `bidders_specs` = \'sample specs2\', `bidders_price` = \'1300\'\nWHERE sha1(id) = \'da4b9237bacccdf19c0760cab7aec4a8359010b0\'', '2022-10-26 05:47:07'),
(3, 'rmdsalamanca', 'UPDATE `purchase_transactions` SET `winner_bidder` = \'sdfvsdfv\', `second_lowest_bidder` = \'sdfvsdfv\', `third_lowest_bidder` = \'sdfvsdfv\', `address_winner_bidder` = \'sdfvsdfv\', `address_second_lowest_bidder` = \'sdfvsdvf\', `address_third_lowest_bidder` = \'sdfvsdfvsdfv\'\nWHERE `transaction_id` IS NULL', '2022-11-02 03:04:36'),
(4, 'rmdsalamanca', 'UPDATE `purchase_transactions` SET `winner_bidder` = \'asd\', `second_lowest_bidder` = \'asd\', `third_lowest_bidder` = \'asd\', `address_winner_bidder` = \'asdasd\', `address_second_lowest_bidder` = \'asd\', `address_third_lowest_bidder` = \'asd\'\nWHERE `transaction_id` IS NULL', '2022-11-02 03:10:01'),
(5, 'rmdsalamanca', 'UPDATE `purchase_transactions` SET `winner_bidder` = \'asd\', `second_lowest_bidder` = \'asdasd\', `third_lowest_bidder` = \'asd\', `address_winner_bidder` = \'asd\', `address_second_lowest_bidder` = \'asd\', `address_third_lowest_bidder` = \'asd\'\nWHERE `transaction_id` IS NULL', '2022-11-02 03:11:42'),
(6, 'rmdsalamanca', 'UPDATE `purchase_transactions` SET `winner_bidder` = \'asd\', `second_lowest_bidder` = \'asdasd\', `third_lowest_bidder` = \'asd\', `address_winner_bidder` = \'asd\', `address_second_lowest_bidder` = \'asd\', `address_third_lowest_bidder` = \'asd\'\nWHERE `transaction_id` IS NULL', '2022-11-02 03:12:47'),
(7, 'rmdsalamanca', 'UPDATE `purchase_transactions` SET `winner_bidder` = \'asd\', `second_lowest_bidder` = \'asdasd\', `third_lowest_bidder` = \'asd\', `address_winner_bidder` = \'asd\', `address_second_lowest_bidder` = \'asd\', `address_third_lowest_bidder` = \'asd\'\nWHERE `transaction_id` IS NULL', '2022-11-02 03:13:46'),
(8, 'rmdsalamanca', 'UPDATE `purchase_transactions` SET `winner_bidder` = \'asd\', `second_lowest_bidder` = \'asdasd\', `third_lowest_bidder` = \'asd\', `address_winner_bidder` = \'asd\', `address_second_lowest_bidder` = \'asd\', `address_third_lowest_bidder` = \'asd\'\nWHERE `transaction_id` IS NULL', '2022-11-02 03:14:56'),
(9, 'rmdsalamanca', 'UPDATE `purchase_transactions` SET `winner_bidder` = \'asd\', `second_lowest_bidder` = \'asdasd\', `third_lowest_bidder` = \'asd\', `address_winner_bidder` = \'asd\', `address_second_lowest_bidder` = \'asd\', `address_third_lowest_bidder` = \'asd\'\nWHERE `transaction_id` IS NULL', '2022-11-02 03:15:14'),
(10, 'rmdsalamanca', 'UPDATE `purchase_transactions` SET `winner_bidder` = \'asd\', `second_lowest_bidder` = \'asdasd\', `third_lowest_bidder` = \'asd\', `address_winner_bidder` = \'asd\', `address_second_lowest_bidder` = \'asd\', `address_third_lowest_bidder` = \'asd\'\nWHERE `transaction_id` IS NULL', '2022-11-02 03:15:19'),
(11, 'rmdsalamanca', 'UPDATE `purchase_transactions` SET `winner_bidder` = \'asd\', `second_lowest_bidder` = \'asdasd\', `third_lowest_bidder` = \'asd\', `address_winner_bidder` = \'asd\', `address_second_lowest_bidder` = \'asd\', `address_third_lowest_bidder` = \'asd\'\nWHERE `transaction_id` = \'2022-10-0001\'', '2022-11-02 03:17:22'),
(12, 'rmdsalamanca', 'UPDATE `purchase_transactions` SET `winner_bidder` = \'asd\', `second_lowest_bidder` = \'asdasd\', `third_lowest_bidder` = \'asd\', `address_winner_bidder` = \'asd\', `address_second_lowest_bidder` = \'asd\', `address_third_lowest_bidder` = \'asd\'\nWHERE `transaction_id` = \'2022-10-0001\'', '2022-11-02 03:17:41'),
(13, 'rmdsalamanca', 'UPDATE `purchase_transactions` SET `winner_bidder` = \'dsdfvsdf\', `second_lowest_bidder` = \'sdfvsdfv\', `third_lowest_bidder` = \'sdfv\', `address_winner_bidder` = \'sdfv\', `address_second_lowest_bidder` = \'fvsdfv\', `address_third_lowest_bidder` = \'sdfvsd\'\nWHERE `transaction_id` = \'2022-10-0003\'', '2022-11-02 03:48:51'),
(14, 'rmdsalamanca', 'SELECT *\nFROM `purchase_datas` `pd`\nJOIN `purchase_transactions` `pt` ON `pt`.`transaction_id` = `pd`.`transaction_id`\nWHERE sha1(pd.id) = \'da4b9237bacccdf19c0760cab7aec4a8359010b0\'', '2022-11-02 06:35:28'),
(15, 'rmdsalamanca', 'SELECT *\nFROM `purchase_datas` `pd`\nJOIN `purchase_transactions` `pt` ON `pt`.`transaction_id` = `pd`.`transaction_id`\nWHERE sha1(pd.id) = \'da4b9237bacccdf19c0760cab7aec4a8359010b0\'', '2022-11-02 06:37:43'),
(16, 'rmdsalamanca', 'SELECT *\nFROM `purchase_datas` `pd`\nJOIN `purchase_transactions` `pt` ON `pt`.`transaction_id` = `pd`.`transaction_id`\nWHERE sha1(pd.id) = \'da4b9237bacccdf19c0760cab7aec4a8359010b0\'', '2022-11-02 06:38:40'),
(17, 'rmdsalamanca', 'SELECT *\nFROM `purchase_datas` `pd`\nJOIN `purchase_transactions` `pt` ON `pt`.`transaction_id` = `pd`.`transaction_id`\nWHERE sha1(pd.id) = \'da4b9237bacccdf19c0760cab7aec4a8359010b0\'', '2022-11-02 06:53:24'),
(18, 'rmdsalamanca', 'SELECT *\nFROM `purchase_datas` `pd`\nJOIN `purchase_transactions` `pt` ON `pt`.`transaction_id` = `pd`.`transaction_id`\nWHERE sha1(pd.id) = \'da4b9237bacccdf19c0760cab7aec4a8359010b0\'', '2022-11-02 07:15:37'),
(19, 'rmdsalamanca', 'SELECT *\nFROM `purchase_datas` `pd`\nJOIN `purchase_transactions` `pt` ON `pt`.`transaction_id` = `pd`.`transaction_id`\nWHERE sha1(pd.id) = \'da4b9237bacccdf19c0760cab7aec4a8359010b0\'', '2022-11-02 07:16:35'),
(20, 'rmdsalamanca', 'SELECT *\nFROM `purchase_datas` `pd`\nJOIN `purchase_transactions` `pt` ON `pt`.`transaction_id` = `pd`.`transaction_id`\nWHERE sha1(pd.id) = \'da4b9237bacccdf19c0760cab7aec4a8359010b0\'', '2022-11-02 07:19:44'),
(21, 'rmdsalamanca', 'UPDATE `purchase_datas` SET `bidders_specs` = \'adcasd\', `winner_bidders_price` = \'12\', `second_bidders_price` = \'12\', `third_bidders_price` = \'12\'\nWHERE sha1(id) = \'c1dfd96eea8cc2b62785275bca38ac261256e278\'', '2022-11-02 07:25:18'),
(22, 'rmdsalamanca', 'UPDATE `purchase_datas` SET `bidders_specs` = \'cas zx zx czxc zx czxc\', `winner_bidders_price` = \'12\', `second_bidders_price` = \'13\', `third_bidders_price` = \'14\'\nWHERE sha1(id) = \'902ba3cda1883801594b6e1b452790cc53948fda\'', '2022-11-02 07:26:33'),
(23, 'rmdsalamanca', 'UPDATE `purchase_datas` SET `bidders_specs` = \'adcasd\', `winner_bidders_price` = \'15\', `second_bidders_price` = \'15\', `third_bidders_price` = \'5\'\nWHERE sha1(id) = \'c1dfd96eea8cc2b62785275bca38ac261256e278\'', '2022-11-02 07:29:41'),
(24, 'rmdsalamanca', 'UPDATE `purchase_datas` SET `bidders_specs` = \'adcasd\', `winner_bidders_price` = \'1\', `second_bidders_price` = \'1\', `third_bidders_price` = \'1\'\nWHERE sha1(id) = \'c1dfd96eea8cc2b62785275bca38ac261256e278\'', '2022-11-02 07:32:46'),
(25, 'rmdsalamanca', 'UPDATE `purchase_datas` SET `bidders_specs` = \'adcasd\', `winner_bidders_price` = \'2\', `second_bidders_price` = \'2\', `third_bidders_price` = \'2\'\nWHERE sha1(id) = \'c1dfd96eea8cc2b62785275bca38ac261256e278\'', '2022-11-02 07:34:57'),
(26, 'rmdsalamanca', 'UPDATE `purchase_datas` SET `bidders_specs` = \'adcasd\', `winner_bidders_price` = \'3\', `second_bidders_price` = \'3\', `third_bidders_price` = \'3\'\nWHERE sha1(id) = \'c1dfd96eea8cc2b62785275bca38ac261256e278\'', '2022-11-02 07:37:08'),
(27, 'rmdsalamanca', 'UPDATE `purchase_datas` SET `bidders_specs` = \'adcasd\', `winner_bidders_price` = \'4\', `second_bidders_price` = \'4\', `third_bidders_price` = \'4\'\nWHERE sha1(id) = \'c1dfd96eea8cc2b62785275bca38ac261256e278\'', '2022-11-02 07:38:33'),
(28, 'rmdsalamanca', 'UPDATE `purchase_datas` SET `bidders_specs` = \'cas zx zx czxc zx czxc\', `winner_bidders_price` = \'5\', `second_bidders_price` = \'5\', `third_bidders_price` = \'5\'\nWHERE sha1(id) = \'902ba3cda1883801594b6e1b452790cc53948fda\'', '2022-11-02 07:38:52'),
(29, 'rmdsalamanca', 'UPDATE `purchase_datas` SET `bidders_specs` = \'adcasd\', `winner_bidders_price` = \'6\', `second_bidders_price` = \'6\', `third_bidders_price` = \'6\'\nWHERE sha1(id) = \'c1dfd96eea8cc2b62785275bca38ac261256e278\'', '2022-11-02 08:56:09'),
(30, 'rmdsalamanca', 'UPDATE `purchase_transactions` SET `is_editable` = 0, `disabled_edit_by` = \'356a192b7913b04c54574d18c28d46e6395428ab\'\nWHERE `transaction_id` = \'2022-10-0002\'', '2023-06-20 07:00:34'),
(31, 'rmdsalamanca', 'UPDATE `purchase_transactions` SET `is_editable` = 0, `disabled_edit_by` = \'356a192b7913b04c54574d18c28d46e6395428ab\'\nWHERE `transaction_id` = \'2023-06-0005\'', '2023-06-20 09:03:55'),
(32, 'etraining', 'UPDATE `purchase_datas` SET `is_removed` = 1\nWHERE sha1(id) = \'887309d048beef83ad3eabf2a79a64a389ab1c9f\'UPDATE `purchase_transactions` SET `total_item` = \'73\', `total_pr_price` = \'1099\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-07-04 04:12:35'),
(33, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'407\', `specs` = \'f df e\', `quantity` = \'14\', `unit_id` = \'1\', `price_item` = \'2\', `subtotal` = 28, `last_updated_by` = \'iyquinonesjr\'\nWHERE sha1(id) = \'4d134bc072212ace2df385dae143139da74ec0ef\'UPDATE `purchase_transactions` SET `total_item` = \'109\', `total_pr_price` = \'1243\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-08-14 05:51:46'),
(34, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'38\', `specs` = \'sdfsdfv\', `quantity` = \'1\', `unit_id` = \'1\', `price_item` = \'123\', `subtotal` = 123, `last_updated_by` = \'iyquinonesjr\'\nWHERE sha1(id) = \'0716d9708d321ffb6a00818614779e779925365c\'UPDATE `purchase_transactions` SET `total_item` = \'109\', `total_pr_price` = \'1243\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-08-14 06:07:22'),
(35, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'38\', `specs` = \'sdfsdfv\', `quantity` = \'1\', `unit_id` = \'1\', `price_item` = \'123\', `subtotal` = 123, `last_updated_by` = \'iyquinonesjr\'\nWHERE sha1(id) = \'0716d9708d321ffb6a00818614779e779925365c\'UPDATE `purchase_transactions` SET `total_item` = \'109\', `total_pr_price` = \'1243\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-08-14 06:07:23'),
(36, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'38\', `specs` = \'sdfsdfv\', `quantity` = \'1\', `unit_id` = \'1\', `price_item` = \'123\', `subtotal` = 123, `last_updated_by` = \'iyquinonesjr\'\nWHERE sha1(id) = \'0716d9708d321ffb6a00818614779e779925365c\'UPDATE `purchase_transactions` SET `total_item` = \'109\', `total_pr_price` = \'1243\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-08-14 06:07:23'),
(37, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'38\', `specs` = \'sdfsdfv\', `quantity` = \'1\', `unit_id` = \'1\', `price_item` = \'123\', `subtotal` = 123, `last_updated_by` = \'iyquinonesjr\'\nWHERE sha1(id) = \'0716d9708d321ffb6a00818614779e779925365c\'UPDATE `purchase_transactions` SET `total_item` = \'109\', `total_pr_price` = \'1243\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-08-14 06:07:23'),
(38, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'38\', `specs` = \'sdfsdfv\', `quantity` = \'1\', `unit_id` = \'1\', `price_item` = \'123\', `subtotal` = 123, `last_updated_by` = \'iyquinonesjr\'\nWHERE sha1(id) = \'0716d9708d321ffb6a00818614779e779925365c\'UPDATE `purchase_transactions` SET `total_item` = \'109\', `total_pr_price` = \'1243\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-08-14 06:07:23'),
(39, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'38\', `specs` = \'sdfsdfv\', `quantity` = \'1\', `unit_id` = \'1\', `price_item` = \'123\', `subtotal` = 123, `last_updated_by` = \'iyquinonesjr\'\nWHERE sha1(id) = \'0716d9708d321ffb6a00818614779e779925365c\'UPDATE `purchase_transactions` SET `total_item` = \'109\', `total_pr_price` = \'1243\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-08-14 06:07:23'),
(40, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'38\', `specs` = \'sdfsdfv\', `quantity` = \'1\', `unit_id` = \'1\', `price_item` = \'123\', `subtotal` = 123, `last_updated_by` = \'iyquinonesjr\'\nWHERE sha1(id) = \'0716d9708d321ffb6a00818614779e779925365c\'UPDATE `purchase_transactions` SET `total_item` = \'109\', `total_pr_price` = \'1243\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-08-14 06:07:24'),
(41, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'38\', `specs` = \'sdfsdfv\', `quantity` = \'1\', `unit_id` = \'1\', `price_item` = \'123\', `subtotal` = 123, `last_updated_by` = \'iyquinonesjr\'\nWHERE sha1(id) = \'0716d9708d321ffb6a00818614779e779925365c\'UPDATE `purchase_transactions` SET `total_item` = \'109\', `total_pr_price` = \'1243\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-08-14 06:15:41'),
(42, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'38\', `specs` = \'sdfsdfv\', `quantity` = \'1\', `unit_id` = \'1\', `price_item` = \'123\', `subtotal` = 123, `last_updated_by` = \'iyquinonesjr\'\nWHERE sha1(id) = \'0716d9708d321ffb6a00818614779e779925365c\'UPDATE `purchase_transactions` SET `total_item` = \'109\', `total_pr_price` = \'1243\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-08-14 06:21:18'),
(43, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'38\', `specs` = \'sdfsdfv\', `quantity` = \'1\', `unit_id` = \'1\', `price_item` = \'123\', `subtotal` = 123, `last_updated_by` = \'iyquinonesjr\'\nWHERE sha1(id) = \'0716d9708d321ffb6a00818614779e779925365c\'UPDATE `purchase_transactions` SET `total_item` = \'109\', `total_pr_price` = \'1243\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-08-14 06:25:31'),
(44, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'38\', `specs` = \'SSD para bibo\', `quantity` = \'1\', `unit_id` = \'1\', `price_item` = \'123\', `subtotal` = 123, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'0716d9708d321ffb6a00818614779e779925365c\'UPDATE `purchase_transactions` SET `total_item` = \'109\', `total_pr_price` = \'1243\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-08-14 06:38:03'),
(45, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'3\', `specs` = \'wsdsdfxc zxc vsdfvs II\', `quantity` = \'8\', `unit_id` = \'1\', `price_item` = \'4\', `subtotal` = 32, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'472b07b9fcf2c2451e8781e944bf5f77cd8457c8\'UPDATE `purchase_transactions` SET `total_item` = \'109\', `total_pr_price` = \'1243\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-08-14 06:56:56'),
(46, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'407\', `specs` = \'Matigas\', `quantity` = \'14\', `unit_id` = \'1\', `price_item` = \'2\', `subtotal` = 28, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'4d134bc072212ace2df385dae143139da74ec0ef\'UPDATE `purchase_transactions` SET `total_item` = \'109\', `total_pr_price` = \'1243\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-08-14 06:57:55'),
(47, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'38\', `specs` = \'SSD para bibo\', `quantity` = \'1\', `unit_id` = \'1\', `price_item` = \'123\', `subtotal` = 123, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'0716d9708d321ffb6a00818614779e779925365c\'UPDATE `purchase_transactions` SET `total_item` = \'109\', `total_pr_price` = \'1243\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-08-14 07:01:43'),
(48, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:06:28'),
(49, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'10\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 41000, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:09:15'),
(50, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:10:59'),
(51, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'10\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 41000, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:12:01'),
(52, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:13:15'),
(53, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:14:43'),
(54, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:16:35'),
(55, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:17:29'),
(56, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:18:36'),
(57, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:21:51'),
(58, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:24:28'),
(59, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:27:26'),
(60, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:27:31'),
(61, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:27:35'),
(62, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:27:37'),
(63, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:27:49'),
(64, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:28:22'),
(65, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:29:10'),
(66, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:29:45'),
(67, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:30:18'),
(68, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:34:20'),
(69, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:34:22'),
(70, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:34:22'),
(71, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:34:22'),
(72, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:34:23'),
(73, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:34:23'),
(74, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:34:23'),
(75, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:34:23'),
(76, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:34:23'),
(77, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:34:42'),
(78, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:35:07'),
(79, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:35:37'),
(80, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:36:08'),
(81, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:39:02'),
(82, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'38\', `specs` = \'SSD para bibo\', `quantity` = \'2\', `unit_id` = \'1\', `price_item` = \'123\', `subtotal` = 246, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'0716d9708d321ffb6a00818614779e779925365c\'UPDATE `purchase_transactions` SET `total_item` = \'110\', `total_pr_price` = \'1366\'\nWHERE `transaction_id` = \'2023-07-0009\'', '2023-08-23 08:48:12'),
(83, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:53:08'),
(84, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'7\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 28700, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:54:51'),
(85, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:55:34'),
(86, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'7\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 28700, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:55:44'),
(87, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:56:28'),
(88, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:56:40'),
(89, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:57:33'),
(90, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:58:31'),
(91, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 20500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-08-23 08:59:26'),
(92, 'iyquinonesjr', 'UPDATE `purchase_transactions` SET `is_editable` = 1, `enable_edit_by` = \'1b6453892473a467d07372d45eb05abc2031647a\'\nWHERE `transaction_id` = \'2023-08-0001\'', '2023-08-29 03:06:27'),
(93, 'iyquinonesjr', 'UPDATE `purchase_transactions` SET `is_editable` = 0, `disabled_edit_by` = \'1b6453892473a467d07372d45eb05abc2031647a\'\nWHERE `transaction_id` = \'2023-08-0001\'', '2023-08-29 03:06:46'),
(94, 'iyquinonesjr', 'UPDATE `purchase_transactions` SET `is_editable` = 1, `enable_edit_by` = \'1b6453892473a467d07372d45eb05abc2031647a\'\nWHERE `transaction_id` = \'2023-08-0001\'', '2023-08-29 06:42:47'),
(95, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `product_id` = \'712\', `specs` = \'CS 5\', `quantity` = \'6\', `unit_id` = \'3\', `price_item` = \'4100\', `subtotal` = 24600, `last_updated_by` = \'iyquinonesjr\', `remarks_status` = 2\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'2023-08-0001\'', '2023-08-29 06:43:02'),
(96, 'iyquinonesjr', 'UPDATE `purchase_datas` SET `is_removed` = 1\nWHERE sha1(id) = \'bc33ea4e26e5e1af1408321416956113a4658763\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'2023-08-0001\'', '2023-08-29 06:43:37'),
(97, 'etraining', 'INSERT INTO `purchase_datas` (`pr_id`, `transaction_id`, `product_id`, `specs`, `quantity`, `unit_id`, `price_item`, `subtotal`, `last_updated_by`) VALUES (\'10\', \'10\', \'38\', \'WD para chuy\', \'3\', \'3\', \'2300\', 6900, \'etraining\')UPDATE `purchase_transactions` SET `total_item` = \'3\', `total_pr_price` = \'6900\'\nWHERE `transaction_id` = \'10\'', '2023-08-29 08:10:21'),
(98, 'etraining', 'INSERT INTO `purchase_datas` (`pr_id`, `transaction_id`, `product_id`, `specs`, `quantity`, `unit_id`, `price_item`, `subtotal`, `last_updated_by`) VALUES (\'10\', \'10\', \'710\', \'one time subs only\', \'3\', \'1\', \'1850\', 5550, \'etraining\')UPDATE `purchase_transactions` SET `total_item` = \'6\', `total_pr_price` = \'12450\'\nWHERE `transaction_id` = \'10\'', '2023-08-29 08:12:17'),
(99, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'614\', `specs` = \'KF94\', `quantity` = \'100\', `unit_id` = \'4\', `price_item` = \'35\', `subtotal` = 3500, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'0a57cb53ba59c46fc4b692527a38a87c78d84028\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'2023-08-0001\'', '2023-08-29 08:12:27'),
(100, 'etraining', 'INSERT INTO `purchase_datas` (`pr_id`, `transaction_id`, `product_id`, `specs`, `quantity`, `unit_id`, `price_item`, `subtotal`, `last_updated_by`) VALUES (\'10\', \'10\', \'1\', \'UPDATE ME CHOYYYY\', \'100\', \'4\', \'1\', 100, \'etraining\')UPDATE `purchase_transactions` SET `total_item` = \'106\', `total_pr_price` = \'12550\'\nWHERE `transaction_id` = \'10\'', '2023-08-29 08:18:26'),
(101, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'1\', `specs` = \'DELETE ME CHOYYYY\', `quantity` = \'100\', `unit_id` = \'4\', `price_item` = \'10\', `subtotal` = 1000, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'632667547e7cd3e0466547863e1207a8c0c0c549\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'2023-08-0001\'', '2023-08-29 08:19:52'),
(102, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'38\', `specs` = \'Heavy Duty, anti shock and water proof\', `quantity` = \'5\', `unit_id` = \'3\', `price_item` = \'4200\', `subtotal` = 21000, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'fc074d501302eb2b93e2554793fcaf50b3bf7291\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-09-07 01:29:15'),
(103, 'etraining', 'INSERT INTO `purchase_datas` (`pr_id`, `transaction_id`, `product_id`, `specs`, `quantity`, `unit_id`, `price_item`, `subtotal`, `last_updated_by`) VALUES (\'12\', \'12\', \'710\', \'Subscribe now\', \'2\', \'3\', \'845.99\', 1691.98, \'etraining\')UPDATE `purchase_transactions` SET `total_item` = \'2\', `total_pr_price` = \'1691.98\'\nWHERE `transaction_id` = \'12\'', '2023-09-07 01:54:21'),
(104, 'etraining', 'UPDATE `purchase_transactions` SET `purpose` = \'Whats the purpose? hehehe\', `request_type_id` = \'1\', `code_uacs_pap` = \'5\', `procurement_mode_id` = \'1\', `fund_source_id` = \'1\', `date_created_pr` = \'2023-09-06\', `delivery_term` = \'As soon as possible\', `delivery_venue` = \'DSWD Koronadal\', `last_updated_by` = \'2\'\nWHERE `id` = \'12\'', '2023-09-07 02:31:30'),
(105, 'etraining', 'UPDATE `purchase_transactions` SET `purpose` = \'I have no purpose in life :)\', `request_type_id` = \'2\', `code_uacs_pap` = \'6\', `procurement_mode_id` = \'1\', `fund_source_id` = \'10\', `date_created_pr` = \'2023-08-29\', `delivery_term` = \'Deliver matic\', `delivery_venue` = \'Koronadal CITY\', `last_updated_by` = \'2\'\nWHERE `id` = \'11\'', '2023-09-07 05:36:38'),
(106, 'etraining', 'UPDATE `purchase_transactions` SET `purpose` = \'This is a trial PR only.\', `request_type_id` = \'1\', `code_uacs_pap` = \'1\', `procurement_mode_id` = \'6\', `fund_source_id` = \'10\', `date_created_pr` = \'2023-08-23\', `delivery_term` = \'Within 30 days upon receipt of pr\', `delivery_venue` = \'Kanami Koronadal\', `last_updated_by` = \'2\'\nWHERE `id` = \'10\'', '2023-09-26 05:26:07'),
(107, 'etraining', 'UPDATE `purchase_transactions` SET `purpose` = \'This is a trial PR only.\', `request_type_id` = \'1\', `code_uacs_pap` = \'1\', `procurement_mode_id` = \'6\', `fund_source_id` = \'10\', `date_created_pr` = \'2023-08-23\', `delivery_term` = \'Within 30 days upon receipt of pr\', `delivery_venue` = \'Koronadal City\', `last_updated_by` = \'2\'\nWHERE `id` = \'10\'', '2023-09-26 05:26:23'),
(108, 'etraining', 'UPDATE `purchase_datas` SET `product_id` = \'728\', `specs` = \'Spot light/flood light\', `quantity` = \'1\', `unit_id` = \'3\', `price_item` = \'1210\', `subtotal` = 1210, `last_updated_by` = \'etraining\', `remarks_status` = 2\nWHERE sha1(id) = \'ca3512f4dfa95a03169c5a670a4c91a19b3077b4\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-09-26 07:00:05'),
(109, 'ncdublin', 'UPDATE `purchase_datas` SET `product_id` = \'398\', `specs` = \'with antibac at 500ml\', `quantity` = \'3\', `unit_id` = \'7\', `price_item` = \'100\', `subtotal` = 300, `last_updated_by` = \'ncdublin\', `remarks_status` = 2\nWHERE sha1(id) = \'af3e133428b9e25c55bc59fe534248e6a0c0f17b\'UPDATE `purchase_transactions` SET `total_item` = NULL, `total_pr_price` = NULL\nWHERE `transaction_id` = \'\'', '2023-10-03 01:21:20');

-- --------------------------------------------------------

--
-- Table structure for table `user_roles`
--

CREATE TABLE `user_roles` (
  `id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `user_roles`
--

INSERT INTO `user_roles` (`id`, `role_id`, `user_id`, `created_at`) VALUES
(8, 1, 4, '2023-07-14 01:38:43'),
(9, 3, 2, '2023-07-14 01:54:52'),
(10, 3, 3, '2023-07-14 01:55:04'),
(11, 1, 1, '2023-08-14 07:34:37'),
(12, 3, 6, '2023-10-03 01:11:09'),
(13, 2, 7, '2023-10-03 01:11:22'),
(14, 5, 7, '2023-10-03 01:11:29');

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_tracks`
-- (See below for the actual view)
--
CREATE TABLE `v_tracks` (
`id` int(11)
,`sub_track_id` int(11)
,`sub_track_action` int(11)
,`user_id` int(11)
,`transaction_id` varchar(50)
,`purpose` varchar(255)
,`a` varchar(150)
,`b` varchar(150)
,`receive_stat_tracks` tinyint(1)
,`return_action_category` varchar(20)
,`actions` varchar(303)
,`remarks` text
,`received_stat` tinyint(4)
,`receive_stat_sub_tracks` int(1)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_transactions`
-- (See below for the actual view)
--
CREATE TABLE `v_transactions` (
`id` int(11)
,`sub_track_id` int(11)
,`sub_track_action` int(11)
,`user_id` int(11)
,`transaction_id` varchar(50)
,`purpose` varchar(255)
,`a` varchar(150)
,`b` varchar(150)
,`receive_stat_tracks` tinyint(1)
,`return_action_category` varchar(20)
,`category` varchar(20)
,`track_date_received` datetime
,`track_date_created` timestamp
,`actions` varchar(303)
,`remarks` text
,`received_stat` tinyint(4)
,`receive_stat_sub_tracks` int(1)
);

-- --------------------------------------------------------

--
-- Structure for view `v_tracks`
--
DROP TABLE IF EXISTS `v_tracks`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_tracks`  AS  (select `tracks`.`id` AS `id`,`sub_tracks`.`id` AS `sub_track_id`,`sub_tracks`.`action_id` AS `sub_track_action`,`tracks`.`user_id` AS `user_id`,`purchase_transactions`.`transaction_id` AS `transaction_id`,`purchase_transactions`.`purpose` AS `purpose`,`proc1`.`actions` AS `a`,`proc2`.`actions` AS `b`,`tracks`.`receive_stat` AS `receive_stat_tracks`,`proc2`.`category` AS `return_action_category`,case when `proc2`.`actions` is null then `proc1`.`actions` else concat(`proc1`.`actions`,' - ',`proc2`.`actions`) end AS `actions`,case when `proc2`.`actions` is null then `tracks`.`remarks` else `sub_tracks`.`remarks` end AS `remarks`,case when `sub_tracks`.`receive_stat` is null then `tracks`.`receive_stat` else `sub_tracks`.`receive_stat` end AS `received_stat`,case when `sub_tracks`.`receive_stat` is null then 0 else 1 end AS `receive_stat_sub_tracks` from ((((`purchase_transactions` join `tracks` on(`purchase_transactions`.`transaction_id` = `tracks`.`transaction_id`)) left join (select `sub_tracks`.`id` AS `id`,`sub_tracks`.`action_id` AS `action_id`,`sub_tracks`.`track_id` AS `track_id`,`sub_tracks`.`received_by` AS `received_by`,`sub_tracks`.`receive_stat` AS `receive_stat`,`sub_tracks`.`remarks` AS `remarks` from `sub_tracks` where `sub_tracks`.`id` in (select max(`sub_tracks`.`id`) from `sub_tracks` group by `sub_tracks`.`track_id`)) `sub_tracks` on(`sub_tracks`.`track_id` = `tracks`.`id`)) left join `proc_actions` `proc1` on(`tracks`.`action_id` = `proc1`.`id`)) left join `proc_actions` `proc2` on(`sub_tracks`.`action_id` = `proc2`.`id`)) where `tracks`.`stat` = 'CURRENT' and `purchase_transactions`.`is_dropped` is true order by `tracks`.`id` desc) ;

-- --------------------------------------------------------

--
-- Structure for view `v_transactions`
--
DROP TABLE IF EXISTS `v_transactions`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_transactions`  AS  (select `tracks`.`id` AS `id`,`sub_tracks`.`id` AS `sub_track_id`,`sub_tracks`.`action_id` AS `sub_track_action`,`tracks`.`user_id` AS `user_id`,`purchase_transactions`.`transaction_id` AS `transaction_id`,`purchase_transactions`.`purpose` AS `purpose`,`proc1`.`actions` AS `a`,`proc2`.`actions` AS `b`,`tracks`.`receive_stat` AS `receive_stat_tracks`,`proc2`.`category` AS `return_action_category`,`proc1`.`category` AS `category`,`tracks`.`date_received` AS `track_date_received`,`tracks`.`date_created` AS `track_date_created`,case when `proc2`.`actions` is null then `proc1`.`actions` else concat(`proc1`.`actions`,' - ',`proc2`.`actions`) end AS `actions`,case when `proc2`.`actions` is null then `tracks`.`remarks` else `sub_tracks`.`remarks` end AS `remarks`,case when `sub_tracks`.`receive_stat` is null then `tracks`.`receive_stat` else `sub_tracks`.`receive_stat` end AS `received_stat`,case when `sub_tracks`.`receive_stat` is null then 0 else 1 end AS `receive_stat_sub_tracks` from ((((`purchase_transactions` join `tracks` on(`purchase_transactions`.`transaction_id` = `tracks`.`transaction_id`)) left join (select `sub_tracks`.`id` AS `id`,`sub_tracks`.`action_id` AS `action_id`,`sub_tracks`.`track_id` AS `track_id`,`sub_tracks`.`received_by` AS `received_by`,`sub_tracks`.`receive_stat` AS `receive_stat`,`sub_tracks`.`remarks` AS `remarks` from `sub_tracks` where `sub_tracks`.`id` in (select max(`sub_tracks`.`id`) from `sub_tracks` group by `sub_tracks`.`track_id`)) `sub_tracks` on(`sub_tracks`.`track_id` = `tracks`.`id`)) left join `proc_actions` `proc1` on(`tracks`.`action_id` = `proc1`.`id`)) left join `proc_actions` `proc2` on(`sub_tracks`.`action_id` = `proc2`.`id`)) where `tracks`.`stat` = 'CURRENT' and `purchase_transactions`.`is_dropped` is not true order by `tracks`.`id` desc) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `annotations`
--
ALTER TABLE `annotations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pr_id` (`pr_id`);
ALTER TABLE `annotations` ADD FULLTEXT KEY `transaction_id` (`transaction_id`);

--
-- Indexes for table `divisions`
--
ALTER TABLE `divisions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `savedBy` (`savedBy`),
  ADD KEY `updatedBy` (`updatedBy`);

--
-- Indexes for table `documents`
--
ALTER TABLE `documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `savedBy` (`savedBy`);

--
-- Indexes for table `dv_amounts`
--
ALTER TABLE `dv_amounts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tr_id` (`tr_id`);

--
-- Indexes for table `fund_sources`
--
ALTER TABLE `fund_sources`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `hr_transactions`
--
ALTER TABLE `hr_transactions`
  ADD PRIMARY KEY (`id`,`document_type`),
  ADD KEY `savedBy` (`savedBy`),
  ADD KEY `document_type_id` (`document_type`);

--
-- Indexes for table `ob_amounts_count`
--
ALTER TABLE `ob_amounts_count`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tr_id` (`tr_id`);

--
-- Indexes for table `payees`
--
ALTER TABLE `payees`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `procurement_modes`
--
ALTER TABLE `procurement_modes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `proc_actions`
--
ALTER TABLE `proc_actions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `purchase_datas`
--
ALTER TABLE `purchase_datas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pr_id` (`pr_id`);
ALTER TABLE `purchase_datas` ADD FULLTEXT KEY `transaction_id` (`transaction_id`);

--
-- Indexes for table `purchase_transactions`
--
ALTER TABLE `purchase_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`),
  ADD UNIQUE KEY `transaction_id` (`transaction_id`);
ALTER TABLE `purchase_transactions` ADD FULLTEXT KEY `enable_edit_by` (`enable_edit_by`,`checked_finalized_by`,`owner_user_id`,`disabled_edit_by`);

--
-- Indexes for table `remarks`
--
ALTER TABLE `remarks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `request_types`
--
ALTER TABLE `request_types`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `role_id` (`role_id`),
  ADD KEY `permission_id` (`permission_id`);

--
-- Indexes for table `sections`
--
ALTER TABLE `sections`
  ADD PRIMARY KEY (`id`),
  ADD KEY `division_id` (`s_division_id`),
  ADD KEY `savedBy` (`savedBy`),
  ADD KEY `updatedBy` (`updatedBy`);

--
-- Indexes for table `sub_tracks`
--
ALTER TABLE `sub_tracks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tracks`
--
ALTER TABLE `tracks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pr_id` (`pr_id`),
  ADD KEY `transaction_id` (`transaction_id`),
  ADD KEY `transaction_id_2` (`transaction_id`),
  ADD KEY `pr_id_2` (`pr_id`);

--
-- Indexes for table `transaction_logs`
--
ALTER TABLE `transaction_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `units`
--
ALTER TABLE `units`
  ADD PRIMARY KEY (`id`);
ALTER TABLE `units` ADD FULLTEXT KEY `unit` (`unit`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users_logs`
--
ALTER TABLE `users_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `role_id` (`role_id`),
  ADD KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `annotations`
--
ALTER TABLE `annotations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `divisions`
--
ALTER TABLE `divisions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `documents`
--
ALTER TABLE `documents`
  MODIFY `id` tinyint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `dv_amounts`
--
ALTER TABLE `dv_amounts`
  MODIFY `id` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `fund_sources`
--
ALTER TABLE `fund_sources`
  MODIFY `id` tinyint(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `hr_transactions`
--
ALTER TABLE `hr_transactions`
  MODIFY `id` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `ob_amounts_count`
--
ALTER TABLE `ob_amounts_count`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `payees`
--
ALTER TABLE `payees`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `procurement_modes`
--
ALTER TABLE `procurement_modes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `proc_actions`
--
ALTER TABLE `proc_actions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=730;

--
-- AUTO_INCREMENT for table `purchase_datas`
--
ALTER TABLE `purchase_datas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT for table `purchase_transactions`
--
ALTER TABLE `purchase_transactions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `remarks`
--
ALTER TABLE `remarks`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `request_types`
--
ALTER TABLE `request_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `role_permissions`
--
ALTER TABLE `role_permissions`
  MODIFY `id` bigint(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `sections`
--
ALTER TABLE `sections`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `sub_tracks`
--
ALTER TABLE `sub_tracks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tracks`
--
ALTER TABLE `tracks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `transaction_logs`
--
ALTER TABLE `transaction_logs`
  MODIFY `id` tinyint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `units`
--
ALTER TABLE `units`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `users_logs`
--
ALTER TABLE `users_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=110;

--
-- AUTO_INCREMENT for table `user_roles`
--
ALTER TABLE `user_roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `annotations`
--
ALTER TABLE `annotations`
  ADD CONSTRAINT `annotations_ibfk_1` FOREIGN KEY (`pr_id`) REFERENCES `purchase_transactions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `purchase_datas`
--
ALTER TABLE `purchase_datas`
  ADD CONSTRAINT `purchase_datas_ibfk_1` FOREIGN KEY (`pr_id`) REFERENCES `purchase_transactions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD CONSTRAINT `role_permissions_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `role_permissions_ibfk_3` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tracks`
--
ALTER TABLE `tracks`
  ADD CONSTRAINT `tracks_ibfk_1` FOREIGN KEY (`pr_id`) REFERENCES `purchase_transactions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_roles_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
