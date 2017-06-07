function localizeLegend() {
    if (location.href.indexOf('Advanced_System_Info.asp') == -1)
        return;
    if (!window.Highcharts)
        return;
    var userLang = detectLanguage();
    if (userLang == 'en-US')
        return;
    if (Highcharts.charts.length != 2)
        return;
    var chart = Highcharts.charts[0]; // cpu load
    if (!chart || chart.legend.allItems.length != 4)
        return;

    chart.legend.allItems[0].update({name: localize('Busy')});
    chart.legend.allItems[1].update({name: localize('User')});
    chart.legend.allItems[2].update({name: localize('System')});
    chart.legend.allItems[3].update({name: localize('Sirq')});

    chart = Highcharts.charts[1]; // memory load
    if (!chart  || chart.legend.allItems.length != 3)
        return;
    chart.legend.allItems[0].update({name: localize('Used')});
    chart.legend.allItems[1].update({name: localize('Buffers')});
    chart.legend.allItems[2].update({name: localize('Cached')});
}

setTimeout(localizeLegend, 0);