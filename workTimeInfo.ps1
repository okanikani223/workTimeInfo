function workTimeInfo ($start, $end) {
    $restTime = [System.TimeSpan]::FromHours(1);
    $temp     = (Get-EventLog System -After $start -Before $end) + (Get-EventLog Application -After $start -Before $end) |
    group{$_.TimeWritten.ToShortDateString()} |
    %{
        $tempBoot     = ($_.Group.TimeWritten.TimeOfDay | measure -min).Minimum;
        $tempShutDown = ($_.Group.TimeWritten.TimeOfDay | measure -max).Maximum;
        @{
            date          = $_.Name;
            dayOfWeek     = ($_.Group.TimeWritten | select DayOfWeek -First 1);
            boot          = $tempBoot;
            shutDown      = $tempShutDown;
            workingTimes  = $tempShutDown - $tempBoot - $restTime;
        }
    } |
    sort{$_.date};
    $temp;
}

$workTimes = workTimeInfo "2017/01/01 00:00:00" "2017/12/31 23:59:59";
$workTimes | %{[String]::Join("`t", $_.date, $_.dayOfWeek, $_.boot, $_.shutDown, $_.workingTimes)};