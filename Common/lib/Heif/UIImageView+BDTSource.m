//
//  UIImageView+BDTSource.m
//  Article
//
//  Created by fengyadong on 2017/11/13.
//

#import "UIImageView+BDTSource.h"

NSString *const kBDTSourceFeed = @"feed";
NSString *const kBDTSourceDetail = @"detail";
NSString *const kBDTSourcePhotoAlbum = @"photo_album";
NSString *const kBDTSourceUGCCell = @"ugc_cell";

@implementation UIImageView (BDTSource)

- (NSString *)tt_source {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTt_source:(NSString *)tt_source {
    objc_setAssociatedObject(self, @selector(tt_source), tt_source, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation NSURL (BDTSource)

- (NSString *)tt_source {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTt_source:(NSString *)tt_source {
    objc_setAssociatedObject(self, @selector(tt_source), tt_source, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
