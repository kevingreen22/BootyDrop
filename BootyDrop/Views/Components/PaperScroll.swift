//
//  PaperScroll.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/9/24.
//

import SwiftUI
import AVKit

public struct PaperScroll<Content>: View where Content: View {
    @Binding var show: Bool
    @Binding var shouldPlaySoundEffect: Bool
    var height: CGFloat = 400
    var pullText: String? = nil
    var onDismiss: (()->())?
    @ViewBuilder var content: ()->Content
    
    @State private var screenFrame: CGRect? = .zero
    @State var isStatic: Bool = false
    @State private var scrollTopOffset: CGFloat = -36
    @State private var scrollBottomOffset: CGFloat = 36
    @State private var scrollMiddleHeight: CGFloat = 30
    @State private var scrollMiddleOffset: CGFloat = 0
    @GestureState var dragAmount = CGSize.zero
    @State private var chevronOffset: CGFloat = 0
    @State private var isAnimatingChevron: Bool = false
    @State private var chevronScale: CGFloat = 1
    @State private var player: AVAudioPlayer!
    
        
    /// Plays a sound file contained in the main bundle.
    private func playeffect(_ forResource: String, withExtension: String? = ".mp3") throws {
        if shouldPlaySoundEffect {
            guard let url = Bundle.main.url(forResource: forResource, withExtension: withExtension) else { return }
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player.play()
            } catch {
                throw error
            }
        }
    }
    
    init(show: Binding<Bool>, shouldPlaySoundEffect: Binding<Bool>, height: CGFloat = 400, pullText: String? = nil,  onDismiss: (()->())? = nil, content: @escaping ()->Content) {
        _show = show
        self.height = height
        self.pullText = pullText
        _shouldPlaySoundEffect = shouldPlaySoundEffect
        self.onDismiss = onDismiss
        self.content = content
    }
    
        
    public var body: some View {
        ZStack {
            Image("scroll_middle")
                .resizable()
                .overlay(alignment: .top) {
                    content().padding([.top, .bottom], 16)
                } // Main Content
                .frame(width: 310, height: scrollMiddleHeight)
                .offset(y: scrollMiddleOffset)
                .clipped()
            
            Image("scroll_bottom")
                .resizable()
                .scaledToFit()
                .overlay(alignment: .bottom) {
                    if isStatic == false {
                        pullChevron(withText: pullText)
                    }
                } // pull chevron
                .offset(y: scrollBottomOffset)
                .offset(dragAmount)
                .gesture(dragToClose)
                .gesture(isStatic == true ? tapToClose.simultaneously(with: dragToClose) : nil)
            
            Image("scroll_top")
                .resizable()
                .scaledToFit()
                .offset(y: scrollTopOffset)
            
        } // end paper scroll
        .frame(width: (screenFrame?.width ?? UIScreen.main.bounds.width)*0.85)
        .onAppear {
            screenFrame = windowSceneFrame
            openPaperScroll()
        }
    }
    
    private var windowSceneFrame: CGRect? {
        return  (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    }
    
    private func pullChevron(withText: String? = nil) -> some View {
        VStack {
            Image(systemName: "chevron.down")
                .resizable()
                .frame(width: 36, height: 15)
                .scaleEffect(chevronScale)
                .opacity(scrollMiddleHeight == 30 ? 0 : 1)
                .offset(y: chevronOffset)
                .foregroundStyle(Color.gray)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: chevronOffset)
            
            if let withText {
                Text(withText)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.gray)
                    .offset(y: chevronOffset)
                    .opacity(scrollMiddleHeight == 30 ? 0 : 1)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: chevronOffset)
            }
        }
        .offset(y: 24)
    }
    
    private var dragToClose: some Gesture {
        return DragGesture()
            .onChanged { value in
                // only allow drag after the paper scroll is opened.
                if scrollMiddleHeight >= height {
                    // keep the draggable area within a range.
                    if value.location.y > value.startLocation.y && value.translation.height <= 70 {
                        // adjusts the middle scroll's height to stretch with the drag.
                        let distance = value.translation.height - dragAmount.height
                        scrollMiddleHeight += distance*2
                        scrollMiddleOffset += distance
                    }
                }
            }
            .updating($dragAmount) { value, state, transaction in
                // only allow drag after the paper scroll is opened.
                if scrollMiddleHeight >= height {
                    // keep the draggable area within a range.
                    if value.location.y > value.startLocation.y && value.translation.height <= 70 {
                        state.height = value.translation.height
                    }
                }
            }
            .onEnded { value in
                scrollMiddleHeight = height // resets the height
                scrollMiddleOffset = 0 // resets the offset
                dismissPaperScroll()
            }
    }
    
    private var tapToClose: some Gesture {
        TapGesture(count: 1)
            .onEnded { value in
                dismissPaperScroll()
            }
    }
    
    func dismissPaperScroll(delay: Double = 0.3) {
        DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
            withAnimation(.easeInOut) {
                scrollTopOffset = -36
                scrollBottomOffset = 36
                scrollMiddleHeight = 30
                DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
                    withAnimation(.easeInOut) {
                        show = false
                    }
                }
            } completion: {
                onDismiss?()
            }
            try? playeffect("scroll_sound_effect")
        }
    }
    
    func openPaperScroll(delay: Double = 0.3) {
        DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
            withAnimation(.easeInOut) {
                scrollTopOffset = (-height/2)-18
                scrollBottomOffset = (height/2)+18
                scrollMiddleHeight = height
            }
            try? playeffect("scroll_sound_effect")
            chevronOffset = 8
            chevronScale = 1.4
        }
    }
    
}


public struct StaticPaperScroll<Content>: View where Content: View {
    var height: CGFloat = 400
    var openOnAppear: Bool = true
    @Binding var shouldPlaySoundEffect: Bool
    @ViewBuilder var content: ()->Content
    
    @State private var screenFrame: CGRect? = .zero
    @State private var scrollTopOffset: CGFloat = -36
    @State private var scrollBottomOffset: CGFloat = 36
    @State private var scrollMiddleHeight: CGFloat = 30
    @State private var scrollMiddleOffset: CGFloat = 0
    @State private var player: AVAudioPlayer!
    
    /// Plays a sound file contained in the main bundle.
    private func playeffect(_ forResource: String, withExtension: String? = ".mp3") throws {
        if shouldPlaySoundEffect {
            guard let url = Bundle.main.url(forResource: forResource, withExtension: withExtension) else { return }
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player.play()
            } catch {
                throw error
            }
        }
    }
    
    init(height: CGFloat = 400, openOnAppear: Bool = true, shouldPlaySoundEffect: Binding<Bool>, content: @escaping ()->Content) {
        self.openOnAppear = openOnAppear
        _shouldPlaySoundEffect = shouldPlaySoundEffect
        self.height = height
        self.content = content
    }
    
        
    public var body: some View {
        ZStack {
            Image("scroll_middle")
                .resizable()
                .overlay(alignment: .top) {
                    content().padding([.top, .bottom], 16)
                } // Main Content
                .frame(width: 310, height: scrollMiddleHeight)
                .offset(y: scrollMiddleOffset)
                .clipped()
            
            Image("scroll_bottom")
                .resizable()
                .scaledToFit()
                .offset(y: scrollBottomOffset)
                
            Image("scroll_top")
                .resizable()
                .scaledToFit()
                .offset(y: scrollTopOffset)
            
        } // end paper scroll
        .frame(width: (screenFrame?.width ?? UIScreen.main.bounds.width)*0.85)
        .onAppear {
            screenFrame = windowSceneFrame
            if openOnAppear {
                openPaperScroll()
            }
        }
    }
    
    private var windowSceneFrame: CGRect? {
        return  (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds
    }
    
    public func dismissPaperScroll(delay: Double = 0.3) {
        DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
            withAnimation(.easeInOut) {
                scrollTopOffset = -36
                scrollBottomOffset = 36
                scrollMiddleHeight = 30
            }
            try? playeffect("scroll_sound_effect")
        }
    }
    
    public func openPaperScroll(delay: Double = 0.3) {
        DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
            withAnimation(.easeInOut) {
                scrollTopOffset = (-height/2)-18
                scrollBottomOffset = (height/2)+18
                scrollMiddleHeight = height
            }
            try? playeffect("scroll_sound_effect")
        }
    }
    
}



// MARK: Preview
#Preview {
    @Previewable @State var showSettings: Bool = true
    
    ZStack {
        Color.black.opacity(0.7)
            .ignoresSafeArea()
            .transition(.opacity)
        
        PaperScroll(show: $showSettings, shouldPlaySoundEffect: .constant(true), pullText: "Pull to Close") {
            VStack {
                PirateText("Paper Scroll", size: 20)
                    .padding(.horizontal, 4)
                
                Spacer()
                PirateText("Content goes here...", size: 16)
                    .padding(.horizontal, 4)
                Spacer()
                
            }.padding(.top)
        }
    }
}

