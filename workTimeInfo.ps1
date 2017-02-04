Param(
    [Switch]$om
)
$currentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;
Import-Module $currentFolder/module/workTimeInfo.psm1;
Import-Module $currentFolder/module/DateTimeUtil.psm1;

$target_ym  = Read-Host "�Ώ۔N���H(yyyyMM)";
$evenTime   = Read-Host "�ς��H(y/n)";

$target_ym    = if ($target_ym -eq $null -or $target_ym -eq "") {[System.DateTime]::Now.ToString("yyyyMM")} else {$target_ym};
$startEnd     = if ($om) {oneMonthDays $target_ym} else {oneMonthDaysMiddle $target_ym};
$isEven       = if ($evenTime -eq $null -or $evenTime -eq "" -or $evenTime -eq "y") {$true} else {$false};
$workTimeInfo = workTimeInfo $startEnd.start $startEnd.end $isEven;
[String]::Join("`t", "���t", "�j��", "�o�Ύ���", "�ދΎ���", "�ғ�����(�x�e����:1h������)");
$workTimeInfo.workingDays | %{[String]::Join("`t", $_.date, $_.dayOfWeek, $_.boot, $_.shutdown, $_.workingTime)};
[String]::Join("`t", "�����ғ�����", $workTimeInfo.subTotalWorkDays);
[String]::Join("`t", "�����ғ�����", $workTimeInfo.subTotalWorkTime.TotalHours);
[String]::Join("`t", "�x���ғ�����", $workTimeInfo.subTotalHolidayWork);
[String]::Join("`t", "�x���ғ�����", $workTimeInfo.subTotalHolidayWorkTime.TotalHours);
[String]::Join("`t", "���ғ�����"  , $workTimeInfo.totalWorkDays);
[String]::Join("`t", "���ғ�����"  , $workTimeInfo.totalWorkTime.TotalHours);