//
//  TTAdPromotionContentItem.m
//  Article
//
//  Created by 王霖 on 2017/4/27.
//
//

#import "TTAdPromotionContentItem.h"

NSString * const TTActivityContentItemTypeAdPromotion = @"com.toutiao.ActivityContentItem.AdPromotion";

@interface TTAdPromotionContentItem ()

@property (nonatomic, copy, readwrite) NSString *iconURL;
@end

@implementation TTAdPromotionContentItem
@synthesize contentTitle = _contentTitle;

- (instancetype)initWithTitle:(NSString *)title iconURL:(NSString *)url {
    self = [super init];
    if (self) {
        _contentTitle = title;
        _iconURL = url;
    }
    return self;
}

- (NSString *)contentItemType {
    return TTActivityContentItemTypeAdPromotion;
}

@end
