CREATE TABLE "Category" (
    "Id"          SERIAL       NOT NULL,
    "Name"        VARCHAR(255) NOT NULL,
    "DisplayName" VARCHAR(255) NOT NULL,
    "SortOrder"   INT          NOT NULL DEFAULT 0,
    "SectionType" VARCHAR(100) NOT NULL DEFAULT 'Card',
    "ParentId"    INT          NULL,
    PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Category_Parent"        FOREIGN KEY ("ParentId") REFERENCES "Category" ("Id"),
    CONSTRAINT "UQ_Category_ParentId_Name" UNIQUE ("ParentId", "Name")
);

CREATE TABLE "Section" (
    "Id"          SERIAL       NOT NULL,
    "Name"        VARCHAR(255) NOT NULL,
    "DisplayName" VARCHAR(255) NOT NULL,
    "SortOrder"   INT          NOT NULL DEFAULT 0,
    "SectionType" VARCHAR(100) NOT NULL DEFAULT 'Card',
    "ParentId"    INT          NULL,
    "CategoryId"  INT          NOT NULL,
    PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Section_Parent"        FOREIGN KEY ("ParentId")   REFERENCES "Section"  ("Id"),
    CONSTRAINT "FK_Section_Category"      FOREIGN KEY ("CategoryId") REFERENCES "Category" ("Id"),
    CONSTRAINT "UQ_Section_ParentId_Name" UNIQUE ("ParentId", "Name")
);

CREATE TABLE "DropdownList" (
    "Id"   SERIAL       NOT NULL,
    "Name" VARCHAR(255) NOT NULL,
    PRIMARY KEY ("Id"),
    CONSTRAINT "UQ_DropdownList_Name" UNIQUE ("Name")
);

CREATE TABLE "DropdownListItem" (
    "Id"             SERIAL       NOT NULL,
    "Name"           VARCHAR(255) NOT NULL,
    "Value"          VARCHAR(255) NOT NULL,
    "SortOrder"      INT          NOT NULL DEFAULT 0,
    "DropdownListId" INT          NOT NULL,
    PRIMARY KEY ("Id"),
    CONSTRAINT "FK_DropdownListItem_DropdownList" FOREIGN KEY ("DropdownListId") REFERENCES "DropdownList" ("Id")
);

-- Partial indexes enforce uniqueness of Name at the root level (ParentId IS NULL),
-- since standard UNIQUE constraints treat each NULL as distinct.
CREATE UNIQUE INDEX "UQ_Category_RootName" ON "Category" ("Name") WHERE "ParentId" IS NULL;
CREATE UNIQUE INDEX "UQ_Section_RootName"  ON "Section"  ("Name") WHERE "ParentId" IS NULL;

CREATE TABLE "Config" (
    "Id"             SERIAL       NOT NULL,
    "Name"           VARCHAR(255) NOT NULL,
    "DisplayName"    VARCHAR(255) NOT NULL,
    "SortOrder"      INT          NOT NULL DEFAULT 0,
    "DataType"       VARCHAR(100) NOT NULL,
    "Value"          TEXT         NULL,
    "IsEncrypted"    BOOLEAN      NOT NULL DEFAULT FALSE,
    "SectionId"      INT          NOT NULL,
    "DropdownListId" INT          NULL,
    "CreatedAt"      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    "UpdatedAt"      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Config_Section"      FOREIGN KEY ("SectionId")      REFERENCES "Section"      ("Id"),
    CONSTRAINT "FK_Config_DropdownList" FOREIGN KEY ("DropdownListId") REFERENCES "DropdownList" ("Id")
);
