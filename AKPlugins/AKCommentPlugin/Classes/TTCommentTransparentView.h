//
//  TTCommentTransparentView.h
//  Article
//
//  Created by zhaoqin on 23/02/2017.
//
//

#import "SSViewBase.h"

@interface TTCommentTransparentView : SSViewBase
@property (nonatomic, assign) BOOL isResponseTouchEvent;
@property (nonatomic, strong) void (^touchComplete)();

@end
