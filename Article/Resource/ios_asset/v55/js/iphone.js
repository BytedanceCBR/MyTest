window.APP_VERSION = 'v55';
window.startTimestamp = Date.now();
document.addEventListener('DOMContentLoaded', function () {
    // NOTE 前端消除掉iOSV55加载3次js问题
    if (document.body.getAttribute('inited')) {
        return;
    }
    document.body.setAttribute('inited', true);

    loadscript('lib.js', function () {
        loadscript('iphone.js', function () {
            /**
             * V55 直接将正文渲染到HTML中，不会写下发content字段，需要手动下发content为 'v55',区分退出时，
             *     或者初始化时content为空的情况。
             * V55 直接将h5_extra设置到全局window，需要手动触发setExtra。
             */

            window.setContent('v55');
            window.setExtra();
        });
    });
}, false);