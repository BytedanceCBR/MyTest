//
//  TTGifImageView.h
//  Article
//
//  Created by carl on 2017/5/21.
//
//

#import <UIKit/UIKit.h>
#import "VVeboImage.h"
#import "VVeboImageView.h"

@protocol TTAnimationImageView
@property (nonatomic, assign) BOOL repeats;
@property (nonatomic, copy)   void (^completionHandler)(BOOL);
@property (nonatomic, strong, readonly) VVeboImage *gifImage;
@property (nonatomic, assign) NSInteger currentPlayIndex;
@property (nonatomic, assign) BOOL delayDuration;
@end

@interface TTGifImageView : UIImageView <TTAnimationImageView>
@property (nonatomic, assign) BOOL repeats;
@property (nonatomic, copy)   void (^completionHandler)(BOOL);
@property (nonatomic, strong, readonly) VVeboImage *gifImage;
@property (nonatomic, assign) NSInteger currentPlayIndex;
@property (nonatomic, assign) BOOL delayDuration; 
@end


@interface VVeboImageView (TTAnimationImageView) <TTAnimationImageView>
//@warning no implementation 
@end
