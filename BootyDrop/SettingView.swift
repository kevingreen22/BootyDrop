//
//  SettingView.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/4/24.
//

import SwiftUI

struct SettingView: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        Image("scroll3")
            .resizable()
            .flipHorizontal()
            .frame(width: 300, height: 400)
            .pirateShadow(y: 30)
            
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
            
            .overlay(alignment: .topTrailing) {
                closeButton.padding([.top, .trailing], 15)
            }
        
            .transition(.scale)
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
            withAnimation(.bouncy) {
                showSettings.toggle()
            }
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
    @State var showSettings: Bool = true
    
    return SettingView(showSettings: $showSettings)
}



extension Image {
    func flipHorizontal() -> some View {
        self.rotation3DEffect(.degrees(180), axis: (x: 1.0, y: 0.0, z: 0.0))
    }
    
    func flipVertically() -> some View {
        self.rotation3DEffect(.degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
    }
}

