//
//  ButtonsAndMore.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/15/24.
//

import SwiftUI


struct RankingsButton: View {
    @Binding var showRankings: Bool
    
    init(_ showRankings: Binding<Bool>) {
        _showRankings = showRankings
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                showRankings = true
            }
        }, label: {
            Image("crownButton")
                .resizable()
                .frame(width: 40, height: 40)
        })
    }
}

struct SettingsButton: View {
    @Binding var showSettings: Bool
    
    init(_ showSettings: Binding<Bool>) {
        _showSettings = showSettings
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                showSettings = true
            }
        }, label: {
            Image("settingsButton")
                .resizable()
                .frame(width: 40, height: 40)
        })
    }
}

struct MusicButton: View {
    var body: some View {
        Button {
            #warning("Toggle music on/off here")
            
        } label: {
            HM.ButtonLabel(imageName: "trophy", title: "Music")
        }
    }
}

struct SoundButton: View {
    var body: some View {
        Button(action: {
            #warning("Toggle sound effects on/off here")
            
        }, label: {
            HM.ButtonLabel(imageName: "trophy", title: "Sound")
        })
    }
}

struct VibrateButton: View {
    var body: some View {
        Button(action: {
            #warning("Toggle vibrate(haptics) on/off here")
            
        }, label: {
            HM.ButtonLabel(imageName: "trophy", title: "Vibrate")
        })
    }
}

struct ShareButton: View {
    var item: Image
    var body: some View {
        ShareLink(item: item, preview:  SharePreview("BootyDrop", image: item)) {
            HM.ButtonLabel(systemName: "square.and.arrow.up", title: "Share")
        }
    }
}

struct RestartButton: View {
    var action: ()->Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HM.ButtonLabel(imageName: "trophy", title: "Restart")
        }.buttonStyle(.borderedProminent)
    }
}

struct PirateText: View {
    var text: String
    var size: CGFloat
    var textStyle: Font.TextStyle
    
    init(_ text: String, size: CGFloat = 30, relativeTo textStyle: Font.TextStyle = .title) {
        self.text = text
        self.size = size
        self.textStyle = textStyle
    }
    
    var body: some View {
        Text(text)
            .font(.custom(CustomFont.rum, size: size, relativeTo: textStyle))
            .pirateShadow()
    }
}




struct HM {
    
    static func ButtonLabel(imageName: String, title: String, frame: CGSize? = nil) -> some View {
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
    
    static func ButtonLabel(systemName: String, title: String, frame: CGSize? = nil) -> some View {
        VStack {
            Image(systemName: systemName)
                .resizable()
                .frame(width: frame?.width ?? 20, height: frame?.height ?? 20)
            Text(title)
                .font(.custom(CustomFont.rum, size: 16, relativeTo: .subheadline))
                .foregroundStyle(Color.orange.gradient)
                .pirateShadow(y: 4)
        }
    }
    
    
}

