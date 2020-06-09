use demoDB
go

DELETE FROM [ForeignParticipations]
GO
DBCC CHECKIDENT ('dbo.ForeignParticipations',RESEED, 1)
GO

 INSERT INTO [dbo].[ForeignParticipations]
   ([Code],[IsDeleted],[Name])
 VALUES
  ('a', 0, 'Exports or imports of goods'),
  ('b', 0, 'Exports or imports of services'),
  ('c', 0, 'Merchanting'),
  ('d', 0, 'Equity Investments abroad'),
  ('e', 0, 'Non -Equity (External borrowing or lending)'),
  ('f', 0, 'External Remittances'),
  ('g', 0, 'no foreign participation'),
  ('h', 0, 'multiple kinds of foreign participation. See notes')    
 GO
  
