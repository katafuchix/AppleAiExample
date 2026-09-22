//
//  IntegratedAIDemoView.swift
//  AppleAiExample
//
//  Created by cano on 2026/09/22.
//

import SwiftUI
import FoundationModels // iOS 26+
import ImagePlayground   // iOS 18.2+

struct IntegratedAIDemoView: View {
    private let model = SystemLanguageModel.default

    @State private var topic = "宇宙飛行士"
    @State private var generatedConcept = ""
    @State private var isGeneratingConcept = false
    @State private var conceptError: String?

    @State private var isShowingPlayground = false
    @State private var generatedImageURL: URL?

    var body: some View {
        VStack(spacing: 20) {

            // --- Step 1: Foundation Models でコンセプト文を作る ---
            switch model.availability {
            case .available:
                conceptSection
            case .unavailable(let reason):
                Text(unavailableMessage(reason))
                    .foregroundStyle(.secondary)
            }

            Divider()

            // --- Step 2: そのコンセプトを Image Playground に渡す ---
            imageSection
        }
        .padding()
    }

    // MARK: - Step 1

    private var conceptSection: some View {
        VStack(spacing: 12) {
            TextField("お題", text: $topic)
                .textFieldStyle(.roundedBorder)

            Button(isGeneratingConcept ? "生成中..." : "AIにコンセプト文を作ってもらう") {
                Task { await generateConcept() }
            }
            .disabled(isGeneratingConcept || topic.isEmpty)

            if let conceptError {
                Text(conceptError).foregroundStyle(.red)
            }
            if !generatedConcept.isEmpty {
                Text(generatedConcept)
                    .padding(8)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private func generateConcept() async {
        isGeneratingConcept = true
        conceptError = nil
        defer { isGeneratingConcept = false }

        do {
            let session = LanguageModelSession(
                instructions: """
                あなたは画像生成用のコンセプト文を作るアシスタントです。
                ユーザーが与えたお題から、Image Playground に渡すための
                短く具体的な一文(20文字程度、日本語)を1つだけ返してください。
                説明や前置きは不要です。
                """
            )
            let response = try await session.respond(to: topic)
            generatedConcept = response.content
        } catch {
            conceptError = error.localizedDescription
        }
    }

    // MARK: - Step 2

    @Environment(\.supportsImagePlayground) private var supportsImagePlayground

    private var imageSection: some View {
        VStack(spacing: 12) {
            if supportsImagePlayground {
                Button("このコンセプトで画像を生成する") {
                    isShowingPlayground = true
                }
                .disabled(generatedConcept.isEmpty)
                .imagePlaygroundSheet(
                    isPresented: $isShowingPlayground,
                    concept: generatedConcept.isEmpty ? topic : generatedConcept
                ) { url in
                    generatedImageURL = url
                }

                if let generatedImageURL {
                    AsyncImage(url: generatedImageURL) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 200)
                }
            } else {
                Text("この端末ではImage Playgroundを利用できません")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func unavailableMessage(_ reason: SystemLanguageModel.Availability.UnavailableReason) -> String {
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
}
