function workTimeInfo ($start, $end) {
    $restTime    = [System.TimeSpan]::FromHours(1);
    $workingDays = (Get-EventLog system -After $start -Before $end) + (Get-EventLog application -After $start -Before $end) |
    group{$_.TimeWritten.ToShortDateString()} |
    %{
        $tempBootTime     = ($_.Group.TimeWritten.TimeOfDay | measure -min).Minimum;
        $tempShutDownTime = ($_.Group.TimeWritten.TimeOfDay | measure -max).Maximum;
        @{
            date         = $_.Name; 
            dayOfWeek    = [System.Convert]::ToInt32(($_.Group.TimeWritten | select DayOfWeek -First 1).DayOfWeek);
            # dayOfWeekStr = ($_.Group.TimeWritten | select * -First 1).ToString("ddd");
            boot         = $tempBootTime; 
            shutdown     = $tempShutDownTime;
            workingTime  = $tempShutDownTime - $tempBootTime -$restTime;
        }
    } | sort{$_.date}
    $subTotalWorkDays        = ($workingDays | ?{$_.dayOfWeek -ne 0 -and $_.dayOfWeek -ne 6} | measure).Count;
    $subTotalWorkTime        = [System.TimeSpan]::FromMilliseconds(($workingDays | ?{$_.dayOfWeek -ne 0 -and $_.dayOfWeek -ne 6} | %{$_.workingTime.TotalMilliseconds} | measure -Sum).Sum);
    $subTotalHolidayWork     = ($workingDays | ?{$_.dayOfWeek -eq 0 -or $_.dayOfWeek -eq 6} | measure).Count;
    $subTotalHolidayWorkTime = [System.TimeSpan]::FromMilliseconds(($workingDays | ?{$_.dayOfWeek -eq 0 -or $_.dayOfWeek -eq 6} | %{$_.workingTime.TotalMilliseconds} | measure -Sum).Sum);
    $totalWorkDays           = $subTotalWorkDays + $subTotalHolidayWork;
    $totalWorkTime           = $subTotalWorkTime + $subTotalHolidayWorkTime;
    @{
        workingDays             = $workingDays;
        subTotalWorkDays        = $subTotalWorkDays;
        subTotalWorkTime        = $subTotalWorkTime;
        subTotalHolidayWork     = $subTotalHolidayWork;
        subTotalHolidayWorkTime = $subTotalHolidayWorkTime;
        totalWorkDays           = $totalWorkDays;
        totalWorkTime           = $totalWorkTime;
    };
};

$inputStart = Read-Host "�J�n���H(yyyy/MM/dd)"
$inputEnd   = Read-Host "�I�����H(yyyy/MM/dd)"

$start    = "$inputStart 00:00:00";
$end      = "$inputEnd 23:59:59";
$workDays = workTimeInfo $start $end;
[String]::Join("`t", "���t", "�j��", "�o�Ύ���", "�ދΎ���", "�ғ�����(�x�e����:1h������)");
$workDays.workingDays | %{[String]::Join("`t", $_.date, $_.dayOfWeek, $_.boot, $_.shutdown, $_.workingTime)};
[String]::Join("`t", "�����ғ�����", $workDays.subTotalWorkDays);
[String]::Join("`t", "�����ғ�����", $workDays.subTotalWorkTime.TotalHours);
[String]::Join("`t", "�x���ғ�����", $workDays.subTotalHolidayWork);
[String]::Join("`t", "�x���ғ�����", $workDays.subTotalHolidayWorkTime.TotalHours);
[String]::Join("`t", "���ғ�����"  , $workDays.totalWorkDays);
[String]::Join("`t", "���ғ�����"  , $workDays.totalWorkTime.TotalHours);