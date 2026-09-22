//
//  TranslationDemoView.swift
//  MyApp
//
//  Created by cano on 2026/09/21.
//

import SwiftUI
import Translation // iOS 18+  デバイス内の軽量AIモデルを使ってテキストを翻訳するフレームワーク

// 外部の翻訳APIキー（API Key）などを取得することなく、ローカル処理で安全かつ即座にテキストを多言語翻訳します。
// AIそのものの機能とは言い難い

struct TranslationDemoView: View {
    @State private var textToTranslate = "Hello, Apple Intelligence!"
    @State private var showTranslation = false
    @State private var isTranslationAvailable = false

    var body: some View {
        VStack(spacing: 20) {
            Text(textToTranslate)

            if isTranslationAvailable {
                Button("日本語に翻訳") {
                    showTranslation = true
                }
                .translationPresentation(
                    isPresented: $showTranslation,
                    text: textToTranslate
                )
            } else {
                Text("この端末では翻訳を利用できません")
                    .foregroundStyle(.secondary)
            }
        }
        .task(id: textToTranslate) {
            await checkAvailability()
        }
    }

    private func checkAvailability() async {
        let availability = LanguageAvailability()
        do {
            let status = try await availability.status(
                for: textToTranslate,
                to: Locale.Language(identifier: "ja")
            )
            // .installed: すぐ翻訳可 / .supported: 言語パックのDLが必要(システムが案内する)
            isTranslationAvailable = (status != .unsupported)
        } catch {
            // 言語判定に失敗した場合など
            isTranslationAvailable = false
        }
    }
}

/*
struct TranslationDemoView: View {
    @State private var textToTranslate = "Hello, Apple Intelligence!"
    @State private var showTranslation = false

    var body: some View {
        VStack(spacing: 20) {
            Text(textToTranslate)
            
            Button("日本語に翻訳") {
                showTranslation.toggle()
            }
            // 標準のAI翻訳ポップアップを呼び出す modifier
            .translationPresentation(
                isPresented: $showTranslation,
                text: textToTranslate
            )
        }
    }
}
*/

#Preview {
    TranslationDemoView()
}
