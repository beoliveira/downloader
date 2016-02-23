//
//  DetailViewController.h
//  downloader
//
//  Created by Thiago Peres on 23/02/16.
//  Copyright © 2016 peres. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

