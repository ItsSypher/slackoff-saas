# 💩 SlackOff - The World's Worst Team Communication SaaS

Welcome to **SlackOff**, the most frustrating, confusing, and hilariously terrible team communication software ever created! 

## 🎯 What Makes SlackOff Terrible

### Core "Features" 😈

- **Reverse Message Order**: All messages display in reverse chronological order for maximum confusion
- **Auto-Terrible Translation**: Every message gets "translated" through multiple languages and back, making it completely nonsensical
- **Moving Send Button**: The send button moves away when you try to hover over it
- **Random Font & Color Changes**: Text randomly changes fonts and colors every 3 seconds
- **Annoying Sound Effects**: Terrible beep sounds play with every message
- **Fake Error Messages**: Random error popups that don't actually mean anything
- **Emoji Chaos**: Random emoji reactions appear on every message, constantly spinning

### Anti-UX Design Patterns 🤡

- **Rainbow Background**: Seizure-inducing animated gradient background
- **Comic Sans Everything**: Default font is Comic Sans MS, switching to Papyrus and Wingdings randomly
- **Terrible Color Scheme**: Bright, clashing colors that hurt your eyes
- **Wiggling Animations**: Everything constantly wiggles and moves
- **Impossible Interactions**: Buttons that don't work properly, hover effects that break things
- **Fake Users**: Chat includes fake users like "Your Ex" and "Spider in Corner"

### "Premium" Frustration Features 💸

- Messages cost money to send (not actually implemented, but the UI suggests it)
- Backspace key "costs $0.05 per use"
- Premium "Express Translation" that makes messages even worse
- Channels with names like "#general-chaos" and "#terrible-ideas"

## 🚀 How to Run This Disaster

1. **Install Dependencies**:
   ```bash
   npm install
   ```

2. **Start the Development Server**:
   ```bash
   npm run dev
   ```

3. **Open in Browser**: Visit the URL shown in terminal (usually `http://localhost:5173`)

4. **Prepare for Frustration**: Try to have a normal conversation. You can't.

## 🛠️ Technologies Used

- **React 18** with TypeScript
- **Vite** for build tooling
- **CSS3** with terrible animations and gradients
- **Lucide React** for icons that spin unnecessarily
- **Web Audio API** for generating annoying beep sounds

## 🎨 Design Philosophy

SlackOff embodies every possible anti-pattern in UX design:

- **Chaos over Clarity**: If it's confusing, it's working
- **Friction over Flow**: Make every action as difficult as possible
- **Noise over Signal**: Add distractions and remove useful information
- **Broken over Beautiful**: If it looks broken, that's intentional

## ⚠️ Warning

**This software is intentionally terrible.** Do not use for actual team communication unless you want your team to quit immediately.

---

**Remember**: SlackOff is a parody and educational project demonstrating poor UX practices.

```js
export default tseslint.config({
  extends: [
    // Remove ...tseslint.configs.recommended and replace with this
    ...tseslint.configs.recommendedTypeChecked,
    // Alternatively, use this for stricter rules
    ...tseslint.configs.strictTypeChecked,
    // Optionally, add this for stylistic rules
    ...tseslint.configs.stylisticTypeChecked,
  ],
  languageOptions: {
    // other options...
    parserOptions: {
      project: ['./tsconfig.node.json', './tsconfig.app.json'],
      tsconfigRootDir: import.meta.dirname,
    },
  },
})
```

You can also install [eslint-plugin-react-x](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-x) and [eslint-plugin-react-dom](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-dom) for React-specific lint rules:

```js
// eslint.config.js
import reactX from 'eslint-plugin-react-x'
import reactDom from 'eslint-plugin-react-dom'

export default tseslint.config({
  plugins: {
    // Add the react-x and react-dom plugins
    'react-x': reactX,
    'react-dom': reactDom,
  },
  rules: {
    // other rules...
    // Enable its recommended typescript rules
    ...reactX.configs['recommended-typescript'].rules,
    ...reactDom.configs.recommended.rules,
  },
})
```
