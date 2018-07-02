import os

def rewrite_file(file_name, contnet, replace_to):
    os.system("chmod a+w " + file_name)
    file_data = ""
    with open(file_name, "r", encoding="utf-8") as f:
        for line in f:
            if contnet in line:
                line = line.replace(contnet, replace_to)
            file_data += line
    with open(file_name, "w", encoding="utf-8") as f:
        f.write(file_data)


rewrite_file("./Pods/Headers/Public/TTNetworkManager/TTNetworkManager-umbrella.h", "#import \"TTHttpTaskChromium.h\"", "")

rewrite_file("./Pods/TTTracker/TTTracker/Core/TTTrackerProxy.m", "#import <TTNetworkManager.h>", '#import "TTNetworkManager.h"')
rewrite_file("./Pods/TTTracker/TTTracker/Core/TTTrackerUtil.m", "#import <TTInstallUtil.h>", '#import "TTInstallUtil.h"')
rewrite_file("./Pods/BDWebImage/BDWebImage/Classes/Decoder/BDImageDecoderWebP.m", "#import <webp/demux.h>", '#import "demux.h"')

