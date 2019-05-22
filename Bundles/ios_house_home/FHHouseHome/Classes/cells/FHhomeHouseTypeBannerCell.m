//
//  FHhomeHouseTypeBannerCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/4/30.
//

#import "FHhomeHouseTypeBannerCell.h"
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "FHEnvContext.h"
#import "FHConfigModel.h"
#import "UIImageView+BDWebImage.h"
#import <TTDeviceHelper.h>
#import "FHHouseBridgeManager.h"
#import <TTRoute.h>
#import <FHHomeConfigManager.h>

@implementation FHhomeHouseTypeBannerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshData:(id)data
{
    FHConfigDataModel *dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    
    if (!dataModel.opData2list || dataModel.opData2list.count == 0) {
        return;
    }
    
    if (![dataModel.opData2list.firstObject isKindOfClass:[FHConfigDataOpData2ListModel class]]) {
        return;
    }
    
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSArray<FHConfigDataOpData2ItemsModel> *items = ((FHConfigDataOpData2ListModel *)dataModel.opData2list.firstObject).opDataList.items;
    CGFloat viewWidth = ([UIScreen mainScreen].bounds.size.width - 28) / 4.0f;
    
    for (NSInteger i = 0; i < items.count; i++) {
        FHConfigDataOpData2ItemsModel *itemModel = items[i];

        UIView *containView = [UIView new];
        [containView setFrame:CGRectMake( i * viewWidth + 14, 4.0f, viewWidth, 80)];
        [containView setBackgroundColor:[UIColor whiteColor]];

        
        UIImageView *backImage = [UIImageView new];

        if ([itemModel.image isKindOfClass:[NSArray class]] && [itemModel.image.firstObject isKindOfClass:[FHConfigDataOpData2ItemsImageModel class]]) {
            FHConfigDataOpData2ItemsImageModel *itemImage = (FHConfigDataOpData2ItemsImageModel *)itemModel.image.firstObject;
            
            if ([itemImage.url isKindOfClass:[NSString class]]) {
                [backImage bd_setImageWithURL:[NSURL URLWithString:itemImage.url]];
            }
        }
        
        [backImage setBackgroundColor:[UIColor whiteColor]];
        backImage.layer.cornerRadius = 2;
//        backImage.layer.masksToBounds = YE
        // 因为shandowOffset默认为(0,3),此处需要修正下
        backImage.userInteractionEnabled = YES;
        backImage.layer.shadowOffset = CGSizeMake(0, 0);
        backImage.layer.shadowColor = [UIColor themeGray3].CGColor;
        backImage.layer.shadowOpacity = 0.2;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(houseTypeBannerClick:)];
        [backImage addGestureRecognizer:tapGesture];
        CGFloat shaderWidht = 1;
        
        if (viewWidth > 82 * [TTDeviceHelper scaleToScreen375]) {
            [backImage setFrame:CGRectMake((viewWidth - 82 * [TTDeviceHelper scaleToScreen375])/2.0f, 3, 82 * [TTDeviceHelper scaleToScreen375], 69 * [TTDeviceHelper scaleToScreen375])];
        }else
        {
            [backImage setFrame:CGRectMake(0.0f, 3, viewWidth, viewWidth * 69 / 82)];
        }
        
        // 设置阴影的路径 此处效果为在view周边添加宽度为4的阴影效果
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(-shaderWidht, -shaderWidht, backImage.frame.size.width + shaderWidht * 2, backImage.frame.size.height + shaderWidht * 2)];
        backImage.layer.shadowPath = path.CGPath;
        backImage.tag = i;
        [containView addSubview:backImage];
        
        
        if ([itemModel.tagImage isKindOfClass:[NSArray class]] && itemModel.tagImage.count > 0) {
            FHConfigDataOpData2ItemsImageModel *tagImageModel = (FHConfigDataOpData2ItemsImageModel *)itemModel.tagImage.firstObject;
            UIImageView *hotImage = [UIImageView new];
            if ([tagImageModel.url isKindOfClass:[NSString class]]) {
                [hotImage bd_setImageWithURL:[NSURL URLWithString:tagImageModel.url]];
            }
            [hotImage setBackgroundColor:[UIColor whiteColor]];
            [hotImage setFrame:CGRectMake(backImage.frame.size.width - 16 - ([TTDeviceHelper isScreenWidthLarge320] ? : 1.5), 4, 18, 8)];
            [containView addSubview:hotImage];
        }
        
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.text = itemModel.title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [titleLabel setFrame:CGRectMake(backImage.frame.origin.x + 10, 13, backImage.frame.size.width - 10, 20)];
        titleLabel.font = [UIFont themeFontSemibold:16 * [TTDeviceHelper scaleToScreen375]];
        titleLabel.textColor = [UIColor themeGray1];
        titleLabel.textAlignment = 0;
        [containView addSubview:titleLabel];
        
        if (itemModel.addDescription) {
            UILabel *titleAddLabel = [UILabel new];
            titleAddLabel.text = itemModel.addDescription;
            titleAddLabel.textAlignment = NSTextAlignmentCenter;
            [titleAddLabel setFrame:CGRectMake(titleLabel.text.length * 12 * [TTDeviceHelper scaleToScreen375], titleLabel.frame.origin.y + 8, 40, 10)];
            titleAddLabel.font = [UIFont themeFontRegular:6];
            titleAddLabel.textColor = [UIColor themeGray1];
            titleAddLabel.textAlignment = 0;
            [containView addSubview:titleAddLabel];
        }
        
        UILabel *subTitleLabel = [UILabel new];
        subTitleLabel.text = itemModel.descriptionStr;
        subTitleLabel.textAlignment = NSTextAlignmentCenter;
        [subTitleLabel setFrame:CGRectMake(titleLabel.frame.origin.x,titleLabel.frame.origin.y + titleLabel.frame.size.height + 5, titleLabel.frame.size.width, 20)];
        subTitleLabel.font = [UIFont themeFontRegular:11 * [TTDeviceHelper scaleToScreen375]];
        subTitleLabel.textColor = [UIColor themeGray3];
        subTitleLabel.textAlignment = 0;
        [containView addSubview:subTitleLabel];
        [self.contentView addSubview:containView];
    }
}

- (void)houseTypeBannerClick:(id)sender
{
    FHConfigDataModel *dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    
    if (!dataModel.opData2list || dataModel.opData2list.count == 0) {
        NSLog(@"op Data = %@",dataModel.opData2list);
        return;
    }
    
    if (![dataModel.opData2list.firstObject isKindOfClass:[FHConfigDataOpData2ListModel class]]) {
        return;
    }
    
    NSArray<FHConfigDataOpData2ItemsModel> *items = ((FHConfigDataOpData2ListModel *)dataModel.opData2list.firstObject).opDataList.items;
    
    UITapGestureRecognizer *tap = sender;
    if ([tap isKindOfClass:[UITapGestureRecognizer class]]) {
        UIView *tapView = [tap view];
        if (tapView) {
            if (items.count > tapView.tag) {
                FHConfigDataOpDataItemsModel *itemModel = [items objectAtIndex:tapView.tag];
                
                NSMutableDictionary *dictTrace = [NSMutableDictionary new];
                [dictTrace setValue:@"maintab" forKey:@"enter_from"];
                [dictTrace setValue:@"click" forKey:@"enter_type"];
                
                
                if ([itemModel.logPb isKindOfClass:[NSDictionary class]] && itemModel.logPb[@"element_from"] != nil) {
                    [dictTrace setValue:itemModel.logPb[@"element_from"] forKey:@"element_from"];
                }
                
                NSString *stringOriginFrom = itemModel.logPb[@"origin_from"];
                if ([stringOriginFrom isKindOfClass:[NSString class]] && stringOriginFrom.length != 0) {
                    [[[FHHouseBridgeManager sharedInstance] envContextBridge] setTraceValue:stringOriginFrom forKey:@"origin_from"];
                    [dictTrace setValue:stringOriginFrom forKey:@"origin_from"];
                    
                }else
                {
                    [[[FHHouseBridgeManager sharedInstance] envContextBridge] setTraceValue:@"school_operation" forKey:@"origin_from"];
                    [dictTrace setValue:@"school_operation" forKey:@"origin_from"];
                    
                }
                
                NSDictionary *userInfoDict = @{@"tracer":dictTrace};
                TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
                
                if (itemModel.openUrl) {
                    NSURL *url = [NSURL URLWithString:itemModel.openUrl];
                    
                    if ([itemModel.openUrl containsString:@"snssdk1370://category_feed"]) {
                        [FHHomeConfigManager sharedInstance].isNeedTriggerPullDownUpdate = YES;
                        [FHHomeConfigManager sharedInstance].isTraceClickIcon = YES;
                        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
                    }else
                    {
                        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
                    }
                }
            }
        }
    }
}

@end
