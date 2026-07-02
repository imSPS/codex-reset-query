$ErrorActionPreference = "Stop"

$authPath = Join-Path $HOME ".codex/auth.json"
if (-not (Test-Path -LiteralPath $authPath)) {
  throw "auth.json not found: $authPath"
}

$auth = Get-Content -LiteralPath $authPath -Raw | ConvertFrom-Json
$token = $auth.tokens.access_token
if ([string]::IsNullOrWhiteSpace($token)) {
  throw "access_token missing in auth.json"
}

$headers = @{ Authorization = "Bearer $token" }
$uri = "https://chatgpt.com/backend-api/wham/rate-limit-reset-credits"

function Convert-UtcStringToLocal {
  param(
    [Parameter(Mandatory = $false)]
    [string]$UtcString
  )

  if ([string]::IsNullOrWhiteSpace($UtcString)) {
    return $null
  }

  $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
  $utc = [System.DateTimeOffset]::Parse($UtcString, [System.Globalization.CultureInfo]::InvariantCulture, $styles)
  $localZone = [System.TimeZoneInfo]::Local
  $local = [System.TimeZoneInfo]::ConvertTime($utc, $localZone)
  return $local.ToString("yyyy-MM-dd HH:mm:ss zzz")
}

try {
  $resp = Invoke-WebRequest -Uri $uri -Headers $headers -Method GET
  $statusCode = [int]$resp.StatusCode
  $data = $resp.Content | ConvertFrom-Json
} catch {
  $statusCode = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { -1 }
  [pscustomobject]@{
    status_code = $statusCode
    note = if ($statusCode -eq 401) { "401 means credential expired or Authorization header missing/incorrect." } else { $_.Exception.Message }
  } | ConvertTo-Json -Depth 5
  exit 0
}

$credits = @()
foreach ($credit in @($data.credits)) {
  $credits += [pscustomobject]@{
    status = $credit.status
    title = $credit.title
    granted_at = Convert-UtcStringToLocal -UtcString $credit.granted_at
    expires_at = Convert-UtcStringToLocal -UtcString $credit.expires_at
  }
}

[pscustomobject]@{
  status_code = $statusCode
  timezone = [System.TimeZoneInfo]::Local.Id
  available_count = $data.available_count
  credits = $credits
} | ConvertTo-Json -Depth 5
