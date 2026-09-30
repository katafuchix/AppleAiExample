//
//  ImageGenDemoView.swift
//  MyApp
//
//  Created by cano on 2026/09/21.
//

import SwiftUI
import ImagePlayground // iOS 18+
import UIKit

struct ImageGenDemoView: View {
    @Environment(\.supportsImagePlayground) private var supportsImagePlayground
    @State private var isShowingPlayground = false
    @State private var generatedImageURL: URL?

    var body: some View {
        VStack(spacing: 20) {
            if supportsImagePlayground {
                Button("AIで画像を生成する") {
                    isShowingPlayground = true
                }
                .imagePlaygroundSheet(
                    isPresented: $isShowingPlayground,
                    concept: "宇宙を飛ぶ猫"
                ) { url in
                    generatedImageURL = url
                }
                
                // 生成済みの画像があれば画面に表示
                if let url = generatedImageURL,
                   let uiImage = UIImage(contentsOfFile: url.path) {

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
            } else {
                Text("この端末ではImage Playgroundを利用できません")
            }
        }
    }
}

#Preview {
    ImageGenDemoView()
}
