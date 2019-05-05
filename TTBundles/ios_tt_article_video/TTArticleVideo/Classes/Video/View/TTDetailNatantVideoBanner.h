//
//  TTDetailNatantVideoBanner.h
//  Article
//
//  Created by 刘廷勇 on 16/4/20.
//
//

#import "TTDetailNatantViewBase.h"
#import "TTVideoBannerModel.h"

@interface TTDetailNatantVideoBanner : TTDetailNatantViewBase

@property (nonatomic, strong) TTVideoBannerModel *viewModel;
@property (nonatomic, copy) NSString *groupID;
- (instancetype)initWithWidth:(CGFloat)width NS_DESIGNATED_INITIALIZER;

@end
