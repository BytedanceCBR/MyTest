//
//  AKTaskSettingCellLayoutModel.m
//  Article
//
//  Created by chenjiesheng on 2018/3/1.
//

#import "AKTaskSettingDefine.h"
#import "AKTaskSettingCellLayoutModel.h"

@implementation AKTaskSettingCellLayoutModel

- (void)setShowBottomSeparateLine:(BOOL)showBottomSeparateLine
{
    if (_showBottomSeparateLine != showBottomSeparateLine) {
        _showBottomSeparateLine = showBottomSeparateLine;
        if (_showBottomSeparateLine) {
            self.cellHeight += kAKHeightSeparateView;
        } else {
            self.cellHeight -= kAKHeightSeparateView;
        }
    }
}
@end
