//
//  SSWebViewControllerView.h
//  Article
//
//  Created by Zhang Leonardo on 13-8-21.
//
//

#import "SSViewBase.h"
#import "SSWebViewContainer.h"
#import "SSNavigationBar.h"
#import "SSWebViewBackButtonView.h"

typedef enum SSWebViewBackButtonImageType{
    SSWebViewBackButtonImageTypeLeftArrow,         //返回按钮,箭头向左,default
    SSWebViewBackButtonImageTypeDownArrow,         //返回按钮,箭头向下
    SSWebViewBackButtonImageTypeClose,             //关闭按钮
}SSWebViewBackButtonImageType;

typedef enum SSWebViewBackButtonPositionType{
    SSWebViewBackButtonPositionTypeTopLeft,             //返回／关闭按钮在左上方,default
    SSWebViewBackButtonPositionTypeTopRight,            //返回／关闭按钮在右上方
    SSWebViewBackButtonPositionTypeBottomLeft,          //返回／关闭按钮在左下方
    SSWebViewBackButtonPositionTypeBottomRight,         //返回／关闭按钮在右上方
}SSWebViewBackButtonPositionType;

typedef enum SSWebViewBackButtonColorType{
    SSWebViewBackButtonColorTypeDefault,            //黑色
    SSWebViewBackButtonColorTypeLightContent,       //白色
}SSWebViewBackButtonColorType;

typedef enum SSWebViewDismissType{
    SSWebViewDismissTypePop,                //default
    SSWebViewDismissTypePresent
}SSWebViewDismissType;

@interface SSWebViewControllerView : SSViewBase
@property(nonatomic, strong)SSWebViewContainer * ssWebContainer;

@property(nonatomic, assign, setter=setRightButtonDisplay:)BOOL rightButtonDisplayed;

@property (nonatomic, strong) SSNavigationBar * navigationBar;

@property (nonatomic, strong) SSWebViewBackButtonView * backButtonView;
@property (nonatomic, assign)BOOL shouldDisableHistory;             //是否禁止返回上一个web页面,而是直接关闭页面
@property (nonatomic, assign)BOOL shouldShowRefreshAction;
@property (nonatomic, assign)BOOL shouldShowCopyAction;
@property (nonatomic, assign)BOOL shouldShowSafariAction;
@property (nonatomic, assign)BOOL shouldShowShareAction;
@property (nonatomic, assign)BOOL shouldDisableHash; // 是否需要拼接hash
@property (nonatomic, assign)BOOL isWebControl; // 是否web控制返回按钮
@property (nonatomic, assign)BOOL isShowCloseWebBtn; // 是否显示关闭x按钮
@property (nonatomic, assign)NSInteger closeStackCounts;

@property (nonatomic, copy)NSString *shareTitle;
@property (nonatomic, copy)NSString *shareDesc;
@property (nonatomic, copy)NSString *shareImageUrl;

@property (nonatomic, copy)NSString *repostTitle;
@property (nonatomic, copy)NSString *repostSchema;
@property (nonatomic, copy)NSString *repostCoverUrl;
@property (nonatomic, assign) NSInteger repostType;
@property (nonatomic, assign)BOOL isRepostWeitoutiaoFromWeb;


- (instancetype)initWithFrame:(CGRect)frame baseCondition:(NSDictionary *)baseCondition NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

////用于统计， 可以为空
//@property(nonatomic, retain)NSString * groupID;
////用于统计， 可以为空
//@property(nonatomic, retain)NSString * adID;
- (void)setupFShareBtn:(BOOL)isShowBtn;

- (void)loadWithURL:(NSURL *)requestURL;
- (void)loadWithURL:(NSURL *)requestURL requestHeaders:(NSDictionary *)requestHeaders;
- (void)loadWithURL:(NSURL *)requestURL shouldAppendQuery:(BOOL)shouldAppendQuery;
//- (void)enableMakeView:(BOOL)enable;

@end
