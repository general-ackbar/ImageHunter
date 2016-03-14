//
//  PreviewController.m
//  Image Hunter
//
//  Created by Jonatan Yde on 09/02/13.
//  Copyright (c) 2013 Codeninja. All rights reserved.
//

#import "PreviewController.h"

@implementation PreviewController
@synthesize scrollViewPane, imageUrl, spinner;

-(void)viewDidLoad
{
    [super viewDidLoad];

    scrollViewPane.delegate = self;
    scrollViewPane.contentSize = CGSizeMake(1000, 1000);
    scrollViewPane.maximumZoomScale = 8.0f;
    scrollViewPane.minimumZoomScale = .5f;

    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [[self spinner] setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    [self.view addSubview:spinner];

    

    [spinner startAnimating];

    NSThread *t = [[NSThread alloc] initWithTarget:self selector:@selector(loadImageasynchronous) object:nil];
    [t start];
    
}

-(void)loadImageasynchronous
{

    

    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]]];
    UIImageView *imv = [[UIImageView alloc]initWithImage:img];
    imv.tag = 1;
    imv.userInteractionEnabled = YES;

    scrollViewPane.contentSize = img.size; // CGSizeMake( imagePreview.frame.size.width, imagePreview.frame.size.height);
    imv.frame = self.view.bounds; // CGRectMake(0,0, img.size.width, img.size.height);
    
   imv.contentMode = UIViewContentModeScaleAspectFit;
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [imv addGestureRecognizer:singleTap];

    dispatch_async(dispatch_get_main_queue(), ^{
        [scrollViewPane addSubview: imv];
        [spinner stopAnimating];
    });


    
    
}


-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView viewWithTag:1]; // self.imagePreview;
}


-(void)singleTap:(id *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
