Import-Module ./module/workTimeInfo.psm1;
# $inputStart = Read-Host "開始日？(yyyy/MM/dd)"
# $inputEnd   = Read-Host "終了日？(yyyy/MM/dd)"
$target_ym  = Read-Host "対象年月？(yyyyMM)";
$evenTime   = Read-Host "均す？(y/n)";

$startEnd     = startEndDays $target_ym;
$isEven       = $evenTime -eq "y";
$workTimeInfo = workTimeInfo $startEnd.start $startEnd.end $isEven;
[String]::Join("`t", "日付", "曜日", "出勤時間", "退勤時間", "稼働時間(休憩時間:1hを除く)");
$workTimeInfo.workingDays | %{[String]::Join("`t", $_.date, $_.dayOfWeek, $_.boot, $_.shutdown, $_.workingTime)};
[String]::Join("`t", "平日稼働日数", $workTimeInfo.subTotalWorkDays);
[String]::Join("`t", "平日稼働時間", $workTimeInfo.subTotalWorkTime.TotalHours);
[String]::Join("`t", "休日稼働日数", $workTimeInfo.subTotalHolidayWork);
[String]::Join("`t", "休日稼働時間", $workTimeInfo.subTotalHolidayWorkTime.TotalHours);
[String]::Join("`t", "総稼働日数"  , $workTimeInfo.totalWorkDays);
[String]::Join("`t", "総稼働日数"  , $workTimeInfo.totalWorkTime.TotalHours);