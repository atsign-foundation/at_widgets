function checkAndWriteCookie() {
    // change this value to your app's deeplink
    var deepLink = "atcompany-atmosphere://";

    const urlSearchParams = new URLSearchParams(window.location.search);
    const params = Object.fromEntries(urlSearchParams.entries());
    if (params['key'] != undefined && params['atsign'] != undefined) {
        custom = deepLink + params['key'] + '/' + params['atsign'];
        var now = new Date();
        var time = now.getTime();
        var expireTime = time + 1000 * 3600;
        now.setTime(expireTime);
        document.cookie = 'inviteKey=' + custom + ';expires=' + now.toGMTString();
    } else {
        var cookieValue = getCookie("inviteKey");
        if (cookieValue) {
            location.href = cookieValue;
        } else {
            document.writeln("No Cookies...");
        }
    }
}

function getCookie(name) {
    var re = new RegExp(name + "=([^;]+)");
    var value = re.exec(document.cookie);
    return (value != null) ? unescape(value[1]) : null;
}