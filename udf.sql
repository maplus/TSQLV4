USE TSQLV4
GO

-- Simple scalar udf
CREATE FUNCTION dbo.CalculateCircleArea
(
    @Radius FLOAT = 1.0
)
RETURNS FLOAT
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
    RETURN PI() * POWER(@Radius, 2);
END;
GO

-- SELECT dbo.CalculateCircleArea(); -- error! > use default
SELECT dbo.CalculateCircleArea(default);
SELECT dbo.CalculateCircleArea(null);
SELECT dbo.CalculateCircleArea(2.5);
GO


-- Recursive scalar udf
CREATE OR ALTER FUNCTION dbo.CalculateFactorial
(
    @n INT = 1
)
RETURNS DECIMAL(38, 0)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
    RETURN (CASE
                WHEN @n <= 0 THEN
                    NULL
                WHEN @n > 1 THEN
                    CAST(@n AS FLOAT) * dbo.CalculateFactorial(@n - 1)
                WHEN @n = 1 THEN
                    1
            END
           );
END;
GO

SELECT dbo.CalculateFactorial(DEFAULT);
SELECT dbo.CalculateFactorial(NULL);
SELECT dbo.CalculateFactorial(0);
SELECT dbo.CalculateFactorial(5);
SELECT dbo.CalculateFactorial(4.9);
SELECT dbo.CalculateFactorial(32);
GO

CREATE OR ALTER FUNCTION dbo.CalculateFactorial
(
    @n INT = 1
)
RETURNS DECIMAL(38, 0)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
    RETURN (CASE
                WHEN @n > 1 THEN
                    CAST(@n AS FLOAT) * dbo.CalculateFactorial(@n - 1)
                WHEN @n = 1 THEN
                    1
				ELSE
                    NULL
            END
           );
END;
GO


CREATE OR ALTER FUNCTION dbo.CalculateFactorial
(
    @n INT = 1
)
RETURNS BIGINT
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
    RETURN (CASE
                WHEN @n > 1 THEN
                    @n * dbo.CalculateFactorial(@n - 1)
                WHEN @n = 1 THEN
                    1
				ELSE
                    NULL
            END
           );
END;
GO

-- Scalar udf with recursive CTE
CREATE OR ALTER FUNCTION dbo.CalculateFactorial
(
    @n INT = 1
)
RETURNS DECIMAL(38, 0)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
    DECLARE @result DECIMAL(38, 0);
    SET @result = NULL;

    IF @n > 0
    BEGIN
        SET @result = 1.0;

        WITH Numbers (num)
        AS (SELECT 1
            UNION ALL
            SELECT num + 1
            FROM Numbers
            WHERE num < @n)
        SELECT @result = @result * num
        FROM Numbers;
    END;
    RETURN @result;
END;

-------------------------------------------------------------------------------------------
-- Create the NYSIIS replacement rules table
CREATE TABLE dbo.NYSIIS_Replacements
(
    Location nvarchar(10) NOT NULL,
    NGram nvarchar(10) NOT NULL,
    Replacement nvarchar(10) NOT NULL,
    PRIMARY KEY (
                    Location,
                    NGram
                )
);

INSERT INTO NYSIIS_Replacements
(
    Location,
    NGram,
    Replacement
)
VALUES
(N'End', N'DT', N'DD'),
(N'End', N'EE', N'YY'),
(N'End', N'lE', N'YY'),
(N'End', N'ND', N'DD'),
(N'End', N'NT', N'DD'),
(N'End', N'RD', N'DD'),
(N'End', N'RT', N'DD'),
(N'Mid', N'A', N'A'),
(N'Mid', N'E', N'A'),
(N'Mid', N'T', N'A'),
(N'Mid', N'K', N'C'),
(N'Mid', N'M', N'N'),
(N'Mid', N'O', N'A'),
(N'Mid', N'Q', N'G'),
(N'Mid', N'U', N'A'),
(N'Mid', N'Z', N'S'),
(N'Mid', N'AW', N'AA'),
(N'Mid', N'EV', N'AF'),
(N'Mid', N'EW', N'AA'),
(N'Mid', N'lW', N'AA'),
(N'Mid', N'KN', N'NN'),
(N'Mid', N'OW', N'AA'),
(N'Mid', N'PH', N'FF'),
(N'Mid', N'UW', N'AA'),
(N'Mid', N'SCH', N'SSS'),
(N'Start', N'K', N'C'),
(N'Start', N'KN', N'NN'),
(N'Start', N'PF', N'FF'),
(N'Start', N'PH', N'FF'),
(N'Start', N'MAC', N'MCC'),
(N'Start', N'SCH', N'SSS');
go

CREATE FUNCTION dbo.EncodeNYSIIS
(
    @String nvarchar(100)
)
RETURNS nvarchar(6)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
    DECLARE @Result nvarchar(100);
    SET @Result = UPPER(@String);

    -- Step 1: Remove All Nonalphabetic Characters
    WITH Numbers (Num)
    AS (SELECT 1
        UNION ALL
        SELECT Num + 1
        FROM Numbers
        WHERE Num < LEN(@Result))
    SELECT @Result = STUFF(   @Result,
                              Num,
                              1,
                              CASE
                                  WHEN SUBSTRING(@Result, Num, 1) >= N'A'
                                       AND SUBSTRING(@Result, Num, 1) <= N'Z' THEN
                                      SUBSTRING(@Result, Num, 1)
                                  ELSE
                                      N'.'
                              END
                          )
    FROM Numbers;

    SET @Result = REPLACE(@Result, N'.', N'');

    -- Step 2: Replace the Start N-gram
    SELECT TOP (1)
           @Result = STUFF(@Result, 1, LEN(NGram), Replacement)
    FROM dbo.NYSIIS_Replacements
    WHERE Location = N'Start'
          AND SUBSTRING(@Result, 1, LEN(NGram)) = NGram
    ORDER BY LEN(NGram) DESC;

    -- Step 3: Replace the End N-gram
    SELECT TOP (1)
           @Result = STUFF(@Result, LEN(@Result) - LEN(NGram) + 1, LEN(NGram), Replacement)
    FROM dbo.NYSIIS_Replacements
    WHERE Location = N'End'
          AND SUBSTRING(@Result, LEN(@Result) - LEN(NGram) + 1, LEN(NGram)) = NGram
    ORDER BY LEN(NGram) DESC;

    -- Step 4: Save the First Letter of the Name
    DECLARE @FirstLetter NCHAR(1);
    SET @FirstLetter = SUBSTRING(@Result, 1, 1);

    -- Step 5: Replace All Middle N-grams
    DECLARE @Replacement nvarchar(10);
    DECLARE @i int;
    SET @i = 1;
    WHILE @i <= LEN(@Result)
    BEGIN
        SET @Replacement = NULL;

        -- Grab the middle-of-name replacement n-gram
        SELECT TOP (1)
               @Replacement = Replacement
        FROM dbo.NYSIIS_Replacements
        WHERE Location = N'Mid'
              AND SUBSTRING(@Result, @i, LEN(NGram)) = NGram
        ORDER BY LEN(NGram) DESC;

        SET @Replacement = COALESCE(@Replacement, SUBSTRING(@Result, @i, 1));

        -- If we found a replacement, apply it
        SET @Result = STUFF(@Result, @i, LEN(@Replacement), @Replacement);

        -- Move on to the next n-gram
        SET @i = @i + COALESCE(LEN(@Replacement), 1);
    END;

    -- Replace the first character with the first letter we saved at the start
    SET @Result = STUFF(@Result, 1, 1, @FirstLetter);

    -- Here we apply our special rules for the 'H' character. Special handling for 'W'
    -- characters is taken care of in the replacement rules table
    WITH Numbers (Num)
    AS (SELECT 2 -- Don't bother with the first character

        UNION ALL
        SELECT Num + 1
        FROM Numbers
        WHERE Num < LEN(@Result))
    SELECT @Result
        = STUFF(
                   @Result,
                   Num,
                   1,
                   CASE SUBSTRING(@Result, Num, 1)
                       WHEN N'H' THEN
                           CASE
                               WHEN SUBSTRING(@Result, Num + 1, 1) NOT IN ( N'A', N'E', N'I', N'O', N'U' )
                                    OR SUBSTRING(@Result, Num - 1, 1) NOT IN ( N'A', N'E', N'I', N'O', N'U' ) THEN
                                   SUBSTRING(@Result, Num - 1, 1)
                               ELSE
                                   N'H'
                           END
                       ELSE
                           SUBSTRING(@Result, Num, 1)
                   END
               )
    FROM Numbers;

    -- Step 6: Reduce All Side-by-side Duplicate Characters
    -- First replace the first letter of any sequence of two side-by-side
    -- duplicate letters with a period
    WITH Numbers (Num)
    AS (SELECT 1
        UNION ALL
        SELECT Num + 1
        FROM Numbers
        WHERE Num < LEN(@Result))
    SELECT @Result = STUFF(   @Result,
                              Num,
                              1,
                              CASE SUBSTRING(@Result, Num, 1)
                                  WHEN SUBSTRING(@Result, Num + 1, 1) THEN
                                      N'.'
                                  ELSE
                                      SUBSTRING(@Result, Num, 1)
                              END
                          )
    FROM Numbers;

    -- Next replace all periods '.' with an empty string ''
    SET @Result = REPLACE(@Result, N'.', N'');

    -- Step 7: Remove Trailing 'S' Characters
    WHILE RIGHT(@Result, 1) = N'S' AND LEN(@Result) > 1
    SET @Result = STUFF(@Result, LEN(@Result), 1, N'');

    -- Step 8: Remove Trailing 'A' Characters
    WHILE RIGHT(@Result, 1) = N'A' AND LEN(@Result) > 1
    SET @Result = STUFF(@Result, LEN(@Result), 1, N'');

    -- Step 9: Replace Trailing 'AY' Characters with 'Y'
    IF RIGHT(@Result, 2) = 'AY'
        SET @Result = STUFF(@Result, LEN(@Result) - 1, 1, N'');

    -- Step 10: Truncate Result to 6 Characters
    RETURN COALESCE(SUBSTRING(@Result, 1, 6), '');
END;
GO

SELECT LastName,
   dbo.EncodeNYSIIS(LastName) AS NYSIIS
FROM AdventureWorks2017.Person.Person
GROUP BY LastName;

