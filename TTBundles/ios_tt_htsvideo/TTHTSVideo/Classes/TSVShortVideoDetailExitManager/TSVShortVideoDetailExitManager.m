//
//  TSVShortVideoDetailExitManager.m
//  Article
//
//  Created by 王双华 on 2017/6/27.
//
//

#import "TSVShortVideoDetailExitManager.h"

@implementation TSVShortVideoDetailExitManager

- (instancetype)initWithUpdateBlock:(TTExitManagerUpdateImageFrame)updateImageFrameBlock updateTargetViewBlock:(TTExitManagerUpdateTargetView)updateTargetViewBlock;
{
    self = [super init];
    if (self) {
        _updateImageFrameBlock = updateImageFrameBlock;
        _updateTargetViewBlock = updateTargetViewBlock;
    }
    return self;
}

@end
