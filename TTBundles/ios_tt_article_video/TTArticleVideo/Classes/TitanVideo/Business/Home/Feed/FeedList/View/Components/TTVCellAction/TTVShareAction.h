//
//  TTVShareAction.h
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//



#import "TTVMoreAction.h"
#define TTShareKey 201
@class TTActivityShareManager;
@interface TTVShareActionEntity : TTVMoreActionEntity
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *videoSubjectID;
@property (nonatomic ,strong)NSNumber *adID;
@property (nonatomic ,weak)UIResponder *responder;
@property (nonatomic, assign) NSInteger groupFlags;
@end

@interface TTVShareAction : TTVMoreAction
@property (nonatomic ,strong)TTVShareActionEntity *entity;
@property (nonatomic, strong) TTActivityShareManager   *activityActionManager;
@property (nonatomic, copy) UIViewController *(^getPresentingViewControllerOfShare)(UIResponder *responder);
- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity;
- (void)execute:(TTActivityType)type;
@end


