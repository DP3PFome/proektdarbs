-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: May 11, 2026 at 06:05 PM
-- Server version: 8.4.3
-- PHP Version: 8.3.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pakalpojums_kolekcionariem`
--

-- --------------------------------------------------------

--
-- Table structure for table `administrator`
--

CREATE TABLE `administrator` (
  `adminID` varchar(12) NOT NULL,
  `adminName` varchar(40) DEFAULT NULL,
  `adminEmail` varchar(40) DEFAULT NULL,
  `adminPhone` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `administrator`
--

INSERT INTO `administrator` (`adminID`, `adminName`, `adminEmail`, `adminPhone`) VALUES
('A001', 'Admin1', 'admin1@site.com', '+37120000001'),
('A002', 'Admin2', 'admin2@site.com', '+37120000002');

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

CREATE TABLE `category` (
  `categoryId` varchar(12) NOT NULL,
  `nosaukums` varchar(30) NOT NULL,
  `apraksts` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`categoryId`, `nosaukums`, `apraksts`) VALUES
('C001', 'Monētas', 'Dažādu valstu un periodu kolekciju monētas'),
('C002', 'Markas', 'Pasaules pastmarkas no dažādiem gadiem'),
('C003', 'Figūriņas', 'Kolekcionējamas figūras un modeļi');

-- --------------------------------------------------------

--
-- Table structure for table `collection`
--

CREATE TABLE `collection` (
  `collectionId` varchar(12) NOT NULL,
  `title` varchar(50) NOT NULL,
  `description` varchar(150) DEFAULT NULL,
  `creationDate` date DEFAULT NULL,
  `ownerId` varchar(12) DEFAULT NULL,
  `categoryId` varchar(12) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `collection`
--

INSERT INTO `collection` (`collectionId`, `title`, `description`, `creationDate`, `ownerId`, `categoryId`) VALUES
('COL001', 'Reto monētu krājums', 'Kolekcija ar retām Eiropas monētām', '2022-01-15', 'U001', 'C001'),
('COL002', 'Anime figūriņas', 'Japānas anime varoņu figūras', '2023-03-21', 'U002', 'C003'),
('COL003', 'Pasaules markas', 'Dažādu valstu pastmarkas', '2021-11-07', 'U003', 'C002');

-- --------------------------------------------------------

--
-- Table structure for table `comments`
--

CREATE TABLE `comments` (
  `commentId` varchar(12) NOT NULL,
  `content` varchar(300) DEFAULT NULL,
  `author` varchar(12) DEFAULT NULL,
  `itemId` varchar(12) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `comments`
--

INSERT INTO `comments` (`commentId`, `content`, `author`, `itemId`) VALUES
('COM001', 'Ļoti interesanta monēta!', 'U002', 'I001'),
('COM002', 'Man arī ir šī figūra, lieliska kvalitāte!', 'U003', 'I002'),
('COM003', 'Retā markā, labi saglabājusies.', 'U001', 'I003');

-- --------------------------------------------------------

--
-- Table structure for table `image`
--

CREATE TABLE `image` (
  `imageId` varchar(12) NOT NULL,
  `url` varchar(150) DEFAULT NULL,
  `uploadDate` date DEFAULT NULL,
  `itemId` varchar(12) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `image`
--

INSERT INTO `image` (`imageId`, `url`, `uploadDate`, `itemId`) VALUES
('IMG001', 'images/moneta1.jpg', '2024-01-05', 'I001'),
('IMG002', 'images/figura1.jpg', '2024-02-11', 'I002'),
('IMG003', 'images/marka1.jpg', '2024-03-02', 'I003');

-- --------------------------------------------------------

--
-- Table structure for table `item`
--

CREATE TABLE `item` (
  `itemId` varchar(12) NOT NULL,
  `nosaukums` varchar(40) DEFAULT NULL,
  `apraksts` varchar(150) DEFAULT NULL,
  `gads` year DEFAULT NULL,
  `estimatedValue` double DEFAULT NULL,
  `collectionId` varchar(12) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `item`
--

INSERT INTO `item` (`itemId`, `nosaukums`, `apraksts`, `gads`, `estimatedValue`, `collectionId`) VALUES
('I001', '1 Euro 2004', 'Grieķijas 1€ 2004. gada monēta', '2004', 15.5, 'COL001'),
('I002', 'Naruto figūriņa', 'Naruto Shippuden kolekcijas modelis', '2018', 45, 'COL002'),
('I003', 'ASV pastmarka', 'Amerikas 1995. gada pastmarka', '1995', 5.25, 'COL003');

-- --------------------------------------------------------

--
-- Table structure for table `klients`
--

CREATE TABLE `klients` (
  `userID` varchar(12) NOT NULL,
  `userName` varchar(30) NOT NULL,
  `userEmail` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `klients`
--

INSERT INTO `klients` (`userID`, `userName`, `userEmail`) VALUES
('U001', 'Janis', 'janis@example.com'),
('U002', 'Laura', 'laura@example.com'),
('U003', 'Markus', 'markus@example.com');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `administrator`
--
ALTER TABLE `administrator`
  ADD PRIMARY KEY (`adminID`);

--
-- Indexes for table `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`categoryId`);

--
-- Indexes for table `collection`
--
ALTER TABLE `collection`
  ADD PRIMARY KEY (`collectionId`),
  ADD KEY `ownerId` (`ownerId`),
  ADD KEY `categoryId` (`categoryId`);

--
-- Indexes for table `comments`
--
ALTER TABLE `comments`
  ADD PRIMARY KEY (`commentId`),
  ADD KEY `author` (`author`),
  ADD KEY `itemId` (`itemId`);

--
-- Indexes for table `image`
--
ALTER TABLE `image`
  ADD PRIMARY KEY (`imageId`),
  ADD KEY `itemId` (`itemId`);

--
-- Indexes for table `item`
--
ALTER TABLE `item`
  ADD PRIMARY KEY (`itemId`),
  ADD KEY `collectionId` (`collectionId`);

--
-- Indexes for table `klients`
--
ALTER TABLE `klients`
  ADD PRIMARY KEY (`userID`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `collection`
--
ALTER TABLE `collection`
  ADD CONSTRAINT `collection_ibfk_1` FOREIGN KEY (`ownerId`) REFERENCES `klients` (`userID`),
  ADD CONSTRAINT `collection_ibfk_2` FOREIGN KEY (`categoryId`) REFERENCES `category` (`categoryId`);

--
-- Constraints for table `comments`
--
ALTER TABLE `comments`
  ADD CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`author`) REFERENCES `klients` (`userID`),
  ADD CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`itemId`) REFERENCES `item` (`itemId`);

--
-- Constraints for table `image`
--
ALTER TABLE `image`
  ADD CONSTRAINT `image_ibfk_1` FOREIGN KEY (`itemId`) REFERENCES `item` (`itemId`);

--
-- Constraints for table `item`
--
ALTER TABLE `item`
  ADD CONSTRAINT `item_ibfk_1` FOREIGN KEY (`collectionId`) REFERENCES `collection` (`collectionId`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
