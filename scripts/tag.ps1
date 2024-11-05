param (
    [ValidateSet("major", "minor", "patch", "-")]
    [Parameter(Mandatory=$true)]
    [string]$AllPayWeb,
    [ValidateSet("major", "minor", "patch", "-")]
    [Parameter(Mandatory=$true)]
    [string]$AllPayWebAPI,
    [ValidateSet("major", "minor", "patch", "-")]
    [Parameter(Mandatory=$true)]
    [string]$VendorPortalWeb,
    [ValidateSet("major", "minor", "patch", "-")]
    [Parameter(Mandatory=$true)]
    [string]$VendorPortalWebAPI,
    [ValidateSet("major", "minor", "patch", "-")]
    [Parameter(Mandatory=$true)]
    [string]$MQService,
    [ValidateSet("major", "minor", "patch", "-")]
    [Parameter(Mandatory=$true)]
    [string]$BGService,
    [ValidateSet("major", "minor", "patch", "-")]
    [Parameter(Mandatory=$true)]
    [string]$DBMigration
)


function ResolveNewVersion {
    param (
        [string]$oldversion,
        [ValidateSet("major", "minor", "patch")]
        [string]$incrementPart = "patch"  # Default to incrementing the patch
    )

    # Remove the 'v' prefix if present and split the version into parts
    $versionParts = $oldversion.TrimStart('v').Split('.')

    # Ensure that we have exactly 3 parts (major, minor, patch)
    if ($versionParts.Count -ne 3) {
        throw "Invalid version format. Expected format: v<major>.<minor>.<patch>"
    }

    # Convert the version parts to integers
    $majorVersion = [int]$versionParts[0]
    $minorVersion = [int]$versionParts[1]
    $patchVersion = [int]$versionParts[2]

    # Increment the appropriate part based on the parameter passed
    switch ($incrementPart) {
        "major" {
            $majorVersion++
            # Reset minor and patch when major is incremented
            $minorVersion = 0
            $patchVersion = 0
        }
        "minor" {
            $minorVersion++
            # Reset patch when minor is incremented
            $patchVersion = 0
        }
        "patch" {
            $patchVersion++
        }
    }

    # Rebuild the version string with the updated values
    $newVersion = "v{0}.{1}.{2}" -f $majorVersion, $minorVersion, $patchVersion

    # Return the new version
    return $newVersion
}

if ($AllPayWeb -ne "-") {
    try {
        Set-Location .\AllPayVendorWeb
        git fetch --all
        git checkout main
        git pull
        npm version $AllPayWeb
        git push
        git push --tag
        Write-Host "Tag allpay-web success: $(git describe --abbrev=0 --tags)" -ForegroundColor Green
    }
    catch {
        Write-Host "Tag allpay-web error: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        Set-Location ..
    }
}

if ($VendorPortalWeb -ne "-") {
    try {
        Set-Location .\VendorPortalWeb
        git fetch --all
        git checkout main
        git pull
        npm version patch
        git push
        git push --tag
        Write-Host "Tag vendor-portal-web success: $(git describe --abbrev=0 --tags)" -ForegroundColor Green
    }
    catch {
        Write-Host "Tag vendor-portal-web error: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        Set-Location ..
    }
}

if ($MQService -ne "-") {
    try {
        Set-Location .\AllpayMQWorker
        git fetch --all
        git checkout main
        git pull
        $lastVersion = (git describe --abbrev=0 --tags)
        $newVersion = ResolveNewVersion -oldversion $lastVersion -incrementPart $MQService
        git tag $newVersion
        git push --tag
        Write-Host "Tag mq-service success: $(git describe --abbrev=0 --tags)" -ForegroundColor Green
    }
    catch {
        Write-Host "Tag mq-service error: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        Set-Location ..
    }
}

if ($BGService -ne "-") {
    try {
        Set-Location .\AllPayVendorBackgroundService
        git fetch --all
        git checkout main
        git pull
        $lastVersion = (git describe --abbrev=0 --tags)
        $newVersion = ResolveNewVersion -oldversion $lastVersion -incrementPart $BGService
        git tag $newVersion
        git push --tag
        Write-Host "Tag background-service success: $(git describe --abbrev=0 --tags)" -ForegroundColor Green
    }
    catch {
        Write-Host "Tag background-service error: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        Set-Location ..
    }
}

if ($AllPayWebAPI -ne "-") {
    try {
        Set-Location .\AllPayVendorApi
        git fetch --all
        git checkout main
        git pull
        $lastVersion = (git describe --abbrev=0 --tags)
        $newVersion = ResolveNewVersion -oldversion $lastVersion -incrementPart $AllPayWebAPI
        git tag $newVersion
        git push --tag
        Write-Host "Tag allpay-api success: $(git describe --abbrev=0 --tags)" -ForegroundColor Green
    }
    catch {
        Write-Host "Tag allpay-api error: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        Set-Location ..
    }
}

if ($VendorPortalWebAPI -ne "-") {
    try {
        Set-Location .\VendorPortalApi
        git fetch --all
        git checkout main
        git pull
        $lastVersion = (git describe --abbrev=0 --tags)
        $newVersion = ResolveNewVersion -oldversion $lastVersion -incrementPart $VendorPortalWebAPI
        git tag $newVersion
        git push --tag
        Write-Host "Tag vendor-portal-api success: $(git describe --abbrev=0 --tags)" -ForegroundColor Green
    }
    catch {
        Write-Host "Tag vendor-portal-api error: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        Set-Location ..
    }
}

if ($DBMigration -ne "-") {
    try {
        Set-Location .\AllPayVendorDatabase
        git fetch --all
        git checkout main
        git pull
        $lastVersion = (git describe --abbrev=0 --tags)
        $newVersion = ResolveNewVersion -oldversion $lastVersion -incrementPart $DBMigration
        git tag $newVersion
        git push --tag
        Write-Host "Tag db-migration success: $(git describe --abbrev=0 --tags)" -ForegroundColor Green
    }
    catch {
        Write-Host "Tag db-migration error: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        Set-Location ..
    }
}




