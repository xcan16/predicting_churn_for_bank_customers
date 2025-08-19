<#
setup_and_run.ps1
PowerShell betiği — proje klasöründe çalıştırmak için tasarlandı.
Yaptıkları:
 - Python kurulu mu kontrol eder (öncelikle py -3, değilse python),
 - .venv oluşturur (varsa atlar) ve aktif etmeye çalışır,
 - Gerekirse CurrentUser için ExecutionPolicy'yi RemoteSigned yapar,
 - requirements.txt varsa paketleri yükler, yoksa varsayılan paketleri yükler,
 - predicting_churn_for_bank_customers.py dosyasını çalıştırır.
Kullanım: PowerShell'de proje klasöründen .\setup_and_run.ps1 -RunNow ile çalıştırın.
#>

param(
    [switch]$RunNow  # Betik sonunda Python dosyasını otomatik çalıştırmak için -RunNow kullanın
)

$ErrorActionPreference = 'Stop'

function Write-Info($msg){ Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Warn($msg){ Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Err($msg){ Write-Host "[ERROR] $msg" -ForegroundColor Red }

Push-Location $PSScriptRoot
try {
    Write-Info "Python kurulumu kontrol ediliyor..."
    $pythonCmd = $null

    # Önce py -3 sonra python komutlarını dene
    try {
        $ver = & py -3 --version 2>$null
        if ($LASTEXITCODE -eq 0) { $pythonCmd = 'py -3' }
    } catch {}

    if (-not $pythonCmd) {
        try {
            $ver = & python --version 2>$null
            if ($LASTEXITCODE -eq 0) { $pythonCmd = 'python' }
        } catch {}
    }

    if (-not $pythonCmd) {
        Write-Err "Python bulunamadı. Lütfen https://www.python.org/downloads/ adresinden Python 3 kurun ve PATH'e ekleyin."
        exit 1
    }

    Write-Info "Kullanılacak Python komutu: $pythonCmd"
    if ($ver) { Write-Info "Sürüm: $($ver.Trim())" }

    # Sanal ortam
    $venvPath = Join-Path $PSScriptRoot '.venv'
    if (-not (Test-Path $venvPath)) {
        Write-Info "Sanal ortam oluşturuluyor: $venvPath"
        & $pythonCmd -m venv $venvPath
        Write-Info "Sanal ortam oluşturuldu."
    } else {
        Write-Info "Sanal ortam zaten mevcut: $venvPath"
    }

    # ExecutionPolicy gerekirse ayarla
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser -ErrorAction SilentlyContinue
    if ($currentPolicy -in @('Restricted','Undefined')) {
        Write-Warn "CurrentUser ExecutionPolicy: $currentPolicy — Activation script'i çalışmıyorsa RemoteSigned olarak ayarlanacak."
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
            Write-Info "ExecutionPolicy CurrentUser için RemoteSigned olarak ayarlandı."
        } catch {
            Write-Warn "ExecutionPolicy değiştirilemedi: $($_.Exception.Message)"
        }
    } else {
        Write-Info "ExecutionPolicy CurrentUser: $currentPolicy"
    }

    # Aktifleştir
    $activateScript = Join-Path $venvPath 'Scripts\Activate.ps1'
    if (Test-Path $activateScript) {
        Write-Info "Sanal ortam aktifleştiriliyor..."
        try {
            & $activateScript
            Write-Info "Sanal ortam aktifleştirildi."
        } catch {
            Write-Warn "Aktifleştirme sırasında uyarı: $($_.Exception.Message)"
            Write-Warn "Eğer aktifleştirme başarısız olursa manuel olarak: .\\.venv\\Scripts\\Activate.ps1 çalıştırın."
        }
    } else {
        Write-Err "Aktivasyon betiği bulunamadı: $activateScript"
        exit 1
    }

    # pip güncelle
    Write-Info "pip güncelleniyor..."
    & $pythonCmd -m pip install --upgrade pip 2>$null

    # Paket kurulumu
    $req = Join-Path $PSScriptRoot 'requirements.txt'
    if (Test-Path $req) {
        Write-Info "requirements.txt bulundu, paketler yüklenecek."
        & $pythonCmd -m pip install -r $req
    } else {
        Write-Info "requirements.txt bulunamadı — ortak paketler yüklenecek (pandas, numpy, scikit-learn, matplotlib, seaborn)."
        & $pythonCmd -m pip install pandas numpy scikit-learn matplotlib seaborn
    }

    # Çalıştır
    $scriptToRun = Join-Path $PSScriptRoot 'predicting_churn_for_bank_customers.py'
    if (-not (Test-Path $scriptToRun)) {
        Write-Err "Çalıştırılacak Python dosyası bulunamadı: $scriptToRun"
        exit 1
    }

    if ($RunNow) {
        Write-Info "Python dosyası çalıştırılıyor: $scriptToRun"
        & $pythonCmd $scriptToRun
    } else {
        Write-Info "Kurulum tamamlandı. Python dosyasını çalıştırmak için:"
        Write-Host "    & $pythonCmd $scriptToRun" -ForegroundColor Green
        Write-Host "veya sanal ortamı aktifleştirip: .\\.venv\\Scripts\\Activate.ps1 ve sonra python $scriptToRun" -ForegroundColor Green
    }

} catch {
    Write-Err "Hata: $($_.Exception.Message)"
    exit 1
} finally {
    Pop-Location
}
