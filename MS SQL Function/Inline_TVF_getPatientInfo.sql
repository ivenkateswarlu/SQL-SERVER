CREATE FUNCTION dbo.getPatientInfomration_Inline_TVF(
@Month nvarchar(20),
@Year smallint,
@DoctorID nvarchar(20)
)
RETURNS TABLE
AS
Return(
       SELECT Patient_ID, Patient_First_Name, Patient_Last_Name,Servicing_Provider, Servicing_Provider_Number,ID FROM db_owner.patient
	   WHERE File_month=@Month AND File_Year=@Year AND Servicing_Provider_Number=@DoctorID
);
GO

SELECT TOP(10) * FROM dbo.getPatientInfomration_Inline_TVF('September',2024,1234)

