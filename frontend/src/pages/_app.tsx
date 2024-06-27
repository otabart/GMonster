import type { AppProps } from "next/app";
import "../styles/globals.css";
import { WagmiProvider, createConfig, http } from "wagmi";
import { QueryClientProvider, QueryClient } from "@tanstack/react-query";
import { ConnectKitProvider, getDefaultConfig } from "connectkit";
import { useState, useEffect } from "react";
import Head from "next/head";
import { baseSepolia, base } from "wagmi/chains";

const config = createConfig(
  getDefaultConfig({
    // Your dApps chains
    chains: [baseSepolia],
    transports: {
      [baseSepolia.id]: http(baseSepolia.rpcUrls.default.http[0]),
    },
    // Required API Keys
    walletConnectProjectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID!,

    ssr: true,

    // Required App Info
    appName: "Your App Name",

    // Optional App Info
    appDescription: "Your App Description",
    appUrl: "https://family.co", // your app's url
    appIcon: "https://family.co/logo.png", // your app's icon, no bigger than 1024x1024px (max. 1MB)
  })
);

const queryClient = new QueryClient();

function MyApp({ Component, pageProps }: AppProps) {

  const [isMobile, setIsMobile] = useState<boolean>(false);

  useEffect(() => {
    // Run this effect once on mount
    const handleResize = () => {
      // Consider "mobile" if width is less than or equal to 768 pixels
      setIsMobile(window.innerWidth <= 768);
    };
    // Check once on mount
    handleResize();
    // Optionally listen for resize events if you want to dynamically change the view
    window.addEventListener('resize', handleResize);
    // Cleanup the event listener on component unmount
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <ConnectKitProvider>
          <Head>
            <title>GMonster</title>
              <meta property='og:title' content='GMonster' />
              <meta
                property='og:description'
                content='GM GM GM GM GM GM GM GM GM GM GM GM'
              />
              <meta property='og:image' content='https://gmonster.vercel.app/ogp.png' />
              <link rel='icon' type='image/png' sizes='16x16' href='/favicon-16x16.png' />
              <link rel='icon' type='image/png' sizes='32x32' href='/favicon-32x32.png' />
              <link rel='apple-touch-icon' sizes='200x200' href='/apple-touch-icon.png' />
              <meta name='twitter:card' content='summary_large_image' />
              <meta name='twitter:title' content='Monster' />
              <meta
                name='twitter:description'
                content='GM GM GM GM GM GM GM GM GM GM GM GM '
              />
              <meta
                name='twitter:image'
                content='https://gmonster.vercel.app/ogp.png'
              />
            </Head>
            <div className="bg-white-900 text-default h-auto">
              <Component {...pageProps} />
            </div>
        </ConnectKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}

export default MyApp;
