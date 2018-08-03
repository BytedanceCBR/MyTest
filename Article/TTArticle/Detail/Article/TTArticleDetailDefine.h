//
//  TTArticleDetailDefine.h
//  Article
//
//  Created by 冯靖君 on 16/4/11.
//
//

#import <Foundation/Foundation.h>

#define kVaildStayPageMinInterval 1
#define kVaildStayPageMaxInterval 7200

typedef NS_ENUM(NSInteger, TTDetailViewStyle) {
    TTDetailViewStyleLightContent,
    TTDetailViewStyleDarkContent,
    TTDetailViewStyleArticleComment,
    TTDetailViewStylePhotoComment,
    TTDetailViewStylePhotoOnlyWriteButton,
    TTDetailViewStyleCommentDetail
};

//文章详情页模板类型
typedef NS_ENUM(NSUInteger, TTDetailArchType) {
    TTDetailArchTypeNotAssign,            //还未指定
    TTDetailArchTypeNormal,               //普通模式,有评论， 有浮层， 右上角是AA按钮
    TTDetailArchTypeNoComment,            //无评论模式,无浮层，无评论、发评论按钮;右上角是AA按钮
    TTDetailArchTypeNoToolBar,            //隐藏模式, 无浮层，无tool bar 右上角有..按钮
    TTDetailArchTypeSimple,               //精简模式,无浮层，无tool bar 右上角有...按钮
};

#define ASSOCIATED_KEY(PROPERTY) \
k##PROPERTY##Key

#define GENERATE_CATEGORY_PROPERTY(PROPERTY, SETTER, TYPE, POLICY)\
static char ASSOCIATED_KEY(PROPERTY);\
- (void)SETTER:(TYPE)PROPERTY {\
objc_setAssociatedObject(self, &ASSOCIATED_KEY(PROPERTY), PROPERTY, POLICY);\
}\
\
- (TYPE)PROPERTY {\
return objc_getAssociatedObject(self, &ASSOCIATED_KEY(PROPERTY));\
}\

#define SYNTHESE_CATEGORY_PROPERTY_STRONG(PROPERTY, SETTER, TYPE)\
GENERATE_CATEGORY_PROPERTY(PROPERTY, SETTER, TYPE, OBJC_ASSOCIATION_RETAIN_NONATOMIC)
