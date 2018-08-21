//
//  TTVLastReadItem.m
//  Article
//
//  Created by pei yun on 2017/4/7.
//
//

#import "TTVLastReadItem.h"
#import "TTVLastReadContainerView.h"
#import "TTUIResponderHelper.h"

#define kLastReadCellHeightForiPad           44
#define kLastReadCellHeightForiPhone6        40
#define kLastReadCellHeightForiPhone6Plus    40
#define kLastReadCellHeightForOthers         36

#define SecondsInOneMin     60
#define SecondsInOneHour    (60 * 60)
#define SecondsInOneDay     (24 * 60 * 60)

@implementation TTVLastReadItem

- (CGFloat)cellHeightWithWidth:(NSInteger)width {
    if ([TTDeviceHelper isPadDevice]){
        return kLastReadCellHeightForiPad;
    } else if ([TTDeviceHelper is736Screen]) {
        return kLastReadCellHeightForiPhone6Plus;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]){
        return kLastReadCellHeightForiPhone6;
    } else{
        return kLastReadCellHeightForOthers;
    }
}

@end

@interface TTVLastReadCell ()

@property (nonatomic, strong) TTVLastReadContainerView *containerView;

@end

@implementation TTVLastReadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        self.backgroundColor = self.contentView.backgroundColor;
        
        _containerView = [[TTVLastReadContainerView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_containerView];
    }
    return self;    
}

- (void)setItem:(TTVLastReadItem *)item
{
    [super setItem:item];
    
    self.containerView.lastRead = item.lastRead;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat paddingForCellView = [TTUIResponderHelper paddingForViewWidth:0];
    self.containerView.frame = CGRectMake(paddingForCellView, 0, self.contentView.width - 2 * paddingForCellView, self.contentView.height);
}

@end
