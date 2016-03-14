//
//  GalleryViewController.h
//  Image Hunter
//
//  Created by Jonatan Yde on 07/02/13.
//  Copyright (c) 2013 Codeninja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface GalleryViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    BOOL selectionActive;
    NSMutableArray *selectedCells;
    UIBarButtonItem *saveButton;
    UIBarButtonItem *busyIndicator;
    int currentIndex;
    UIActivityIndicatorView *busy;
}
@property (retain, nonatomic) NSMutableArray *requestData;
@property (retain, nonatomic) NSString *query;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)buttonLoadMore:(id)sender;

@end
