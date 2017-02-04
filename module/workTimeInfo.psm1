$restTime         = [System.TimeSpan]::FromHours(1);

# ���Ԃ�timeUnit(��)�P�ʂŋς��ĕԂ��B
function makeEvenTime ([System.TimeSpan]$time, [int]$timeUnit) {
    $adjustmentMinuts = [System.TimeSpan]::FromSeconds((($timeUnit * 60) / 2) - 1);
    [System.TimeSpan]::FromMinutes([Math]::Truncate($time.Add($adjustmentMinuts).TotalMinutes / $timeUnit) * $timeUnit);
};

# �w�肵�����O���A���ԂŃC�x���g���O��Ԃ��B
function getEventLog ($logName, $start, $end) {
    Get-EventLog $logName -After $start -Before $end;
};

# �C�x���g���O����w�肳�ꂽ�͈͂̊��ԂŏA�Ǝ��ԏ���Ԃ��B
# �A�Ǝ��ԏ��̓��e�͈ȉ��̒ʂ�
# �@�P�D�����̏o�΁A�ދ΁A�ғ�����(�x�e���Ԃ�����)
# �@�Q�D�����̑��ғ�����
# �@�R�D�����̑��ғ�����
# �@�S�D�x���̑��ғ�����
# �@�T�D�x���̑��ғ�����
# �@�U�D�����Ƌx���̑��ғ������̍��v
# �@�V�D�����Ƌx���̑��ғ����Ԃ̍��v
# isEven �t���O�ŁA���Ԃ̋ς�����(15���P��)�̗L����ύX�\
function workTimeInfo ($start, $end, $isEven) {
    $workingDays = (getEventLog "System" $start $end) + (getEventLog "Application" $start $end) <#+ (getEventLog "Security" $start $end)#> |
    group{$_.TimeWritten.ToShortDateString()} |
    %{
        $tempBootTime     = if ($isEven) {makeEvenTime ($_.Group.TimeWritten.TimeOfDay | measure -min).Minimum 15} else {($_.Group.TimeWritten.TimeOfDay | measure -min).Minimum};
        $tempShutDownTime = if ($isEven) {makeEvenTime ($_.Group.TimeWritten.TimeOfDay | measure -max).Maximum 15} else {($_.Group.TimeWritten.TimeOfDay | measure -max).Maximum};
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

# Export-ModuleMember -Function workTimeInfo