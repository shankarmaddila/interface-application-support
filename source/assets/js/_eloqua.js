// console.group("<head> eloqua")

var _elqQ;

_elqQ = _elqQ || [];

_elqQ.push(["elqSetSiteId", "672"]);

_elqQ.push(["elqTrackPageView"]);

(function() {
    var async_load;
    async_load = function() {
        var s, x;
        s = document.createElement("script");
        s.type = "text/javascript";
        s.async = true;
        s.src = "//img.en25.com/i/elqCfg.min.js";
        x = document.getElementsByTagName("script")[0];
        x.parentNode.insertBefore(s, x);
    };
    if (window.addEventListener) {
        window.addEventListener("DOMContentLoaded", async_load, false);
    } else {
        if (window.attachEvent) {
            window.attachEvent("onload", async_load);
        }
    }
})();


var timerId = null,
    timeout = 5;

WaitUntilCustomerGUIDIsRetrieved = function(){
    if (!!(timerId)) {
        if (timeout == 0) {
            return;
        }
        if (typeof this.GetElqCustomerGUID === 'function') {
            Eloqua.loadComplete(GetElqCustomerGUID());
            return;
        }
        timeout -= 1;
    }
    timerId = setTimeout("WaitUntilCustomerGUIDIsRetrieved()", 500);
    return;
}

window.onload = WaitUntilCustomerGUIDIsRetrieved;

_elqQ.push(['elqGetCustomerGUID']);

// console.groupEnd()
