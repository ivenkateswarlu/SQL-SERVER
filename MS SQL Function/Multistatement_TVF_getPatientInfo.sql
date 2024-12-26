CREATE FUNCTION dbo.getPatientInformation(
@Month nvarchar(20),
@Year smallint,
@DoctorID nvarchar(20)
)
RETURNS @PatientTable TABLE
(
     PatientID nvarchar(50),
	 FirstName nvarchar(50),
	 LastName nvarchar(50),
	 Doctor_Name nvarchar(100),
	 Doctor_ID  nvarchar(50),
	 Unique_Pin INT

)
AS
BEGIN
       INSERT INTO @PatientTable (PatientID,FirstName,LastName,Doctor_Name,Doctor_ID,Unique_Pin)
	   SELECT Patient_ID, Patient_First_Name, Patient_Last_Name,Servicing_Provider, Servicing_Provider,ID FROM db_owner.patient_table
	   WHERE File_month=@Month AND File_Year=@Year AND Servicing_Provider=@DoctorID;

	   RETURN;
        
END;
GO


SELECT TOP(10) * FROM dbo.getPatientInformation('September',2024,1234)


