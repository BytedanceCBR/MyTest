//
//  TTLiveHeaderView+Star.h
//  Article
//
//  Created by matrixzk on 8/11/16.
//
//

#import "TTLiveHeaderView.h"

@interface TTLiveHeaderView ()

@property (nonatomic, strong) UIButton *avatarButton;
//@property (nonatomic, strong) UILabel *starNameLabel;
//@property (nonatomic, strong) UILabel *titleLabel;

@end

@interface TTLiveHeaderView (Star)
- (void)setupSubviews4LiveTypeStar;
@end
