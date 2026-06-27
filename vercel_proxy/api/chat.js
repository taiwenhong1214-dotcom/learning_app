// api/chat.js
export default async function handler(req, res) {
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method Not Allowed' });
    }

    const apiKey = process.env.OPENROUTER_API_KEY;

    if (!apiKey) {
        return res.status(500).json({ error: 'Missing OPENROUTER_API_KEY in Vercel environment' });
    }

    try {
        const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`,
                'HTTP-Referer': 'https://bm-learning-app.vercel.app'
            },
            body: JSON.stringify(req.body)
        });

        if (!response.ok) {
            const errorText = await response.text();
            return res.status(response.status).json({ error: 'Upstream AI provider error', details: errorText });
        }

        // Check if the client requested a stream
        if (req.body.stream) {
            res.setHeader('Content-Type', 'text/event-stream');
            res.setHeader('Cache-Control', 'no-cache');
            res.setHeader('Connection', 'keep-alive');
            if (res.flushHeaders) res.flushHeaders();

            if (response.body.getReader) {
                const reader = response.body.getReader();
                const decoder = new TextDecoder("utf-8");
                while (true) {
                    const { done, value } = await reader.read();
                    if (done) break;
                    res.write(decoder.decode(value));
                }
            } else {
                for await (const chunk of response.body) {
                    res.write(chunk);
                }
            }
            res.end();
        } else {
            // Non-streaming response
            const json = await response.json();
            return res.status(200).json(json);
        }
    } catch (error) {
        res.status(500).json({ error: 'Failed to communicate with AI provider', details: error.message });
    }
}
