//
//  TTFavouriteContentItem.h
//  Article
//
//  Created by 延晋 张 on 2017/1/18.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityContentItemProtocol.h"

extern NSString * const TTActivityContentItemTypeFavourite;

@interface TTFavouriteContentItem : NSObject <TTActivityContentItemSelectedProtocol>

@property (nonatomic, copy) TTCustomAction customAction;
@property (nonatomic, assign) BOOL selected;

@end
