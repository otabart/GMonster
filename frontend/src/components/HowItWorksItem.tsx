import React, { ReactNode } from 'react';

interface HowItWorksItemProps {
  number: string;
  title: string;
  description: string | ReactNode;
}

const HowItWorksItem: React.FC<HowItWorksItemProps> = ({ number, title, description }) => (
  <div className="bg-white p-6 pt-10 rounded-lg shadow-md relative">
    <div className="absolute top-0 left-1/2 transform -translate-x-1/2 -translate-y-1/2">
      <div className="w-16 h-16 bg-blue-200 rounded-full flex items-center justify-center text-white font-bold text-2xl border-4 border-white">
        {number}
      </div>
    </div>
    <h3 className="text-xl font-semibold mb-2 mt-4">{title}</h3>
    <div className="text-gray-600">{description}</div>
  </div>
);

export default HowItWorksItem;
