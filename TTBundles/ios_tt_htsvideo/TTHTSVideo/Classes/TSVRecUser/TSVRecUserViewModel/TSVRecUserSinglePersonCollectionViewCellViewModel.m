//
//  TSVRecUserSinglePersonCollectionViewCellViewModel.m
//  Article
//
//  Created by 王双华 on 2017/9/27.
//

#import "TSVRecUserSinglePersonCollectionViewCellViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTRoute.h"

@interface TSVRecUserSinglePersonCollectionViewCellViewModel()

@property (nonatomic, copy, readwrite) NSString *avatarURL;
@property (nonatomic, copy, readwrite) NSString *userName;
@property (nonatomic, copy, readwrite) NSString *userAuthInfo;
@property (nonatomic, copy, readwrite) NSString *recommendReason;
@property (nonatomic, copy, readwrite) NSString *userID;
@property (nonatomic, copy, readwrite) NSString *statsPlaceHolder;
@property (nonatomic, strong) TSVRecUserSinglePersonModel *model;

@end

@implementation TSVRecUserSinglePersonCollectionViewCellViewModel

- (instancetype)initWithModel:(TSVRecUserSinglePersonModel *)model
{
    if (self = [super init]) {
        _model = model;
        [self bindModel];
    }
    return self;
}

- (void)bindModel
{
    RACChannelTo(self, avatarURL) = RACChannelTo(self, model.user.avatarURL);
    RACChannelTo(self, userName) = RACChannelTo(self, model.user.name);
    RACChannelTo(self, userAuthInfo) = RACChannelTo(self, model.user.userAuthInfo);
    RACChannelTo(self, isFollowing, @NO) = RACChannelTo(self, model.user.isFollowing);
    RACChannelTo(self, recommendReason) = RACChannelTo(self, model.recommendReason);
    RACChannelTo(self, userID) = RACChannelTo(self, model.user.userID);
    RACChannelTo(self, statsPlaceHolder) = RACChannelTo(self, model.statsPlaceHolder);
}

@end
