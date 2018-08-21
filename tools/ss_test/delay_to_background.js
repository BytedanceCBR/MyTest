var testName = "Delay to background"
var target = UIATarget.localTarget();
var app = target.frontMostApp();

target.delay(5)
target.deactivateAppForDuration(5);
