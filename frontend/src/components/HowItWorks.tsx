import React, { useState } from 'react';
import HowItWorksItem from './HowItWorksItem';

const HowItWorks: React.FC = () => {
  const [isVideoLoaded, setIsVideoLoaded] = useState(false);

  const handleVideoLoaded = () => {
    setIsVideoLoaded(true);
  };

  return (
    <section className="py-12 bg-gray-100">
      <div className="container mx-auto px-4">
        <h2 className="text-3xl font-bold text-center mb-16">How it works</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12">
          <HowItWorksItem
            number="1"
            title="Deposit & Set timezone"
            description="Deposit 0.002 ETH(Base) and set a time to wake up. 3 hours every day you setup"
          />
          <HowItWorksItem
            number="2"
            title="GM action"
            description={
              <>
                GM action on pined farcaster framed post in{' '}
                <a
                  href="https://warpcast.com/~/channel/gmonster"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-purple-600 hover:text-purple-800 underline"
                >
                  Farcaster #gmonster channel
                </a>
                .
              </>
            }
          />
          <HowItWorksItem
            number="3"
            title="Continue for 21 days"
            description="Continues for 21 days! If you miss more than 3 days, the deposit will be distributed to other achievers."
          />
        </div>
        <div className="w-full max-w-xl mx-auto">
          <div className="aspect-w-16 aspect-h-9 bg-gray-200 rounded-lg overflow-hidden">
            <iframe
              src="https://www.youtube.com/embed/h2WGs1tJDl4"
              title="YouTube video player"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
              onLoad={handleVideoLoaded}
              className={"h-80 w-full"}
            ></iframe>
          </div>
        </div>
      </div>
    </section>
  );
};

export default HowItWorks;
