//
//  UILazyImageView.m
//  Media Library
//
//  Created by Jonatan Yde on 31/01/13.
//  Copyright (c) 2013 Codeninja. All rights reserved.
//

#import "UILazyImageView.h"

@implementation UILazyImageView
@synthesize url, imageLoaded, spinner;


-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
 
    imageLoaded = NO;

    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    [[self spinner] setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
    [self addSubview:spinner];
    [spinner startAnimating];
 
    NSThread *t = [[NSThread alloc]initWithTarget:self selector:@selector(loadImage) object:nil];
    [t start];
}

-(void)loadImage
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self->url]]];
        [self->spinner stopAnimating];
        self->imageLoaded = YES;
    });
    
    
}

@end
