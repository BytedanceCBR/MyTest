//
//  TTDetailModel+TTVTrackToolbarMode.m
//  Article
//
//  Created by pei yun on 2017/4/25.
//
//

#import "TTDetailModel+TTVTrackToolbarMode.h"
#import <objc/runtime.h>
#import "TTDetailModel+videoArticleProtocol.h"
#import "TTArticleDetailDefine.h"

@implementation TTDetailModel (TTVTrackToolbarMode)

- (BOOL)hasLoadedArticle
{
   return [objc_getAssociatedObject(self, @selector(hasLoadedArticle)) boolValue];
}

- (void)setHasLoadedArticle:(BOOL)hasLoadedArticle
{
   objc_setAssociatedObject(self, @selector(hasLoadedArticle), @(hasLoadedArticle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTDetailArchType)currentDetailType
{
    if (!self.hasLoadedArticle) {
        return TTDetailArchTypeNotAssign;
    }
    
    if (([self.protocoledArticle.groupFlags longLongValue] & kArticleGroupFlagsDetailTypeSimple) > 0) {
        return TTDetailArchTypeSimple;
    }
    else if (([self.protocoledArticle.groupFlags longLongValue] & kArticleGroupFlagsDetailTypeNoToolBar) > 0) {
        if ([TTDeviceHelper isPadDevice]) {
            return TTDetailArchTypeNoComment;
        }
        else {
            return TTDetailArchTypeNoToolBar;
        }
    }
    else if (([self.protocoledArticle.groupFlags longLongValue] & kArticleGroupFlagsDetailTypeNoComment) > 0) {
        return TTDetailArchTypeNoComment;
    }
    else {
        return TTDetailArchTypeNormal;
    }
}

- (void)trackToolbarMode
{
    NSString *event = @"detail";
    switch ([self currentDetailType]) {
        case TTDetailArchTypeSimple: {
            wrapperTrackEvent(event, @"simple_mode");
        }
            break;
        case TTDetailArchTypeNoComment: {
            wrapperTrackEvent(event, @"no_comments_mode");
        }
            break;
        case TTDetailArchTypeNoToolBar: {
            wrapperTrackEvent(event, @"hide_mode");
        }
            break;
        default:
            break;
    }
}

@end
