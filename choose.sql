USE AdventureWorks2017;
GO

-- INDEX STARTS WITH 1
SELECT
	P.FirstName, PP.PhoneNumber,
	PP.PhoneNumberTypeID,
	CHOOSE(PP.PhoneNumberTypeID, 'Cell', 'Home', 'Work') AS PhoneType
FROM PERSON.Person P JOIN PERSON.PersonPhone PP ON P.BUSINESSeNTITYiD = PP.BUSINESSeNTITYiD;
