import XCTest
@testable import QuickTranslate

final class ChatCompletionTests: XCTestCase {
    func testRequestEncoding() throws {
        let request = ChatCompletionRequest(
            model: "google/gemma-4-26b-a4b",
            messages: [
                ChatMessage(role: "system", content: "You are a translator."),
                ChatMessage(role: "user", content: "Hello"),
            ],
            temperature: 0.1
        )
        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["model"] as? String, "google/gemma-4-26b-a4b")
        XCTAssertEqual(json["temperature"] as? Double, 0.1)

        let messages = json["messages"] as! [[String: String]]
        XCTAssertEqual(messages.count, 2)
        XCTAssertEqual(messages[0]["role"], "system")
        XCTAssertEqual(messages[1]["content"], "Hello")
    }

    func testResponseDecoding() throws {
        let json = """
        {
            "choices": [
                {
                    "message": {
                        "role": "assistant",
                        "content": "こんにちは"
                    }
                }
            ]
        }
        """
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)

        XCTAssertEqual(response.choices.count, 1)
        XCTAssertEqual(response.choices[0].message.content, "こんにちは")
        XCTAssertEqual(response.choices[0].message.role, "assistant")
    }
}
