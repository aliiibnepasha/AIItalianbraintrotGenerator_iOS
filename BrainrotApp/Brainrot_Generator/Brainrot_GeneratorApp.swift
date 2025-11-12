//
//  Brainrot_GeneratorApp.swift
//  Brainrot_Generator
//
//  Created by MacBook 2017 on 07/11/2025.
//

import SwiftUI
import Firebase

private enum AppFlowStep {
    case splash
    case intro1
    case intro2
    case intro3
    case main
}

@main
struct Brainrot_GeneratorApp: App {
    @State private var step: AppFlowStep = .splash
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch step {
                case .splash:
                    SplashView(onFinished: { step = .intro1 })
                case .intro1:
                    Intro1View(onNext: { step = .intro2 })
                case .intro2:
                    Intro2View(onNext: { step = .intro3 })
                case .intro3:
                    Intro3View(onGetStarted: { step = .main })
                case .main:
                    HomeView()
                }
            }
        }
    }
}
