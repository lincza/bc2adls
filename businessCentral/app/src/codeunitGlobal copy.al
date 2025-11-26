codeunit 82581 ADLSESetupGlobal implements ADLSESetup
{
    var
        NoSchemaExportedErr: Label 'No schema has been exported yet. Please export schema first before exporting the data.';


    procedure GetAccountName(): Text[24]
    begin

    end;

    procedure GetContainer(): Text[63]
    begin

    end;

    procedure GetMaxPayloadSizeMiB(): Integer
    begin

    end;

    procedure GetDataFormat(): Enum "ADLSE CDM Format"
    begin

    end;

    procedure GetEmitTelemetry(): Boolean
    begin

    end;

    procedure GetMultiCompanyExport(): Boolean
    begin

    end;

    procedure GetSkipTimestampSortingOnRecs(): Boolean
    begin

    end;

    procedure GetStorageType(): Enum "ADLSE Storage Type"
    var
        ADLSESetupRec: Record "ADLSE Setup";
    begin
        ADLSESetupRec.Get();
        exit(ADLSESetupRec.GetStorageType());
    end;

    procedure GetWorkspace(): Text[100]
    begin

    end;

    procedure GetLakehouse(): Text[100]
    begin

    end;

    procedure GetLandingZone(): Text[250]
    begin

    end;

    procedure GetSchemaExportedOn(): DateTime
    begin

    end;

    procedure GetTranslations(): Text[250]
    begin

    end;

    procedure GetExportEnumAsInteger(): Boolean
    begin

    end;

    procedure GetDeleteTable(): Boolean
    begin

    end;

    procedure GetMaximumRetries(): Integer
    begin

    end;

    procedure GetDeliveredDateTime(): Boolean
    begin

    end;

    procedure GetExportCompanyDatabaseTables(): Text[30]
    begin

    end;

    procedure GetDelayedExport(): Integer
    begin

    end;

    procedure GetUseFieldCaptions(): Boolean
    begin

    end;

    procedure GetUseIDsForDuplicatesOnly(): Boolean
    begin

    end;

    procedure GetUseFriendlyCompanyName(): Boolean
    begin

    end;

    procedure GetUseTableCaptions(): Boolean
    begin

    end;

    procedure GetSyncCompany(): Text[30]
    begin

    end;

    procedure TestField(FieldID: Integer): Text[30]
    var
        ADLSESetupRec: Record "ADLSE Setup";
        RecRef: RecordRef;
        FRef: FieldRef;
    begin
        ADLSESetupRec.Get();
        RecRef := ADLSESetupRec.RecordId.GetRecord();
        FRef := RecRef.Field(FieldID);
        FRef.TestField();
    end;

    procedure CheckSchemaExported()
    var
        Rec: Record "ADLSE Setup";
    begin
        Rec.GetSingleton();
        if Rec."Schema Exported On" = 0DT then
            Error(NoSchemaExportedErr);
    end;

    procedure GetSystemId(): Text[250]
    var
        ADLSESetupRec: Record "ADLSE Setup";
    begin
        ADLSESetupRec.GetSingleton();
        exit(ADLSESetupRec.SystemId);
    end;

    procedure GetRealRec(var ADLSESetup: Record "ADLSE Setup Spec Company"): Boolean
    begin
        exit(ADLSESetup.Get());
    end;

    procedure GetRealRec(var ADLSESetup: Record "ADLSE Setup"): Boolean
    begin
        exit(ADLSESetup.Get());
    end;

}