Import-Module ./module/workTimeInfo.psm1;
$inputStart = Read-Host "�J�n���H(yyyy/MM/dd)"
$inputEnd   = Read-Host "�I�����H(yyyy/MM/dd)"
$evenTime   = Read-Host "�ς��H(y/n)";

$start    = "$inputStart 00:00:00";
$end      = "$inputEnd 23:59:59";
$isEven   = $evenTime -eq "y";
$workDays = workTimeInfo $start $end $isEven;
[String]::Join("`t", "���t", "�j��", "�o�Ύ���", "�ދΎ���", "�ғ�����(�x�e����:1h������)");
$workDays.workingDays | %{[String]::Join("`t", $_.date, $_.dayOfWeek, $_.boot, $_.shutdown, $_.workingTime)};
[String]::Join("`t", "�����ғ�����", $workDays.subTotalWorkDays);
[String]::Join("`t", "�����ғ�����", $workDays.subTotalWorkTime.TotalHours);
[String]::Join("`t", "�x���ғ�����", $workDays.subTotalHolidayWork);
[String]::Join("`t", "�x���ғ�����", $workDays.subTotalHolidayWorkTime.TotalHours);
[String]::Join("`t", "���ғ�����"  , $workDays.totalWorkDays);
[String]::Join("`t", "���ғ�����"  , $workDays.totalWorkTime.TotalHours);