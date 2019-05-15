//
//  TTVPlayerStateControl.h
//  Article
//
//  Created by panxiang on 2018/8/30.
//

#import <Foundation/Foundation.h>

@interface TTVPlayerStateControl : NSObject
@property (nonatomic, assign ,readonly) BOOL isDragging;
@property (nonatomic, assign ,readonly) BOOL isShowing;
@property (nonatomic, assign ,readonly) BOOL canShowTitle;
@property (nonatomic, assign ,readonly) BOOL canShowTitleShadow;
@property (nonatomic, assign ,readonly) BOOL isLocked;
@end
