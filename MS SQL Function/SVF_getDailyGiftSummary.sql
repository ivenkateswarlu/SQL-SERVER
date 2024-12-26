CREATE FUNCTION dbo.GetGiftSummary(
@TargetDate DATE
)
RETURNS DECIMAL(18, 2) -- Adjust the return type as needed
AS
BEGIN
    DECLARE @Result DECIMAL(18, 2);

    WITH Gift_Date_Condition AS (
        SELECT ID, Amount, DTE, DATEADDED, TYPE, CONSTIT_ID, USERGIFTID, GIFT_CODE 
        FROM [database].[dbo].Transcation_Table
        WHERE TYPE IN (1,8,27,9,10,15,31,34) AND CAST(DATEADDED AS Date) = @TargetDate

        UNION ALL

        SELECT ID, Amount, DTE, DATEADDED, TYPE, CONSTIT_ID, USERGIFTID, GIFT_CODE 
        FROM [database].[dbo].Transcation_Table
        WHERE TYPE IN (18) AND GIFT_CODE IN (1234,1234,1234) AND CAST(DATEADDED AS Date) = @TargetDate

        UNION ALL

        SELECT ID, Amount, DTE, DATEADDED, TYPE, CONSTIT_ID, USERGIFTID, GIFT_CODE 
        FROM [database].[dbo].Transcation_Table
        WHERE TYPE IN (2,3,11,12,13,14,16,17) AND GIFT_CODE IN (1234,1234,1234) AND CAST(DATEADDED AS Date) = @TargetDate
    ),
    Main_Table AS (
        SELECT *
        FROM Gift_Date_Condition

        UNION ALL

        SELECT G.ID as ID, G.Amount as Amount, G.DTE as DTE, G.DATEADDED as DATEADDED, G.TYPE as TYPE, G.CONSTIT_ID as CONSTIT_ID, G.USERGIFTID as USERGIFTID, G.GIFT_CODE  as GIFT_CODE
        FROM [database].[dbo].Transcation_Table AS G
        LEFT JOIN [database].[dbo].GIFTSPLIT AS GS ON G.ID = GS.GIFTID
        LEFT JOIN [database].[dbo].CAMPAIGN AS C ON GS.GIFTID = C.ID
        WHERE C.CAMPAIGN_ID = 'REAL' AND G.TYPE IN (1,9,10) AND CAST(G.DATEADDED AS Date) = @TargetDate
    )
    SELECT @Result = SUM(Amount)
    FROM Main_Table;

    RETURN @Result;
END;
GO


SELECT dbo.GetGiftSummary('2024-12-23') AS GiftSummary;

