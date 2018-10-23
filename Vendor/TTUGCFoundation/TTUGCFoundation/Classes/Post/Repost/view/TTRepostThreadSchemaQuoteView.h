//
//  TTRepostThreadSchemaQuoteView.h
//  Article
//
//  Created by ranny_90 on 2017/9/11.
//
//
#import "SSThemed.h"
#import "Thread.h"

@interface TTRepostQuoteModel : NSObject

@property (nonatomic,copy) NSString *title;

@property (nonatomic,copy) NSString *titleRichSpan;

@property (nonatomic,assign) BOOL isVideo;

@property (nonatomic,copy) NSString *coverURL;

- (instancetype)initWithRepostParam:(NSDictionary *)repostParam;

@end


@interface TTRepostThreadSchemaQuoteView : SSThemedView

- (instancetype)initWithQuoteModel:(TTRepostQuoteModel *)quoteModel;

- (instancetype)initWithRepostParam:(NSDictionary *)repostParam;

@end
