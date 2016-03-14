//
//  UILazyImageView.h
//  Media Library
//
//  Created by Jonatan Yde on 31/01/13.
//  Copyright (c) 2013 Codeninja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILazyImageView : UIImageView

@property (retain, nonatomic) NSString *url;
@property (nonatomic) BOOL imageLoaded;
@property (retain, nonatomic) UIActivityIndicatorView *spinner;


@end
