//
//  FoundationModelsDemoView.swift
//  AppleAiExample
//
//  Created by cano on 2026/09/22.
//

import SwiftUI
import FoundationModels // ① テキスト生成AI（Foundation Models）のフレームワークを読み込む

struct FoundationModelsDemoView: View {
    // ② システム標準の言語モデル（SystemLanguageModel）を取得
    private let model = SystemLanguageModel.default

    @State private var prompt = "SwiftUIの魅力を一文で教えて" // ユーザーが入力する質問
    @State private var result = ""                         // AIからの回答を入れる変数
    @State private var isGenerating = false                // 生成中（ローディング）フラグ
    @State private var errorMessage: String?              // エラー発生時のメッセージ

    var body: some View {
        VStack(spacing: 20) {
            // ③ AIモデルの「利用可能状態（availability）」に応じて画面を切り替える
            switch model.availability {
            case .available:
                availableContent // AIが使えるなら入力フォームとボタンを表示
            case .unavailable(let reason):
                Text(message(for: reason)) // 使えないならその理由を表示
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }

    // AIが使える状態のときのUI画面
    private var availableContent: some View {
        VStack(spacing: 16) {
            TextField("プロンプト", text: $prompt)
                .textFieldStyle(.roundedBorder)

            // ボタンを押すと非同期処理（Task）でAIに質問を投げる
            Button(isGenerating ? "生成中..." : "AIに聞く") {
                Task { await generate() }
            }
            .disabled(isGenerating || prompt.isEmpty) // 生成中や入力空のときはボタンを無効化

            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red) // エラーがあれば赤文字で表示
            }
            Text(result) // AIからの回答を表示
        }
    }

    // ④ なぜAIが使えないのか、理由ごとにメッセージを出し分ける関数
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

    // ⑤ AIへプロンプトを送信して回答を受け取る関数（非同期処理）
    private func generate() async {
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false } // 関数の処理が終わったら必ず生成中フラグをfalseに戻す

        do {
            // ⑥ AIセッションを作成（instructionsでAIの役割や口調を指定）
            let session = LanguageModelSession(
                instructions: "あなたは簡潔に日本語で答えるアシスタントです。"
            )
            // ⑦ AIに質問を投げてレスポンスを待つ（await）
            let response = try await session.respond(to: prompt)
            result = response.content // 回答テキストを画面変数に代入
        } catch {
            // 安全対策（ガードレール違反や入力長オーバー等）で失敗した場合はエラーを表示
            errorMessage = error.localizedDescription
        }
    }
}


#### 2. `LanguageModelSession(instructions:)` でAIのキャラクターを決める
* **ポイント：**
  * AIとの対話を開始するセッションを作る際、`instructions`（システムプロンプト）を渡します[cite: 4]。
* **なぜ大事？：**
  * ここで `"あなたは簡潔に日本語で答えるアシスタントです。"` のように指示（ペルソナや制約）を与えることで、AIの回答のトーンや文字数をコントロールできます[cite: 4]。

#### 3. `session.respond(to:)` メソッド（最重要メソッド）
* **ポイント：**
  * `imagePlaygroundSheet` と並ぶ、**Foundation Modelsにおける最大の核心メソッド**です[cite: 2, 4]。
* **なぜ大事？：**
