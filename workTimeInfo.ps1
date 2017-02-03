Import-Module ./module/workTimeInfo.psm1;
$inputStart = Read-Host "開始日？(yyyy/MM/dd)"
$inputEnd   = Read-Host "終了日？(yyyy/MM/dd)"
$evenTime   = Read-Host "均す？(y/n)";

$start    = "$inputStart 00:00:00";
$end      = "$inputEnd 23:59:59";
$isEven   = $evenTime -eq "y";
$workDays = workTimeInfo $start $end $isEven;
[String]::Join("`t", "日付", "曜日", "出勤時間", "退勤時間", "稼働時間(休憩時間:1hを除く)");
$workDays.workingDays | %{[String]::Join("`t", $_.date, $_.dayOfWeek, $_.boot, $_.shutdown, $_.workingTime)};
[String]::Join("`t", "平日稼働日数", $workDays.subTotalWorkDays);
[String]::Join("`t", "平日稼働時間", $workDays.subTotalWorkTime.TotalHours);
[String]::Join("`t", "休日稼働日数", $workDays.subTotalHolidayWork);
[String]::Join("`t", "休日稼働時間", $workDays.subTotalHolidayWorkTime.TotalHours);
[String]::Join("`t", "総稼働日数"  , $workDays.totalWorkDays);
[String]::Join("`t", "総稼働日数"  , $workDays.totalWorkTime.TotalHours);