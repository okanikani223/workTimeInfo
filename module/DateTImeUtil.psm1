# 年月(yyyyMM)から月初と月末の日時を返す。
function oneMonthDays ([String]$yyyyMM) {
    $yyyy        = $yyyyMM.Substring(0, 4);
    $mm          = $yyyyMM.Substring(4, 2);
    $daysInMonth = [System.DateTime]::DaysInMonth($yyyy, $mm);
    
    daysWithRange $yyyy $mm "01" $daysInMonth;
};

# 年月(yyyyMM)から前月中日～今月中日の日時を返す。
function oneMonthDaysMiddle ([String]$yyyyMM) {
    $yyyy        = $yyyyMM.Substring(0, 4);
    $mm          = $yyyyMM.Substring(4, 2);
    $beforeYYYY  = if ($mm -eq "01") {$yyyy - 1} else {$yyyy};
    $beforeMM    = if ($mm -eq "01") {"12"} else {$mm - 1};

    @{
        start = startDateTime $beforeYYYY $beforeMM "16";
        end   = endDateTime $yyyy $mm "15";
    };
};

# 年月と開始日、終了日から日時に整形した文字列を返す。
function daysWithRange ($yyyy, $mm, $startDay, $endDay) {
    @{
        start = startDateTime $yyyy $mm $startDay;
        end   = endDateTime $yyyy $mm $endDay;
    };
};

function startDateTime ($yyyy, $mm, $day) {
    dateTime $yyyy $mm $day "00:00:00";
};

function endDateTime ($yyyy, $mm, $day) {
    dateTime $yyyy $mm $day "23:59:59";
};

function dateTime ($yyyy, $mm, $day, $time) {
    [String]::Join(" ", [String]::Join("/", $yyyy, $mm, $day), $time);
};

# Export-ModuleMember -Function DateTimeUtil