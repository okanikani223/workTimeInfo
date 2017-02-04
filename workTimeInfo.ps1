Import-Module ./module/workTimeInfo.psm1;
# $inputStart = Read-Host "�J�n���H(yyyy/MM/dd)"
# $inputEnd   = Read-Host "�I�����H(yyyy/MM/dd)"
$target_ym  = Read-Host "�Ώ۔N���H(yyyyMM)";
$evenTime   = Read-Host "�ς��H(y/n)";

$startEnd     = startEndDays $target_ym;
$isEven       = $evenTime -eq "y";
$workTimeInfo = workTimeInfo $startEnd.start $startEnd.end $isEven;
[String]::Join("`t", "���t", "�j��", "�o�Ύ���", "�ދΎ���", "�ғ�����(�x�e����:1h������)");
$workTimeInfo.workingDays | %{[String]::Join("`t", $_.date, $_.dayOfWeek, $_.boot, $_.shutdown, $_.workingTime)};
[String]::Join("`t", "�����ғ�����", $workTimeInfo.subTotalWorkDays);
[String]::Join("`t", "�����ғ�����", $workTimeInfo.subTotalWorkTime.TotalHours);
[String]::Join("`t", "�x���ғ�����", $workTimeInfo.subTotalHolidayWork);
[String]::Join("`t", "�x���ғ�����", $workTimeInfo.subTotalHolidayWorkTime.TotalHours);
[String]::Join("`t", "���ғ�����"  , $workTimeInfo.totalWorkDays);
[String]::Join("`t", "���ғ�����"  , $workTimeInfo.totalWorkTime.TotalHours);