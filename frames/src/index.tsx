import { Button, Frog, TextInput } from 'frog'
import { devtools } from 'frog/dev'
import { serveStatic } from 'frog/serve-static'
import { GmonsterAbi } from '../constants/GmonsterAbi.js'
// import { neynar } from 'frog/hubs'

export const app = new Frog({
  imageAspectRatio: '1:1'
})


app.frame('/', (c) => {
  return c.res({
    action: '/finish',
    image: 'https://gmon-frames.vercel.app/title.png',
    intents: [
      <Button.Transaction target="/challenge">GM</Button.Transaction>,
    ]
  })
})

app.frame('/finish', (c) => {
  const { transactionId } = c
  return c.res({
    image: 'https://gmon-frames.vercel.app/gmon/01.png', // TODO: Changed everyday
  })
})

app.transaction('/challenge', (c) => {
  return c.contract({
    abi: GmonsterAbi,
    chainId: 'eip155:84532', // TODO: To be changed. Base is eip155:8453, Base Sepolia is eip155:84532
    functionName: 'challenge',
    to: '0x7ca674d4f3579658cd1fba597b92d8d931a493ff' // TODO: To be changed
  })
})
devtools(app, { serveStatic })

if (typeof Bun !== 'undefined') {
  Bun.serve({
    fetch: app.fetch,
    port: 3000,
  })
  console.log('Server is running on port 3000')
}
