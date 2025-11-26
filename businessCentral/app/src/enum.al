enum 82564 ADLSESetupType implements ADLSESetup
{
    value(0; Global)
    {
        Implementation = ADLSESetup = ADLSESetupGlobal;
    }
    value(1; "Per Company")
    {
        Implementation = ADLSESetup = ADLSESetupLocal;
    }
}