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
            HM.ButtonLabel(imageName: "rankings_button")
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
            HM.ButtonLabel(imageName: "settings_button")
        })
    }
}

struct MusicButton: View {
    var frame: CGSize? = nil
    @AppStorage(AppStorageKey.music) var music: Bool = false
    
    var body: some View {
        Button {
            #warning("Toggle music on/off here")
            withAnimation { music.toggle() }
            
        } label: {
            HM.ButtonLabel(imageName: "music_button", title: "Music", isOff: $music, frame: frame)
        }
    }
}

struct SoundButton: View {
    var frame: CGSize? = nil
    @AppStorage(AppStorageKey.sound) var sound: Bool = false
    
    var body: some View {
        Button(action: {
            #warning("Toggle sound effects on/off here")
            withAnimation { sound.toggle() }
            
        }, label: {
            HM.ButtonLabel(imageName: "sound_button", title: "Sound", isOff: $sound, frame: frame)
        })
    }
}

struct VibrateButton: View {
    var frame: CGSize? = nil
    @AppStorage(AppStorageKey.vibrate) var vibrate: Bool = false
    
    var body: some View {
        Button(action: {
            #warning("Toggle vibrate(haptics) on/off here")
            withAnimation { vibrate.toggle() }
            
        }, label: {
            HM.ButtonLabel(imageName: "vibrate_button", title: "Vibrate", isOff: $vibrate, frame: frame)
        })
    }
}

struct ShareButton: View {
    var item: Image
    var frame: CGSize? = nil
    
    var body: some View {
        ShareLink(item: item, preview: SharePreview("BootyDrop", image: item)) {
            HM.ButtonLabel(systemName: "square.and.arrow.up", title: "Share", fontSize: 14, frame: frame)
                .foregroundStyle(Color.black.opacity(0.8))
        }
    }
}

struct RestartButton: View {
    var frame: CGSize? = nil
    var action: ()->Void
    
    @State private var rotation: Double = 0
    
    var body: some View {
        Button {
            withAnimation {
                rotation = -360
            } completion: {
                action()
            }
        } label: {
            HM.ButtonLabel(image:
                            Image(systemName: "exclamationmark.arrow.circlepath")
                                .resizable()
                                .rotationEffect(.degrees(rotation)
                            ),
                           title: "Restart",
                           fontSize: 14,
                           frame: frame)
            .foregroundStyle(Color.black.opacity(0.8))
        }
        .buttonStyle(.borderedProminent)
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
            .foregroundStyle(Color.black)
            .font(.custom(CustomFont.rum, size: size, relativeTo: textStyle))
            .pirateShadow()
    }
}


struct ButtonOffImage: View {
    var body: some View {
        Image(systemName: "xmark.circle.fill")
            .resizable()
            .foregroundStyle(Color.red)
            .background(Color.accentColor)
            .clipShape(Circle())
            .frame(width: 24, height: 24)
            .transition(.scale)
    }
}

extension View {
    func buttonOff(_ isOff: Bool) -> some View {
        self
            .overlay(alignment: .bottomTrailing) {
                if isOff {
                    ButtonOffImage()
                }
            }
    }
}


struct HM {
    
    static func ButtonLabel(imageName: String, title: String? = nil, fontSize: Double = 16, isOff: Binding<Bool> = .constant(false), frame: CGSize? = nil) -> some View {
        VStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .buttonOff(isOff.wrappedValue)
            if let title {
                Text(title)
                    .font(.custom(CustomFont.rum, size: fontSize, relativeTo: .subheadline))
                    .foregroundStyle(Color.orange.gradient)
                    .pirateShadow(y: 4)
            }
        }
        .frame(width: frame?.width ?? 40, height: frame?.height ?? 40)
    }
    
    static func ButtonLabel(systemName: String, title: String? = nil, fontSize: Double = 16, isOff: Binding<Bool> = .constant(false), frame: CGSize? = nil) -> some View {
        VStack {
            Image(systemName: systemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .buttonOff(isOff.wrappedValue)
            if let title {
                Text(title)
                    .font(.custom(CustomFont.rum, size: fontSize, relativeTo: .subheadline))
                    .foregroundStyle(Color.orange.gradient)
                    .pirateShadow(y: 4)
            }
        }
        .frame(width: frame?.width ?? 40, height: frame?.height ?? 40)
    }
    
    
    static func ButtonLabel(image: (some View), title: String? = nil, fontSize: Double = 16, isOff: Binding<Bool> = .constant(false), frame: CGSize? = nil) -> some View {
        VStack {
            image
                .aspectRatio(contentMode: .fit)
                .buttonOff(isOff.wrappedValue)
            if let title {
                Text(title)
                    .font(.custom(CustomFont.rum, size: fontSize, relativeTo: .subheadline))
                    .foregroundStyle(Color.orange.gradient)
                    .pirateShadow(y: 4)
            }
        }
        .frame(width: frame?.width ?? 40, height: frame?.height ?? 40)
    }
    
}

