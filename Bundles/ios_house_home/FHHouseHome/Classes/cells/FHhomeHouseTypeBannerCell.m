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

- (void)refreshData:(FHHouseType)houseType
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
    
    NSArray<FHConfigDataOpData2ItemsModel> *items = nil;
    
    for (NSInteger i = 0; i < dataModel.opData2list.count; i ++) {
        FHConfigDataOpData2ListModel *dataModelItem = dataModel.opData2list[i];
        if (dataModelItem.opData2Type && [dataModelItem.opData2Type integerValue] == houseType && dataModelItem.opDataList && dataModelItem.opDataList.items.count > 0) {
            items = dataModelItem.opDataList.items;
        }
    }
    
    CGFloat viewWidth = ([UIScreen mainScreen].bounds.size.width - 32) / 4.0f;
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        viewWidth = ([UIScreen mainScreen].bounds.size.width - 30) / 4.0f;
    }
    CGFloat scaleRatio = 0.9;

    CGFloat imageWidth = viewWidth * scaleRatio;
    CGFloat imageHeight = viewWidth * 69 / 82 * scaleRatio;
    
    for (NSInteger i = 0; i < items.count; i++) {
        FHConfigDataOpData2ItemsModel *itemModel = items[i];

        UIView *containView = [UIView new];
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            [containView setFrame:CGRectMake( i * viewWidth + 15, 4.0f, viewWidth, 80)];
        }else
        {
            [containView setFrame:CGRectMake( i * viewWidth + 20, 4.0f, viewWidth, 65)];
        }
        [containView setBackgroundColor:[UIColor clearColor]];
        containView.layer.cornerRadius = 2;
        
        UIImageView *backImage = [UIImageView new];
        UIView *shaderBackView = [UIView new];

        if ([itemModel.image isKindOfClass:[NSArray class]] && [itemModel.image.firstObject isKindOfClass:[FHConfigDataOpData2ItemsImageModel class]]) {
            FHConfigDataOpData2ItemsImageModel *itemImage = (FHConfigDataOpData2ItemsImageModel *)itemModel.image.firstObject;
            
            if ([itemImage.url isKindOfClass:[NSString class]]) {
                [backImage bd_setImageWithURL:[NSURL URLWithString:itemImage.url]];
            }
        }
        
        [backImage setBackgroundColor:[UIColor clearColor]];
        backImage.layer.cornerRadius = 2;
//        backImage.layer.masksToBounds = YE
        // 因为shandowOffset默认为(0,3),此处需要修正下
        backImage.userInteractionEnabled = YES;
//        backImage.layer.shadowOffset = CGSizeMake(0, 0);
//        backImage.layer.shadowColor = [UIColor themeGray3].CGColor;
//        backImage.layer.shadowOpacity = 0.2;
        backImage.layer.masksToBounds = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(houseTypeBannerClick:)];
        [backImage addGestureRecognizer:tapGesture];
        CGFloat shaderWidht = 3;
        
        [backImage setFrame:CGRectMake((viewWidth - imageWidth)/2, 3, imageWidth, imageHeight)];

        [shaderBackView setFrame:CGRectMake(backImage.frame.origin.x + 3, backImage.frame.origin.y + 3, backImage.frame.size.width - 6, backImage.frame.size.height - 6)];
        [shaderBackView setBackgroundColor:[UIColor clearColor]];
        
        
        // 设置阴影的路径 此处效果为在view周边添加宽度为4的阴影效果
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(- shaderWidht, -shaderWidht, shaderBackView.frame.size.width + shaderWidht * 2, shaderBackView.frame.size.height + shaderWidht * 2)];
        shaderBackView.layer.shadowPath = path.CGPath;
        shaderBackView.layer.shadowOffset = CGSizeMake(0, 0);
        shaderBackView.layer.shadowColor = [UIColor themeGray3].CGColor;
        shaderBackView.layer.shadowOpacity = 0.2;
        
        backImage.tag = i;
        [containView addSubview:shaderBackView];
        [containView addSubview:backImage];
        
        if ([itemModel.tagImage isKindOfClass:[NSArray class]] && itemModel.tagImage.count > 0) {
            FHConfigDataOpData2ItemsImageModel *tagImageModel = (FHConfigDataOpData2ItemsImageModel *)itemModel.tagImage.firstObject;
            UIImageView *hotImage = [UIImageView new];
            if ([tagImageModel.url isKindOfClass:[NSString class]]) {
                [hotImage bd_setImageWithURL:[NSURL URLWithString:tagImageModel.url]];
            }
            [hotImage setBackgroundColor:[UIColor whiteColor]];
            [hotImage setFrame:CGRectMake(backImage.frame.size.width - ([TTDeviceHelper isScreenWidthLarge320] ? 17 : 18.5), 4, 21, 10)];
            [containView addSubview:hotImage];
        }
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.text = itemModel.title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [titleLabel setFrame:CGRectMake(backImage.frame.origin.x + ([TTDeviceHelper isScreenWidthLarge320] ? 8 : 10), 17, backImage.frame.size.width - 10, 20)];
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            titleLabel.font = [UIFont themeFontSemibold:16 * [TTDeviceHelper scaleToScreen375]];
        }else
        {
            titleLabel.font = [UIFont themeFontSemibold:12];
            [titleLabel setFrame:CGRectMake(backImage.frame.origin.x + ([TTDeviceHelper isScreenWidthLarge320] ? 8 : 10), 12, backImage.frame.size.width - 10, 20)];
        }
        titleLabel.textColor = [UIColor themeGray1];
        titleLabel.textAlignment = 0;
        [containView addSubview:titleLabel];
        
        CGFloat titleAddLbaelWidth = 25;
        
        if (itemModel.title.length > 5) {
            titleAddLbaelWidth = 20;
        }
        
        if (itemModel.addDescription) {
            UILabel *titleAddLabel = [UILabel new];
            titleAddLabel.text = itemModel.addDescription;
            titleAddLabel.textAlignment = NSTextAlignmentCenter;
            if ( [TTDeviceHelper isScreenWidthLarge320]) {
                [titleAddLabel setFrame:CGRectMake(containView.frame.size.width - titleAddLbaelWidth, titleLabel.frame.origin.y + 8, titleAddLbaelWidth, 10)];
            }else
            {
                [titleAddLabel setFrame:CGRectMake(containView.frame.size.width - titleAddLbaelWidth + 3, titleLabel.frame.origin.y + 8, titleAddLbaelWidth, 10)];
            }
            titleAddLabel.font = [UIFont themeFontRegular:6];
            titleAddLabel.textColor = [UIColor themeGray1];
            titleAddLabel.textAlignment = 0;
            [containView addSubview:titleAddLabel];
        }
        
        UILabel *subTitleLabel = [UILabel new];
        subTitleLabel.text = itemModel.descriptionStr;
        subTitleLabel.textAlignment = NSTextAlignmentCenter;
        [subTitleLabel setFrame:CGRectMake(titleLabel.frame.origin.x,titleLabel.frame.origin.y + titleLabel.frame.size.height, titleLabel.frame.size.width, 20)];
        if ( [TTDeviceHelper isScreenWidthLarge320]) {
            subTitleLabel.font = [UIFont themeFontRegular:11 * [TTDeviceHelper scaleToScreen375]];
        }else
        {
            subTitleLabel.font = [UIFont themeFontRegular:8];
        }
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
