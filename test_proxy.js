const fs = require('fs');

async function test() {
    const response = await fetch("https://bm-learning-app.vercel.app/api/chat", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            models: [
                'qwen/qwen3-coder:free',
                'nvidia/nemotron-3-ultra-550b-a55b:free',
                'openai/gpt-oss-120b:free',
            ],
            messages: [
                { role: "system", content: "You are a BM tutor. Keep it short." },
                { role: "user", content: "teach me bm" }
            ],
            temperature: 0.7,
            stream: true
        })
    });

    const reader = response.body.getReader();
    const decoder = new TextDecoder("utf-8");
    let full = "";
    while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        const chunk = decoder.decode(value);
        console.log("CHUNK:", chunk);
        full += chunk;
    }
    console.log("FULL:", full);
}

test();
