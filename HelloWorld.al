// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

pageextension 50100 CustomerListExt extends "Customer List"
{
    trigger OnOpenPage();
    var
        Signature: Text;
    begin
        Signature := GetSignature('wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY',
                                  '20120215',
                                  'us-east-1',
                                  'iam');
    end;

    local procedure GetSignature(AKey: Text; DateStamp: Text; RegionName: Text; ServiceName: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        CryptographyMgt: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        kSecret, kDate, kRegion, kService, kSigning : Text;
    begin
        kSecret := StrSubstNo('AWS4%1', AKey);

        kDate := CryptographyMgt.GenerateHashAsBase64String(DateStamp, kSecret, HashAlgorithmType::SHA256);
        kRegion := CryptographyMgt.GenerateBase64KeyedHashAsBase64String(RegionName, kDate, HashAlgorithmType::SHA256);
        kService := CryptographyMgt.GenerateBase64KeyedHashAsBase64String(ServiceName, kRegion, HashAlgorithmType::SHA256);
        kSigning := CryptographyMgt.GenerateBase64KeyedHashAsBase64String('aws4_request', kService, HashAlgorithmType::SHA256);

        Message('kDate: %1\' +
                'kRegion: %2\' +
                'kService: %3\' +
                'kSigning: %4',
                Base64ValueToHex(kDate),
                Base64ValueToHex(kRegion),
                Base64ValueToHex(kService),
                Base64ValueToHex(kSigning));

        exit(Base64ValueToHex(kSigning));
    end;

    local procedure Base64ValueToHex(Value: Text) Result: Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        TypeHelper: Codeunit "Type Helper";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        TxtBuilder: TextBuilder;
        b: Byte;
    begin
        TempBlob.CreateOutStream(OutStr);
        Base64Convert.FromBase64(Value, OutStr);
        TempBlob.CreateInStream(InStr);

        while not InStr.EOS do begin
            InStr.Read(b, 1);
            TxtBuilder.Append(TypeHelper.IntToHex(b).PadLeft(2, '0'));
        end;

        Result := TxtBuilder.ToText().ToLower();
    end;
}