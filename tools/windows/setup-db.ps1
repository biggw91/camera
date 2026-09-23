# =====================================================================
#  Phase 3 - MySQL DB / 전용 계정 만들기 (Windows PowerShell 5.1 이상)
#
#  하는 일:
#   1. DB(thermal_event) 생성 (이미 있으면 그대로 둠)
#   2. 서버 전용 MySQL 계정(thermal_app) 생성 또는 비밀번호 변경
#      - 이 계정은 thermal_event DB 만 사용할 수 있습니다 (root 를 서버에 쓰지 않기 위함)
#   3. 저장소 최상위 .env 파일에 DB 접속 정보 기록 (.env 는 Git 에 올라가지 않음)
#
#  - 테이블은 만들지 않습니다. 테이블은 서버가 처음 켜질 때 자동으로 만들어집니다 (Flyway).
#  - MySQL root 비밀번호는 mysql 프로그램이 직접 물어보며, 어디에도 저장하지 않습니다.
#
#  실행 방법: setup-db.bat 더블클릭
# =====================================================================
param(
    [string]$DbName = 'thermal_event',
    [string]$AppUser = 'thermal_app',
    # 자동 테스트용. 평소에는 비워 두면 화면에서 입력받습니다.
    [string]$AppPassword
)

$ErrorActionPreference = 'Stop'
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$envPath = Join-Path $repoRoot '.env'
$envExamplePath = Join-Path $repoRoot '.env.example'
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

function Fail([string]$message) {
    Write-Host ''
    Write-Host "[오류] $message" -ForegroundColor Red
    exit 1
}

Write-Host '====================================================='
Write-Host ' Phase 3 - MySQL DB / 전용 계정 만들기' -ForegroundColor Cyan
Write-Host '====================================================='

# ---- 1. mysql.exe 찾기 ------------------------------------------------
$mysql = (Get-Command mysql -ErrorAction SilentlyContinue).Source
if (-not $mysql -and $env:ProgramFiles -and (Test-Path "$env:ProgramFiles\MySQL")) {
    $mysql = (Get-ChildItem "$env:ProgramFiles\MySQL" -Recurse -Filter mysql.exe -ErrorAction SilentlyContinue |
        Select-Object -First 1).FullName
}
if (-not $mysql) { Fail 'mysql.exe 를 찾을 수 없습니다. MySQL 설치 위치를 확인해 주세요.' }
Write-Host "mysql 위치: $mysql"

# ---- 2. 입력값 확인 ----------------------------------------------------
if ($DbName -notmatch '^[A-Za-z0-9_]+$') { Fail "DB 이름은 영문/숫자/_ 만 가능합니다: $DbName" }
if ($AppUser -notmatch '^[A-Za-z0-9_]+$') { Fail "계정 이름은 영문/숫자/_ 만 가능합니다: $AppUser" }

if (-not $AppPassword) {
    Write-Host ''
    Write-Host "서버 전용 계정($AppUser)에 사용할 새 비밀번호를 정해서 입력하세요."
    Write-Host ' - 8자 이상, 영문/숫자/특수문자 사용 가능'
    Write-Host ' - 사용할 수 없는 문자: \  ''  "  공백  #  $'
    Write-Host ' - 입력한 글자는 화면에 보이지 않습니다.'
    $p1 = Read-Host '새 비밀번호' -AsSecureString
    $p2 = Read-Host '새 비밀번호 확인' -AsSecureString
    $toPlain = {
        param($secure)
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
        try { [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
        finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
    }
    $AppPassword = & $toPlain $p1
    if ($AppPassword -ne (& $toPlain $p2)) { Fail '두 비밀번호가 다릅니다. 다시 실행해 주세요.' }
}
if ($AppPassword.Length -lt 8) { Fail '비밀번호는 8자 이상이어야 합니다.' }
# \ ' " 는 SQL 문장을, 공백 # $ 는 .env 파일 해석을 깨뜨릴 수 있어 막습니다.
if ($AppPassword -match '[\\''"\s#$]') { Fail '비밀번호에 사용할 수 없는 문자(\ '' " 공백 # $)가 있습니다.' }

# ---- 3. DB / 계정 생성 -------------------------------------------------
$sql = @"
CREATE DATABASE IF NOT EXISTS ``$DbName`` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE USER IF NOT EXISTS '$AppUser'@'localhost' IDENTIFIED BY '$AppPassword';
ALTER USER '$AppUser'@'localhost' IDENTIFIED BY '$AppPassword';
GRANT ALL PRIVILEGES ON ``$DbName``.* TO '$AppUser'@'localhost';
FLUSH PRIVILEGES;
SELECT CONCAT('OK: database=', SCHEMA_NAME) AS result FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = '$DbName';
"@

Write-Host ''
Write-Host 'MySQL root(관리자) 비밀번호를 물어보면 입력하세요. (MySQL 설치 때 정한 비밀번호)' -ForegroundColor Yellow
$mysqlArgs = @('-u', 'root', '--default-character-set=utf8mb4', '--batch', '--skip-column-names')
if (-not $env:MYSQL_PWD) { $mysqlArgs += '-p' }   # MYSQL_PWD 는 자동 테스트용
# mysql 이 화면에 직접 비밀번호를 물어볼 수 있도록 출력을 가로채지 않습니다.
$ErrorActionPreference = 'Continue'
$sql | & $mysql @mysqlArgs
$exitCode = $LASTEXITCODE
$ErrorActionPreference = 'Stop'
if ($exitCode -ne 0) {
    Fail 'MySQL 명령 실행에 실패했습니다. root 비밀번호가 맞는지, MySQL 서비스가 켜져 있는지 확인해 주세요.'
}
Write-Host "DB '$DbName' 와 계정 '$AppUser' 준비 완료" -ForegroundColor Green

# ---- 4. .env 파일에 접속 정보 기록 --------------------------------------
if (Test-Path $envPath) {
    $lines = [System.Collections.Generic.List[string]]([System.IO.File]::ReadAllLines($envPath, $utf8NoBom))
} elseif (Test-Path $envExamplePath) {
    $lines = [System.Collections.Generic.List[string]]([System.IO.File]::ReadAllLines($envExamplePath, $utf8NoBom))
} else {
    $lines = New-Object System.Collections.Generic.List[string]
}
$values = [ordered]@{
    DB_HOST     = 'localhost'
    DB_PORT     = '3306'
    DB_NAME     = $DbName
    DB_USERNAME = $AppUser
    DB_PASSWORD = $AppPassword
}
foreach ($key in $values.Keys) {
    $index = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^\s*$key\s*=") { $index = $i; break }
    }
    $line = "$key=$($values[$key])"
    if ($index -ge 0) { $lines[$index] = $line } else { $lines.Add($line) }
}
[System.IO.File]::WriteAllLines($envPath, $lines, $utf8NoBom)
Write-Host ".env 파일에 DB 접속 정보를 기록했습니다: $envPath" -ForegroundColor Green
Write-Host '(.env 는 Git 에 올라가지 않습니다. 이 파일을 다른 사람에게 보내지 마세요.)'
Write-Host ''
Write-Host '다음 단계: tools\windows\run-server.bat 을 실행하면 테이블이 자동으로 만들어집니다.' -ForegroundColor Cyan
