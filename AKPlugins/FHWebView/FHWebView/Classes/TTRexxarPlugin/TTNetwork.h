//
//  TTNetwork.h
//  Article
//
//  Created by muhuai on 2017/7/3.
//
//

#import <Foundation/Foundation.h>
#import <TTRexxar/TTRDynamicPlugin.h>
#import "BDTDefaultHTTPRequestSerializer.h"

@interface FHCommonJSONHTTPRequestSerializer : BDTDefaultHTTPRequestSerializer

@end

@interface TTNetwork : TTRDynamicPlugin
TTR_EXPORT_HANDLER(fetch)
TTR_EXPORT_HANDLER(getNetCommonParams)
@end
