import { useState, useEffect } from 'react';
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ConnectWallet }  from '../components/Button/ConnectWallet';
import { useAccount, useWriteContract, useReadContract } from "wagmi";
import { parseEther } from 'viem';
import LoadingIndicator from "./LoadingIndicator";
import { GmonsterAbi } from '../constants/GmonsterAbi';
import { GmonsterAddress } from '../constants/GmonsterAddress';
import { toast } from "sonner";

const DEPOSIT_AMOUNT = parseEther('0.002'); // 0.002 ETH in wei

const JoinChallenge = () => {
  const [startTime, setStartTime] = useState('07:00');
  const [endTime, setEndTime] = useState('10:00');
  const [timezone, setTimezone] = useState('');
  const [seasonStartTimestamp, setSeasonStartTimestamp] = useState<bigint>(BigInt(0));
  const { isConnected, address } = useAccount();
  const { isPending, writeContract } = useWriteContract();
  const { data: seasonData } = useReadContract({
    address: GmonsterAddress as `0x${string}`,
    abi: GmonsterAbi,
    functionName: "season",
  });

  useEffect(() => {
    const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
    setTimezone(tz);

    if (seasonData && 'seasonStartTimestamp' in seasonData) {
      setSeasonStartTimestamp(BigInt(seasonData.seasonStartTimestamp));
    }
  }, [seasonData]);

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
    
    // Check if the current time is before the season start
    if (BigInt(Math.floor(Date.now() / 1000)) >= seasonStartTimestamp) {
      toast.error("The season has already started. Deposits are no longer accepted.");
      return;
    }

    // Check if the endTimeUnix is after or equal to the season start time
    if (endTimeUnix < seasonStartTimestamp) {
      toast.error("Your challenge end time must be after the season start time.");
      return;
    }

    writeContract(
      {
        address: GmonsterAddress as `0x${string}`,
        abi: GmonsterAbi,
        functionName: "deposit",
        args: [endTimeUnix],
        value: DEPOSIT_AMOUNT,
      },
      {
        onSuccess(data) {
          toast.success("Deposit success!", {
            action: {
              label: "Share on X",
              onClick: () => {
                const shareText = encodeURIComponent(
                  `I pledge to Base to get up early for 21 days. 🫡 \nhttps://gmonster.vercel.app/`
                );
                const hashtags = encodeURIComponent("GMonster,Base Summer");
                const related = encodeURIComponent("twitterapi,twitter");
                const url = `https://x.com/intent/tweet?text=${shareText}&hashtags=${hashtags}&related=${related}`;
                window.open(url, "_blank")?.focus();
              },
            },
          });
        },
        onError(error) {
          toast.error(`Failed to deposit: ${error.message}`);
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
            Make sure your wallet address is connected to your Farcaster account.
          </p>
          
          {isConnected ? (
            <Button 
              onClick={deposit} 
              className="w-full bg-blue-500 hover:bg-blue-600 text-white text-lg py-3 px-6 rounded-full transition duration-300 ease-in-out transform hover:scale-105"
              disabled={isPending}
            >
              {isPending ? <LoadingIndicator /> : "Deposit 0.002 ETH"}
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
