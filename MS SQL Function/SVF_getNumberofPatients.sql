CREATE FUNCTION dbo.Number_Of_Patients(
 @Month nvarchar(20),
 @Year  smallint
)
RETURNS INT
AS
BEGIN

		DECLARE @coutofPatients INT;

		SELECT @coutofPatients=Count(FH_Patient_ID)FROM db_owner.patientTable
		WHERE File_month=@Month AND File_Year =@Year

		RETURN @coutofPatients;

END;

GO

SELECT dbo.Number_Of_Patients('September',2024);

DROP FUNCTION dbo.Number_Of_Patients;


