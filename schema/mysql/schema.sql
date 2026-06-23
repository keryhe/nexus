CREATE TABLE `Category` (
    `Id`          INT          NOT NULL AUTO_INCREMENT,
    `Name`        VARCHAR(255) NOT NULL,
    `DisplayName` VARCHAR(255) NOT NULL,
    `SortOrder`   INT          NOT NULL DEFAULT 0,
    `SectionType` VARCHAR(100) NOT NULL DEFAULT 'Card',
    `ParentId`    INT          NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_Category_Parent`        FOREIGN KEY (`ParentId`) REFERENCES `Category` (`Id`),
    CONSTRAINT `UQ_Category_ParentId_Name` UNIQUE (`ParentId`, `Name`)
);

-- MySQL does not support partial indexes, so triggers enforce uniqueness of Name at the root level (ParentId IS NULL).
DELIMITER $$

CREATE TRIGGER `trg_Category_RootName_Insert`
BEFORE INSERT ON `Category`
FOR EACH ROW
BEGIN
    IF NEW.`ParentId` IS NULL THEN
        IF EXISTS (SELECT 1 FROM `Category` WHERE `ParentId` IS NULL AND `Name` = NEW.`Name`) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A root-level Category with this Name already exists.';
        END IF;
    END IF;
END$$

CREATE TRIGGER `trg_Category_RootName_Update`
BEFORE UPDATE ON `Category`
FOR EACH ROW
BEGIN
    IF NEW.`ParentId` IS NULL THEN
        IF EXISTS (SELECT 1 FROM `Category` WHERE `ParentId` IS NULL AND `Name` = NEW.`Name` AND `Id` != NEW.`Id`) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A root-level Category with this Name already exists.';
        END IF;
    END IF;
END$$

DELIMITER ;

CREATE TABLE `Section` (
    `Id`          INT          NOT NULL AUTO_INCREMENT,
    `Name`        VARCHAR(255) NOT NULL,
    `DisplayName` VARCHAR(255) NOT NULL,
    `SortOrder`   INT          NOT NULL DEFAULT 0,
    `SectionType` VARCHAR(100) NOT NULL DEFAULT 'Card',
    `ParentId`    INT          NULL,
    `CategoryId`  INT          NOT NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_Section_Parent`        FOREIGN KEY (`ParentId`)   REFERENCES `Section`  (`Id`),
    CONSTRAINT `FK_Section_Category`      FOREIGN KEY (`CategoryId`) REFERENCES `Category` (`Id`),
    CONSTRAINT `UQ_Section_ParentId_Name` UNIQUE (`ParentId`, `Name`)
);

-- MySQL does not support partial indexes, so triggers enforce uniqueness of Name at the root level (ParentId IS NULL).
DELIMITER $$

CREATE TRIGGER `trg_Section_RootName_Insert`
BEFORE INSERT ON `Section`
FOR EACH ROW
BEGIN
    IF NEW.`ParentId` IS NULL THEN
        IF EXISTS (SELECT 1 FROM `Section` WHERE `ParentId` IS NULL AND `Name` = NEW.`Name`) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A root-level Section with this Name already exists.';
        END IF;
    END IF;
END$$

CREATE TRIGGER `trg_Section_RootName_Update`
BEFORE UPDATE ON `Section`
FOR EACH ROW
BEGIN
    IF NEW.`ParentId` IS NULL THEN
        IF EXISTS (SELECT 1 FROM `Section` WHERE `ParentId` IS NULL AND `Name` = NEW.`Name` AND `Id` != NEW.`Id`) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A root-level Section with this Name already exists.';
        END IF;
    END IF;
END$$

DELIMITER ;

CREATE TABLE `DropdownList` (
    `Id`   INT          NOT NULL AUTO_INCREMENT,
    `Name` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `UQ_DropdownList_Name` UNIQUE (`Name`)
);

CREATE TABLE `DropdownListItem` (
    `Id`             INT          NOT NULL AUTO_INCREMENT,
    `Name`           VARCHAR(255) NOT NULL,
    `Value`          VARCHAR(255) NOT NULL,
    `SortOrder`      INT          NOT NULL DEFAULT 0,
    `DropdownListId` INT          NOT NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_DropdownListItem_DropdownList` FOREIGN KEY (`DropdownListId`) REFERENCES `DropdownList` (`Id`)
);

CREATE TABLE `Config` (
    `Id`             INT          NOT NULL AUTO_INCREMENT,
    `Name`           VARCHAR(255) NOT NULL,
    `DisplayName`    VARCHAR(255) NOT NULL,
    `SortOrder`      INT          NOT NULL DEFAULT 0,
    `DataType`       VARCHAR(100) NOT NULL,
    `Value`          TEXT         NULL,
    `IsEncrypted`    TINYINT(1)   NOT NULL DEFAULT 0,
    `SectionId`      INT          NOT NULL,
    `DropdownListId` INT          NULL,
    `CreatedAt`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `UpdatedAt`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_Config_Section`      FOREIGN KEY (`SectionId`)      REFERENCES `Section`      (`Id`),
    CONSTRAINT `FK_Config_DropdownList` FOREIGN KEY (`DropdownListId`) REFERENCES `DropdownList` (`Id`)
);
