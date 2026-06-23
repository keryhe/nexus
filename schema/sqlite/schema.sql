-- SQLite does not enforce foreign keys by default.
-- Run "PRAGMA foreign_keys = ON;" in each connection to enable enforcement.

CREATE TABLE "Category" (
    "Id"          INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name"        TEXT         NOT NULL,
    "DisplayName" TEXT         NOT NULL,
    "SortOrder"   INTEGER      NOT NULL DEFAULT 0,
    "SectionType" TEXT         NOT NULL DEFAULT 'Card',
    "ParentId"    INTEGER      NULL,
    CONSTRAINT "FK_Category_Parent"        FOREIGN KEY ("ParentId") REFERENCES "Category" ("Id"),
    CONSTRAINT "UQ_Category_ParentId_Name" UNIQUE ("ParentId", "Name")
);

CREATE TABLE "Section" (
    "Id"          INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name"        TEXT         NOT NULL,
    "DisplayName" TEXT         NOT NULL,
    "SortOrder"   INTEGER      NOT NULL DEFAULT 0,
    "SectionType" TEXT         NOT NULL DEFAULT 'Card',
    "ParentId"    INTEGER      NULL,
    "CategoryId"  INTEGER      NOT NULL,
    CONSTRAINT "FK_Section_Parent"        FOREIGN KEY ("ParentId")   REFERENCES "Section"  ("Id"),
    CONSTRAINT "FK_Section_Category"      FOREIGN KEY ("CategoryId") REFERENCES "Category" ("Id"),
    CONSTRAINT "UQ_Section_ParentId_Name" UNIQUE ("ParentId", "Name")
);

-- Partial indexes enforce uniqueness of Name at the root level (ParentId IS NULL),
-- since standard UNIQUE constraints treat each NULL as distinct.
CREATE UNIQUE INDEX "UQ_Category_RootName" ON "Category" ("Name") WHERE "ParentId" IS NULL;
CREATE UNIQUE INDEX "UQ_Section_RootName"  ON "Section"  ("Name") WHERE "ParentId" IS NULL;

CREATE TABLE "DropdownList" (
    "Id"   INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name" TEXT         NOT NULL,
    CONSTRAINT "UQ_DropdownList_Name" UNIQUE ("Name")
);

CREATE TABLE "DropdownListItem" (
    "Id"             INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name"           TEXT         NOT NULL,
    "Value"          TEXT         NOT NULL,
    "SortOrder"      INTEGER      NOT NULL DEFAULT 0,
    "DropdownListId" INTEGER      NOT NULL,
    CONSTRAINT "FK_DropdownListItem_DropdownList" FOREIGN KEY ("DropdownListId") REFERENCES "DropdownList" ("Id")
);

CREATE TABLE "Config" (
    "Id"             INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name"           TEXT         NOT NULL,
    "DisplayName"    TEXT         NOT NULL,
    "SortOrder"      INTEGER      NOT NULL DEFAULT 0,
    "DataType"       TEXT         NOT NULL,
    "Value"          TEXT         NULL,
    "IsEncrypted"    INTEGER      NOT NULL DEFAULT 0,  -- 0 = false, 1 = true
    "SectionId"      INTEGER      NOT NULL,
    "DropdownListId" INTEGER      NULL,
    "CreatedAt"      TEXT         NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    "UpdatedAt"      TEXT         NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    CONSTRAINT "FK_Config_Section"      FOREIGN KEY ("SectionId")      REFERENCES "Section"      ("Id"),
    CONSTRAINT "FK_Config_DropdownList" FOREIGN KEY ("DropdownListId") REFERENCES "DropdownList" ("Id")
);
