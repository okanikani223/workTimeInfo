Param(
    [Switch]$om
)
$currentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;
Import-Module $currentFolder/module/workTimeInfo.psm1;
Import-Module $currentFolder/module/DateTimeUtil.psm1;

$target_ym  = Read-Host "‘ÎÛ”NŒH(yyyyMM)";
$evenTime   = Read-Host "‹Ï‚·H(y/n)";

$target_ym    = if ($target_ym -eq $null -or $target_ym -eq "") {[System.DateTime]::Now.ToString("yyyyMM")} else {$target_ym};
$startEnd     = if ($om) {oneMonthDays $target_ym} else {oneMonthDaysMiddle $target_ym};
$isEven       = if ($evenTime -eq $null -or $evenTime -eq "" -or $evenTime -eq "y") {$true} else {$false};
$workTimeInfo = workTimeInfo $startEnd.start $startEnd.end $isEven;
[String]::Join("`t", "“ú•t", "—j“ú", "o‹ÎŠÔ", "‘Ş‹ÎŠÔ", "‰Ò“­ŠÔ(‹xŒeŠÔ:1h‚ğœ‚­)");
$workTimeInfo.workingDays | %{[String]::Join("`t", $_.date, $_.dayOfWeek, $_.boot, $_.shutdown, $_.workingTime)};
[String]::Join("`t", "•½“ú‰Ò“­“ú”", $workTimeInfo.subTotalWorkDays);
[String]::Join("`t", "•½“ú‰Ò“­ŠÔ", $workTimeInfo.subTotalWorkTime.TotalHours);
[String]::Join("`t", "‹x“ú‰Ò“­“ú”", $workTimeInfo.subTotalHolidayWork);
[String]::Join("`t", "‹x“ú‰Ò“­ŠÔ", $workTimeInfo.subTotalHolidayWorkTime.TotalHours);
[String]::Join("`t", "‘‰Ò“­“ú”"  , $workTimeInfo.totalWorkDays);
[String]::Join("`t", "‘‰Ò“­“ú”"  , $workTimeInfo.totalWorkTime.TotalHours);