# Set base paths
$JobsRoot = "C:\Users\nutthkon\Desktop\test\jobs"
$OutputRoot = "C:\Users\nutthkon\Documents\GitHub\allpay\deployment\pipeline"

# Get all config.xml files
$configFiles = Get-ChildItem -Path $JobsRoot -Recurse -Filter "config.xml"

foreach ($config in $configFiles) {
    try {
        # Read as text and replace version 1.1 with 1.0
        $rawXml = Get-Content $config.FullName -Raw
        $rawXml = $rawXml -replace "version='1.1'", "version='1.0'"

        # Parse as XML
        [xml]$xml = $rawXml

        # Get job name from path
        $jobName = Split-Path -Parent $config.FullName | Split-Path -Leaf

        # Extract pipeline script
        $pipelineScript = $xml.'flow-definition'.definition.script

        if (-not [string]::IsNullOrWhiteSpace($pipelineScript)) {
            # Output path: ./pipeline/<jobName>/Jenkinsfile
            $jobOutputDir = Join-Path $OutputRoot $jobName
            New-Item -ItemType Directory -Force -Path $jobOutputDir | Out-Null
            $outputFile = Join-Path $jobOutputDir "jenkinsfile"

            $pipelineScript | Out-File -Encoding UTF8 -FilePath $outputFile
            Write-Host "✔️  Backed up $jobName pipeline to $outputFile"
        }
        else {
            Write-Warning "⚠️  No pipeline script found in job '$jobName'. Skipping."
        }
    } catch {
        Write-Warning "❌ Failed to process: $($config.FullName). Error: $_"
    }
}
