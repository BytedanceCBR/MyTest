//
//  TTVideoPGCCell.h
//  Article
//
//  Created by 刘廷勇 on 15/11/5.
//
//

#import <UIKit/UIKit.h>
#import "TTVideoPGCViewModel.h"
#import "TTDeviceHelper.h"

#define kVideoPGCBarHeight ([TTDeviceHelper isScreenWidthLarge320] ? 48.0 : 44.0)

@interface TTVideoPGCBar : UIView

@property (nonatomic, strong) TTVideoPGCViewModel *viewModel;

@end
