//
//  PaperScroll.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/9/24.
//

import SwiftUI

public struct PaperScroll<Content>: View where Content: View {
    @Binding var show: Bool
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
    
    init(show: Binding<Bool>, height: CGFloat = 400, pullText: String? = nil, onDismiss: (()->())? = nil, content: @escaping ()->Content) {
        _show = show
        self.height = height
        self.pullText = pullText
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
        }
    }
    
    func openPaperScroll(delay: Double = 0.3) {
        DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
            withAnimation(.easeInOut) {
                scrollTopOffset = (-height/2)-18
                scrollBottomOffset = (height/2)+18
                scrollMiddleHeight = height
            }
            chevronOffset = 8
            chevronScale = 1.4
        }
    }
    
}


public struct StaticPaperScroll<Content>: View where Content: View {
    var height: CGFloat = 400
    var openOnAppear: Bool = true
    @ViewBuilder var content: ()->Content
    
    @State private var screenFrame: CGRect? = .zero
    @State private var scrollTopOffset: CGFloat = -36
    @State private var scrollBottomOffset: CGFloat = 36
    @State private var scrollMiddleHeight: CGFloat = 30
    @State private var scrollMiddleOffset: CGFloat = 0
    
    init(height: CGFloat = 400, openOnAppear: Bool = true, content: @escaping ()->Content) {
        self.openOnAppear = openOnAppear
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
//                DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
//                    withAnimation(.easeInOut) {
//                        show = false
//                    }
//                }
            }
        }
    }
    
    public func openPaperScroll(delay: Double = 0.3) {
        DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
            withAnimation(.easeInOut) {
                scrollTopOffset = (-height/2)-18
                scrollBottomOffset = (height/2)+18
                scrollMiddleHeight = height
            }
        }
    }
    
}


#Preview {
    @Previewable @State var showSettings: Bool = true
    @Previewable @StateObject var game: GameScene = {
        let scene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        return scene
    }()
    
    ZStack {
        Color.black.opacity(0.7)
            .ignoresSafeArea()
            .transition(.opacity)
        
        PaperScroll(show: $showSettings, pullText: "Pull to Close") {
            VStack {
                PirateText("Paper Scroll", size: 20).padding(.horizontal, 4)
                VStack(spacing: 10) {
                    MusicButton()
                    SoundButton()
                    VibrateButton()
                }.padding(.vertical, 16)
                
                RestartButton { }
            }
        }
        
//        StaticPaperScroll(show: $showSettings) {
//            VStack {
//                PirateText("Paper Scroll", size: 20).padding(.horizontal, 4)
//                VStack(spacing: 10) {
//                    MusicButton().environmentObject(game)
//                    SoundButton().environmentObject(game)
//                    VibrateButton()
//                }.padding(.vertical, 16)
//                
//                RestartButton { }
//            }
//        }
    }
}
