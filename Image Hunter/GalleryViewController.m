//
//  GalleryViewController.m
//  Image Hunter
//
//  Created by Jonatan Yde on 07/02/13.
//  Copyright (c) 2013 Codeninja. All rights reserved.
//

#import "GalleryViewController.h"
#import "ImageInfo.h"
#import "PreviewController.h"
#import "UILazyImageView.h"
#import "GoogleSearcher.h"
#import <AssetsLibrary/AssetsLibrary.h>



@implementation GalleryViewController
@synthesize requestData, spinner, query;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    currentIndex = 0;
    
    UIBarButtonItem *editButton = self.editButtonItem;
    editButton.title = NSLocalizedString(@"Select", @"Select");
    selectionActive = NO;
    [editButton setTarget:self];
    [editButton setAction:@selector(switchSelectionMode:)];
    
    self.navigationItem.rightBarButtonItem = editButton;
    
    
    
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setFooterReferenceSize:CGSizeMake(self.view.frame.size.width , 44)];
    
    
    saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(beginDownload:)];
    
    busy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    busy.hidesWhenStopped = YES;
//    [busy startAnimating];
//    [self.navigationItem.rightBarButtonItem initWithCustomView:busy];
    
    busyIndicator =[[UIBarButtonItem alloc] initWithCustomView: busy];
    
    
    selectedCells = [[NSMutableArray alloc] init];
}


-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionReusableView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"load" forIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionView Datasource
// 1

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return [self.requestData count];
}

// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"MediaCell";


    
    ImageInfo *mediaItem = [self.requestData objectAtIndex: indexPath.row ];
    
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc] init];
    }
    

    cell.backgroundColor = [UIColor blackColor];

    
    UILazyImageView *lv = [[UILazyImageView alloc] init]; //WithImage:[UIImage imageNamed:@"empty-frame.png"]];
    lv.contentMode = UIViewContentModeScaleToFill;
    lv.frame = cell.bounds;
    lv.url = mediaItem.ThumbURL;
    
    [cell addSubview:lv];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectionActive)
    {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        if([selectedCells containsObject:indexPath])
        {
            cell.alpha = 1;
            [selectedCells removeObject:indexPath];
        }
        else
        {
            cell.alpha = 0.5;
            [selectedCells addObject:indexPath];
        }
        
    }
    else
        [self performSegueWithIdentifier:@"segueToPreview" sender:[requestData objectAtIndex: indexPath.row]];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PreviewController *dest = [segue destinationViewController];
    ImageInfo *info = (ImageInfo *)sender;
    dest.imageUrl = info.ImageURL;
}


// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/
- (IBAction)switchSelectionMode:(id)sender {
//    UIBarButtonItem *button = (UIBarButtonItem *)sender;

    if(selectionActive)
    {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Select", @"Select");
        self.navigationItem.rightBarButtonItem.style = UIBarButtonSystemItemEdit;
        selectionActive = NO;
        
        for (NSIndexPath *cellIndex in selectedCells) {
            [self.collectionView cellForItemAtIndexPath:cellIndex].alpha = 1;
        }
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.navigationItem.rightBarButtonItem, nil];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Done", @"Done");
        self.navigationItem.rightBarButtonItem.style = UIBarButtonSystemItemDone;
        
        
        selectionActive = YES;
        for (NSIndexPath *cellIndex in selectedCells) {
            [self.collectionView cellForItemAtIndexPath:cellIndex].alpha = 0.5;
        }
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: self.navigationItem.rightBarButtonItem, saveButton, busyIndicator, nil];
    }
}

- (IBAction)beginDownload:(id)sender
{
    __block NSInteger downloadCount = 0;
    __block NSInteger totalCount = 0;
    

    //Start spinner
    dispatch_async(dispatch_get_main_queue(), ^{
        [busy startAnimating];
    });

    //Iterate through the selected files
    for (NSIndexPath *index in selectedCells) {
        
        //Get URL
        NSURL *url = [NSURL URLWithString: ((ImageInfo *)[requestData objectAtIndex:index.row]).ImageURL];
        
        //Start asynchronous download of image
        [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, UIImage *image) {
            
            //save image once downloaded
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^
             {
                 PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                 changeRequest.creationDate = [NSDate date];
             }
             
                                              completionHandler:^(BOOL success, NSError * _Nullable error) {
                                                  //Keep track of files processed
                                                  totalCount++;
                                                  if (!success) {
                                                      //An error occurred
                                                      NSLog(@"Failed to save image. %@", index);
                                                  }
                                                  else
                                                  {
                                                      //The files was saved succesfully
                                                      downloadCount++;
                                                  }
            
                                                  //All done, so inform user
                                                  if(totalCount == selectedCells.count)
                                                  {
                                                      //Clear the selected images
                                                      [selectedCells removeAllObjects];
                
                                                      //Show alert box when all done. Inform user how many images were actually saved
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                    
                                                          UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Done" message:[NSString stringWithFormat:@"Succeded to download %ld images.", (long)downloadCount] preferredStyle:UIAlertControllerStyleAlert];
                                                          UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                                                          [alert addAction:defaultAction];

                                                          //Once th euser press OK stop spinner
                                                          [self presentViewController:alert animated:YES completion:^{
                                                              [busy stopAnimating];
                                                          }];
                                                      });
                                                  }
                                              }
             ];
            //Clear alpha marking
            [self.collectionView cellForItemAtIndexPath:index].alpha = 1;
        }];
    }

}


- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}


- (void)downloadImagesAsynchronous
{
    [spinner stopAnimating];
}

- (IBAction)buttonLoadMore:(id)sender {
    
    currentIndex += 20;
    
    [requestData addObjectsFromArray:[GoogleSearcher PerformSearchUsingQuery:query fromIndex:currentIndex]];
    
    [self.collectionView reloadData];
    
    //CGPoint bottomOffset = CGPointMake(0, self.collectionView.contentSize.height - self.collectionView.bounds.size.height);
    //NSLog(@"%d x %d", bottomOffset.x, bottomOffset.y);
    //[self.collectionView setContentOffset:bottomOffset animated:YES];

}


@end
