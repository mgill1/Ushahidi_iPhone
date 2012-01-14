/*****************************************************************************
 ** Copyright (c) 2010 Ushahidi Inc
 ** All rights reserved
 ** Contact: team@ushahidi.com
 ** Website: http://www.ushahidi.com
 **
 ** GNU Lesser General Public License Usage
 ** This file may be used under the terms of the GNU Lesser
 ** General Public License version 3 as published by the Free Software
 ** Foundation and appearing in the file LICENSE.LGPL included in the
 ** packaging of this file. Please review the following information to
 ** ensure the GNU Lesser General Public License version 3 requirements
 ** will be met: http://www.gnu.org/licenses/lgpl.html.
 **
 **
 ** If you have questions regarding the use of this file, please contact
 ** Ushahidi developers at team@ushahidi.com.
 **
 *****************************************************************************/

#import "MapViewController.h"
#import "LoadingViewController.h"
#import "AlertView.h"
#import "InputView.h"
#import "MKMapView+Extension.h"
#import "NSString+Extension.h"
#import "Settings.h"
#import "MKPinAnnotationView+Extension.h"

typedef enum {
	MapTypeNormal,
	MapTypeSatellite,
	MapTypeHybrid
} MapType;

@interface MapViewController ()

- (void) showSearchBar:(BOOL)show animated:(BOOL)animated;

@end

@implementation MapViewController

@synthesize mapView, searchBar, mapType, locationName, locationDetails, locationLatitude, locationLongitude;

#pragma mark -
#pragma mark Internal

- (void) showSearchBar:(BOOL)show animated:(BOOL)animated {
	self.searchBar.tintColor = [[Settings sharedSettings] searchBarTintColor];
	if (animated) {
		[UIView beginAnimations:@"SearchBarVisibility" context:NULL];
		[UIView setAnimationDuration:0.3];
	}
	CGRect searchBarFrame = self.searchBar.frame;
	if (show) {
		if (self.searchBar.frame.origin.y < 0) {
			searchBarFrame.origin.y += self.searchBar.frame.size.height;
		}
		[self.searchBar becomeFirstResponder];
	}
	else {
		if (self.searchBar.frame.origin.y >= 0) {
			searchBarFrame.origin.y -= self.searchBar.frame.size.height;
		}
		[self.searchBar resignFirstResponder];
	}
	self.searchBar.frame = searchBarFrame;
	if (animated) {
		[UIView commitAnimations];
	}
}

#pragma mark -
#pragma mark Handlers

- (IBAction) search:(id)sender {
	DLog(@"");
	[self showSearchBar:YES animated:YES];
}

- (IBAction) findLocation:(id)sender {
	DLog(@"");
	if (self.mapView.showsUserLocation && self.mapView.userLocation != nil) {
		[self.mapView resizeRegionToFitAllPins:YES animated:YES];
	}
	else {
		[self.loadingView showWithMessage:NSLocalizedString(@"Locating...", nil)];
		self.mapView.showsUserLocation = YES;
	}
}

- (IBAction) mapTypeChanged:(id)sender {
	self.mapView.mapType = self.mapType.selectedSegmentIndex;
}

#pragma mark -
#pragma mark UIViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	self.toolBar.tintColor = [[Settings sharedSettings] toolBarTintColor];
	[self showSearchBar:NO animated:NO];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.locationName != nil) {
		self.title = self.locationName;
		if (self.locationDetails == nil) {
			self.locationDetails = [NSString stringWithFormat:@"%@, %@", self.locationLatitude, self.locationLongitude];
		}
	}
	else {
		self.title = NSLocalizedString(@"Map", nil);
		self.locationName = [NSString stringWithFormat:@"%@, %@", self.locationLatitude, self.locationLongitude];
	}
	[self.mapView removeAllPins];
	[self.mapView addPinWithTitle:self.locationName
	 					 subtitle:self.locationDetails 
						 latitude:self.locationLatitude 
						longitude:self.locationLongitude];
	[self.mapView resizeRegionToFitAllPins:NO animated:NO];
}

- (void)dealloc {
	[locationName release];
	[locationDetails release];
	[locationLatitude release];
	[locationLongitude release];
	[mapView release];
	[mapType release];
	[searchBar release];
	[super dealloc];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapViewWillStartLoadingMap:(MKMapView *)theMapView {
	DLog(@"");
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)theMapView {
	DLog(@"");
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)theMapView withError:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
}

- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	return [MKPinAnnotationView getPinForMap:theMapView andAnnotation:annotation];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	[self.loadingView hide];
	[self.mapView resizeRegionToFitAllPins:YES animated:YES];
}

@end
