//
//  FHMultiMediaBaseCell.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHMultiMediaBaseCell.h"

@implementation FHMultiMediaBaseCell

- (void)updateViewModel:(FHMultiMediaItemModel *)model {
    
}

-(UIImage *)placeHolder {
    if (!_placeHolder) {
        _placeHolder = [UIImage imageNamed:@"default_image"];
    }
    return _placeHolder;
}

@end
