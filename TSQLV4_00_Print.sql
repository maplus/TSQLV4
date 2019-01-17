Declare @VariableName VARCHAR(100)
SET @VariableName = 'a'
Print (@VariableName)
SET @VariableName = 'b'
Print (@VariableName)
go


DECLARE @varText INT;
SET @varText = 10;
SELECT @varText as varText;
SET @varText = 11;
SELECT @varText as varText;
GO


DECLARE @max AS INT, @rc AS INT;
SET @max = 10;
SET @rc = 0;

WHILE @rc < @max
BEGIN
  SET @rc += 1;
  PRINT(@rc);
END
GO