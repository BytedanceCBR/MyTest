//
//  TTRPhoto.h
//  Article
//
//  Created by lizhuoli on 2017/9/4.
//
//

#import <Foundation/Foundation.h>
#import <TTRexxar/TTRDynamicPlugin.h>

@interface TTRPhoto : TTRDynamicPlugin

TTR_EXPORT_HANDLER(takePhoto);
TTR_EXPORT_HANDLER(confirmUploadPhoto);

@end
