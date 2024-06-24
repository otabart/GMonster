import React from 'react';
import Image from 'next/image';

const Footer = () => {
  const shareText = encodeURIComponent('Gmonster https://gmonster.vercel.app/');
  const twitterShareUrl = `https://twitter.com/intent/tweet?text=${shareText}`;
  const farcasterShareUrl = `https://warpcast.com/~/compose?text=${shareText}`;

  return (
    <footer className="bg-blue-600 text-white py-6">
      <div className="container mx-auto px-4 flex flex-col items-center">
        <div className="flex items-center space-x-4 mb-4">
          <span>SHARE</span>
          <a href={twitterShareUrl} target="_blank" rel="noopener noreferrer">
            <Image
              src="/x.png"
              alt="Share Gmonster on Twitter"
              width={32} 
              height={32}
              className="cursor-pointer"
            />
          </a>
          <a href={farcasterShareUrl} target="_blank" rel="noopener noreferrer">
            <Image
              src="/farcaster.png"
              alt="Share on Farcaster"
              width={32}
              height={32}
              className="cursor-pointer"
            />
          </a>
        </div>
        <h2 className="text-xl font-bold mb-2">Baratie</h2>
        <p className="text-sm mb-4">©2024 Baratie.</p>
        <p className="text-sm text-center">
          Gmonster is intended for entertainment purposes only and is not intended for use in detection, diagnosis, or treatment of any medical condition or disease.
        </p>
      </div>
    </footer>
  );
};

export default Footer;
