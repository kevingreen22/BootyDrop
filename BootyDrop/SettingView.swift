//
//  SettingView.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/4/24.
//

import SwiftUI

struct SettingView: View {
    
    var body: some View {
        Image("scroll3")
            .resizable()
            .frame(width: 300, height: 400)
            .pirateShadow(y: 10)
            
            .overlay(alignment: .top) {
                VStack {
                    Text("Settings")
                        .font(.custom(CustomFont.rum, size: 30, relativeTo: .largeTitle))
                        .pirateShadow()
                    
                    VStack(spacing: 18) {
                        Button(action: {
                            
                        }, label: {
                            ButtonLabel(imageName: "trophy", title: "Music")
                        })
                        
                        Button(action: {}, label: {
                            ButtonLabel(imageName: "trophy", title: "Sound")
                        })
                        
                        Button(action: {}, label: {
                            ButtonLabel(imageName: "trophy", title: "Vibrate")
                        })
                    }.padding(.bottom, 20)
                    
                    Button(action: {}, label: {
                        ButtonLabel(imageName: "trophy", title: "Restart")
                    }).buttonStyle(.borderedProminent)
                    
                }.padding(.top, 24)
            }
        
            .transition(.asymmetric(insertion: .scale, removal: .move(edge: .leading)))
        
            .overlay(alignment: .topTrailing) {
                closeButton.padding([.top, .trailing], 15)
            }
    }
    
    
    
    func ButtonLabel(imageName: String, title: String, frame: CGSize? = nil) -> some View {
        VStack {
            Image(imageName)
                .resizable()
                .frame(width: frame?.width ?? 20, height: frame?.height ?? 20)
            Text(title)
                .font(.custom(CustomFont.rum, size: 16, relativeTo: .subheadline))
                .foregroundStyle(Color.orange.gradient)
                .pirateShadow(y: 4)
            
        }
    }
    
    var closeButton: some View {
        Button(action: {
            // close settings view here
        }, label: {
            Image("close_button")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundStyle(Color.black)
                .clipShape(Circle())
        }).pirateShadow(y: 4)
    }
    
}

#Preview {
    SettingView()
}
