//
//  TTForumTableViewHeader.m
//  Article
//
//  Created by yuxin on 4/17/15.
//
//

#import "TTMomentEnterView.h"
#import "ArticleBadgeManager.h"
#import "TTDeviceHelper.h"

@implementation TTMomentEnterView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)awakeFromNib {
    
    [super awakeFromNib];
    
    if ([UIScreen mainScreen].bounds.size.width > 320.0f) {
        self.titleLb.font = [UIFont systemFontOfSize:18];        
    }
    if ([TTDeviceHelper isPadDevice]) {
        self.titleLb.font = [UIFont systemFontOfSize:22];
    }
    
    self.rightBadgeView.hidden = YES;
    self.avatarImageView.hidden = YES;
    self.leftBadgeView.hidden = YES;
     
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveBadgeChangedNotification:) name:kArticleBadgeManagerRefreshedNotification object:nil];
//
// 
//    [self receiveBadgeChangedNotification:nil];
}

//- (void)receiveBadgeChangedNotification:(NSNotification*)noti
//{
//    if ([[ArticleBadgeManager shareManger].momentUpdateNumber integerValue] > 0) {
//        self.rightBadgeView.hidden = NO;
//        self.rightBadgeView.badgeNumber = TTBadgeNumberPoint;
//        self.avatarImageView.hidden = NO;
//        [self.avatarImageView setImageWithURLString:[ArticleBadgeManager shareManger].momentUpdateUser.avatarURLString];
//    }
//    else {
//        
//        self.rightBadgeView.badgeNumber = TTBadgeNumberHidden;
//        self.rightBadgeView.hidden = YES;
//        self.avatarImageView.hidden = YES;
//    }
//    
//    self.leftBadgeView.hidden = YES;
//    
//    if ([[ArticleBadgeManager shareManger].needFollowNumber integerValue] > 0) {
//        
//        self.leftBadgeView.hidden = NO;
//        self.leftBadgeView.badgeNumber = [[ArticleBadgeManager shareManger].needFollowNumber integerValue];
//    }
//    else {
//        self.leftBadgeView.hidden = YES;
// 
//    }
//}

- (IBAction)enterTouched:(id)sender
{
    self.rightBadgeView.hidden = YES;
    self.avatarImageView.hidden = YES;
    if (self.enterTouchHandler) {
        self.enterTouchHandler();
    }

}

- (void)setCellImageName:(NSString*)imageName {
    
    self.cellImageView.hidden = NO;
    self.cellImageView.imageName = imageName;
    self.titleLeftMargin.constant = 110;
}


@end
