use demoDB
go

alter table Activities
drop column statId

--alter table Activities
--drop column regid



alter table Address
drop column statId, addressType

alter table Persons
drop column statId

alter table ActivityCategories
drop column OldParentId
