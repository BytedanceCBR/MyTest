# TTVideoActivityIndicator Class Reference

&nbsp;&nbsp;**Inherits from** UIView  
&nbsp;&nbsp;**Declared in** TTVideoActivityIndicator.h<br />  
TTVideoActivityIndicator.m  

## Overview

A control similar to iOS' UIActivityIndicatorView modeled after Google&rsquo;s Material Design Activity spinner.

## Tasks

### Other Methods

[&ndash;&nbsp;setAnimating:](#//api/name/setAnimating:)  

[&ndash;&nbsp;startAnimating](#//api/name/startAnimating)  

[&ndash;&nbsp;stopAnimating](#//api/name/stopAnimating)  

[&ndash;&nbsp;isAnimating](#//api/name/isAnimating)  

[&ndash;&nbsp;lineWidth](#//api/name/lineWidth)  

### Other Methods

[&nbsp;&nbsp;hidesWhenStopped](#//api/name/hidesWhenStopped) *property* 

[&nbsp;&nbsp;timingFunction](#//api/name/timingFunction) *property* 

[&nbsp;&nbsp;duration](#//api/name/duration) *property* 

## Properties

<a name="//api/name/duration" title="duration"></a>
### duration

Property indicating the duration of the animation, default is 1.5s. Should be set prior to -[startAnimating]

`@property (nonatomic, readwrite) NSTimeInterval duration`

#### Discussion
Property indicating the duration of the animation, default is 1.5s. Should be set prior to -[startAnimating]

#### Declared In
* `TTVideoActivityIndicator.h`

<a name="//api/name/hidesWhenStopped" title="hidesWhenStopped"></a>
### hidesWhenStopped

Sets whether the view is hidden when not animating.

`@property (nonatomic) BOOL hidesWhenStopped`

#### Discussion
Sets whether the view is hidden when not animating.

#### Declared In
* `TTVideoActivityIndicator.h`

<a name="//api/name/timingFunction" title="timingFunction"></a>
### timingFunction

Specifies the timing function to use for the control&rsquo;s animation. Defaults to kCAMediaTimingFunctionEaseInEaseOut

`@property (nonatomic, strong) CAMediaTimingFunction *timingFunction`

#### Discussion
Specifies the timing function to use for the control&rsquo;s animation. Defaults to kCAMediaTimingFunctionEaseInEaseOut

#### Declared In
* `TTVideoActivityIndicator.h`

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/isAnimating" title="isAnimating"></a>
### isAnimating

Property indicating whether the view is currently animating.

`- (BOOL)isAnimating`

#### Discussion
Property indicating whether the view is currently animating.

#### Declared In
* `TTVideoActivityIndicator.h`

<a name="//api/name/lineWidth" title="lineWidth"></a>
### lineWidth

Sets the line width of the spinner&rsquo;s circle.

`- (CGFloat)lineWidth`

#### Discussion
Sets the line width of the spinner&rsquo;s circle.

#### Declared In
* `TTVideoActivityIndicator.h`

<a name="//api/name/setAnimating:" title="setAnimating:"></a>
### setAnimating:

<ul>
<li>Convenience function for starting &amp; stopping animation with a boolean variable instead of explicit</li>
<li>method calls.
*</li>
<li>@param animate true to start animating, false to stop animating.</li>
</ul>

`- (void)setAnimating:(BOOL)*animate*`

#### Discussion
<ul>
<li>Convenience function for starting &amp; stopping animation with a boolean variable instead of explicit</li>
<li>method calls.
*</li>
<li>@param animate true to start animating, false to stop animating.</li>
</ul>


<strong>Note:</strong> This method simply calls the <a href="#//api/name/startAnimating">startAnimating</a> or <a href="#//api/name/stopAnimating">stopAnimating</a> methods based on the value of the animate parameter.

#### Declared In
* `TTVideoActivityIndicator.h`

<a name="//api/name/startAnimating" title="startAnimating"></a>
### startAnimating

Starts animation of the spinner.

`- (void)startAnimating`

#### Discussion
Starts animation of the spinner.

#### Declared In
* `TTVideoActivityIndicator.h`

<a name="//api/name/stopAnimating" title="stopAnimating"></a>
### stopAnimating

Stops animation of the spinnner.

`- (void)stopAnimating`

#### Discussion
Stops animation of the spinnner.

#### Declared In
* `TTVideoActivityIndicator.h`

