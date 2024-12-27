//
//  ButtonsAndMore.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/15/24.
//

import SwiftUI
import SpriteKit

struct RankingsButton: View {
    var action: ()->()
    
    var body: some View {
        Button {
            action()
        } label: {
            HM.ButtonLabel(imageName: "rankings_button")
        }
    }
}

struct SettingsButton: View {
    var action: ()->()
        
    var body: some View {
        Button {
            action()
        } label: {
            HM.ButtonLabel(imageName: "settings_button")
        }
    }
}

struct MusicButton: View {
    var frame: CGSize? = nil
    @Binding var shouldPlayMusic: Bool
    var action: ()->()
       
    var body: some View {
        Button {
            action()
        } label: {
            HM.ButtonLabel(imageName: "music_button", title: "Music", offIndicator: $shouldPlayMusic, frame: frame)
        }
    }
}

struct SoundButton: View {
    var frame: CGSize? = nil
    @Binding var shouldPlaySoundEffects: Bool
    var action: ()->()
        
    var body: some View {
        Button {
            action()
        } label: {
            HM.ButtonLabel(imageName: "sound_button", title: "Sound", offIndicator: $shouldPlaySoundEffects, frame: frame)
        }
    }
}

struct VibrateButton: View {
    var frame: CGSize? = nil
    @Binding var shouldVibrate: Bool
    var action: ()->()
        
    var body: some View {
        Button {
            action()
        } label: {
            HM.ButtonLabel(imageName: "vibrate_button", title: "Vibrate", offIndicator: $shouldVibrate, frame: frame)
        }
    }
}

struct ShareButton: View {
    var item: Image
    var frame: CGSize? = nil
    
    @AppStorage(AppStorageKey.sound) var shouldPlaySoundEffects: Bool = true
    
    var body: some View {
        ShareLink(item: item, preview: SharePreview("BootyDrop", image: item)) {
            HM.ButtonLabel(systemName: "square.and.arrow.up", title: "Share", fontSize: 14, frame: frame)
                .foregroundStyle(Color.black.opacity(0.8))
        }
        .onTapGesture {
            if shouldPlaySoundEffects {
                try? SoundManager.playeffect(SoundResourceName.soundEffectClick)
            }
        }
    }
}

struct RestartButton: View {
    var frame: CGSize? = nil
    var action: ()->()
    
    @State private var rotation: Double = 0
        
    init(frame: CGSize? = nil, action: @escaping ()->()) {
        self.frame = frame
        self.action = action
    }
    
    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                rotation = -360
            } completion: {
                action()
            }
        } label: {
            HM.ButtonLabel(
                image:
                    Image(systemName: "exclamationmark.arrow.circlepath")
                    .resizable()
                    .rotationEffect(
                        .degrees(rotation)),
                title: "Restart",
                fontSize: 14,
                frame: frame)
            .foregroundStyle(Color.black.opacity(0.8))
        }
        .buttonStyle(.borderedProminent)
    }
}

struct ExitGameButton: View {
    var frame: CGSize? = nil
    var action: ()->()
    
    @State private var rotation: Double = 0
        
    init(frame: CGSize? = nil, action: @escaping ()->()) {
        self.frame = frame
        self.action = action
    }

    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                rotation = -360
            } completion: {
                action()
            }
        } label: {
            HM.ButtonLabel(
                image:
                    Image(systemName: "arrow.uturn.backward")
                    .resizable()
                    .rotationEffect(
                        .degrees(rotation)),
                title: "Exit",
                fontSize: 14,
                frame: frame)
            .foregroundStyle(Color.black.opacity(0.8))
        }
        .buttonStyle(.borderedProminent)
    }
}

struct StartButton: View {
    var action: ()->()
        
    var body: some View {
        Button {
            action()
        } label: {
            HM.ButtonLabel(
                image:
                    Image("coin")
                    .resizable()
                    .scaledToFit(),
                title: "Start",
                fontSize: 30,
                frame: CGSize(width: 150, height: 80))
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
    func buttonOffIndicator(_ hide: Binding<Bool>?) -> some View {
        self.overlay(alignment: .bottomTrailing) {
                if hide != nil, let hide = hide, !hide.wrappedValue {
                    ButtonOffImage()
                }
            }
    }
}

struct HM {
    static func ButtonLabel(imageName: String, title: String? = nil, fontSize: Double = 16, offIndicator: Binding<Bool>? = nil, frame: CGSize? = nil) -> some View {
        VStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .buttonOffIndicator(offIndicator)
            if let title {
                Text(title)
                    .font(.custom(CustomFont.rum, size: fontSize, relativeTo: .subheadline))
                    .foregroundStyle(Color.orange.gradient)
                    .pirateShadow(y: 4)
            }
        }
        .frame(width: frame?.width ?? 40, height: frame?.height ?? 40)
    }
    
    static func ButtonLabel(systemName: String, title: String? = nil, fontSize: Double = 16, offIndicator: Binding<Bool>? = nil, frame: CGSize? = nil) -> some View {
        VStack {
            Image(systemName: systemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .buttonOffIndicator(offIndicator)
            if let title {
                Text(title)
                    .font(.custom(CustomFont.rum, size: fontSize, relativeTo: .subheadline))
                    .foregroundStyle(Color.orange.gradient)
                    .pirateShadow(y: 4)
            }
        }
        .frame(width: frame?.width ?? 40, height: frame?.height ?? 40)
    }
    
    static func ButtonLabel(image: (some View), title: String? = nil, fontSize: Double = 16, withIndicator: Binding<Bool>? = nil, frame: CGSize? = nil) -> some View {
        VStack {
            image
                .aspectRatio(contentMode: .fit)
                .buttonOffIndicator(withIndicator)
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

