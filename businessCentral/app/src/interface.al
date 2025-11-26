interface ADLSESetup
{
    procedure GetAccountName(): Text[24];
    procedure GetContainer(): Text[63];
    procedure GetMaxPayloadSizeMiB(): Integer;
    procedure GetDataFormat(): Enum "ADLSE CDM Format";
    procedure GetEmitTelemetry(): Boolean;
    procedure GetMultiCompanyExport(): Boolean;
    procedure GetSkipTimestampSortingOnRecs(): Boolean;
    procedure GetStorageType(): Enum "ADLSE Storage Type";
    procedure GetWorkspace(): Text[100];
    procedure GetLakehouse(): Text[100];
    procedure GetLandingZone(): Text[250];
    procedure GetSchemaExportedOn(): DateTime;
    procedure GetTranslations(): Text[250];
    procedure GetExportEnumAsInteger(): Boolean;
    procedure GetDeleteTable(): Boolean;
    procedure GetMaximumRetries(): Integer;
    procedure GetDeliveredDateTime(): Boolean;
    procedure GetExportCompanyDatabaseTables(): Text[30];
    procedure GetDelayedExport(): Integer;
    procedure GetUseFieldCaptions(): Boolean;
    procedure GetUseIDsForDuplicatesOnly(): Boolean;
    procedure GetUseFriendlyCompanyName(): Boolean;
    procedure GetUseTableCaptions(): Boolean;
    procedure GetSyncCompany(): Text[30];
    procedure TestField(FieldID: Integer): Text[30];
    procedure CheckSchemaExported();
    procedure GetSystemId(): Text[250];
    procedure GetRealRec(var ADLSESetup: Record "ADLSE Setup Spec Company"): Boolean;
    procedure GetRealRec(var ADLSESetup: Record "ADLSE Setup"): Boolean;


}