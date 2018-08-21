//
//  TTFavouriteActivity.h
//  Article
//
//  Created by 延晋 张 on 2017/1/18.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityProtocol.h"
#import "TTFavouriteContentItem.h"
#import "TTActivityPanelDefine.h"

@interface TTFavouriteActivity : NSObject <TTActivityProtocol, TTActivityPanelActivityProtocol>

@property (nonatomic, strong) TTFavouriteContentItem *contentItem;

@end
