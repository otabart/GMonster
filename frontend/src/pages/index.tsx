import React, { useRef } from 'react';
import type { NextPage } from "next";
import dynamic from 'next/dynamic';
import { useState } from 'react';
import Image from 'next/image';
import { Button } from "@/components/ui/button";

import { Toaster } from "@/components/ui/toaster";
import { Toaster as ToasterSonner } from "@/components/ui/sonner";
import HowItWorks from '../components/HowItWorks';
import JoinChallenge from '../components/JoinChallenge';
import Footer from '../components/Footer';
const VideoPlayer = dynamic(() => import('../components/VideoPlayer'), {
  loading: () => <div className="w-full h-full bg-gray-200 animate-pulse" />,
  ssr: false
});

const Home: NextPage = () => {
  const [isVideoLoaded, setIsVideoLoaded] = useState(false);
  const joinChallengeRef = useRef<HTMLDivElement>(null);

  const scrollToJoinChallenge = () => {
    if (joinChallengeRef.current) {
      joinChallengeRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <div className="min-h-screen flex flex-col">
      {/* PC */}
      <div className="hidden md:flex flex-grow relative">
        <div className="w-[20%]" />
        <div className="w-[80%] relative">
          <div className="w-full pt-[45%]"> 
            <div className="absolute top-0 right-0 w-full h-full">
              {!isVideoLoaded && (
                <div className="absolute inset-0 bg-gray-200 animate-pulse" />
              )}
              <VideoPlayer
                src="/top-movie.mp4"
                onLoadedData={() => setIsVideoLoaded(true)}
                className={`w-full h-full object-cover ${isVideoLoaded ? 'opacity-100' : 'opacity-0'} transition-opacity duration-300`}
              />
            </div>
          </div>
        </div>
        
        <div className="absolute left-0 top-1/2 transform -translate-y-1/2 w-[40%] z-10">
          <div className="relative left-1/2 transform -translate-x-1/2">
            <Image
              src="/logo.svg"
              alt="GMaster Logo"
              width={400}
              height={133}
              className="max-w-full h-auto"
            />
          </div>
        </div>
      </div>

      {/* SP */}
      <div className="md:hidden flex flex-col">
        <div className="w-full pt-[56.25%] relative"> 
          {!isVideoLoaded && (
            <div className="absolute inset-0 bg-gray-200 animate-pulse" />
          )}
          <VideoPlayer
            src="/top-movie.mp4"
            onLoadedData={() => setIsVideoLoaded(true)}
            className={`absolute top-0 left-0 w-full h-full object-cover ${isVideoLoaded ? 'opacity-100' : 'opacity-0'} transition-opacity duration-300`}
          />
        </div>
        
        <div className="w-full relative -mt-[10%] z-10 px-4 md:px-8">
          <div className="md:hidden flex justify-center">
            <Image
              src="/logo.svg"
              alt="GMaster Logo"
              width={300}
              height={100}
              className="max-w-full h-auto"
            />
          </div>
          <div className="hidden md:block">
            <Image
              src="/logo.svg"
              alt="GMaster Logo"
              width={400}
              height={133}
              className="max-w-full h-auto"
            />
          </div>
        </div>
      </div>

      <div className="py-8 mx-4 sm:mx-8 md:mx-16 lg:mx-32">
        <div className="max-w-7xl mx-auto">
          <div className="md:flex md:items-center md:justify-between">
            <div className="flex-1 min-w-0">
              <p className="text-xl md:text-xl font-bold text-gray-900 mb-6 md:mb-0">
                This morning challenge gives you something fun to look forward to when you wake up in the morning. GMonster is only available to join by July 3rd!
              </p>
            </div>
            <div className="mt-6 flex justify-center md:mt-0 md:ml-8">
              <Button
                className="bg-blue-500 hover:bg-blue-600 text-white text-lg py-3 px-6 rounded-full transition duration-300 ease-in-out transform hover:scale-105"
                onClick={scrollToJoinChallenge}
              >
                Join Challenge
              </Button>
            </div>
          </div>
        </div>
      </div>

      <HowItWorks />
      <div ref={joinChallengeRef}>
        <JoinChallenge />
      </div>
      <Footer />

      <Toaster />
      <ToasterSonner position="bottom-right" />
    </div>
  );
};

export default Home;
