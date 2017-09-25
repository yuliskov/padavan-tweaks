function fixDeviceListIcons() {
    // on update, Main page > Device icons
    var clientsTable = jQuery('table[id$=Clients_table]');
    clientsTable.on('DOMNodeInserted', function(){
        batchReplaceImageWithDiv(clientsTable.find('img[src^="/bootstrap/img/wl_device"]'), /\d/i, 'comp');
    });

    // Main page > Device icons
    batchReplaceImageWithDiv(clientsTable.find('img[src^="/bootstrap/img/wl_device"]'), /\d/i, 'comp');

    // Admimistration > Work Mode icons
    fixImageSrc('div#Senario img[src^="bootstrap/img/wl_device"]', true, '^bootstrap/img', getRootImageDir('main'));
}

function fixShareDirIcons() {
    // on update, USB page > Samba/FTP dir list
    jQuery('div.FdTemp').on('DOMNodeInserted', function() {
        batchReplaceImageWithDiv('div.FdTemp img[src^="/bootstrap/img/wl_device"]', /\d/i, 'comp');
        fixImageSrc('div.FdTemp img[src^="/images/Tree/vert_line_s"]', false, '^/images', getRootImageDir('main')); // collaplse node
    });

    // USB page > Share tab icons
    batchReplaceImageWithDiv('div#shareStatus img[src^="/images/AiDisk"]', /Folder[^\.]*/i, '_0');
    batchReplaceImageWithDiv('div#shareStatus img[src^="/images/AiDisk"]', /User[^\.]*/i, '_0');
}

function localizeItoggle() {
    console.log('hack: attempt to fix itoggle');
    var mainToggle = jQuery('div.main_itoggle');
    mainToggle.on('DOMNodeInserted', function() {
        var itoggle = mainToggle.find('label.itoggle');
        itoggle.addClass(localize('itoggle'));
    });
}

function applyHighchartsDarkTheme() {
    var myScriptPath = getCommonDir() + '/js/highcharts_dark_theme.js';
    jQuery('head').append('<script id="highcharts_dark_theme" src="' + myScriptPath + '"></script>');
}

function chainGetFile($objects, propName, onGetFile, idx) {
    if (!idx)
        idx = 0;
    if ($objects.length == idx)
        return;
    var $obj = $objects.eq(idx);
    var fileUrl = $obj;
    if (propName)
        fileUrl = $obj.attr(propName);
    jQuery.get(fileUrl, function(result){onGetFile(result, $obj, idx); chainGetFile($objects, propName, onGetFile, ++idx)});
}

function getCurrentPalette() {
    var palette = localStorageGetItem('palette');
    var theme = getCurrentTheme();
    var themePalette = palette[theme.name];
    var result = themePalette || [];
    return result;
}

function setCurrentPalette(themePalette) {
    var palette = localStorageGetItem('palette');
    var theme = getCurrentTheme();
    palette[theme.name] = themePalette;
    localStorageSetItem('palette', palette);
}

function restorePaletteFromStorage(processFn) {
    console.log('palette: restore palette from storage');
    var palette = getCurrentPalette();
    var len = palette.length;
    if (!len) 
        return;
    var links = jQuery('link[rel="stylesheet"]');
    links.each(function(idx) {
        // NOTE: we trust palette that next style be our style
        var $link = jQuery(this);
        if (len && (idx < len)) {
            var cssContent = palette[idx];
            if (processFn)
                cssContent = processFn(cssContent, $link.attr('href'));

            // NOTE: fix logo color when restoring theme from url: place all styles at the end
            appendCustomCSSStyle(cssContent, 'paletteStyle' + idx);

            palette[idx] = cssContent;
            setCurrentPalette(palette);
        }
    });
}

function restorePaletteFromFile() {
    console.log('palette: restore palette from url');

    var links = jQuery('link[rel="stylesheet"]');
    var palette = [];
    chainGetFile(links, 'href', function(cssContent, $link, idx) {
        cssContent = transformPalette(cssContent, $link.attr('href'));

        addCustomCSSStyle(cssContent, 'paletteStyle' + idx, $link);

        palette.push(cssContent);
        setCurrentPalette(palette);
    });
}

function stringContainsIn(targetStr, strArr) {
    if (!(strArr instanceof Array))
        strArr = [strArr];
    var len = strArr.length;
    for (var i = 0; i < len; i++) {
        if (targetStr.indexOf(strArr[i]) >= 0)
            return true;
    }
    return false;
}

function shadeColor2(color, percent) {   
    var f=parseInt(color.slice(1),16),t=percent<0?0:255,p=percent<0?percent*-1:percent,R=f>>16,G=f>>8&0x00FF,B=f&0x0000FF;
    return "#"+(0x1000000+(Math.round((t-R)*p)+R)*0x10000+(Math.round((t-G)*p)+G)*0x100+(Math.round((t-B)*p)+B)).toString(16).slice(1);
}

function getComplementaryColor(currentColor, idx) {
    if (idx == 0)
        return currentColor;
    var newColor = shadeColor2('#' + currentColor, 0.5).replace('#', ''); // darken
    return newColor;
}

function transformPalette(cssContent, cssUrl) {
    var theme = getCurrentTheme();
    var paletteInfo = theme.paletteInfo;
    if (!paletteInfo)
        throw 'paletteInfo is undefined';

    jQuery.each(paletteInfo, function(key, value) {
        if (value.filterUrl && !stringContainsIn(cssUrl, value.filterUrl))
            return;
        var currentColor = value.currentColor.replace('#', '');
        var originColorArr = value.originColor;
        if (!(originColorArr instanceof Array))
            originColorArr = [originColorArr];
        var len = originColorArr.length;
        for (var i = 0; i < len; i++) {
            var originColor = originColorArr[i];

            var regExp = new RegExp(originColor, 'gi');

            var prefix = '';
            if (originColor.indexOf('rgba') >= 0 || originColor.indexOf('#') == 0)
                prefix = '#';
            if (originColor.indexOf('%23') == 0) {
                prefix = '%23';
            }

            cssContent = cssContent.replace(regExp, prefix + getComplementaryColor(currentColor, i)); // replace algorithm
        }
    });
    
    // fix relative paths
    var currentDir = cssUrl.replace(/[^\/]*\.css/i, '../');
    cssContent = cssContent.replace(/\.\.\//gi, currentDir);
    // NOTE: for debug purposes
    cssContent = '/* ORIGINAL URL: ' + cssUrl + ' */\n\n' + cssContent;
    return cssContent;
}

function restorePalette() {
    var palette = getCurrentPalette();
    var len = palette.length;
    if (len) {
        restorePaletteFromStorage();
    } else {
        restorePaletteFromFile();
    }
}

function initColorPicker(initColor, settingName) {
    var colorPicker = jQuery('<input type="text"/>');
    colorPicker.data('name', settingName);
    colorPicker.on("dragstop.spectrum hide.spectrum", function(e, color) {
        var color = color.toHexString();
        var $this = jQuery(this);
        var name = $this.data('name');
        var paletteInfo = getPaletteInfo(name);
        var oldColor = paletteInfo.currentColor;
        paletteInfo.currentColor = color;
        setPaletteInfo(name, paletteInfo);
        if (oldColor != color)
            restorePaletteFromFile();
    });

    return colorPicker;
}

function setPaletteInfo(key, value) {
    var theme = getCurrentTheme();
    paletteInfo = theme.paletteInfo;
    if (!paletteInfo)
        paletteInfo = {};
    paletteInfo[key] = value;
    theme.paletteInfo = paletteInfo;
    setCurrentTheme(theme);
}

function getPaletteInfo(key) {
    var theme = getCurrentTheme();
    var paletteInfo = theme.paletteInfo;
    if (!paletteInfo) {
        paletteInfo = {};
    }

    if (!paletteInfo[key]) {
        paletteInfo[key] = {};
    }

    return paletteInfo[key];
}

function showHidePalette(settingName, valArr, testVal) {
    console.log('showHidePalette', valArr, testVal);
    var selVal = testVal;
    var found = false;
    jQuery.each(valArr, function(idx, val) {
        if (val == selVal) {
            found = true;
            return false;
        }
    });
    if (!found)
        hideSettingOption(settingName);
    else showSettingOption(settingName);
}

function addPaletteSelectOption(title, settingName, originColor, initColor, filterUrl, dropdownName, dropdownValues, parentRowId) {
    var paletteInfo = getPaletteInfo(settingName);

    if (paletteInfo.currentColor) {
        initColor = paletteInfo.currentColor;
    } else {
        paletteInfo.currentColor = initColor;
    }

    if (filterUrl)
        paletteInfo.filterUrl = filterUrl;
    paletteInfo.originColor = originColor;
    setPaletteInfo(settingName, paletteInfo);
    
    var colorPicker = initColorPicker(initColor, settingName);
    if (parentRowId) {
        var parendPicker = jQuery('#' + parentRowId + '>td');
        parendPicker.append('<span style="margin-left: 10px"/>');
        parendPicker.append(colorPicker);
    } else {
        addSettingOption(title, colorPicker, null, settingName);
    }
    colorPicker.spectrum({
        color: initColor
    });

    if (dropdownName && dropdownValues) {
        if (!(dropdownValues instanceof Array))
            dropdownValues = [dropdownValues];
        var dropdown = jQuery('select[name=' + dropdownName + ']');
        dropdown.on('change initEnd', function(){showHidePalette(settingName, dropdownValues, this.options[this.selectedIndex].value)});
    }
}

function insertCommonLibs() {
    var prefix = '/white-theme/';
    var head = jQuery('head');
    head.append("<script id='spectrum' src='" + prefix + "js/spectrum.js'></script>");
    head.append("<link id='spectrum' rel='stylesheet' href='" + prefix + "css/spectrum.css'/>");
}

function fixAdvancedSettingsTable() {
    // find: http://my.router/as.asp
    if (location.href.indexOf('/as.asp') == -1)
        return;

    var table = jQuery('#tabMenu').siblings('table.table');
    table.addClass('table-setting').removeClass('table');
}

function fixActiveMenuItem() {
    // apply this code: menuL1_icon_a = new Array("", "icon-home-active", "icon-hdd-active", "icon-retweet-active", "icon-globe-active", "icon-tasks-active", "icon-random-active", "icon-wrench-active");
    var icon = jQuery('ul#mainMenu li.active i');
    var iconClassName = icon.attr('class');
    icon.attr('class', iconClassName + '-active');
}

var editableLogoList = ['xiaomi-white', 'custom', 'xiaomi-big', findRouterId(), 'default'];
restoreLogo('xiaomi-white');
restoreBackground();
fixDeviceListIcons();
fixShareDirIcons();
localizeItoggle();
insertCommonLibs();
// red
addPaletteSelectOption(localize('Main Color'), 'mainColor', 'fd6440|FF5722', '#fd6440', getCurrentTheme().name);
// logo icon: red
addPaletteSelectOption(localize('Logo Color'), 'logoColor1', 'fd6440|f57921', '#fd6440', 'common-theme', 'switchLogo', editableLogoList);
// logo text: grey
addPaletteSelectOption(localize('Logo Color'), 'logoColor2', '909090|f3f3f3', '#909090', 'common-theme', 'switchLogo', editableLogoList, 'logoColor1');
// text complementary colors: grey
addPaletteSelectOption(localize('Text Color'), 'textColor', ['#909090', '#AAAFB2', 'rgba\\(238, 238, 238, 0\\)', '%23909090', '#ccc'], '#909090', getCurrentTheme().name);
restorePalette();
fixAdvancedSettingsTable();
setTimeout(fixActiveMenuItem, 0);
fixIPTVTablesOnDarkTheme();