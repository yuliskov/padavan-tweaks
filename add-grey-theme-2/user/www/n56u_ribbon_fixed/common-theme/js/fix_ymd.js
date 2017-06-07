function redraw_history(){
    var i,h,ymd,grid,hash;

    grid =  '<table class="table table-striped" width="100%" cellspacing="1">';
    grid += '<tr><th valign="top" style="text-align:left"><#Date#></th>';
    grid += '<th width="25%" style="text-align:right" valign="top"><#Downlink#></th>';
    grid += '<th width="25%" style="text-align:right" valign="top"><#Uplink#></th>';
    grid += '<th width="25%" style="text-align:right" valign="top"><#Total#></th></tr>';

    hash = getHash();
    if (hash == '#dy'){
        $j('#tab_tr_mo').parents('li').removeClass('active');
        $j('#tab_tr_dy').parents('li').addClass('active');
        E('bx_label').innerHTML = '<#menu4#> - <#menu4_2_3#>';
        E('dafm').disabled = 0;
        for (i = 0; i < daily_history.length; ++i){
            h = daily_history[i];
            ymd = getYMD(h[0]);
            grid += makeRow(ymdText(ymd[0], ymd[1], ymd[2]), rescale(h[1]), rescale(h[2]), rescale(h[1] + h[2]));
        }
    }else{
        $j('#tab_tr_dy').parents('li').removeClass('active');
        $j('#tab_tr_mo').parents('li').addClass('active');
        E('bx_label').innerHTML = '<#menu4#> - <#menu4_2_4#>';
        // E('dafm').disabled = 1;
        E('dafm').disabled = 0;
        for (i = 0; i < monthly_history.length; ++i){
            h = monthly_history[i];
            ymd = getYMD(h[0]);
            // grid += makeRow(ymText(ymd[0], ymd[1]), rescale(h[1]), rescale(h[2]), rescale(h[1] + h[2]));
            grid += makeRow(ymText(ymd[0], ymd[1], ymd[2]), rescale(h[1]), rescale(h[2]), rescale(h[1] + h[2]));
        }
    }

    E('bwm-daily-grid').innerHTML = grid + '</table>';
}

function ymText(yr, mo, da){
    switch (dateFormat) {
    case 1:
        return (mo + 1) + '-' + yr;
    case 2:
        return months_s[mo] + ', ' + yr;
    case 3:
        return months_f[mo] + ', ' + yr;
    case 4:
        return pad(mo + 1, 2) + '.' + yr;
    case 5:
        return months_s[mo] + '-' + yr;
    case 6:
        return months_s[mo] + ' ' + yr;
    }
    return yr + '-' + pad(mo + 1, 2);
}

function buildYMOnlySelect() {
    var select = jQuery('<select id="dafm" style="width: 200px;" onchange="changeDate(this);" tabindex="2"></select>');
    select.append('<option value="0">yyyy-mm</option>');
    select.append('<option value="1">m-yyyy</option>');
    select.append('<option value="2">mmm, yyyy</option>');
    select.append('<option value="3">mmmm, yyyy</option>');
    select.append('<option value="4">mm.yyyy</option>');
    select.append('<option value="5">mmm-yyyy</option>');
    select.append('<option value="6">mmm yyyy</option>');
    return select;
}

function buildYMDSelect() {
    var select = jQuery('<select id="dafm" style="width: 200px;" onchange="changeDate(this);" tabindex="2"></select>');
    select.append('<option value="0">yyyy-mm-dd</option>');
    select.append('<option value="1">m-dd-yyyy</option>');
    select.append('<option value="2">mmm d, yyyy</option>');
    select.append('<option value="3">mmmm d, yyyy</option>');
    select.append('<option value="4">dd.mm.yyyy</option>');
    select.append('<option value="5">dd-mmm-yyyy</option>');
    select.append('<option value="6">d mmm yyyy</option>');
    return select;
}

function fixMonthlySelect() {
    var $sel = jQuery('#dafm');
    $sel.find('option').each(function() {
        var $option = jQuery(this);
        var oldText = $option.text();
        if (!$option.data('oldText'))
            $option.data('oldText', oldText);
        var newText = oldText.replace(/(-dd)|( d)|(dd.)|(dd-)|(d )/gi, '');
        $option.text(newText);
    });
}

function fixDailySelect() {
    var $sel = jQuery('#dafm');
    $sel.find('option').each(function() {
        var $option = jQuery(this);
        var oldText = $option.data('oldText');
        if (!oldText)
            return;
        $option.text(oldText);
    });
}

if (location.href.indexOf('Main_TrafficMonitor_daily.asp') >= 0) {
    console.log('apply ymd fixes');
    jQuery('#tab_tr_mo').click(fixMonthlySelect);
    jQuery('#tab_tr_dy').click(fixDailySelect);
    if (location.href.indexOf('Main_TrafficMonitor_daily.asp#MO') >= 0) {
        fixMonthlySelect();
    }
}

