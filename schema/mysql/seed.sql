-- =============================================================================
-- NexusConfig Demo Seed Data (MySQL)
-- Apply AFTER schema.sql: mysql -u root -p NexusConfig < seed.sql
-- =============================================================================

-- DropdownList + items (referenced by dropdown-type configs)
INSERT INTO `DropdownList` (`Name`) VALUES ('LogLevel');

INSERT INTO `DropdownListItem` (`Name`, `Value`, `SortOrder`, `DropdownListId`) VALUES
    ('Debug',   'debug',   1, 1),
    ('Info',    'info',    2, 1),
    ('Warning', 'warning', 3, 1),
    ('Error',   'error',   4, 1);

-- =============================================================================
-- Category: Application  (SectionType = 'Card' — child sections render as cards)
-- =============================================================================
INSERT INTO `Category` (`Name`, `DisplayName`, `SortOrder`, `SectionType`, `ParentId`) VALUES
    ('Application', 'Application', 1, 'Card', NULL);

-- Sub-category: Application > Database
INSERT INTO `Category` (`Name`, `DisplayName`, `SortOrder`, `SectionType`, `ParentId`) VALUES
    ('Database', 'Database', 1, 'tab-h', 1);

-- Sub-category: Application > Security
INSERT INTO `Category` (`Name`, `DisplayName`, `SortOrder`, `SectionType`, `ParentId`) VALUES
    ('Security', 'Security', 2, 'accordion', 1);

-- =============================================================================
-- Category: Notifications  (SectionType = 'tab-h' — child sections render as tabs)
-- =============================================================================
INSERT INTO `Category` (`Name`, `DisplayName`, `SortOrder`, `SectionType`, `ParentId`) VALUES
    ('Notifications', 'Notifications', 2, 'tab-h', NULL);

-- =============================================================================
-- Sections for Application (CategoryId = 1)
-- =============================================================================
INSERT INTO `Section` (`Name`, `DisplayName`, `SortOrder`, `SectionType`, `ParentId`, `CategoryId`) VALUES
    ('General', 'General', 1, 'Card', NULL, 1);

-- =============================================================================
-- Sections for Application > Database (CategoryId = 2)
-- =============================================================================
INSERT INTO `Section` (`Name`, `DisplayName`, `SortOrder`, `SectionType`, `ParentId`, `CategoryId`) VALUES
    ('Connection', 'Connection',   1, 'Card', NULL, 2),
    ('Pool',       'Pool Settings',2, 'Card', NULL, 2);

-- =============================================================================
-- Sections for Application > Security (CategoryId = 3)
-- =============================================================================
INSERT INTO `Section` (`Name`, `DisplayName`, `SortOrder`, `SectionType`, `ParentId`, `CategoryId`) VALUES
    ('Auth',    'Authentication', 1, 'Card', NULL, 3),
    ('Tokens',  'Tokens',         2, 'Card', NULL, 3);

-- =============================================================================
-- Sections for Notifications (CategoryId = 4)
-- =============================================================================
INSERT INTO `Section` (`Name`, `DisplayName`, `SortOrder`, `SectionType`, `ParentId`, `CategoryId`) VALUES
    ('Email', 'Email', 1, 'Card', NULL, 4),
    ('Sms',   'SMS',   2, 'Card', NULL, 4);

-- =============================================================================
-- Config values — Application > General (SectionId = 1)
-- Exercises: bool, int, float, color, dropdown, multiline
-- =============================================================================
INSERT INTO `Config` (`Name`, `DisplayName`, `SortOrder`, `DataType`, `Value`, `IsEncrypted`, `SectionId`, `DropdownListId`) VALUES
    ('MaintenanceMode',  'Maintenance Mode',    1, 'bool',      'false',    0, 1, NULL),
    ('MaxUploadSizeMb',  'Max Upload Size (MB)', 2, 'int',       '50',       0, 1, NULL),
    ('RequestTimeoutS',  'Request Timeout (s)',  3, 'float',     '30.5',     0, 1, NULL),
    ('BrandColor',       'Brand Color',          4, 'color',     '#1976D2',  0, 1, NULL),
    ('LoggingLevel',     'Logging Level',        5, 'dropdown',  'info',     0, 1, 1),
    ('WelcomeMessage',   'Welcome Message',      6, 'multiline', 'Welcome to the application.\nPlease log in to continue.', 0, 1, NULL);

-- =============================================================================
-- Config values — Application > Database > Connection (SectionId = 2)
-- Exercises: url, int, bool
-- =============================================================================
INSERT INTO `Config` (`Name`, `DisplayName`, `SortOrder`, `DataType`, `Value`, `IsEncrypted`, `SectionId`, `DropdownListId`) VALUES
    ('ConnectionString', 'Connection String', 1, 'url',  'Server=localhost;Database=app;User=root;Password=secret;', 1, 2, NULL),
    ('CommandTimeoutS',  'Command Timeout (s)',2, 'int',  '30',  0, 2, NULL),
    ('EnableRetry',      'Enable Retry',       3, 'bool', 'true', 0, 2, NULL);

-- =============================================================================
-- Config values — Application > Database > Pool (SectionId = 3)
-- Exercises: int, bool
-- =============================================================================
INSERT INTO `Config` (`Name`, `DisplayName`, `SortOrder`, `DataType`, `Value`, `IsEncrypted`, `SectionId`, `DropdownListId`) VALUES
    ('MinPoolSize',   'Min Pool Size',    1, 'int',  '5',     0, 3, NULL),
    ('MaxPoolSize',   'Max Pool Size',    2, 'int',  '100',   0, 3, NULL),
    ('Pooling',       'Pooling Enabled',  3, 'bool', 'true',  0, 3, NULL);

-- =============================================================================
-- Config values — Application > Security > Auth (SectionId = 4)
-- Exercises: bool, int, guid
-- =============================================================================
INSERT INTO `Config` (`Name`, `DisplayName`, `SortOrder`, `DataType`, `Value`, `IsEncrypted`, `SectionId`, `DropdownListId`) VALUES
    ('RequireMfa',         'Require MFA',           1, 'bool', 'false', 0, 4, NULL),
    ('SessionTimeoutMin',  'Session Timeout (min)',  2, 'int',  '60',    0, 4, NULL),
    ('AppClientId',        'App Client ID',          3, 'guid', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 0, 4, NULL);

-- =============================================================================
-- Config values — Application > Security > Tokens (SectionId = 5)
-- Exercises: int, date, json
-- =============================================================================
INSERT INTO `Config` (`Name`, `DisplayName`, `SortOrder`, `DataType`, `Value`, `IsEncrypted`, `SectionId`, `DropdownListId`) VALUES
    ('AccessTokenTtlMin',  'Access Token TTL (min)',  1, 'int',  '15',         0, 5, NULL),
    ('RefreshTokenTtlDays','Refresh Token TTL (days)',2, 'int',  '30',         0, 5, NULL),
    ('TokenExpiryDate',    'Token Expiry Date',       3, 'date', '2027-01-01', 0, 5, NULL),
    ('JwtClaims',          'JWT Claims (JSON)',        4, 'json', '{"sub":"user","roles":["admin","viewer"]}', 0, 5, NULL);

-- =============================================================================
-- Config values — Notifications > Email (SectionId = 6)
-- Exercises: url, email, int, bool, time
-- =============================================================================
INSERT INTO `Config` (`Name`, `DisplayName`, `SortOrder`, `DataType`, `Value`, `IsEncrypted`, `SectionId`, `DropdownListId`) VALUES
    ('SmtpHost',        'SMTP Host',          1, 'url',   'smtp://mail.example.com', 0, 6, NULL),
    ('SmtpPort',        'SMTP Port',          2, 'int',   '587',                     0, 6, NULL),
    ('SmtpUseTls',      'Use TLS',            3, 'bool',  'true',                    0, 6, NULL),
    ('SenderAddress',   'Sender Address',     4, 'email', 'noreply@example.com',     0, 6, NULL),
    ('DailyDigestTime', 'Daily Digest Time',  5, 'time',  '08:00:00',                0, 6, NULL);

-- =============================================================================
-- Config values — Notifications > SMS (SectionId = 7)
-- Exercises: url, bool, int, datetime
-- =============================================================================
INSERT INTO `Config` (`Name`, `DisplayName`, `SortOrder`, `DataType`, `Value`, `IsEncrypted`, `SectionId`, `DropdownListId`) VALUES
    ('SmsApiEndpoint',  'API Endpoint',        1, 'url',      'https://api.sms-provider.com/v1/send', 0, 7, NULL),
    ('SmsApiKey',       'API Key',             2, 'url',      'sk-placeholder-api-key',               1, 7, NULL),
    ('SmsEnabled',      'SMS Enabled',         3, 'bool',     'false',                                0, 7, NULL),
    ('RetryCount',      'Retry Count',         4, 'int',      '3',                                    0, 7, NULL),
    ('LastBatchSent',   'Last Batch Sent',     5, 'datetime', '2026-04-01T09:00:00',                  0, 7, NULL);
