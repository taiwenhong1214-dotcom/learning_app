Create a Flutter ai_screen.dart for a Bahasa Malaysia learning app.

Requirements:
- Two features in this screen, use a tab bar to switch between them:

Tab 1 - AI Conversation Practice:
- Show a chat interface (like WhatsApp)
- User types a message in Bahasa Malaysia
- App sends it and AI replies in BM, corrects grammar mistakes, and encourages the user
i use vercel to store the openrouter api key
- Model: 
qwen/qwen3-coder:free
nvidia/nemotron-3-ultra-550b-a55b:free
openai/gpt-oss-120b:free
(if one Ai not working automatically use another one),also set the streaming to true

- System prompt: "You are a Bahasa Malaysia tutor. The user is a beginner learning BM. Reply in simple Bahasa Malaysia, gently correct any grammar mistakes, and encourage them. Keep replies short."

Tab 2 - AI Quiz Generator:
- User selects difficulty: Easy, Medium, Hard
- A "Generate Quiz" button calls Claude API to generate 5 multiple choice questions about Bahasa Malaysia vocabulary
- Display the questions one by one with 4 options each
- Show correct/wrong feedback after each answer
- Show total score at the end
- API prompt to send: "Generate 5 Bahasa Malaysia vocabulary multiple choice questions at [difficulty] level. Each question shows an English word and 4 BM options. Return as JSON array with fields: question, options (array of 4), answer (index 0-3)."

Create a Flutter learn_screen.dart for a Bahasa Malaysia vocabulary learning app.

Requirements:
- Show a list of 5 categories: Greetings, Numbers, Colours, Food, Family
- Each category shows an icon, title, and progress (e.g. "0/10 learned")
- Tapping a category opens a detail page showing all 10 vocab cards for that category
- Each vocab card shows:
  - BM word (large, bold)
  - English meaning
  - Example sentence in BM
  - A speaker icon button that uses flutter_tts plugin to pronounce the BM word out loud
  - A bookmark/heart icon to mark as favourite
- Add a search bar at the top of the main list page
- Search filters vocab by BM word or English meaning across all categories
- Hardcode at least 10 vocab items per category using this data:

Greetings: Selamat pagi (Good morning), Selamat petang (Good afternoon), Selamat malam (Good night), Apa khabar (How are you), Baik (Fine), Terima kasih (Thank you), Sama-sama (You're welcome), Maaf (Sorry), Tolong (Please/Help), Selamat tinggal (Goodbye)

Numbers: Satu (One), Dua (Two), Tiga (Three), Empat (Four), Lima (Five), Enam (Six), Tujuh (Seven), Lapan (Eight), Sembilan (Nine), Sepuluh (Ten)

Colours: Merah (Red), Biru (Blue), Hijau (Green), Kuning (Yellow), Hitam (Black), Putih (White), Oren (Orange), Ungu (Purple), Perang (Brown), Kelabu (Grey)

Food: Nasi (Rice), Mee (Noodles), Ayam (Chicken), Ikan (Fish), Sayur (Vegetables), Roti (Bread), Telur (Egg), Susu (Milk), Air (Water), Buah (Fruit)

Family: Ibu (Mother), Bapa (Father), Adik (Younger sibling), Kakak (Older sister), Abang (Older brother), Datuk (Grandfather), Nenek (Grandmother), Anak (Child), Suami (Husband), Isteri (Wife)