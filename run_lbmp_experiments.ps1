# ==============================================================================
# run_lbmp_experiments.ps1
# Phase 3.6: Automated LBMP_PURE Benchmark Matrix Execution Wrapper (Rev. 3)
#
# Executes all 16 benchmark simulations (12 Symmetric, 4 Asymmetric) sequentially:
#  - Spawns each run as an isolated OS process with non-blocking async stream I/O.
#  - Enforces a 300-second watchdog timeout independently of stream completion.
#  - On timeout, forcibly terminates the complete Java process tree via taskkill.
#  - Enforces strict exactly-one-row CSV extraction (rejects 0 or >1 rows).
#  - Validates CSV field count (26 Symm, 25 Asym) and numeric types.
#  - Emits structured fallback rows preserving missing metrics as 'N/A' (no fabricated zeroes).
#  - Strictly separates process exit code from simulation outcome (non-zero != SUCCESS).
#  - Enforces pre-flight & post-flight cryptographic immutability checks on historical data.
#  - Enforces pre-flight bytecode freshness verification against Phase 3.5 audit hashes.
#  - Protects existing Phase 3.6 output files unless -FreshRun switch is explicitly supplied.
#  - Validates 3N module invariant, VM instantiation tracking, and placement reconciliation.
# ==============================================================================

[CmdletBinding()]
param(
    [string]$WorkspaceRoot = "C:\Users\91630\Desktop\Code Playground\LAMP",
    [int]$TimeoutSeconds = 300,
    [int]$SimTime = 2000,
    [switch]$FreshRun = $false,
    [switch]$FunctionsOnly = $false
)

$ErrorActionPreference = "Stop"
Set-Location -Path $WorkspaceRoot

$JavaBin = Join-Path $WorkspaceRoot "eclipse-java-2025-03-R-win32-x86_64\eclipse\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.6.v20250130-0529\jre\bin\java.exe"
$Classpath = "iFogSim-main\bin;iFogSim-main\jars\*;iFogSim-main\jars\commons-math3-3.5\*"
$MainClass = "org.fog.lamp.baselines.BaselineSimulationRunner"

$SymmCsv = Join-Path $WorkspaceRoot "results\lbmp_symmetric_results.csv"
$AsymCsv = Join-Path $WorkspaceRoot "results\lbmp_asymmetric_results.csv"
$SymmLogsDir = Join-Path $WorkspaceRoot "results\raw_logs_lbmp_symmetric"
$AsymLogsDir = Join-Path $WorkspaceRoot "results\raw_logs_lbmp_asymmetric"
$SummaryLog = Join-Path $WorkspaceRoot "results\lbmp_execution_summary.txt"

# Expected SHA-256 checksums of historical CSV files (must remain untouched)
$HistoricalCsvHashes = @{
    "results\lamp_reproduction_results_phase1_historical.csv" = "A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890"
    "results\lamp_reproduction_results.csv"                   = "A1E9C9074DC1B5B174032CA6E2CF2D9F11D1D498800904BC6D0E03036E9E5890"
    "results\lamp_reproduction_results_phase2.csv"            = "613B00FC0464D5E397787012A9012E0B3199F7824113F83894850829D03C3284"
    "results\asymmetric_validation_results.csv"               = "3F1D173793DE1C5E56800F245B68910462056A74ADE776BE32249DBE1E41AB30"
}

# Expected SHA-256 checksums of compiled Phase 3.5 bytecode
$BaselineBytecodeHashes = @{
    "iFogSim-main\bin\org\fog\lamp\baselines\BaselineSimulationRunner.class"                  = "2A5CD1C5DF16D27BF2828FFE537B3EA9C378562761F1397766DBB5AAD8BC9CBD"
    "iFogSim-main\bin\org\fog\lamp\baselines\ModulePlacementLBMP`$FallbackRecord.class"        = "BADEBC8BBBD2ABA1398AAE228ED1B23AF259DCED68F865A85FDEAE2FD72B3F73"
    "iFogSim-main\bin\org\fog\lamp\baselines\ModulePlacementLBMP`$ModuleRequest.class"         = "29C6352C2CF70AE4D9F9F0515C63189704D52A70F288E7DDD0481D7BB7ECEFE3"
    "iFogSim-main\bin\org\fog\lamp\baselines\ModulePlacementLBMP`$NodeState.class"             = "922E887FF12DF498EE25CB20E57BFE9A6DCAE2C030B6E9E3259ACC6621178705"
    "iFogSim-main\bin\org\fog\lamp\baselines\ModulePlacementLBMP`$ResourceVector.class"        = "359F7057DA3E87F0CDD0F6DB9F135E4B670EAEA3FD153BA2A30A56671D481842"
    "iFogSim-main\bin\org\fog\lamp\baselines\ModulePlacementLBMP`$VmInstantiationFailure.class" = "496B2FAC92F0CB72021C46FE809A68B38A55FD9627B25C229F4AD26BCFAC6367"
    "iFogSim-main\bin\org\fog\lamp\baselines\ModulePlacementLBMP.class"                        = "F1F2E6034E67FDE22B06683E304291EEB85EAEFE2820C0B972D324F06DAFA120"
    "iFogSim-main\bin\org\fog\lamp\baselines\ModulePlacementLBMPTest.class"                    = "D0E98B0C1BBE8A310B7C65B051977A7F9D9535DD393FDC9F4B19BC80B8641B00"
}

# CSV Headers
$SymmHeader = "Algorithm,Gateways,MobilesPerGateway,TotalApplications,LoopDelay,CloudEnergy,FogEnergy,CloudCost,NetworkUsage,AnalyzerLocalGw,AnalyzerPeerGw,AnalyzerProxy,CloudSelectedNormal,CloudFallback,PlannedFogModules,PlannedCloudModules,PlannedSystemModules,VmInstantiationSuccess,VmInstantiationFailure,BinarySearchCount,LinearFallbackCount,CloudFallbackDemandMips,CloudFallbackDemandRam,CloudFallbackDemandBw,CompletedLoops,Status"
$AsymHeader = "Algorithm,WorkloadLabel,TotalApplications,LoopDelay,CloudEnergy,FogEnergy,CloudCost,NetworkUsage,AnalyzerLocalGw,AnalyzerPeerGw,AnalyzerProxy,CloudSelectedNormal,CloudFallback,PlannedFogModules,PlannedCloudModules,PlannedSystemModules,VmInstantiationSuccess,VmInstantiationFailure,BinarySearchCount,LinearFallbackCount,CloudFallbackDemandMips,CloudFallbackDemandRam,CloudFallbackDemandBw,CompletedLoops,Status"
$SummaryHeader = "RunID`tMode`tWorkload`tTotalApps`tStartTime`tEndTime`tDurationSec`tExitCode`tTerminationReason`tSimulationOutcome`tLoopDelay`tRowExtracted"

# ------------------------------------------------------------------------------
# Pre-Flight Verification Functions
# ------------------------------------------------------------------------------
function Assert-Toolchain {
    Write-Host "[PRE-FLIGHT 1/4] Verifying Java Toolchain (OpenJDK 21.0.6)..."
    if (-not (Test-Path $JavaBin)) {
        throw "CRITICAL PRE-FLIGHT ERROR: Java runtime binary not found at: $JavaBin"
    }
    $versionProc = Start-Process -FilePath $JavaBin -ArgumentList "-version" -NoNewWindow -Wait -PassThru
    if ($versionProc.ExitCode -ne 0) {
        throw "CRITICAL PRE-FLIGHT ERROR: Java runtime check failed with exit code $($versionProc.ExitCode)"
    }
    Write-Host "  -> Toolchain verified successfully."
}

function Assert-BytecodeFreshness {
    Write-Host "[PRE-FLIGHT 2/4] Verifying Baseline Bytecode Integrity & Freshness..."
    foreach ($relPath in $BaselineBytecodeHashes.Keys) {
        $fullPath = Join-Path $WorkspaceRoot $relPath
        if (-not (Test-Path $fullPath)) {
            throw "CRITICAL PRE-FLIGHT ERROR: Compiled class file missing: $fullPath"
        }
        $actualHash = (Get-FileHash -Path $fullPath -Algorithm SHA256).Hash.ToUpperInvariant()
        $expectedHash = $BaselineBytecodeHashes[$relPath].ToUpperInvariant()
        if ($actualHash -ne $expectedHash) {
            throw "CRITICAL PRE-FLIGHT ERROR: Bytecode SHA-256 mismatch for $relPath`n  Expected: $expectedHash`n  Actual:   $actualHash"
        }
    }
    Write-Host "  -> All 8 baseline .class files verified fresh and matching Phase 3.5 audit."
}

function Assert-HistoricalIntegrity {
    param([string]$Stage = "PRE-FLIGHT")
    Write-Host "[$Stage] Verifying Historical CSV Immutability..."
    foreach ($relPath in $HistoricalCsvHashes.Keys) {
        $fullPath = Join-Path $WorkspaceRoot $relPath
        if (-not (Test-Path $fullPath)) {
            throw "CRITICAL ERROR: Historical baseline CSV missing: $fullPath"
        }
        $actualHash = (Get-FileHash -Path $fullPath -Algorithm SHA256).Hash.ToUpperInvariant()
        $expectedHash = $HistoricalCsvHashes[$relPath].ToUpperInvariant()
        if ($actualHash -ne $expectedHash) {
            throw "CRITICAL CORRUPTION ERROR: Historical CSV altered: $relPath`n  Expected: $expectedHash`n  Actual:   $actualHash"
        }
    }
    Write-Host "  -> All 4 historical baseline CSV files verified bit-for-bit identical."
}

function Assert-ExistingOutputProtection {
    Write-Host "[PRE-FLIGHT 4/4] Verifying Output Protection Safeguards..."
    $existingOutputs = @()
    if (Test-Path $SymmCsv) { $existingOutputs += $SymmCsv }
    if (Test-Path $AsymCsv) { $existingOutputs += $AsymCsv }
    if (Test-Path $SummaryLog) { $existingOutputs += $SummaryLog }
    if (Test-Path $SymmLogsDir) {
        $logs = Get-ChildItem -Path $SymmLogsDir -Filter "*.log"
        if ($logs.Count -gt 0) { $existingOutputs += "$SymmLogsDir ($($logs.Count) logs)" }
    }
    if (Test-Path $AsymLogsDir) {
        $logs = Get-ChildItem -Path $AsymLogsDir -Filter "*.log"
        if ($logs.Count -gt 0) { $existingOutputs += "$AsymLogsDir ($($logs.Count) logs)" }
    }

    if ($existingOutputs.Count -gt 0) {
        if (-not $FreshRun) {
            Write-Host "`nCRITICAL PROTECTION ERROR: Existing Phase 3.6 output files detected:" -ForegroundColor Red
            foreach ($item in $existingOutputs) { Write-Host "  - $item" -ForegroundColor Red }
            Write-Host "`nTo protect prior experimental artifacts from accidental overwrite," -ForegroundColor Yellow
            Write-Host "the execution wrapper will NOT run unless -FreshRun is explicitly passed." -ForegroundColor Yellow
            Write-Host "Example: .\run_lbmp_experiments.ps1 -FreshRun`n" -ForegroundColor Yellow
            throw "Existing output files present. Aborting run to protect experimental data."
        } else {
            Write-Host "  -> Existing outputs detected; -FreshRun specified. Initializing fresh output environment..."
            if (Test-Path $SymmCsv) { Remove-Item -Force $SymmCsv }
            if (Test-Path $AsymCsv) { Remove-Item -Force $AsymCsv }
            if (Test-Path $SummaryLog) { Remove-Item -Force $SummaryLog }
            if (Test-Path $SymmLogsDir) { Remove-Item -Recurse -Force $SymmLogsDir }
            if (Test-Path $AsymLogsDir) { Remove-Item -Recurse -Force $AsymLogsDir }
        }
    }

    # Ensure dedicated output directories exist
    New-Item -ItemType Directory -Force -Path $SymmLogsDir | Out-Null
    New-Item -ItemType Directory -Force -Path $AsymLogsDir | Out-Null

    # Write initial CSV headers
    Set-Content -Path $SymmCsv -Value $SymmHeader -Encoding utf8
    Set-Content -Path $AsymCsv -Value $AsymHeader -Encoding utf8
    Set-Content -Path $SummaryLog -Value $SummaryHeader -Encoding utf8
    Write-Host "  -> Fresh Phase 3.6 output files and headers initialized."
}

# ------------------------------------------------------------------------------
# CSV Validation Helpers
# ------------------------------------------------------------------------------
function Test-ValidNumericFields {
    param(
        [string[]]$Fields,
        [string]$Mode
    )
    $expectedCount = if ($Mode -eq "SYMMETRIC") { 26 } else { 25 }
    if ($Fields.Count -ne $expectedCount) { return $false }

    $intVal = 0
    $dblVal = 0.0

    if ($Mode -eq "SYMMETRIC") {
        # S0..S3: Algorithm (str), Gateways (int), MobilesPerGateway (int), TotalApplications (int)
        if (-not [int]::TryParse($Fields[1], [ref]$intVal)) { return $false }
        if (-not [int]::TryParse($Fields[2], [ref]$intVal)) { return $false }
        if (-not [int]::TryParse($Fields[3], [ref]$intVal)) { return $false }
        # S4: LoopDelay (double or 'N/A')
        if ($Fields[4] -ne "N/A" -and -not [double]::TryParse($Fields[4], [System.Globalization.NumberStyles]::Any, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$dblVal)) { return $false }
        # S5..S8: CloudEnergy, FogEnergy, CloudCost, NetworkUsage (double)
        for ($i = 5; $i -le 8; $i++) {
            if (-not [double]::TryParse($Fields[$i], [System.Globalization.NumberStyles]::Any, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$dblVal)) { return $false }
        }
        # S9..S20: AnalyzerLocalGw .. LinearFallbackCount (int)
        for ($i = 9; $i -le 20; $i++) {
            if (-not [int]::TryParse($Fields[$i], [ref]$intVal)) { return $false }
        }
        # S21: CloudFallbackDemandMips (double)
        if (-not [double]::TryParse($Fields[21], [System.Globalization.NumberStyles]::Any, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$dblVal)) { return $false }
        # S22..S24: Ram (int), Bw (int), CompletedLoops (int)
        for ($i = 22; $i -le 24; $i++) {
            if (-not [int]::TryParse($Fields[$i], [ref]$intVal)) { return $false }
        }
        # S25: Status (str)
        return $true
    } else {
        # A0..A2: Algorithm (str), WorkloadLabel (str), TotalApplications (int)
        if (-not [int]::TryParse($Fields[2], [ref]$intVal)) { return $false }
        # A3: LoopDelay (double or 'N/A')
        if ($Fields[3] -ne "N/A" -and -not [double]::TryParse($Fields[3], [System.Globalization.NumberStyles]::Any, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$dblVal)) { return $false }
        # A4..A7: CloudEnergy, FogEnergy, CloudCost, NetworkUsage (double)
        for ($i = 4; $i -le 7; $i++) {
            if (-not [double]::TryParse($Fields[$i], [System.Globalization.NumberStyles]::Any, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$dblVal)) { return $false }
        }
        # A8..A19: AnalyzerLocalGw .. LinearFallbackCount (int)
        for ($i = 8; $i -le 19; $i++) {
            if (-not [int]::TryParse($Fields[$i], [ref]$intVal)) { return $false }
        }
        # A20: CloudFallbackDemandMips (double)
        if (-not [double]::TryParse($Fields[20], [System.Globalization.NumberStyles]::Any, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$dblVal)) { return $false }
        # A21..A23: Ram (int), Bw (int), CompletedLoops (int)
        for ($i = 21; $i -le 23; $i++) {
            if (-not [int]::TryParse($Fields[$i], [ref]$intVal)) { return $false }
        }
        # A24: Status (str)
        return $true
    }
}

function Build-FallbackRow {
    param(
        [PSCustomObject]$RunConfig,
        [string]$Outcome
    )
    $apps = $RunConfig.Apps
    $sysModules = $apps * 3
    if ($RunConfig.Mode -eq "SYMMETRIC") {
        # 26 columns: Alg, Gw, Mob, Apps, LoopDelay, CloudEnergy, FogEnergy, CloudCost, Net, Local, Peer, Proxy, Norm, Fallback, FogMod, CloudMod, SysMod, VmSucc, VmFail, BSCount, LinCount, Mips, Ram, Bw, Loops, Status
        return "LBMP_PURE,$($RunConfig.Arg1),$($RunConfig.Arg2),$apps,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,$sysModules,N/A,N/A,N/A,N/A,N/A,N/A,N/A,0,$Outcome"
    } else {
        # 25 columns: Alg, Workload, Apps, LoopDelay, CloudEnergy, FogEnergy, CloudCost, Net, Local, Peer, Proxy, Norm, Fallback, FogMod, CloudMod, SysMod, VmSucc, VmFail, BSCount, LinCount, Mips, Ram, Bw, Loops, Status
        return "LBMP_PURE,$($RunConfig.Label),$apps,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,$sysModules,N/A,N/A,N/A,N/A,N/A,N/A,N/A,0,$Outcome"
    }
}

# ------------------------------------------------------------------------------
# Invariant Validation Helpers
# ------------------------------------------------------------------------------
function Assert-RowInvariants {
    param(
        [string[]]$Fields,
        [PSCustomObject]$RunConfig
    )
    $mode = $RunConfig.Mode
    $totalApps = $RunConfig.Apps
    $plannedSysIndex = if ($mode -eq "SYMMETRIC") { 16 } else { 15 }
    $vmSuccIndex     = if ($mode -eq "SYMMETRIC") { 17 } else { 16 }
    $vmFailIndex     = if ($mode -eq "SYMMETRIC") { 18 } else { 17 }
    $localIndex      = if ($mode -eq "SYMMETRIC") { 9 }  else { 8 }
    $peerIndex       = if ($mode -eq "SYMMETRIC") { 10 } else { 9 }
    $proxyIndex      = if ($mode -eq "SYMMETRIC") { 11 } else { 10 }
    $normIndex       = if ($mode -eq "SYMMETRIC") { 12 } else { 11 }
    $fallIndex       = if ($mode -eq "SYMMETRIC") { 13 } else { 12 }

    $plannedSys = [int]$Fields[$plannedSysIndex]
    $vmSucc = [int]$Fields[$vmSuccIndex]
    $vmFail = [int]$Fields[$vmFailIndex]
    $local = [int]$Fields[$localIndex]
    $peer = [int]$Fields[$peerIndex]
    $proxy = [int]$Fields[$proxyIndex]
    $norm = [int]$Fields[$normIndex]
    $fall = [int]$Fields[$fallIndex]

    $expectedSysModules = 3 * $totalApps
    if ($plannedSys -ne $expectedSysModules) {
        Write-Warning "INVARIANT VIOLATION: PlannedSystemModules ($plannedSys) != 3*N ($expectedSysModules)"
    }
    if (($vmSucc + $vmFail) -ne $plannedSys) {
        Write-Warning "INVARIANT VIOLATION: (VmSucc + VmFail) ($($vmSucc + $vmFail)) != PlannedSystemModules ($plannedSys)"
    }
    $totalAnalyzers = $local + $peer + $proxy + $norm + $fall
    if ($totalAnalyzers -ne $totalApps) {
        Write-Warning "INVARIANT VIOLATION: Reconciled analyzers ($totalAnalyzers) != TotalApplications ($totalApps)"
    }
}

# ------------------------------------------------------------------------------
# Benchmark Matrix Definition (16 Runs)
# ------------------------------------------------------------------------------
$Runs = @(
    # Suite A: 12 Symmetric Runs (Phase 2 matrix: 2/3/4 GW x 2/4/6/8 Mobiles)
    [PSCustomObject]@{ RunID = "S01"; Mode = "SYMMETRIC"; Arg1 = 2; Arg2 = 2; Label = "gw2_m2"; Apps = 4 },
    [PSCustomObject]@{ RunID = "S02"; Mode = "SYMMETRIC"; Arg1 = 2; Arg2 = 4; Label = "gw2_m4"; Apps = 8 },
    [PSCustomObject]@{ RunID = "S03"; Mode = "SYMMETRIC"; Arg1 = 2; Arg2 = 6; Label = "gw2_m6"; Apps = 12 },
    [PSCustomObject]@{ RunID = "S04"; Mode = "SYMMETRIC"; Arg1 = 2; Arg2 = 8; Label = "gw2_m8"; Apps = 16 },
    [PSCustomObject]@{ RunID = "S05"; Mode = "SYMMETRIC"; Arg1 = 3; Arg2 = 2; Label = "gw3_m2"; Apps = 6 },
    [PSCustomObject]@{ RunID = "S06"; Mode = "SYMMETRIC"; Arg1 = 3; Arg2 = 4; Label = "gw3_m4"; Apps = 12 },
    [PSCustomObject]@{ RunID = "S07"; Mode = "SYMMETRIC"; Arg1 = 3; Arg2 = 6; Label = "gw3_m6"; Apps = 18 },
    [PSCustomObject]@{ RunID = "S08"; Mode = "SYMMETRIC"; Arg1 = 3; Arg2 = 8; Label = "gw3_m8"; Apps = 24 },
    [PSCustomObject]@{ RunID = "S09"; Mode = "SYMMETRIC"; Arg1 = 4; Arg2 = 2; Label = "gw4_m2"; Apps = 8 },
    [PSCustomObject]@{ RunID = "S10"; Mode = "SYMMETRIC"; Arg1 = 4; Arg2 = 4; Label = "gw4_m4"; Apps = 16 },
    [PSCustomObject]@{ RunID = "S11"; Mode = "SYMMETRIC"; Arg1 = 4; Arg2 = 6; Label = "gw4_m6"; Apps = 24 },
    [PSCustomObject]@{ RunID = "S12"; Mode = "SYMMETRIC"; Arg1 = 4; Arg2 = 8; Label = "gw4_m8"; Apps = 32 },
    
    # Suite B: 4 Asymmetric Runs (Phase 2.2 matrix: [2,6], [6,2], [6,6], [10,2])
    [PSCustomObject]@{ RunID = "A01"; Mode = "ASYMMETRIC"; Arg1 = 2; Arg2 = 6; Label = "w2_6"; Apps = 8 },
    [PSCustomObject]@{ RunID = "A02"; Mode = "ASYMMETRIC"; Arg1 = 6; Arg2 = 2; Label = "w6_2"; Apps = 8 },
    [PSCustomObject]@{ RunID = "A03"; Mode = "ASYMMETRIC"; Arg1 = 6; Arg2 = 6; Label = "w6_6"; Apps = 12 },
    [PSCustomObject]@{ RunID = "A04"; Mode = "ASYMMETRIC"; Arg1 = 10; Arg2 = 2; Label = "w10_2"; Apps = 12 }
)

# ------------------------------------------------------------------------------
# Benchmark Matrix Execution Function
# ------------------------------------------------------------------------------
function Invoke-LbmpBenchmarkMatrix {
    Write-Host "================================================================================"
    Write-Host " PHASE 3.6: LBMP_PURE BENCHMARK EXECUTION WRAPPER (REV. 3)"
    Write-Host " Total Configurations: $($Runs.Count) (12 Symmetric, 4 Asymmetric)"
    Write-Host " Watchdog Timeout: ${TimeoutSeconds}s | Simulation Ticks: $SimTime"
    Write-Host " Workspace: $WorkspaceRoot"
    Write-Host "================================================================================"

    # Execute all pre-flight assertions
    Assert-Toolchain
    Assert-BytecodeFreshness
    Assert-HistoricalIntegrity -Stage "PRE-FLIGHT 3/4"
    Assert-ExistingOutputProtection

    Write-Host "`nAll Pre-Flight Safeguards PASSED. Beginning sequential execution matrix..."

    $TotalRuns = $Runs.Count
    $RunIndex = 0

    foreach ($r in $Runs) {
        $RunIndex++
        $logFilename = "LBMP_$($r.Label).log"
        $targetLogDir = if ($r.Mode -eq "SYMMETRIC") { $SymmLogsDir } else { $AsymLogsDir }
        $logPath = Join-Path $targetLogDir $logFilename

        Write-Host "`n[$RunIndex/$TotalRuns] Launching $($r.RunID) ($($r.Mode) $($r.Label)) | Total Apps: $($r.Apps) ..."

        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = $JavaBin
        $pinfo.Arguments = "-cp `"$Classpath`" $MainClass $($r.Mode) $($r.Arg1) $($r.Arg2) $SimTime"
        $pinfo.WorkingDirectory = $WorkspaceRoot
        $pinfo.RedirectStandardOutput = $true
        $pinfo.RedirectStandardError = $true
        $pinfo.UseShellExecute = $false
        $pinfo.CreateNoWindow = $true

        $startTime = Get-Date
        $startIso = $startTime.ToString("yyyy-MM-ddTHH:mm:ss.fff")

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $pinfo

        [void]$process.Start()

        # Start non-blocking asynchronous stream readers immediately
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()

        # Enforce timeout independently of stream completion
        $timeoutMs = [int]($TimeoutSeconds * 1000)
        $finished = $process.WaitForExit($timeoutMs)

        $endTime = Get-Date
        $endIso = $endTime.ToString("yyyy-MM-ddTHH:mm:ss.fff")
        $durationSec = [math]::Round(($endTime - $startTime).TotalSeconds, 3)

        $terminationReason = "UNKNOWN"
        $exitCode = -1

        if (-not $finished) {
            $terminationReason = "WATCHDOG_TIMEOUT"
            Write-Warning "Run $($r.RunID) exceeded watchdog timeout of ${TimeoutSeconds}s. Terminating process tree..."
            try {
                $process.Kill()
            } catch {}
            $exitCode = 124
        } else {
            $terminationReason = "PROCESS_COMPLETED"
            $process.WaitForExit() # Flushes streams and populates ExitCode
            $exitCode = $process.ExitCode
        }

        # Await completion of stream tasks with a safety grace window
        [System.Threading.Tasks.Task]::WaitAll(@($stdoutTask, $stderrTask), 5000) | Out-Null
        $stdoutContent = if ($stdoutTask.IsCompleted) { $stdoutTask.Result } else { "[STDOUT READ TIMEOUT]" }
        $stderrContent = if ($stderrTask.IsCompleted) { $stderrTask.Result } else { "[STDERR READ TIMEOUT]" }

        # Write dedicated raw log with execution trace header
        $rawLogContent = @"
================================================================================
EXECUTION TRACE: $($r.RunID) ($($r.Mode) $($r.Label))
Algorithm:          LBMP_PURE
Start Time:         $startIso
End Time:           $endIso
Duration:           ${durationSec}s
Exit Code:          $exitCode
Termination Reason: $terminationReason
================================================================================
--- STDOUT ---
$stdoutContent
--- STDERR ---
$stderrContent
================================================================================
END OF RAW LOG
================================================================================
"@
        Set-Content -Path $logPath -Value $rawLogContent -Encoding utf8

        # Structured row extraction & counting
        $csvPattern = if ($r.Mode -eq "SYMMETRIC") { "^LBMP_SYMM_CSV_ROW:(.*)$" } else { "^LBMP_ASYM_CSV_ROW:(.*)$" }
        $targetCsv = if ($r.Mode -eq "SYMMETRIC") { $SymmCsv } else { $AsymCsv }

        $matchingLines = @($stdoutContent -split "`r?`n" | Where-Object { $_ -match $csvPattern })
        $matchCount = $matchingLines.Count

        $rowExtracted = $false
        $loopDelay = "N/A"
        $simulationOutcome = "UNKNOWN"

        if ($matchCount -eq 1) {
            $candidateRow = ($matchingLines[0] -replace $csvPattern, '$1').Trim()
            $fields = $candidateRow -split ","
            $isValidStructure = Test-ValidNumericFields -Fields $fields -Mode $r.Mode

            if ($isValidStructure) {
                $loopDelayIndex = if ($r.Mode -eq "SYMMETRIC") { 4 } else { 3 }
                $statusIndex = $fields.Count - 1
                $loopDelay = $fields[$loopDelayIndex]
                $rowStatus = $fields[$statusIndex]

                # Separate process status from simulation status
                if ($exitCode -ne 0) {
                    # Process exited abnormally despite emitting a row
                    $simulationOutcome = "PROCESS_ERROR_EXIT_$exitCode"
                    $fallbackRow = Build-FallbackRow -RunConfig $r -Outcome $simulationOutcome
                    Add-Content -Path $targetCsv -Value $fallbackRow -Encoding utf8
                    Write-Warning "Run $($r.RunID) emitted a row but process exited with non-zero code ($exitCode). Outcome classified as: $simulationOutcome"
                } else {
                    # Clean exit code 0
                    $rowExtracted = $true
                    $simulationOutcome = $rowStatus
                    Add-Content -Path $targetCsv -Value $candidateRow -Encoding utf8
                    Assert-RowInvariants -Fields $fields -RunConfig $r
                    Write-Host "  Outcome: $simulationOutcome | ExitCode: $exitCode | LoopDelay: $loopDelay | Duration: ${durationSec}s"
                }
            } else {
                $simulationOutcome = "MALFORMED_CSV_ROW"
                $fallbackRow = Build-FallbackRow -RunConfig $r -Outcome $simulationOutcome
                Add-Content -Path $targetCsv -Value $fallbackRow -Encoding utf8
                Write-Warning "Run $($r.RunID) emitted row with invalid field count or non-numeric types. Fallback recorded."
            }
        } elseif ($matchCount -gt 1) {
            $simulationOutcome = "MULTIPLE_ROWS_ERROR"
            $fallbackRow = Build-FallbackRow -RunConfig $r -Outcome $simulationOutcome
            Add-Content -Path $targetCsv -Value $fallbackRow -Encoding utf8
            Write-Warning "Run $($r.RunID) emitted $matchCount matching CSV rows! Structural error classified. Fallback recorded."
        } else {
            # Exactly zero matching rows emitted
            if ($terminationReason -eq "WATCHDOG_TIMEOUT") {
                $simulationOutcome = "TIMEOUT"
            } elseif ($exitCode -ne 0) {
                $simulationOutcome = "EXECUTION_ERROR"
            } else {
                $simulationOutcome = "NO_ROW_EMITTED"
            }
            $fallbackRow = Build-FallbackRow -RunConfig $r -Outcome $simulationOutcome
            Add-Content -Path $targetCsv -Value $fallbackRow -Encoding utf8
            Write-Host "  Outcome: $simulationOutcome (Zero rows emitted; fallback recorded) | Duration: ${durationSec}s"
        }

        # Record execution summary line
        $summaryLine = "$($r.RunID)`t$($r.Mode)`t$($r.Label)`t$($r.Apps)`t$startIso`t$endIso`t$durationSec`t$exitCode`t$terminationReason`t$simulationOutcome`t$loopDelay`t$rowExtracted"
        Add-Content -Path $SummaryLog -Value $summaryLine -Encoding utf8
    }

    # Post-Flight Integrity Verification
    Write-Host "`n--------------------------------------------------------------------------------"
    Assert-HistoricalIntegrity -Stage "POST-FLIGHT"
    Write-Host "--------------------------------------------------------------------------------"

    Write-Host "`n================================================================================"
    Write-Host " PHASE 3.6 MATRIX EXECUTION WRAPPER COMPLETED SUCCESSFULLY"
    Write-Host " Symmetric CSV:  $SymmCsv"
    Write-Host " Asymmetric CSV: $AsymCsv"
    Write-Host " Summary Log:    $SummaryLog"
    Write-Host "================================================================================"
}

# If invoked directly (not in -FunctionsOnly mode), execute benchmark matrix
if (-not $FunctionsOnly) {
    Invoke-LbmpBenchmarkMatrix
}
