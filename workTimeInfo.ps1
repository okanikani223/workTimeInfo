Param(
    [Switch]$om
)
$currentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;
Import-Module $currentFolder/module/workTimeInfo.psm1;
Import-Module $currentFolder/module/DateTimeUtil.psm1;

$target_ym  = Read-Host "対象年月？(yyyyMM)";
$evenTime   = Read-Host "均す？(y/n)";

$target_ym    = if ($target_ym -eq $null -or $target_ym -eq "") {[System.DateTime]::Now.ToString("yyyyMM")} else {$target_ym};
$startEnd     = if ($om) {oneMonthDays $target_ym} else {oneMonthDaysMiddle $target_ym};
$isEven       = if ($evenTime -eq $null -or $evenTime -eq "" -or $evenTime -eq "y") {$true} else {$false};
$workTimeInfo = workTimeInfo $startEnd.start $startEnd.end $isEven;
[String]::Join("`t", "日付", "曜日", "出勤時間", "退勤時間", "稼働時間(休憩時間:1hを除く)");
$workTimeInfo.workingDays | %{[String]::Join("`t", $_.date, $_.dayOfWeek, $_.boot, $_.shutdown, $_.workingTime)};
[String]::Join("`t", "平日稼働日数", $workTimeInfo.subTotalWorkDays);
[String]::Join("`t", "平日稼働時間", $workTimeInfo.subTotalWorkTime.TotalHours);
[String]::Join("`t", "休日稼働日数", $workTimeInfo.subTotalHolidayWork);
[String]::Join("`t", "休日稼働時間", $workTimeInfo.subTotalHolidayWorkTime.TotalHours);
[String]::Join("`t", "総稼働日数"  , $workTimeInfo.totalWorkDays);
[String]::Join("`t", "総稼働日数"  , $workTimeInfo.totalWorkTime.TotalHours);