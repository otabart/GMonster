import { useState, useEffect } from 'react';
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ConnectWallet }  from '../components/Button/ConnectWallet';
import { useAccount, useWriteContract } from "wagmi";
import LoadingIndicator from "./LoadingIndicator";
const JoinChallenge = () => {
  const [startTime, setStartTime] = useState('07:00');
  const [endTime, setEndTime] = useState('10:00');
  const [timezone, setTimezone] = useState('');
  const { isConnected } = useAccount();
  // const { isPending, writeContract } = useWriteContract();
  const { isPending } = useWriteContract();

  useEffect(() => {
    const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
    setTimezone(tz);
  }, []);

  const handleStartTimeChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newStartTime = e.target.value;
    setStartTime(newStartTime);
    
    const [hours, minutes] = newStartTime.split(':').map(Number);
    const endDate = new Date(2000, 0, 1, hours + 3, minutes);
    setEndTime(endDate.toTimeString().slice(0, 5));
  };

  return (
    <section className="py-12 bg-white">
      <div className="container mx-auto px-4">
        <h2 className="text-3xl font-bold text-center mb-8">Join Challenge</h2>
        <div className="max-w-md mx-auto">
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              I wake up
            </label>
            <div className="flex items-center">
              <Input
                type="time"
                value={startTime}
                onChange={handleStartTimeChange}
                className="mr-2"
              />
              <span className="mx-2">to</span>
              <div className="ml-2 py-2 px-4 rounded">
                {endTime}
              </div>
              <span className="ml-2">({timezone})</span>
            </div>
          </div>
          <p className="text-sm text-gray-600 mb-6">
            Make sure your wallet address connected to your Farcaster account.
          </p>
          
          {isConnected ? (
            <Button className="w-full bg-blue-500 hover:bg-blue-600 text-white text-lg py-3 px-6 rounded-full transition duration-300 ease-in-out transform hover:scale-105">
              {isPending ? <LoadingIndicator /> : "Deposit 0.002ETH"}
            </Button>
          ) : (
            <ConnectWallet />
          )}
        </div>
      </div>
    </section>
  );
};

export default JoinChallenge;
