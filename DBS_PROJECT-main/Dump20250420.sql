CREATE DATABASE  IF NOT EXISTS `inv_man` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `inv_man`;
-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: inv_man
-- ------------------------------------------------------
-- Server version	8.0.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin` (
  `AID` int NOT NULL,
  `Aname` varchar(100) DEFAULT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`AID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin`
--

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
INSERT INTO `admin` VALUES (1,'John Admin','555-1234'),(2,'Sarah Manager','555-5678'),(3,'Mike Supervisor','555-9012');
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branch`
--

DROP TABLE IF EXISTS `branch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `branch` (
  `BranchID` int NOT NULL,
  `Bname` varchar(100) DEFAULT NULL,
  `InventoryID` int DEFAULT NULL,
  PRIMARY KEY (`BranchID`),
  KEY `InventoryID` (`InventoryID`),
  CONSTRAINT `branch_ibfk_1` FOREIGN KEY (`InventoryID`) REFERENCES `inventory` (`InventoryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch`
--

LOCK TABLES `branch` WRITE;
/*!40000 ALTER TABLE `branch` DISABLE KEYS */;
INSERT INTO `branch` VALUES (1,'North Branch',1),(2,'South Branch',2),(3,'East Branch',3),(4,'West Branch',4);
/*!40000 ALTER TABLE `branch` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery`
--

DROP TABLE IF EXISTS `delivery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery` (
  `DeliveryID` int NOT NULL AUTO_INCREMENT,
  `Address` varchar(200) DEFAULT NULL,
  `PinCode` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`DeliveryID`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery`
--

LOCK TABLES `delivery` WRITE;
/*!40000 ALTER TABLE `delivery` DISABLE KEYS */;
INSERT INTO `delivery` VALUES (1,'123 Main St, Apt 4B','10001'),(2,'456 Oak Ave','20002'),(3,'789 Pine Rd','30003'),(4,'101 Hero Blvd','40004'),(7,'Haryana','122001'),(8,'Haryana','122001');
/*!40000 ALTER TABLE `delivery` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee`
--

DROP TABLE IF EXISTS `employee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee` (
  `EID` int NOT NULL,
  `Ename` varchar(100) DEFAULT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`EID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee`
--

LOCK TABLES `employee` WRITE;
/*!40000 ALTER TABLE `employee` DISABLE KEYS */;
INSERT INTO `employee` VALUES (1,'David Employee','555-1122'),(2,'Emma Worker','555-3344'),(3,'Frank Staff','555-5566'),(4,'Grace Helper','555-7788');
/*!40000 ALTER TABLE `employee` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory` (
  `InventoryID` int NOT NULL,
  `Itemname` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`InventoryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` VALUES (1,'Electronics Stock'),(2,'Clothing Stock'),(3,'Books Stock'),(4,'Home Goods Stock');
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoice`
--

DROP TABLE IF EXISTS `invoice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoice` (
  `InvoiceID` int NOT NULL AUTO_INCREMENT,
  `OrderNo` int DEFAULT NULL,
  `UserID` int DEFAULT NULL,
  PRIMARY KEY (`InvoiceID`),
  UNIQUE KEY `OrderNo` (`OrderNo`),
  KEY `UserID` (`UserID`),
  CONSTRAINT `invoice_ibfk_1` FOREIGN KEY (`OrderNo`) REFERENCES `orders` (`OrderNo`),
  CONSTRAINT `invoice_ibfk_2` FOREIGN KEY (`UserID`) REFERENCES `users` (`userID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoice`
--

LOCK TABLES `invoice` WRITE;
/*!40000 ALTER TABLE `invoice` DISABLE KEYS */;
INSERT INTO `invoice` VALUES (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,7,8),(7,8,8);
/*!40000 ALTER TABLE `invoice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `location` (
  `DeliveryID` int NOT NULL,
  `City` varchar(100) NOT NULL,
  `Street` varchar(100) NOT NULL,
  `Country` varchar(100) DEFAULT NULL,
  `Cname` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`DeliveryID`,`City`,`Street`),
  CONSTRAINT `location_ibfk_1` FOREIGN KEY (`DeliveryID`) REFERENCES `delivery` (`DeliveryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `location`
--

LOCK TABLES `location` WRITE;
/*!40000 ALTER TABLE `location` DISABLE KEYS */;
INSERT INTO `location` VALUES (1,'New York','Main St','USA','Alice Johnson'),(2,'Los Angeles','Oak Ave','USA','Bob Smith'),(3,'Chicago','Pine Rd','USA','Charlie Brown'),(4,'Miami','Hero Blvd','USA','Diana Prince'),(7,'gurgaon','Haryana','india','Ab Devillers'),(8,'gurgaon','Haryana','india','Ab Devillers');
/*!40000 ALTER TABLE `location` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_delivery`
--

DROP TABLE IF EXISTS `order_delivery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_delivery` (
  `OrderNo` int NOT NULL,
  `DeliveryID` int NOT NULL,
  PRIMARY KEY (`OrderNo`,`DeliveryID`),
  KEY `DeliveryID` (`DeliveryID`),
  CONSTRAINT `order_delivery_ibfk_1` FOREIGN KEY (`OrderNo`) REFERENCES `orders` (`OrderNo`),
  CONSTRAINT `order_delivery_ibfk_2` FOREIGN KEY (`DeliveryID`) REFERENCES `delivery` (`DeliveryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_delivery`
--

LOCK TABLES `order_delivery` WRITE;
/*!40000 ALTER TABLE `order_delivery` DISABLE KEYS */;
INSERT INTO `order_delivery` VALUES (1,1),(5,1),(2,2),(3,3),(4,4),(7,7),(8,8);
/*!40000 ALTER TABLE `order_delivery` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `OrderNo` int NOT NULL AUTO_INCREMENT,
  `Date` date DEFAULT NULL,
  `Amount` decimal(10,2) DEFAULT NULL,
  `userID` int DEFAULT NULL,
  `EmployeeID` int DEFAULT NULL,
  `InventoryID` int DEFAULT NULL,
  PRIMARY KEY (`OrderNo`),
  KEY `EmployeeID` (`EmployeeID`),
  KEY `InventoryID` (`InventoryID`),
  KEY `orders_ibfk_1` (`userID`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `users` (`userID`),
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`EmployeeID`) REFERENCES `employee` (`EID`),
  CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`InventoryID`) REFERENCES `inventory` (`InventoryID`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,'2025-04-10',1049.98,1,1,1),(2,'2025-04-13',1499.99,2,2,1),(3,'2025-04-15',99.97,3,3,3),(4,'2025-04-18',329.98,4,4,4),(5,'2025-04-19',249.98,5,1,2),(7,'2025-04-20',4899.95,8,1,1),(8,'2025-04-20',149.97,8,1,1);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `PID` int NOT NULL,
  `Pname` varchar(100) DEFAULT NULL,
  `Category` varchar(50) DEFAULT NULL,
  `Price` decimal(10,2) DEFAULT NULL,
  `OrderNo` int DEFAULT NULL,
  `SupID` int DEFAULT NULL,
  `StorageID` int DEFAULT NULL,
  PRIMARY KEY (`PID`),
  KEY `OrderNo` (`OrderNo`),
  KEY `SupID` (`SupID`),
  KEY `StorageID` (`StorageID`),
  CONSTRAINT `product_ibfk_1` FOREIGN KEY (`OrderNo`) REFERENCES `orders` (`OrderNo`),
  CONSTRAINT `product_ibfk_2` FOREIGN KEY (`SupID`) REFERENCES `supplier` (`SupID`),
  CONSTRAINT `product_ibfk_3` FOREIGN KEY (`StorageID`) REFERENCES `storage` (`StorageID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (1,'iPhone 13','Electronics',999.99,7,1,1),(2,'Samsung Galaxy S21','Electronics',899.99,7,1,1),(3,'MacBook Pro','Electronics',1499.99,2,1,2),(4,'Dell XPS 15','Electronics',1299.99,NULL,1,2),(5,'Men\'s Basic T-shirt','Clothing',19.99,5,2,3),(6,'Women\'s Blouse','Clothing',29.99,NULL,2,3),(7,'Slim Fit Jeans','Clothing',49.99,8,2,4),(8,'Casual Dress Pants','Clothing',59.99,NULL,2,4),(9,'The Great Gatsby','Books',12.99,3,3,5),(10,'To Kill a Mockingbird','Books',14.99,3,3,5),(11,'How to Cook Everything','Books',24.99,NULL,3,6),(12,'The Art of War','Books',9.99,3,3,6),(13,'Stand Mixer','Home Goods',249.99,4,4,7),(14,'Blender','Home Goods',79.99,NULL,4,7),(15,'Queen Sheet Set','Home Goods',39.99,4,4,8),(16,'Down Comforter','Home Goods',89.99,NULL,4,8),(17,'B.S. Grewal','Books',10.00,NULL,3,6),(18,'Asus Tuf A15','Electronics',1000.00,NULL,1,2);
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `storage`
--

DROP TABLE IF EXISTS `storage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `storage` (
  `StorageID` int NOT NULL,
  `Sitem` varchar(100) DEFAULT NULL,
  `Quantity` int DEFAULT NULL,
  PRIMARY KEY (`StorageID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `storage`
--

LOCK TABLES `storage` WRITE;
/*!40000 ALTER TABLE `storage` DISABLE KEYS */;
INSERT INTO `storage` VALUES (1,'Smartphones',95),(2,'Laptops',30),(3,'T-shirts',100),(4,'Jeans',77),(5,'Fiction Books',200),(6,'Non-fiction Books',150),(7,'Kitchen Appliances',40),(8,'Bedding',60);
/*!40000 ALTER TABLE `storage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier`
--

DROP TABLE IF EXISTS `supplier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supplier` (
  `SupID` int NOT NULL,
  `Sname` varchar(100) DEFAULT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`SupID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier`
--

LOCK TABLES `supplier` WRITE;
/*!40000 ALTER TABLE `supplier` DISABLE KEYS */;
INSERT INTO `supplier` VALUES (1,'Tech Suppliers Inc.','555-9900'),(2,'Fashion Wholesale','555-8800'),(3,'Book Distributors','555-7700'),(4,'Home Essentials Co.','555-6600');
/*!40000 ALTER TABLE `supplier` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `userID` int NOT NULL AUTO_INCREMENT,
  `Password` varchar(255) DEFAULT NULL,
  `Cname` varchar(100) DEFAULT NULL,
  `Address` varchar(200) DEFAULT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `AdminID` int DEFAULT NULL,
  PRIMARY KEY (`userID`),
  KEY `AdminID` (`AdminID`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`AdminID`) REFERENCES `admin` (`AID`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'password123','Alice Johnson','123 Main St, Apt 4B','555-1111','alice@example.com',1),(2,'password123','Bob Smith','456 Oak Ave','555-2222','bob@example.com',NULL),(3,'password123','Charlie Brown','789 Pine Rd','555-3333','charlie@example.com',NULL),(4,'password123','Diana Prince','101 Hero Blvd','555-4444','diana@example.com',NULL),(5,'password123','Edward Norton','202 Actor St','555-5555','edward@example.com',NULL),(6,'adminpass','Admin User','Admin Office','555-0000','admin@example.com',2),(7,'scrypt:32768:8:1$Df8bMb6nOs0jFGKg$e36298f108631a07e7859bb271450e872e3e6b9cefd553c0aa91c1ecead4a99ec3669613cdebfb6ad50516bb5defc8788697cea4eb12de8e10dfb2433abf9b83','Abhigyan Singh','lukhnow','987654','abhi@gmail.com',NULL),(8,'scrypt:32768:8:1$5BVnFXCxAjUZwuN0$ba6d4a1d647abcf83799c0180238f5d24e8d88b627d2cd8c0b20a4adb19bc666b085761b8c8e0d0bec43e7b683f8da800406ed6e38a21d7e7bd98389c8cbe456','Ab Devillers','Haryana','9876543','Abd@gmail.com',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-20 22:45:15
