# =====================================================================
#  Phase 1 - 개발환경 확인 스크립트 (Windows PowerShell 5.1 이상)
#
#  이 스크립트는 "확인만" 합니다. 아무 프로그램도 설치/변경/삭제하지 않습니다.
#  결과는 화면에 표시되고, 같은 폴더의 env-report.txt 에도 저장됩니다.
#  (env-report.txt 는 .gitignore 에 등록되어 Git에 올라가지 않습니다)
#
#  실행 방법: check-env.bat 을 더블클릭하거나,
#            PowerShell 에서  .\tools\windows\check-env.bat
# =====================================================================

$ErrorActionPreference = 'Continue'
$reportPath = Join-Path $PSScriptRoot 'env-report.txt'
$results = New-Object System.Collections.Generic.List[object]
$lines = New-Object System.Collections.Generic.List[string]

function Write-Line([string]$text, [string]$color = 'Gray') {
    Write-Host $text -ForegroundColor $color
    $lines.Add($text) | Out-Null
}

# 명령어를 실행해서 첫 줄(버전 정보)을 돌려줍니다. 명령어가 없으면 $null.
function Get-CommandVersion([string]$command, [string[]]$arguments) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) { return $null }
    try {
        # java 등은 버전을 stderr(오류 출력)로 내보내므로 2>&1 로 합쳐서 읽습니다.
        $output = & $command @arguments 2>&1 | ForEach-Object { "$_" } |
            Where-Object { $_.Trim() -and $_ -notmatch 'JAVA_TOOL_OPTIONS' -and $_ -notmatch '^-+$' }
        $first = $output | Select-Object -First 1
        if (-not $first) { return '설치됨 (버전 출력 없음)' }
        return $first.Trim()
    } catch {
        return "실행 오류: $($_.Exception.Message)"
    }
}

function Add-Result([string]$name, [string]$value, [string]$neededFrom, [bool]$required) {
    $ok = [bool]$value
    $results.Add([pscustomobject]@{
        Name = $name; Ok = $ok; Value = $(if ($ok) { $value } else { '설치 안 됨 / 찾을 수 없음' })
        NeededFrom = $neededFrom; Required = $required
    }) | Out-Null
}

Write-Line '====================================================='
Write-Line ' Unitconnect Thermal PoC - Phase 1 개발환경 확인' 'Cyan'
Write-Line " 실행 시각: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Line '====================================================='

# ---- 1. OS -----------------------------------------------------------
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $osText = "$($os.Caption) (버전 $($os.Version), $($os.OSArchitecture))"
} catch {
    $osText = [System.Environment]::OSVersion.VersionString
}
Add-Result 'OS' $osText '-' $true

# ---- 2. Java (Spring Boot 서버용) -------------------------------------
Add-Result 'Java (java)'  (Get-CommandVersion 'java'  @('-version')) 'Phase 2' $true
Add-Result 'Java 컴파일러 (javac)' (Get-CommandVersion 'javac' @('-version')) 'Phase 2' $true
$javaHome = if ($env:JAVA_HOME) { $env:JAVA_HOME } else { $null }
Add-Result 'JAVA_HOME 환경변수' $javaHome 'Phase 2' $false

# ---- 3. Node.js / npm (현재 필수 아님) --------------------------------
Add-Result 'Node.js' (Get-CommandVersion 'node' @('-v')) '선택' $false
Add-Result 'npm'     (Get-CommandVersion 'npm'  @('-v')) '선택' $false

# ---- 4. Docker (MySQL 을 Docker 로 띄울 경우) --------------------------
Add-Result 'Docker' (Get-CommandVersion 'docker' @('--version')) 'Phase 3 (선택)' $false

# ---- 5. MySQL --------------------------------------------------------
$mysqlVersion = Get-CommandVersion 'mysql' @('--version')
if (-not $mysqlVersion) {
    # PATH 에 없어도 기본 설치 폴더에 있을 수 있으므로 한 번 더 찾아봅니다.
    $mysqlDir = "$env:ProgramFiles\MySQL"
    if ($env:ProgramFiles -and (Test-Path $mysqlDir)) {
        $mysqlExe = Get-ChildItem $mysqlDir -Recurse -Filter mysql.exe -ErrorAction SilentlyContinue |
            Select-Object -First 1
    }
    if ($mysqlExe) { $mysqlVersion = "PATH 미등록, 설치 위치: $($mysqlExe.FullName)" }
}
Add-Result 'MySQL 클라이언트' $mysqlVersion 'Phase 3' $false
$mysqlService = Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'MySQL*' } |
    ForEach-Object { "$($_.Name) ($($_.Status))" }
Add-Result 'MySQL 서비스(서버)' ($mysqlService -join ', ') 'Phase 3' $false
# MySQL 은 PC 에 직접 설치하거나 Docker 로 실행할 수 있으므로 둘 중 하나만 있으면 됩니다.
$dockerOk = ($results | Where-Object { $_.Name -eq 'Docker' }).Ok
$dbWay = if ($mysqlService) { 'MySQL 서버 직접 설치됨' } elseif ($dockerOk) { 'Docker 로 MySQL 실행 가능' } else { $null }
Add-Result 'DB 실행 방법 (MySQL 또는 Docker)' $dbWay 'Phase 3' $true

# ---- 6. Android Studio / SDK ----------------------------------------
$studioPaths = @(
    "$env:ProgramFiles\Android\Android Studio",
    "${env:ProgramFiles(x86)}\Android\Android Studio",
    "$env:LOCALAPPDATA\Programs\Android Studio",
    "$env:LOCALAPPDATA\JetBrains\Toolbox\apps\AndroidStudio"
)
$studio = $studioPaths | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
Add-Result 'Android Studio' $studio 'Phase 6' $true

$sdk = @($env:ANDROID_HOME, $env:ANDROID_SDK_ROOT, "$env:LOCALAPPDATA\Android\Sdk") |
    Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
Add-Result 'Android SDK' $sdk 'Phase 6' $false
$adb = Get-CommandVersion 'adb' @('--version')
if (-not $adb -and $sdk -and (Test-Path "$sdk\platform-tools\adb.exe")) {
    $adb = "PATH 미등록, 위치: $sdk\platform-tools\adb.exe"
}
Add-Result 'adb (스마트폰 연결 도구)' $adb 'Phase 6' $false

# ---- 7. Flutter (현재 계획은 Android 네이티브라 선택) -------------------
Add-Result 'Flutter' (Get-CommandVersion 'flutter' @('--version')) '선택' $false

# ---- 8. Git ---------------------------------------------------------
Add-Result 'Git' (Get-CommandVersion 'git' @('--version')) 'Phase 2' $true

# ---- 9. 빌드 도구 (없어도 프로젝트에 포함된 Wrapper 로 동작) -------------
Add-Result 'Maven (mvn)' (Get-CommandVersion 'mvn' @('-v')) '선택 (Wrapper 사용)' $false
Add-Result 'Gradle'      (Get-CommandVersion 'gradle' @('-v')) '선택 (Wrapper 사용)' $false

# ---- 결과 출력 ------------------------------------------------------
Write-Line ''
foreach ($r in $results) {
    $mark  = if ($r.Ok) { '[ OK ]' } elseif ($r.Required) { '[없음]' } else { '[선택]' }
    $color = if ($r.Ok) { 'Green' } elseif ($r.Required) { 'Red' } else { 'Yellow' }
    Write-Line ("{0} {1,-26} : {2}" -f $mark, $r.Name, $r.Value) $color
    if (-not $r.Ok) { Write-Line ("        -> 필요 시점: {0}" -f $r.NeededFrom) 'DarkGray' }
}

# Java 버전이 17 이상인지 확인 (Spring Boot 3 는 Java 17 이상 필요)
$javaLine = ($results | Where-Object { $_.Name -eq 'Java (java)' }).Value
if ($javaLine -match 'version "(\d+)') {
    $major = [int]$Matches[1]
    if ($major -eq 1 -and $javaLine -match 'version "1\.(\d+)') { $major = [int]$Matches[1] }
    Write-Line ''
    if ($major -ge 17) {
        Write-Line "Java 주 버전 $major -> Spring Boot 3 사용 가능" 'Green'
    } else {
        Write-Line "Java 주 버전 $major -> Spring Boot 3 는 Java 17 이상이 필요합니다 (설치 필요)" 'Red'
    }
}

$missing = $results | Where-Object { -not $_.Ok -and $_.Required }
Write-Line ''
Write-Line '-----------------------------------------------------'
if ($missing) {
    Write-Line '설치가 필요한 필수 항목:' 'Red'
    $missing | ForEach-Object { Write-Line "  - $($_.Name) ($($_.NeededFrom))" 'Red' }
    Write-Line '(스크립트는 아무것도 설치하지 않았습니다. 설치 여부는 직접 결정해 주세요.)'
} else {
    Write-Line '필수 항목이 모두 설치되어 있습니다.' 'Green'
}
Write-Line '-----------------------------------------------------'

$lines | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host ''
Write-Host "결과가 저장되었습니다: $reportPath" -ForegroundColor Cyan
Write-Host '이 파일 내용을 복사해서 Claude 에게 붙여넣어 주세요.' -ForegroundColor Cyan
