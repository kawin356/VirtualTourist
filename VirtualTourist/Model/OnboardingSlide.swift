//
//  OnboardingSlide.swift
//  VirtualTourist
//
//  Created by Kittikawin Sontinarakul on 18/4/2563 BE.
//  Copyright © 2563 Kittikawin Sontinarakul. All rights reserved.
//

import Foundation

struct OnboardingSlide {
    let imageName: String
    let title: String
    let description : String
    
    static let collection: [OnboardingSlide] = [
        OnboardingSlide(imageName: "imSlide1", title: "Welcome To Virsual Tourist", description: "Make you to travel around the world. \nSee the world you never seen before"),
        OnboardingSlide(imageName: "imSlide2", title: "Virsual Tourist", description: "This app allows users specify travel locations around the world, and create virtual photo albums for each location"),
        OnboardingSlide(imageName: "imSlide3", title: "The app have two view", description: "Travel Locations Map View \nand Photo Album View")
    ]
}
