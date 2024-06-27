import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ConnectWallet } from "../components/Button/ConnectWallet";
import { useAccount, useWriteContract, useReadContract } from "wagmi";
import LoadingIndicator from "./LoadingIndicator";
import { GmonsterAbi } from "../constants/GmonsterAbi";
import { GmonsterAddress } from "../constants/GmonsterAddress";
import { toast } from "sonner";
import { parseEther } from "viem";

const JoinChallenge = () => {
  const [startTime, setStartTime] = useState("07:00");
  const [endTime, setEndTime] = useState("10:00");
  const [timezone, setTimezone] = useState("");
  const { isConnected, address: userAddress } = useAccount();
  const { isPending, writeContract } = useWriteContract();
  const DEPOSIT_AMOUNT = parseEther("0.002");
  const [isDeposited, setIsDeposited] = useState(false);

  const { data: challengesData } = useReadContract({
    address: GmonsterAddress as `0x${string}`,
    abi: GmonsterAbi,
    functionName: "challenges",
    args: [userAddress!],
  });

  useEffect(() => {
    const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
    setTimezone(tz);
  }, []);

  useEffect(() => {
    if (challengesData) {
      console.log("challengesData", challengesData);
      if (challengesData[0] > 0) {
        console.log("Deposited");
        setIsDeposited(true);
      }
    }
  }, [challengesData]);

  const handleStartTimeChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newStartTime = e.target.value;
    setStartTime(newStartTime);
    //Set end time to 3 hours later
    const [hours, minutes] = newStartTime.split(":").map(Number);
    const newMinutes = minutes < 10 ? `0${minutes}` : minutes;
    const newHours = hours + 3 >= 24 ? hours + 3 - 24 : hours + 3;
    const newEndTime = `${newHours}:${newMinutes}`;
    setEndTime(newEndTime);
  };

  const getEndTimeUnixTimestamp = (): bigint => {
    const [hours, minutes] = endTime.split(":").map(Number);
    //TODO set correct date
    const chllengeDate = new Date(Date.UTC(2024, 5, 28)); // Months are 0-indexed, so 4 represents May
    const chllengeTimestamp = Math.floor(chllengeDate.getTime() / 1000);
    console.log("chllengeTimestamp", chllengeTimestamp);

    const localEndDate = new Date(2024, 5, 28, hours, minutes);
    let localEndTimestamp = Math.floor(localEndDate.getTime() / 1000);
    console.log("localEndTimestamp", localEndTimestamp);

    // If the end time is earlier than the current time, set it for tomorrow
    if (chllengeTimestamp > localEndTimestamp) {
      localEndDate.setDate(localEndDate.getDate() + 1);
      localEndTimestamp = Math.floor(localEndDate.getTime() / 1000);
      console.log("localEndTimestamp", localEndTimestamp);
    }

    return BigInt(localEndTimestamp);
  };

  const deposit = async () => {
    const endTimeUnix = getEndTimeUnixTimestamp();
    console.log("@@@endTimeUnix=", endTimeUnix);
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
          setIsDeposited(true);
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
              <div className="ml-2 py-2 px-4 rounded">{endTime}</div>
              <span className="ml-2">({timezone})</span>
            </div>
          </div>
          <p className="text-sm text-gray-600 mb-6">
            Make sure your wallet address connected to your Farcaster account.
          </p>

          {!isConnected ? (
            <ConnectWallet />
          ) : !isDeposited ? (
            <Button
              onClick={deposit}
              className="w-full bg-blue-500 hover:bg-blue-600 text-white text-lg py-3 px-6 rounded-full transition duration-300 ease-in-out transform hover:scale-105"
            >
              {isPending ? <LoadingIndicator /> : "Deposit 0.002ETH"}
            </Button>
          ) : (
            <Button
              onClick={() =>
                window.open("https://warpcast.com/~/channel/gmonster")
              }
              className="w-full text-white text-lg py-3 px-6 rounded-full transition duration-300 ease-in-out transform hover:scale-105"
              style={{ backgroundColor: "#8A63D2" }}
            >
              Follow channel on Farcaster
            </Button>
          )}
        </div>
      </div>
    </section>
  );
};

export default JoinChallenge;
