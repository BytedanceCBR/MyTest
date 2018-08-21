//
//  AKTaskSettingCellModel.m
//  Article
//
//  Created by chenjiesheng on 2018/3/1.
//

#import "AKTaskSettingDefine.h"
#import "AKTaskSettingCellModel.h"

@implementation AKTaskSettingCellModel

- (AKTaskSettingCellLayoutModel *)layoutModel
{
    if (_layoutModel == nil) {
        AKTaskSettingCellLayoutModel *layout = [[AKTaskSettingCellLayoutModel alloc] init];
        CGFloat height = kAKHeightOperationView;
        
        if (!isEmptyString(self.operationRegionTitle)) {
            CGSize titleSize = [self.operationRegionTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kAKFontDesRegionTitle]}];
            layout.heightOperationRegionTitle = titleSize.height;
        }
        
        CGFloat desRegionHeight = 0;
        if (!isEmptyString(self.desRegionTitle)) {
            desRegionHeight += kAKPaddingTopDesRegionComponent;
            CGSize titleSize = [self.desRegionTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kAKFontDesRegionTitle]}];
            desRegionHeight += titleSize.height;
            layout.heightDesRegionTitle = titleSize.height;
        }
        if ([UIImage imageNamed:self.desImageName]) {
            desRegionHeight += kAKPaddingTopDesRegionComponent;
            desRegionHeight += self.desImageSize.height;
            layout.sizeDesRegionImage = self.desImageSize;
        }
        desRegionHeight += kAKPaddingBottomDesRegion;
        if (desRegionHeight < kAkHeightMinDesRegion) {
            desRegionHeight = kAkHeightMinDesRegion;
        }
        
        height += desRegionHeight;
        layout.cellHeight = height;
        _layoutModel = layout;
    }
    return _layoutModel;
}

@end
