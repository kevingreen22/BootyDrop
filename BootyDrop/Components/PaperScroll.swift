//
//  PaperScroll.swift
//  BootyDrop
//
//  Created by Kevin Green on 8/9/24.
//

import SwiftUI

struct PaperScroll<Content: View>: View {
    @Binding var show: Bool
    var height: CGFloat = 400
    @ViewBuilder var content: Content
    
    @State private var scrollTopOffset: CGFloat = -36
    @State private var scrollBottomOffset: CGFloat = 36
    @State private var scrollMiddleHeight: CGFloat = 30
    @State private var scrollMiddleOffset: CGFloat = 0
    @GestureState var dragAmount = CGSize.zero
    
    var body: some View {
        ZStack {
            Image("scroll_middle")
                .resizable()
                .overlay(alignment: .top) {
                    content.padding(.top, 24)
                } // Main Content
                .frame(width: 310, height: scrollMiddleHeight)
                .offset(y: scrollMiddleOffset)
                .clipped()
            
            Image("scroll_bottom")
                .resizable()
                .scaledToFit()
                .offset(y: scrollBottomOffset)
                .offset(dragAmount)
                .gesture(dragToClose)
                .gesture(tapToClose.simultaneously(with: dragToClose))
            
            Image("scroll_top")
                .resizable()
                .scaledToFit()
                .offset(y: scrollTopOffset)
            
        } // end paper scroll
        .frame(width: UIScreen.main.bounds.width*0.85)
        .onAppear {
            openPaperScroll()
        }
    }
    
    var dragToClose: some Gesture {
        return DragGesture()
            .onChanged { value in
                // only allow drag after the paper scroll is opened.
                if value.location.y > value.startLocation.y && value.translation.height <= 70 {
                    // adjusts the middle scroll's height to stretch with the drag.
                    let distance = value.translation.height - dragAmount.height
                    scrollMiddleHeight += distance*2
                    scrollMiddleOffset += distance
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
    
    var tapToClose: some Gesture {
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
        }
    }
    
}


#Preview {
    @State var showSettings: Bool = true
    
    return PaperScroll(show: $showSettings) {
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
            })
            .buttonStyle(.borderedProminent)
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
    
}

