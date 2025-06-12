import { useState, useEffect } from 'react'
import { Send, Users, Settings, Phone, Video } from 'lucide-react'
import './App.css'

interface Message {
  id: string
  username: string
  text: string
  timestamp: Date
  isTranslated?: boolean
  originalText?: string
}

const ANNOYING_SOUNDS = [
  '🎺 BRAAAAP! 🎺',
  '🔔 DING DONG DING! 🔔',
  '📢 ATTENTION EVERYONE! 📢',
  '🚨 ALERT! ALERT! 🚨',
  '🎵 NEVER GONNA GIVE YOU UP! 🎵'
]

const RANDOM_EMOJI_REACTIONS = ['💩', '🤡', '🙈', '😵‍💫', '🤮', '💀', '👻', '🤷‍♂️']

function App() {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      username: 'SystemAdmin',
      text: 'Welcome to SlackOff! Prepare for maximum frustration! 😈',
      timestamp: new Date(Date.now() - 60000)
    }
  ])
  const [currentMessage, setCurrentMessage] = useState('')
  const [username] = useState('User' + Math.floor(Math.random() * 1000))
  const [buttonPosition, setButtonPosition] = useState({ x: 0, y: 0 })
  const [showFakeError, setShowFakeError] = useState(false)
  const [currentFont, setCurrentFont] = useState('Arial')
  const [messageColor, setMessageColor] = useState('#000000')

  // Terrible auto-translation function
  const terribleTranslate = async (text: string): Promise<string> => {
    let translatedText = text
    // Simulate going through multiple translations
    for (let i = 0; i < 3; i++) {
      // Fake translation that just makes text worse
      translatedText = translatedText
        .replace(/the/gi, 'ze')
        .replace(/you/gi, 'u')
        .replace(/are/gi, 'r')
        .replace(/to/gi, '2')
        .replace(/for/gi, '4')
        .replace(/and/gi, '&')
        .replace(/ing/gi, 'in')
        .replace(/er/gi, 'r')
        + ' [BADLY TRANSLATED]'
    }
    return translatedText
  }

  // Move send button when user tries to hover
  const handleButtonHover = () => {
    const newX = Math.random() * 300 - 150
    const newY = Math.random() * 100 - 50
    setButtonPosition({ x: newX, y: newY })
  }

  // Random font and color changes
  useEffect(() => {
    const interval = setInterval(() => {
      const fonts = ['Comic Sans MS', 'Papyrus', 'Impact', 'Wingdings', 'Times New Roman']
      const colors = ['#ff00ff', '#00ff00', '#ff0000', '#0000ff', '#ffff00', '#ff8000']
      setCurrentFont(fonts[Math.floor(Math.random() * fonts.length)])
      setMessageColor(colors[Math.floor(Math.random() * colors.length)])
    }, 3000)
    return () => clearInterval(interval)
  }, [])

  // Annoying notification sound effect
  const playAnnoyingSound = () => {
    // Create a terrible beep sound
    const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)()
    const oscillator = audioContext.createOscillator()
    const gainNode = audioContext.createGain()
    
    oscillator.connect(gainNode)
    gainNode.connect(audioContext.destination)
    
    oscillator.frequency.value = 1000 + Math.random() * 1000
    oscillator.type = 'square'
    gainNode.gain.value = 0.3
    
    oscillator.start()
    oscillator.stop(audioContext.currentTime + 0.5)
  }

  const sendMessage = async () => {
    if (!currentMessage.trim()) {
      setShowFakeError(true)
      setTimeout(() => setShowFakeError(false), 3000)
      return
    }

    // Play annoying sound
    playAnnoyingSound()

    // Translate the message terribly
    const translatedText = await terribleTranslate(currentMessage)
    
    const newMessage: Message = {
      id: Date.now().toString(),
      username: username,
      text: translatedText,
      timestamp: new Date(),
      isTranslated: true,
      originalText: currentMessage
    }

    // Add message to the BEGINNING of array (reverse chronological order)
    setMessages(prev => [newMessage, ...prev])
    setCurrentMessage('')

    // Random chance to add system messages
    if (Math.random() > 0.7) {
      setTimeout(() => {
        const systemMessage: Message = {
          id: Date.now().toString() + '_system',
          username: 'SlackOff Bot',
          text: ANNOYING_SOUNDS[Math.floor(Math.random() * ANNOYING_SOUNDS.length)],
          timestamp: new Date()
        }
        setMessages(prev => [systemMessage, ...prev])
        playAnnoyingSound()
      }, 1000)
    }
  }

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      sendMessage()
    }
  }

  return (
    <div className="slackoff-container">
      {/* Fake error popup */}
      {showFakeError && (
        <div className="fake-error">
          <h3>💥 CRITICAL ERROR 💥</h3>
          <p>Your message contains too much productivity. Please add more confusion.</p>
          <button onClick={() => setShowFakeError(false)}>Make it Worse</button>
        </div>
      )}

      {/* Header */}
      <header className="slackoff-header">
        <div className="header-left">
          <h1 className="logo">💩 SlackOff</h1>
          <span className="tagline">Where productivity goes to die!</span>
        </div>
        <div className="header-right">
          <Phone className="header-icon" />
          <Video className="header-icon" />
          <Users className="header-icon" />
          <Settings className="header-icon spinning" />
        </div>
      </header>

      {/* Main content */}
      <div className="main-content">
        {/* Sidebar */}
        <aside className="sidebar">
          <div className="channels">
            <h3>📢 Channels</h3>
            <div className="channel-list">
              <div className="channel active">🔥 #general-chaos</div>
              <div className="channel">💥 #random-explosions</div>
              <div className="channel">🤡 #terrible-ideas</div>
              <div className="channel">😵‍💫 #confusion-central</div>
              <div className="channel">🚨 #emergency-nonsense</div>
            </div>
          </div>
          
          <div className="users">
            <h3>👥 Online (Everyone Always)</h3>
            <div className="user-list">
              <div className="user">🤖 SlackOff Bot</div>
              <div className="user">👻 Your Ex</div>
              <div className="user">🕷️ Spider in Corner</div>
              <div className="user">🔥 The Fire Marshal</div>
              <div className="user">🎭 Anonymous User #47</div>
            </div>
          </div>
        </aside>

        {/* Chat area */}
        <main className="chat-area">
          <div className="channel-header">
            <h2>#general-chaos</h2>
            <p>📊 Messages displayed in random order for maximum confusion</p>
          </div>

          {/* Messages (in reverse chronological order) */}
          <div className="messages-container">
            {messages.map((message) => (
              <div 
                key={message.id} 
                className="message"
                style={{ 
                  fontFamily: currentFont,
                  color: messageColor,
                  animation: `wiggle ${1 + Math.random()}s infinite`
                }}
              >
                <div className="message-header">
                  <span className="username">{message.username}</span>
                  <span className="timestamp">
                    {message.timestamp.toLocaleTimeString()} (probably wrong)
                  </span>
                  <span className="emoji-reaction">
                    {RANDOM_EMOJI_REACTIONS[Math.floor(Math.random() * RANDOM_EMOJI_REACTIONS.length)]}
                  </span>
                </div>
                <div className="message-content">
                  {message.text}
                  {message.isTranslated && (
                    <div className="original-text">
                      <small>Original: {message.originalText}</small>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>

          {/* Message input */}
          <div className="message-input-container">
            <div className="input-wrapper">
              <textarea
                value={currentMessage}
                onChange={(e) => setCurrentMessage(e.target.value)}
                onKeyPress={handleKeyPress}
                placeholder="Type your message (it will be auto-ruined)..."
                className="message-input"
                style={{ fontFamily: currentFont }}
              />
              <button
                className="send-button"
                onClick={sendMessage}
                onMouseEnter={handleButtonHover}
                style={{
                  transform: `translate(${buttonPosition.x}px, ${buttonPosition.y}px) rotate(${Math.random() * 360}deg)`,
                  transition: 'all 0.5s ease'
                }}
              >
                <Send size={16} />
                Send (Maybe)
              </button>
            </div>
            <div className="input-footer">
              <span className="typing-indicator">
                💀 No one is typing (they gave up)
              </span>
            </div>
          </div>
        </main>
      </div>
    </div>
  )
}

export default App
