//
//  TTEditUserProfileSectionView.h
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"



@interface TTEditUserProfileSectionView : TTThemedSplitView

@property (nonatomic, strong) SSThemedLabel *titleLabel;

+ (CGFloat)defaultSectionHeight;

@end
