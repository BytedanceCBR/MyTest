//
//  WDDetailViewModel.h
//  Article
//
//  Created by 延晋 张 on 16/4/13.
//
//

#import <Foundation/Foundation.h>

@class WDDetailModel;
@class WDPersonModel;

typedef enum JSWDMetaInsertImageType {
    JSWDMetaInsertImageTypeNone,      //kJsMetaImageNoneKey
    JSWDMetaInsertImageTypeOrigin,    //kJsMetaImageOriginKey
    JSWDMetaInsertImageTypeThumb      //kJsMetaImageThumbKey
}JSWDMetaInsertImageType;

@interface WDDetailViewModel : NSObject

- (nonnull instancetype)initWithDetailModel:(nonnull WDDetailModel *)detailModel;

- (void)tt_setArticleHasRead;

- (BOOL)isAuthor;
- (nonnull WDPersonModel *)person;

- (CGFloat)tt_getLastContentOffsetY;
- (void)tt_setContentOffsetY:(CGFloat)offsetY;

@end

@interface WDDetailViewModel(WDDetailNativeContentCategory)
/**
 *  获取转码页的HTML， 如果不是转码页，且不是导流页超时导致加载转码页，则返回nil
 *
 *  @param webView 从该值获取webview的高宽，不会进行加载等设置
 *
 *  @return 获取转码页的HTML
 */
- (nullable NSString *)tt_nativeContentHTMLForWebView:(nullable UIView *)webView;

/**
 *  获取转码页的baseURL
 *
 *  @return 如果是非转码页，且不是导流页超时导致加载转码页，返回nil
 */
- (nullable NSURL *)tt_nativeContentFilePath;

@end

