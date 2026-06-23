CREATE TABLE [Category] (
    [Id]          INT           NOT NULL IDENTITY(1,1),
    [Name]        NVARCHAR(255) NOT NULL,
    [DisplayName] NVARCHAR(255) NOT NULL,
    [SortOrder]   INT           NOT NULL CONSTRAINT [DF_Category_SortOrder] DEFAULT 0,
    [SectionType] NVARCHAR(100) NOT NULL CONSTRAINT [DF_Category_SectionType] DEFAULT 'Card',
    [ParentId]    INT           NULL,
    CONSTRAINT [PK_Category]        PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Category_Parent]        FOREIGN KEY ([ParentId]) REFERENCES [Category] ([Id]),
    CONSTRAINT [UQ_Category_ParentId_Name] UNIQUE ([ParentId], [Name])
);

CREATE TABLE [Section] (
    [Id]          INT           NOT NULL IDENTITY(1,1),
    [Name]        NVARCHAR(255) NOT NULL,
    [DisplayName] NVARCHAR(255) NOT NULL,
    [SortOrder]   INT           NOT NULL CONSTRAINT [DF_Section_SortOrder] DEFAULT 0,
    [SectionType] NVARCHAR(100) NOT NULL CONSTRAINT [DF_Section_SectionType] DEFAULT 'Card',
    [ParentId]    INT           NULL,
    [CategoryId]  INT           NOT NULL,
    CONSTRAINT [PK_Section]           PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Section_Parent]        FOREIGN KEY ([ParentId])   REFERENCES [Section]  ([Id]),
    CONSTRAINT [FK_Section_Category]      FOREIGN KEY ([CategoryId]) REFERENCES [Category] ([Id]),
    CONSTRAINT [UQ_Section_ParentId_Name] UNIQUE ([ParentId], [Name])
);

-- Filtered indexes enforce uniqueness of Name at the root level (ParentId IS NULL),
-- since standard UNIQUE constraints treat each NULL as distinct.
CREATE UNIQUE INDEX [UQ_Category_RootName] ON [Category] ([Name]) WHERE [ParentId] IS NULL;
CREATE UNIQUE INDEX [UQ_Section_RootName]  ON [Section]  ([Name]) WHERE [ParentId] IS NULL;

CREATE TABLE [DropdownList] (
    [Id]   INT           NOT NULL IDENTITY(1,1),
    [Name] NVARCHAR(255) NOT NULL,
    CONSTRAINT [PK_DropdownList]       PRIMARY KEY ([Id]),
    CONSTRAINT [UQ_DropdownList_Name]  UNIQUE ([Name])
);

CREATE TABLE [DropdownListItem] (
    [Id]             INT           NOT NULL IDENTITY(1,1),
    [Name]           NVARCHAR(255) NOT NULL,
    [Value]          NVARCHAR(255) NOT NULL,
    [SortOrder]      INT           NOT NULL CONSTRAINT [DF_DropdownListItem_SortOrder] DEFAULT 0,
    [DropdownListId] INT           NOT NULL,
    CONSTRAINT [PK_DropdownListItem]                PRIMARY KEY ([Id]),
    CONSTRAINT [FK_DropdownListItem_DropdownList]   FOREIGN KEY ([DropdownListId]) REFERENCES [DropdownList] ([Id])
);

CREATE TABLE [Config] (
    [Id]             INT            NOT NULL IDENTITY(1,1),
    [Name]           NVARCHAR(255)  NOT NULL,
    [DisplayName]    NVARCHAR(255)  NOT NULL,
    [SortOrder]      INT            NOT NULL CONSTRAINT [DF_Config_SortOrder] DEFAULT 0,
    [DataType]       NVARCHAR(100)  NOT NULL,
    [Value]          NVARCHAR(MAX)  NULL,
    [IsEncrypted]    BIT            NOT NULL CONSTRAINT [DF_Config_IsEncrypted] DEFAULT 0,
    [SectionId]      INT            NOT NULL,
    [DropdownListId] INT            NULL,
    [CreatedAt]      DATETIME2      NOT NULL CONSTRAINT [DF_Config_CreatedAt]   DEFAULT SYSUTCDATETIME(),
    [UpdatedAt]      DATETIME2      NOT NULL CONSTRAINT [DF_Config_UpdatedAt]   DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_Config]              PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Config_Section]      FOREIGN KEY ([SectionId])      REFERENCES [Section]      ([Id]),
    CONSTRAINT [FK_Config_DropdownList] FOREIGN KEY ([DropdownListId]) REFERENCES [DropdownList] ([Id])
);
