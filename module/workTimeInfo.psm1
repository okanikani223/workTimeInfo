$adjustmentMinuts = [System.TimeSpan]::FromSeconds(449);
$restTime         = [System.TimeSpan]::FromHours(1);
# 時間を15分単位で均す関数
function makeEvenTime ([System.TimeSpan]$time) {
    [System.TimeSpan]::FromMinutes([Math]::Truncate($time.Add($adjustmentMinuts).TotalMinutes / 15) * 15);
};
# 指定したログ名、期間でイベントログを取得する関数
function getEventLog ($logName, $start, $end) {
    Get-EventLog $logName -After $start -Before $end;
};
# イベントログから指定された範囲の期間で作業時間情報を取得する関数
# 取得する作業時間情報は以下の通り
# 　１．日毎の起動、終了、稼働時間
# 　２．平日の総稼働日数
# 　３．平日の総稼働時間
# 　４．休日の総稼働日数
# 　５．休日の総稼働時間
# 　６．平日と休日の総稼働日数の合計
# 　７．平日と休日の総稼働時間の合計
# isEven フラグで、時間の均し処理(15分単位)の有無を変更可能
function workTimeInfo ($start, $end, $isEven) {
    $workingDays = (getEventLog "System" $start $end) + (getEventLog "Application" $start $end) + (getEventLog "Security" $start $end) |
    group{$_.TimeWritten.ToShortDateString()} |
    %{
        $tempBootTime     = if ($isEven) {makeEvenTime ($_.Group.TimeWritten.TimeOfDay | measure -min).Minimum} else {($_.Group.TimeWritten.TimeOfDay | measure -min).Minimum};
        $tempShutDownTime = if ($isEven) {makeEvenTime ($_.Group.TimeWritten.TimeOfDay | measure -max).Maximum} else {($_.Group.TimeWritten.TimeOfDay | measure -max).Maximum};
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