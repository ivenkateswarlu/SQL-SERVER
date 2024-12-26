CREATE FUNCTION dbo.getDailyGiftInfo_MultiStatement_TVF(
@TargetDate Date
)

RETURNS @Giftinformation TABLE (
	Gift_System_Record_ID INT,
	GiftAmount DECIMAL(18,2),
	GiftDate DATE,
	GiftDateAdded DATE,
	GiftType INT,
	Constituent_System_Record_ID INT,
	GiftId nvarchar(30),
	GiftCode nvarchar(30)
)

AS

BEGIN
	       WITH Gift_Date_Condition AS (
						SELECT ID, Amount, DTE, DATEADDED, TYPE, CONSTIT_ID, USERGIFTID, GIFT_CODE 
						FROM [OIA-Blackbaud].[dbo].GIFT
						WHERE TYPE IN (1,8,27,9,10,15,31,34) AND CAST(DATEADDED AS Date) = @TargetDate

						UNION ALL

						SELECT ID, Amount, DTE, DATEADDED, TYPE, CONSTIT_ID, USERGIFTID, GIFT_CODE 
						FROM [OIA-Blackbaud].[dbo].GIFT
						WHERE TYPE IN (18) AND GIFT_CODE IN (5131,16652,17900) AND CAST(DATEADDED AS Date) = @TargetDate

						UNION ALL

						SELECT ID, Amount, DTE, DATEADDED, TYPE, CONSTIT_ID, USERGIFTID, GIFT_CODE 
						FROM [OIA-Blackbaud].[dbo].GIFT
						WHERE TYPE IN (2,3,11,12,13,14,16,17) AND GIFT_CODE IN (5131,16652,17900) AND CAST(DATEADDED AS Date) = @TargetDate
					),
					Main_Table AS (
						SELECT *
						FROM Gift_Date_Condition

						UNION ALL

						SELECT G.ID as ID, G.Amount as Amount, G.DTE as DTE, G.DATEADDED as DATEADDED, G.TYPE as TYPE, G.CONSTIT_ID as CONSTIT_ID, G.USERGIFTID as USERGIFTID, G.GIFT_CODE  as GIFT_CODE
						FROM [OIA-Blackbaud].[dbo].GIFT AS G
						LEFT JOIN [OIA-Blackbaud].[dbo].GIFTSPLIT AS GS ON G.ID = GS.GIFTID
						LEFT JOIN [OIA-Blackbaud].[dbo].CAMPAIGN AS C ON GS.GIFTID = C.ID
						WHERE C.CAMPAIGN_ID = 'REALIZEDPLAN' AND G.TYPE IN (1,9,10) AND CAST(G.DATEADDED AS Date) = @TargetDate
					)
				INSERT INTO @Giftinformation(Gift_System_Record_ID,GiftAmount,GiftDate,GiftDateAdded,GiftType,Constituent_System_Record_ID,GiftId,GiftCode)
				SELECT * FROM Main_Table;
			RETURN;
END;
GO

SELECT * FROM dbo.getDailyGiftInfo_MultiStatement_TVF('2024-12-23')
ORDER BY Gift_System_Record_ID DESC;

DROP FUNCTION getDailyGiftInfo_MultiStatement_TVF;
USE[OIA-HCP];


			--SELECT ID, Amount, DTE, DATEADDED, TYPE, CONSTIT_ID, USERGIFTID, GIFT_CODE FROM [OIA-Blackbaud].[dbo].GIFT
			--WHERE CAST(DATEADDED as Date)=@TargetDate;