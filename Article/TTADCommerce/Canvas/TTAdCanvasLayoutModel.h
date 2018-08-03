//
//  TTAdCanvasLayoutModel.h
//  Article
//
//  Created by yin on 2017/3/27.
//
//

typedef NS_ENUM(NSUInteger, TTAdCanvasItemType) {
    TTAdCanvasItemType_Text,
    TTAdCanvasItemType_Image,
    TTAdCanvasItemType_LoopPic,
    TTAdCanvasItemType_FullPic,
    TTAdCanvasItemType_Video,
    TTAdCanvasItemType_Live,
    TTAdCanvasItemType_Button,
    TTAdCanvasItemType_DownloadButton,
    TTAdCanvasItemType_PhoneButton,
};

#import <JSONModel/JSONModel.h>

@class TTAdCanvasLayoutStyleModel;
@class TTAdCanvasLayoutDataModel;
@interface TTAdCanvasLayoutModel : JSONModel

@property (nonatomic, strong)NSString<Optional>* name;
@property (nonatomic, strong)TTAdCanvasLayoutStyleModel<Optional>* styles;
@property (nonatomic, strong)TTAdCanvasLayoutDataModel<Optional>* data;
@property (nonatomic, strong)NSNumber<Optional>* autoplay;

@property (nonatomic, assign) NSInteger indexPath;

- (TTAdCanvasItemType)itemType;

- (BOOL)isInValidComponent;

@end


@interface TTAdCanvasLayoutStyleModel : JSONModel

@property (nonatomic, strong)NSNumber<Optional>* height;
@property (nonatomic, strong)NSNumber<Optional>* width;
@property (nonatomic, strong)NSNumber<Optional>* marginTop;
@property (nonatomic, strong)NSNumber<Optional>* marginBottom;
@property (nonatomic, strong)NSNumber<Optional>* marginLeft;
@property (nonatomic, strong)NSNumber<Optional>* marginRight;
@property (nonatomic, strong)NSNumber<Optional>* fontSize;
@property (nonatomic, strong)NSNumber<Optional>* lineHeight;
@property (nonatomic, strong)NSString<Optional>* color;
@property (nonatomic, strong)NSString<Optional>* textAlign;
@property (nonatomic, strong)NSString<Optional>* borderColor;
@property (nonatomic, strong)NSNumber<Optional>* borderRadius;
@property (nonatomic, strong)NSNumber<Optional>* borderWidth;
@property (nonatomic, strong)NSNumber<Optional>* borderStyle;
@property (nonatomic, strong)NSString<Optional>* backgroundColor;

- (NSTextAlignment)textAlignment;

@end

@protocol NSString;
@interface TTAdCanvasLayoutDataModel : JSONModel

@property (nonatomic, strong)NSString<Optional>* text;
@property (nonatomic, strong)NSString<Optional>* imgsrc;
@property (nonatomic, strong)NSString<Optional>* url;
@property (nonatomic, strong)NSString<Optional>* coverUrl;
@property (nonatomic, strong)NSString<Optional>* coverTag;
@property (nonatomic, strong)NSString<Optional>* videoId;

@property (nonatomic, strong)NSArray<Optional, NSString>* imgs;
@property (nonatomic, strong)NSString<Optional>* liveId;
@property (nonatomic, strong)NSString<Optional>* androidLink;
@property (nonatomic, strong)NSString<Optional>* iosLink;
@property (nonatomic, strong)NSString<Optional>* apple_id;
@property (nonatomic, strong)NSString<Optional>* open_url;
@property (nonatomic, strong)NSString<Optional>* ipa_url;
@property (nonatomic, strong)NSString<Optional>* telnum;
@property (nonatomic, strong)NSString<Optional>* portraitMode;

- (BOOL)isFullScreen;

@end

@class TTAdCanvasLayoutModel;
@protocol TTAdCanvasLayoutModel;
@interface TTAdCanvasJsonLayoutModel : JSONModel

@property (nonatomic, strong)NSArray<Optional, TTAdCanvasLayoutModel>* components;
@property (nonatomic, strong)TTAdCanvasLayoutModel<Optional>* rootView;

@end




