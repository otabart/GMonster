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

const getImageUrl = () => {
  const today = new Date();
  const day = today.getDate();

  const dateToImageMap: { [key: number]: string } = {
    1: 'https://gmon-frames.vercel.app/gmon/16.png',
    2: 'https://gmon-frames.vercel.app/gmon/17.png',
    3: 'https://gmon-frames.vercel.app/gmon/18.png',
    4: 'https://gmon-frames.vercel.app/gmon/19.png',
    5: 'https://gmon-frames.vercel.app/gmon/20.png',
    6: 'https://gmon-frames.vercel.app/gmon/01.png',
    7: 'https://gmon-frames.vercel.app/gmon/02.png',
    8: 'https://gmon-frames.vercel.app/gmon/03.png',
    9: 'https://gmon-frames.vercel.app/gmon/04.png',
    10: 'https://gmon-frames.vercel.app/gmon/05.png',
    11: 'https://gmon-frames.vercel.app/gmon/06.png',
    12: 'https://gmon-frames.vercel.app/gmon/07.png',
    13: 'https://gmon-frames.vercel.app/gmon/08.png',
    14: 'https://gmon-frames.vercel.app/gmon/09.png',
    15: 'https://gmon-frames.vercel.app/gmon/10.png',
    16: 'https://gmon-frames.vercel.app/gmon/11.png',
    17: 'https://gmon-frames.vercel.app/gmon/12.png',
    18: 'https://gmon-frames.vercel.app/gmon/13.png',
    19: 'https://gmon-frames.vercel.app/gmon/14.png',
    20: 'https://gmon-frames.vercel.app/gmon/15.png',
    21: 'https://gmon-frames.vercel.app/gmon/16.png',
    22: 'https://gmon-frames.vercel.app/gmon/17.png',
    23: 'https://gmon-frames.vercel.app/gmon/18.png',
    24: 'https://gmon-frames.vercel.app/gmon/19.png',
    25: 'https://gmon-frames.vercel.app/gmon/20.png',
    26: 'https://gmon-frames.vercel.app/gmon/21.png',
    27: 'https://gmon-frames.vercel.app/gmon/20.png',
    28: 'https://gmon-frames.vercel.app/gmon/20.png',
    29: 'https://gmon-frames.vercel.app/gmon/20.png',
    30: 'https://gmon-frames.vercel.app/gmon/20.png',
    31: 'https://gmon-frames.vercel.app/gmon/20.png',
  };

  return dateToImageMap[day] || 'https://gmon-frames.vercel.app/gmon/20.png';
  
}

app.frame('/finish', (c) => {
  const today = new Date();
  const day = today.getDate();
  console.log("@@@day=", day)
  const { transactionId } = c
  return c.res({
    image: getImageUrl(),
    intents: [
      <Button.Reset>Top</Button.Reset>,
      <Button.Link href="https://gmonster.vercel.app/dashboard">Dashboard</Button.Link>,
    ]
  })
})

app.transaction('/challenge', (c) => {
  return c.contract({
    abi: GmonsterAbi,
    chainId: 'eip155:8453',
    functionName: 'challenge',
    to: '0x9d44492232aD68Dfd71c4C66510f0A3e0Fa1307c'
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
