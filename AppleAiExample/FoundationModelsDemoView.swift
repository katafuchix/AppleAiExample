//
//  FoundationModelsDemoView.swift
//  AppleAiExample
//
//  Created by cano on 2026/09/22.
//

import SwiftUI
import FoundationModels // iOS 26+ / Xcode 26+

struct FoundationModelsDemoView: View {
    private let model = SystemLanguageModel.default

    @State private var prompt = "SwiftUIの魅力を一文で教えて"
    @State private var result = ""
    @State private var isGenerating = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            switch model.availability {
            case .available:
                availableContent
            case .unavailable(let reason):
                Text(message(for: reason))
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }

    // 利用可能なときのUI
    private var availableContent: some View {
        VStack(spacing: 16) {
            TextField("プロンプト", text: $prompt)
                .textFieldStyle(.roundedBorder)

            Button(isGenerating ? "生成中..." : "AIに聞く") {
                Task { await generate() }
            }
            .disabled(isGenerating || prompt.isEmpty)

            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }
            Text(result)
        }
    }

    // 未対応の理由ごとにメッセージを出し分ける
    private func message(for reason: SystemLanguageModel.Availability.UnavailableReason) -> String {
        switch reason {
        case .deviceNotEligible:
            return "この端末はApple Intelligenceに対応していません"
        case .appleIntelligenceNotEnabled:
            return "設定でApple Intelligenceをオンにしてください"
        case .modelNotReady:
            return "モデルを準備中です。しばらくしてからお試しください"
        @unknown default:
            return "現在この機能は利用できません"
        }
    }

    private func generate() async {
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            let session = LanguageModelSession(
                instructions: "あなたは簡潔に日本語で答えるアシスタントです。"
            )
            let response = try await session.respond(to: prompt)
            result = response.content
        } catch {
            // ガードレール違反、コンテキスト長超過などもここに来る
            errorMessage = error.localizedDescription
        }
    }
}
