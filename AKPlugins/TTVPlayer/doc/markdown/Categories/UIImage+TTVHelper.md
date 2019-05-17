# UIImage(TTVHelper) Category Reference

&nbsp;&nbsp;**Declared in** UIImage+TTVHelper.h<br />  
UIImage+TTVHelper.m  

## Tasks

### 

[+&nbsp;ttv_imageWithColor:size:](#//api/name/ttv_imageWithColor:size:)  

[&ndash;&nbsp;ttv_resizedImageForSize:](#//api/name/ttv_resizedImageForSize:)  

[&ndash;&nbsp;ttv_imageWithTintColor:](#//api/name/ttv_imageWithTintColor:)  

<a title="Class Methods" name="class_methods"></a>
## Class Methods

<a name="//api/name/ttv_imageWithColor:size:" title="ttv_imageWithColor:size:"></a>
### ttv_imageWithColor:size:

生成一张纯色图片

`+ (UIImage *)ttv_imageWithColor:(UIColor *)*color* size:(CGSize)*size*`

#### Parameters

*color*  
&nbsp;&nbsp;&nbsp;颜色  

*size*  
&nbsp;&nbsp;&nbsp;生成的图片size  

#### Discussion
生成一张纯色图片

#### Declared In
* `UIImage+TTVHelper.h`

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/ttv_imageWithTintColor:" title="ttv_imageWithTintColor:"></a>
### ttv_imageWithTintColor:

以新的色值对图片进行着色

`- (UIImage *)ttv_imageWithTintColor:(UIColor *)*tintColor*`

#### Parameters

*tintColor*  
&nbsp;&nbsp;&nbsp;着色的色值  

#### Discussion
以新的色值对图片进行着色

#### Declared In
* `UIImage+TTVHelper.h`

<a name="//api/name/ttv_resizedImageForSize:" title="ttv_resizedImageForSize:"></a>
### ttv_resizedImageForSize:

生成一张新的尺寸图片

`- (UIImage *)ttv_resizedImageForSize:(CGSize)*size*`

#### Parameters

*size*  
&nbsp;&nbsp;&nbsp;生成的图片size  

#### Discussion
生成一张新的尺寸图片

#### Declared In
* `UIImage+TTVHelper.h`

