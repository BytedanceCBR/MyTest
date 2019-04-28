//
//  TSVShortVideoDetailExitManager.h
//  Article
//
//  Created by 王双华 on 2017/6/27.
//
//

#import <Foundation/Foundation.h>
#import "TTImageView.h"

typedef CGRect(^TTExitManagerUpdateImageFrame)();
typedef UIView *(^TTExitManagerUpdateTargetView)();

@interface TSVShortVideoDetailExitManager : NSObject

@property(nonatomic, strong) TTExitManagerUpdateImageFrame updateImageFrameBlock;
@property(nonatomic, strong) TTExitManagerUpdateTargetView updateTargetViewBlock;
@property(nonatomic, copy) NSString *maskViewThemeColorKey;
@property(nonatomic, assign) TTImageViewContentMode fakeImageContentMode;

- (instancetype)initWithUpdateBlock:(TTExitManagerUpdateImageFrame)updateImageFrameBlock updateTargetViewBlock:(TTExitManagerUpdateTargetView)updateTargetViewBlock;

@end
