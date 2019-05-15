//
//  UIImageView+BDTSource.h
//  Article
//
//  Created by fengyadong on 2017/11/13.
//

#import <UIKit/UIKit.h>

extern NSString *const kBDTSourceFeed;
extern NSString *const kBDTSourceDetail;
extern NSString *const kBDTSourcePhotoAlbum;
extern NSString *const kBDTSourceUGCCell;

@interface UIImageView (BDTSource)

@property (nonatomic, strong) NSString *tt_source;

@end

@interface NSURL (BDTSource)

@property (nonatomic, strong) NSString *tt_source;

@end
