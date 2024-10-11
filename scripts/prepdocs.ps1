if (-not $script:azdCmd) {
    $script:azdCmd = Get-Command azd -ErrorAction SilentlyContinue
}

# Check if 'azd' command is available
if (-not $script:azdCmd) {
    throw "Error: 'azd' command is not found. Please ensure you have 'azd' installed. For installation instructions, visit: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd"
}

if (-not $script:dotnetCmd) {
    $script:dotnetCmd = Get-Command dotnet -ErrorAction SilentlyContinue
}

# Check if 'dotnet' command is available
if (-not $script:dotnetCmd) {
    throw "Error: 'dotnet' command is not found. Please ensure you have 'dotnet' installed. For installation instructions, visit: https://learn.microsoft.com/en-us/dotnet/core/tools/"
}

function Invoke-ExternalCommand {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Command,
        
        [Parameter(Mandatory = $false)]
        [string]$Arguments
    )

    $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processStartInfo.FileName = $Command
    $processStartInfo.Arguments = $Arguments
    $processStartInfo.RedirectStandardOutput = $true
    $processStartInfo.RedirectStandardError = $true
    $processStartInfo.UseShellExecute = $false
    $processStartInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processStartInfo
    $process.Start() | Out-Null
    $output = $process.StandardOutput.ReadToEnd()
    $errorOutput = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    if ($errorOutput) {
        Write-Error $errorOutput
    }

    return $output
}

if ([string]::IsNullOrEmpty($env:AZD_PREPDOCS_RAN) -or $env:AZD_PREPDOCS_RAN -eq "false") {
    Write-Host 'Running "PrepareDocs.dll"'

    Get-Location | Select-Object -ExpandProperty Path

    # Constructs the arguments for running the .NET project that prepares documents for Azure services.
    # The script processes PDF and JSON files located in the ./data/ directory.
    # It uses various Azure service endpoints and settings provided through environment variables.
    # 
    # Environment Variables:
    # - AZURE_STORAGE_BLOB_ENDPOINT: The endpoint for the Azure Storage Blob service.
    # - AZURE_STORAGE_CONTAINER: The name of the Azure Storage container.
    # - AZURE_SEARCH_SERVICE_ENDPOINT: The endpoint for the Azure Search service.
    # - AZURE_SEARCH_INDEX: The name of the Azure Search index.
    # - AZURE_FORMRECOGNIZER_SERVICE_ENDPOINT: The endpoint for the Azure Form Recognizer service.
    # - AZURE_TENANT_ID: The Azure Active Directory tenant ID.
    # 
    # The --verbose flag is used to enable detailed logging.
    $commonArguments = @(
        "--storageendpoint $($env:AZURE_STORAGE_BLOB_ENDPOINT)"
        "--container $($env:AZURE_STORAGE_CONTAINER)"
        "--searchendpoint $($env:AZURE_SEARCH_SERVICE_ENDPOINT)"
        "--searchindex $($env:AZURE_SEARCH_INDEX)"
        "--formrecognizerendpoint $($env:AZURE_FORMRECOGNIZER_SERVICE_ENDPOINT)"
        "--tenantid $($env:AZURE_TENANT_ID)"
        "--verbose"
    )

    if ($env:AZURE_COMPUTERVISION_SERVICE_ENDPOINT -and $env:USE_VISION) {
        Write-Host "Using GPT-4 Vision"
        $commonArguments += "--computervisionendpoint $($env:AZURE_COMPUTERVISION_SERVICE_ENDPOINT)"
    }

    if ($env:USE_AOAI -eq "true") {
        Write-Host "Using Azure OpenAI"
        $commonArguments += "--openaiendpoint $($env:AZURE_OPENAI_ENDPOINT)"
        $commonArguments += "--embeddingmodel $($env:AZURE_OPENAI_EMBEDDING_DEPLOYMENT)"
    }
    else {
        Write-Host "Using OpenAI"
        $commonArguments += "--embeddingmodel $($env:OPENAI_EMBEDDING_DEPLOYMENT)"
    }

    $commonArgumentsString = $commonArguments -join " "

    # Run for PDF files
    $pdfArguments = "run --project app/prepdocs/PrepareDocs/PrepareDocs.csproj ./data/**/*.pdf $commonArgumentsString"
    Write-Host "dotnet $pdfArguments"
    $output = Invoke-ExternalCommand -Command "dotnet" -Arguments $pdfArguments
    Write-Host $output

    # Run for JSON files
    $jsonArguments = "run --project app/prepdocs/PrepareDocs/PrepareDocs.csproj ./data/**/*.json $commonArgumentsString"
    Write-Host "dotnet $jsonArguments"
    $output = Invoke-ExternalCommand -Command "dotnet" -Arguments $jsonArguments
    Write-Host $output

    azd env set AZD_PREPDOCS_RAN "true"
}
else {
    Write-Host "AZD_PREPDOCS_RAN is set to true. Skipping the run."
}