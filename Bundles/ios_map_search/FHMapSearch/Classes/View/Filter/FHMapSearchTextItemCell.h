//
//  FHMapSearchTextItemCell.h
//  DemoFunTwo
//
//  Created by 春晖 on 2019/7/10.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMapSearchTextItemCell : UICollectionViewCell

@property(nonatomic , strong) UIFont *titleFont;
-(void)updateWithTitle:(NSString *)title highlighted:(BOOL)highlighted;

@end

NS_ASSUME_NONNULL_END
