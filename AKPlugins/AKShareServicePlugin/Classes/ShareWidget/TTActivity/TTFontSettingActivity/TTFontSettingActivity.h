//
//  TTFontSettingActivity.h
//  Article
//
//  Created by 延晋 张 on 2017/1/12.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityProtocol.h"
#import "TTFontSettingContentItem.h"

@interface TTFontSettingActivity : NSObject <TTActivityProtocol>

@property (nonatomic, strong) TTFontSettingContentItem *contentItem;

@end
