$restTime         = [System.TimeSpan]::FromHours(1);
$startRestTime    = [System.TimeSpan]::FromHours(13);
$limitTime        = [System.TimeSpan]::FromMinutes(1433);
$fixedWorkTime    = [System.TimeSpan]::FromMinutes(465);
$defaultOverTime  = [System.TimeSpan]::FromHours(0);
# 時間をtimeUnit(分)単位で均して返す。
function makeEvenTime ([System.TimeSpan]$time, [int]$timeUnit) {
    $convertFromMinuts = $timeUnit * 60; 
    if ($time -gt $limitTime) { return [System.TimeSpan]::FromSeconds([Math]::Truncate($time.TotalSeconds / $convertFromMinuts) * $convertFromMinuts);}
    $adjustmentMinuts  = [System.TimeSpan]::FromSeconds(($convertFromMinuts / 2) - 1);
    [System.TimeSpan]::FromSeconds([Math]::Truncate($time.Add($adjustmentMinuts).TotalSeconds / $convertFromMinuts) * $convertFromMinuts);
};

# 指定したログ名、期間でイベントログを返す。
function getEventLog ($logName, $start, $end) {
    Get-EventLog $logName -After $start -Before $end;
};

# イベントログから指定された範囲の期間で就業時間情報を返す。
# 就業時間情報の内容は以下の通り
# 　１．日毎の出勤、退勤、稼働時間(休憩時間を除く)
# 　２．平日の総稼働日数
# 　３．平日の総稼働時間
# 　４．休日の総稼働日数
# 　５．休日の総稼働時間
# 　６．平日と休日の総稼働日数の合計
# 　７．平日と休日の総稼働時間の合計
# isEven フラグで、時間の均し処理(15分単位)の有無を変更可能
function workTimeInfo ($start, $end, $isEven) {
    $workingDays = (getEventLog "System" $start $end) + (getEventLog "Application" $start $end) <#+ (getEventLog "Security" $start $end)#> |
    group{$_.TimeWritten.ToShortDateString()} |
    %{
        $tempBootDateTime     = ($_.Group.TimeWritten | measure -min).Minimum;
        $tempShutDonwDateTime = ($_.Group.TimeWritten | measure -max).Maximum;
        $tempBootTime         = if ($isEven) {makeEvenTime $tempBootDateTime.TimeOfDay 15}     else {$tempBootDateTime.TimeOfDay};
        $tempShutDownTime     = if ($isEven) {makeEvenTime $tempShutDonwDateTime.TimeOfDay 15} else {$tempShutDonwDateTime.TimeOfDay};
        $tempWorkingTime      = if ($tempShutDownTime -lt $startRestTime) {$tempShutDownTime - $tempBootTime} else {$tempShutDownTime - $tempBootTime -$restTime};
        @{
            date          = $_.Name; 
            dayOfWeekCode = [System.Convert]::ToInt32($tempBootDateTime.DayOfWeek);
            dayOfWeek     = $tempBootDateTime.ToString("ddd");
            boot          = $tempBootTime; 
            shutdown      = $tempShutDownTime;
            workingTime   = $tempWorkingTime;
            overTime      = if ($tempWorkingTime -gt $fixedWorkTime) {$tempWorkingTime - $fixedWorkTime} else {$defaultOverTime};
        }
    } | sort{$_.date}
    $subTotalWorkDays        = ($workingDays | ?{$_.dayOfWeekCode -ne 0 -and $_.dayOfWeekCode -ne 6} | measure).Count;
    $subTotalWorkTime        = [System.TimeSpan]::FromMilliseconds(($workingDays | ?{$_.dayOfWeekCode -ne 0 -and $_.dayOfWeekCode -ne 6} | %{$_.workingTime.TotalMilliseconds} | measure -Sum).Sum);
    $subTotalOverTime        = [System.TimeSpan]::FromMilliseconds(($workingDays | ?{$_.dayOfWeekCode -ne 0 -and $_.dayOfWeekCode -ne 6} | %{$_.overTime.TotalMilliseconds} | measure -Sum).Sum);
    $subTotalHolidayWork     = ($workingDays | ?{$_.dayOfWeekCode -eq 0 -or $_.dayOfWeekCode -eq 6} | measure).Count;
    $subTotalHolidayWorkTime = [System.TimeSpan]::FromMilliseconds(($workingDays | ?{$_.dayOfWeekCode -eq 0 -or $_.dayOfWeekCode -eq 6} | %{$_.workingTime.TotalMilliseconds} | measure -Sum).Sum);
    $subTotalHolidayOverTime = [System.TimeSpan]::FromMilliseconds(($workingDays | ?{$_.dayOfWeekCode -eq 0 -or $_.dayOfWeekCode -eq 6} | %{$_.overTime.TotalMilliseconds} | measure -Sum).Sum);
    $totalWorkDays           = $subTotalWorkDays + $subTotalHolidayWork;
    $totalWorkTime           = $subTotalWorkTime + $subTotalHolidayWorkTime;
    $totalOverTime           = $subTotalOverTime + $subTotalHolidayOverTime;
    @{
        workingDays             = $workingDays;
        subTotalWorkDays        = $subTotalWorkDays;
        subTotalWorkTime        = $subTotalWorkTime;
        subTotalOverTime        = $subTotalOverTime;
        subTotalHolidayWork     = $subTotalHolidayWork;
        subTotalHolidayWorkTime = $subTotalHolidayWorkTime;
        subTotalHolidayOverTime = $subTotalHolidayOverTime;
        totalWorkDays           = $totalWorkDays;
        totalWorkTime           = $totalWorkTime;
        totalOverTime           = $totalOverTime;
    };
};

# Export-ModuleMember -Function workTimeInfo