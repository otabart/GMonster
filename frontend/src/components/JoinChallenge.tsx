import { useState, useEffect } from 'react';
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ConnectWallet }  from '../components/Button/ConnectWallet';
import { useAccount, useWriteContract } from "wagmi";
import LoadingIndicator from "./LoadingIndicator";
import { GmonsterAbi } from '../constants/GmonsterAbi';
import { GmonsterAddress } from '../constants/GmonsterAddress';
import { toast } from "sonner";
import { parseEther } from 'viem';

const JoinChallenge = () => {
  const [startTime, setStartTime] = useState('07:00');
  const [endTime, setEndTime] = useState('10:00');
  const [timezone, setTimezone] = useState('');
  const { isConnected } = useAccount();
  const { isPending, writeContract } = useWriteContract();
  const DEPOSIT_AMOUNT = parseEther('0.002');
  

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

  const getEndTimeUnixTimestamp = (): bigint => {
    const now = new Date();
    const [hours, minutes] = endTime.split(':').map(Number);
    const endDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), hours, minutes);
    
    // If the end time is earlier than the current time, set it for tomorrow
    if (endDate < now) {
      endDate.setDate(endDate.getDate() + 1);
    }
    
    return BigInt(Math.floor(endDate.getTime() / 1000)); // Convert to seconds and then to BigInt
  };

  const deposit = async () => {
    const endTimeUnix = getEndTimeUnixTimestamp();
    writeContract(
      {
        address: GmonsterAddress as `0x${string}`,
        abi: GmonsterAbi,
        functionName: "deposit",
        args: [endTimeUnix],
        value: DEPOSIT_AMOUNT,
      },
      {
        onSuccess(data, variables, context) {
          toast("Deposit success!", {
            action: {
              label: "Share on X",
              onClick: () => {
                const shareText = encodeURIComponent(
                  `I pledge to Base to get up early for 21 days. 🫡 \nhttps://gmonster.vercel.app//`
                );
                const hashtags = encodeURIComponent("GMonster,Base Summer");
                const related = encodeURIComponent("twitterapi,twitter");
                const url = `https://x.com/intent/tweet?text=${shareText}&hashtags=${hashtags}&related=${related}`;
                const newWindow = window.open(url, "_blank");
                newWindow?.focus();
              },
            },
          });
        },
      }
    );
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
            <Button onClick={deposit} className="w-full bg-blue-500 hover:bg-blue-600 text-white text-lg py-3 px-6 rounded-full transition duration-300 ease-in-out transform hover:scale-105">
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
