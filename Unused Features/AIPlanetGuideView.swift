// AIPlanetGuideView.swift
// Feature 8: AI-powered planet guide placeholder implementation

import SwiftUI

/// This view demonstrates where an on‑device LLM would be invoked to answer user questions.
/// In a real implementation you would integrate a CoreML model (e.g., a quantized transformer) and
/// feed the selected planet's data to generate responses.
struct AIPlanetGuideView: View {
    @State private var question: String = ""
    @State private var answer: String = ""
    @State private var isLoading = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Ask the AI about any planet")
                .font(.headline)
                .padding(.bottom, 2)
            TextField("Enter your question…", text: $question)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(isLoading)
            Button(isLoading ? "Thinking…" : "Get Answer") {
                fetchAnswer()
            }
            .disabled(question.isEmpty || isLoading)
            .padding(.vertical, 4)
            if !answer.isEmpty {
                Divider()
                Text(answer)
                    .padding(.top, 4)
            }
            Spacer()
        }
        .padding()
    }

    private func fetchAnswer() {
        // Placeholder: simulate latency and return a canned response.
        isLoading = true
        answer = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            answer = "The planet \(question) is fascinating because… [AI response would appear here]."
            isLoading = false
        }
    }
}

struct AIPlanetGuideView_Previews: PreviewProvider {
    static var previews: some View {
        AIPlanetGuideView()
    }
}
