[CmdletBinding()]
param(
    # Setup only prepares the project unless opening VS Code is explicitly requested.
    [switch]$OpenVSCode,
    [switch]$SkipVSCodeInstall
)

$ErrorActionPreference = 'Stop'

function Write-Status {
    param(
        [Parameter(Mandatory = $true)][ValidateSet('CHECK', 'PASS', 'INFO', 'WARN', 'FAIL')][string]$Kind,
        [Parameter(Mandatory = $true)][string]$Message
    )
    Write-Host "[$Kind] $Message"
}

function Test-DotNet10Sdk {
    param([Parameter(Mandatory = $true)][string]$Command)
    try {
        $sdks = & $Command --list-sdks 2>$null
        return $LASTEXITCODE -eq 0 -and ($sdks -match '(?m)^\s*10\.\d+\.\d+\s+\[')
    }
    catch { return $false }
}

function Add-UserPathEntry {
    param([Parameter(Mandatory = $true)][string]$Directory)

    # PATH is the list of folders Windows searches when you type a command.
    # Add a user-level tool now and for future terminals without admin rights.
    $separator = [System.IO.Path]::PathSeparator
    $stored = [Environment]::GetEnvironmentVariable('Path', 'User')
    $entries = @($stored -split [regex]::Escape([string]$separator) | Where-Object { $_ })
    if ($entries -notcontains $Directory) {
        [Environment]::SetEnvironmentVariable('Path', ((@($entries) + $Directory) -join $separator), 'User')
    }
    if (($env:Path -split [regex]::Escape([string]$separator)) -notcontains $Directory) {
        $env:Path = "$Directory$separator$env:Path"
    }
}

function Get-VisualStudioCode {
    # VS Code may be installed while its command has not yet appeared on PATH.
    $codeCommand = Get-Command code -ErrorAction SilentlyContinue
    if ($null -ne $codeCommand) {
        return [pscustomobject]@{ EditorPath = $codeCommand.Source; CliPath = $codeCommand.Source; Source = 'PATH' }
    }

    $roots = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code'),
        (Join-Path $env:ProgramFiles 'Microsoft VS Code')
    )
    if (${env:ProgramFiles(x86)}) {
        $roots += Join-Path ${env:ProgramFiles(x86)} 'Microsoft VS Code'
    }

    foreach ($root in $roots | Where-Object { $_ }) {
        $editor = Join-Path $root 'Code.exe'
        if (Test-Path -LiteralPath $editor) {
            $cli = @((Join-Path $root 'bin\code.cmd'), (Join-Path $root 'bin\code')) |
                Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
            return [pscustomobject]@{
                EditorPath = $editor
                CliPath = if ($null -ne $cli) { $cli } else { $editor }
                Source = $root
            }
        }
    }
    return $null
}

function Install-VisualStudioCode {
    # Prefer per-user setup: a student account should not need administrator access.
    Write-Status INFO 'Visual Studio Code is the editor used for this module.'
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($null -ne $winget) {
        Write-Status INFO 'Trying the official Microsoft Visual Studio Code package through winget.'
        & $winget.Source install --id Microsoft.VisualStudioCode --exact --scope user --accept-source-agreements --accept-package-agreements --silent --disable-interactivity
        if ($LASTEXITCODE -eq 0) {
            $found = Get-VisualStudioCode
            if ($null -ne $found) { return $found }
            Write-Status WARN 'winget completed, but VS Code could not yet be found.'
        }
        else {
            Write-Status WARN "winget could not install VS Code (exit code $LASTEXITCODE)."
        }
    }
    else {
        Write-Status WARN 'winget is not available on this PC.'
    }

    # Official Microsoft fallback: the VS Code User Setup installer never requests elevation.
    $installer = Join-Path $env:TEMP 'BFC-Assessment1-VSCodeUserSetup.exe'
    try {
        Write-Status INFO 'Trying the official Visual Studio Code User Setup installer.'
        Invoke-WebRequest -Uri 'https://update.code.visualstudio.com/latest/win32-x64-user/stable' -OutFile $installer -UseBasicParsing
        & $installer /VERYSILENT /NORESTART /MERGETASKS=!runcode
        if ($LASTEXITCODE -ne 0) {
            Write-Status WARN "The VS Code User Setup installer exited with code $LASTEXITCODE."
            return $null
        }
        return Get-VisualStudioCode
    }
    catch {
        Write-Status WARN "VS Code could not be installed automatically: $($_.Exception.Message)"
        return $null
    }
    finally {
        if (Test-Path -LiteralPath $installer) { Remove-Item -LiteralPath $installer -Force }
    }
}

function Add-UserDotNetPath {
    param([Parameter(Mandatory = $true)][string]$InstallDirectory)
    Add-UserPathEntry -Directory $InstallDirectory
    [Environment]::SetEnvironmentVariable('DOTNET_ROOT', $InstallDirectory, 'User')
    $env:DOTNET_ROOT = $InstallDirectory
}

function Install-UserDotNet10Sdk {
    # An SDK includes the compiler and build tools, not just a runtime.
    Write-Status CHECK 'A .NET 10 SDK was not found. Attempting an official user-level installation.'
    $directory = Join-Path $env:LOCALAPPDATA 'BFC-AGP\dotnet'
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $installer = Join-Path $env:TEMP 'bfc-agp-dotnet-install.ps1'
    try {
        Invoke-WebRequest -Uri 'https://dot.net/v1/dotnet-install.ps1' -OutFile $installer -UseBasicParsing
        & $installer -Channel '10.0' -Quality 'GA' -InstallDir $directory -NoPath
        if ($LASTEXITCODE -ne 0) { throw "The official .NET installer exited with code $LASTEXITCODE." }
    }
    finally {
        if (Test-Path -LiteralPath $installer) { Remove-Item -LiteralPath $installer -Force }
    }
    Add-UserDotNetPath -InstallDirectory $directory
    $candidate = Join-Path $directory 'dotnet.exe'
    if (-not (Test-Path -LiteralPath $candidate) -or -not (Test-DotNet10Sdk -Command $candidate)) {
        throw 'A compatible .NET 10 SDK was not available after installation. Ask college IT to install it, then run setup again.'
    }
    return $candidate
}

function Invoke-DotNetStep {
    param(
        [Parameter(Mandatory = $true)][string]$DotNetCommand,
        [Parameter(Mandatory = $true)][string]$Stage,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )
    Write-Status INFO "${Stage}: dotnet $($Arguments -join ' ')"
    & $DotNetCommand @Arguments
    if ($LASTEXITCODE -ne 0) {
        # A non-zero exit code means the program reported a failed step.
        throw "$Stage failed (exit code $LASTEXITCODE)."
    }
}

function Ensure-NuGetOrgSource {
    param([Parameter(Mandatory = $true)][string]$DotNetCommand)

    # MonoGame packages are published on nuget.org. A number of managed
    # college PCs have only the .NET SDK's offline sources enabled, which
    # produces NU1101 for every MonoGame package. Keep this repair user-level,
    # repeatable and safe to run on every setup attempt.
    $sourceUrl = 'https://api.nuget.org/v3/index.json'
    Write-Status CHECK 'Checking the NuGet.org package source used by MonoGame.'

    $sourceOutput = @(& $DotNetCommand nuget list source 2>&1 | ForEach-Object { [string]$_ })
    $sourceExitCode = $LASTEXITCODE
    if ($sourceExitCode -ne 0) {
        $detail = ($sourceOutput -join ' ').Trim()
        if ([string]::IsNullOrWhiteSpace($detail)) { $detail = 'the dotnet command did not provide additional details' }
        throw "Could not inspect NuGet sources: $detail"
    }

    $urlIndex = -1
    for ($index = 0; $index -lt $sourceOutput.Count; $index++) {
        if ($sourceOutput[$index].Trim() -eq $sourceUrl) {
            $urlIndex = $index
            break
        }
    }

    if ($urlIndex -ge 0) {
        $sourceName = $null
        $sourceState = 'Enabled'
        for ($index = $urlIndex - 1; $index -ge 0 -and $index -ge ($urlIndex - 4); $index--) {
            if ($sourceOutput[$index] -match '^\s*(?:\d+\.\s*)?(?<name>.+?)\s+\[(?<state>Enabled|Disabled)\]\s*$') {
                $sourceName = $Matches['name'].Trim()
                $sourceState = $Matches['state']
                break
            }
        }

        if ($sourceState -eq 'Disabled' -and -not [string]::IsNullOrWhiteSpace($sourceName)) {
            Write-Status INFO "NuGet.org is registered as '$sourceName' but disabled; enabling it for this user."
            & $DotNetCommand nuget enable source --name $sourceName
            if ($LASTEXITCODE -ne 0) {
                throw "NuGet.org could not be enabled. Run 'dotnet nuget enable source --name $sourceName' and retry setup."
            }
        }
        Write-Status PASS 'NuGet.org source is available for package restore.'
        return
    }

    Write-Status INFO 'NuGet.org is not registered. Adding the official source for this user.'
    $addOutput = @(& $DotNetCommand nuget add source $sourceUrl --name 'nuget.org' 2>&1 | ForEach-Object { [string]$_ })
    $addExitCode = $LASTEXITCODE
    if ($addExitCode -ne 0) {
        $detail = ($addOutput -join ' ').Trim()
        if ([string]::IsNullOrWhiteSpace($detail)) { $detail = 'the dotnet command did not provide additional details' }
        throw "NuGet.org could not be added: $detail"
    }

    Write-Status PASS 'NuGet.org source was added for this user.'
}

try {
    # Use this file's own folder, so double-clicking works from anywhere.
    $projectRoot = Split-Path -Parent $PSCommandPath
    Set-Location -LiteralPath $projectRoot
    Write-Status INFO "Preparing Assessment 1 at: $projectRoot"
    Write-Status INFO 'This setup is safe to run again; it rechecks tools and reuses restored packages.'

    $isWindows = $env:OS -eq 'Windows_NT'
    $platformProject = if ($isWindows) { 'WindowsDX/Platformer3D.csproj' } else { 'DesktopGL/Platformer3D.csproj' }
    $platformName = if ($isWindows) { 'WindowsDX' } else { 'DesktopGL' }
    Write-Status PASS "Operating-system target: $platformName"

    $vsCode = $null
    if ($isWindows) {
        Write-Status CHECK 'Looking for Visual Studio Code.'
        $vsCode = Get-VisualStudioCode
        if ($null -eq $vsCode -and -not $SkipVSCodeInstall) { $vsCode = Install-VisualStudioCode }
        if ($null -ne $vsCode) {
            Write-Status PASS "Visual Studio Code found: $($vsCode.EditorPath)"
        }
        else {
            Write-Status WARN 'VS Code is still unavailable. The build can continue, but college IT may need to provide it.'
        }
    }

    Write-Status CHECK 'Looking for a compatible .NET 10 SDK.'
    Write-Status INFO 'The SDK contains the compiler and development tools used to build the C# project.'
    $dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
    if ($null -ne $dotnet -and (Test-DotNet10Sdk -Command $dotnet.Source)) {
        $dotnetCommand = $dotnet.Source
        Write-Status PASS "Using installed .NET SDK: $((& $dotnetCommand --version).Trim())"
    }
    elseif ($isWindows) {
        $userDotnet = Join-Path $env:LOCALAPPDATA 'BFC-AGP\dotnet\dotnet.exe'
        if (Test-Path -LiteralPath $userDotnet -and (Test-DotNet10Sdk -Command $userDotnet)) {
            Add-UserDotNetPath -InstallDirectory (Split-Path -Parent $userDotnet)
            $dotnetCommand = $userDotnet
            Write-Status PASS "Using existing user-level .NET SDK: $((& $dotnetCommand --version).Trim())"
        }
        else {
            $dotnetCommand = Install-UserDotNet10Sdk
            Write-Status PASS "Installed user-level .NET SDK: $((& $dotnetCommand --version).Trim())"
        }
    }
    else {
        throw 'A .NET 10 SDK is required. Install it from https://dotnet.microsoft.com/download/dotnet/10.0 and run setup again.'
    }

    Ensure-NuGetOrgSource -DotNetCommand $dotnetCommand

    $extensions = @{}
    if ($null -ne $vsCode) {
        foreach ($extension in @(
            [pscustomobject]@{ Id = 'ms-dotnettools.csdevkit'; Name = 'C# Dev Kit'; Purpose = 'C# editing, debugging and project support' },
            [pscustomobject]@{ Id = 'timgjones.hlsltools'; Name = 'HLSL Tools'; Purpose = 'shader-file syntax and language support' }
        )) {
            Write-Status INFO "Preparing $($extension.Name): $($extension.Purpose)."
            & $vsCode.CliPath --install-extension $extension.Id | Write-Output
            $extensions[$extension.Name] = $LASTEXITCODE -eq 0
            if ($extensions[$extension.Name]) {
                Write-Status PASS "$($extension.Name): ready"
            }
            else {
                Write-Status WARN "$($extension.Name) could not be installed automatically. In VS Code, install $($extension.Id)."
            }
        }
    }

    # Restore downloads NuGet libraries first. Content must be restored before
    # the game project because MonoGame processes those assets during build.
    Write-Status INFO 'Restoring NuGet packages. Restore downloads the libraries this project depends on.'
    Invoke-DotNetStep -DotNetCommand $dotnetCommand -Stage 'Restore Content' -Arguments @('restore', './Content/Content.csproj')
    Invoke-DotNetStep -DotNetCommand $dotnetCommand -Stage "Restore $platformName" -Arguments @('restore', "./$platformProject")
    Write-Status INFO "Building $platformName. This compiles C# and processes MonoGame content."
    Invoke-DotNetStep -DotNetCommand $dotnetCommand -Stage "Build $platformName" -Arguments @('build', "./$platformProject", '--no-restore')

    Write-Host ''
    Write-Status PASS 'ASSESSMENT 1 SETUP COMPLETE'
    Write-Status INFO "Visual Studio Code: $(if ($null -ne $vsCode) { 'ready' } else { 'needs attention' })"
    Write-Status INFO '.NET 10 SDK: ready'
    Write-Status INFO "C# Dev Kit: $(if ($extensions['C# Dev Kit']) { 'ready' } else { 'check VS Code Extensions' })"
    Write-Status INFO "HLSL Tools: $(if ($extensions['HLSL Tools']) { 'ready' } else { 'check VS Code Extensions' })"
    Write-Status INFO 'MonoGame dependencies: restored'
    Write-Status INFO "$platformName build: passed"
    if ($null -ne $vsCode) {
        Write-Status INFO "Open this folder in VS Code with: & '$($vsCode.CliPath)' '$projectRoot'"
        Write-Status INFO "Then press F5 with $platformName selected, or run: dotnet run --project ./$platformProject"
        if ($OpenVSCode) { & $vsCode.CliPath $projectRoot }
    }
    else {
        Write-Status INFO "Run the game with: dotnet run --project ./$platformProject"
    }
}
catch {
    Write-Status FAIL $_.Exception.Message
    exit 1
}
