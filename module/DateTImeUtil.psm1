# �N��(yyyyMM)���猎���ƌ����̓�����Ԃ��B
function oneMonthDays ([String]$yyyyMM) {
    $yyyy        = $yyyyMM.Substring(0, 4);
    $mm          = $yyyyMM.Substring(4, 2);
    $daysInMonth = [System.DateTime]::DaysInMonth($yyyy, $mm);
    
    daysWithRange $yyyy $mm "01" $daysInMonth;
};

# �N��(yyyyMM)����O�������`���������̓�����Ԃ��B
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

# �N���ƊJ�n���A�I������������ɐ��`�����������Ԃ��B
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