use demoDb
go

DELETE FROM [Statuses]
GO
DBCC CHECKIDENT ('dbo.Statuses',RESEED, 1)
GO
-- Note: [Statuses] table must have "Liquidated" status with Code = 7 
-- and "active" status with code 1

INSERT INTO [dbo].[Statuses]
  ([Code],[Name], [IsDeleted])
VALUES
('1', 'Active', 0),
('2', 'Dormant', 0),
('3', 'Newly created, not yet active', 0),
('4', 'Inactive',  0),
('5', 'Historical',  0),
('6', 'In liquidation phase', 0),
('7', 'Liquidated',  0),
('8', 'Deleted',  0),
('9', 'Unknown status', 0)
GO

