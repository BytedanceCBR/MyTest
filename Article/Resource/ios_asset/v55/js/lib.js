var loadscript = (function(){
    var scripts = document.querySelectorAll('script');
    var path = '';
    for (var i = 0, l = scripts.length; i < l; i++) {
        var src = scripts[i].src;
        var idx = src.indexOf('/v55/js/lib.js');
        if (idx > -1) {
            path = src.substr(0, idx);
            break;
        } else {
            idx = src.indexOf('/v60/js/lib.js');
            if (idx > -1) {
                path = src.substr(0, idx);
                break;
            }
        }
    }
    if (path) {
        path += '/shared/js/';
    }

    return function (url, callback) {
        if (!path) {
            return;
        }
        var script = document.createElement('script');
        script.src = path + url;
        script.onload = callback;
        document.body.appendChild(script);
        script = null;
    }
})();
