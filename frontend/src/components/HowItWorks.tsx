import React from 'react';
import HowItWorksItem from './HowItWorksItem';

const HowItWorks: React.FC = () => (
  <section className="py-12 bg-gray-100">
    <div className="container mx-auto px-4">
      <h2 className="text-3xl font-bold text-center mb-16">How it works</h2>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        <HowItWorksItem
          number="1"
          title="Deposit & Set timezone"
          description="Deposit 0.002 ETH(Base) and set a time to wake up. 3 hours every day you setup"
        />
        <HowItWorksItem
          number="2"
          title="GM action"
          description="Starting from 4st July, GM action from Farcaster's #gmonster channel."
        />
        <HowItWorksItem
          number="3"
          title="Continue for 21 days"
          description="Continues for 21 days! If you miss more than 3 days, the deposit will be distributed to other achievers."
        />
      </div>
    </div>
  </section>
);

export default HowItWorks;
