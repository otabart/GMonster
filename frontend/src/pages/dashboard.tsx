import { useEffect, useState } from "react";
import type { NextPage } from "next";
import Header from "../components/Header";
import Footer from "../components/Footer";
import WithdrawButton from "../components/WithdrawButton";
import { useAccount, useReadContracts } from "wagmi";
import { formatEther } from "viem";
import { GmonsterAbi } from "../constants/GmonsterAbi";
import { GmonsterAddress } from "../constants/GmonsterAddress";
import { ConnectWallet } from "../components/Button/ConnectWallet";

const gmonContract = {
  address: GmonsterAddress as `0x${string}`,
  abi: GmonsterAbi,
} as const;

const challnegeCount = 21;

const Dashboard: NextPage = () => {
  const [successCount, setSuccessCount] = useState(0);
  const [consecutiveSuccessCount, setConsecutiveSuccessCount] = useState(0);
  const [missedCount, setMissedCount] = useState(0);
  const [depositedAmount, setDepositedAmount] = useState("0");
  const [endTimestamp, setEndTimestamp] = useState(0);
  const [withdrawalDate, setWithdrawalDate] = useState("");
  const [withdrawalTimezone, setWithdrawalTimezone] = useState("");
  const [isFailed, setIsFailed] = useState(false);
  const { isConnected, address: userAddress } = useAccount();

  const res = useReadContracts({
    contracts: [
      {
        ...gmonContract,
        functionName: "challenges",
        args: [userAddress!],
      },
      {
        ...gmonContract,
        functionName: "season",
      },
      {
        ...gmonContract,
        functionName: "getLostCount",
        args: [userAddress!],
      },
      {
        ...gmonContract,
        functionName: "judgeFailOrNot",
        args: [userAddress!],
      },
    ],
  });

  useEffect(() => {
    if (res.data && isConnected) {
      console.log("res", res.data);
      const challenges = res.data[0].result!;
      setDepositedAmount(formatEther(challenges[0]));
      setSuccessCount(Number(challenges[3]));
      setConsecutiveSuccessCount(Number(challenges[4]));

      const season = res.data[1].result!;
      const seasonEndTimestamp = season[1];
      console.log("seasonEndTimestamp", seasonEndTimestamp);
      setEndTimestamp(Number(seasonEndTimestamp));
      // Timestamp to date on your timezone
      const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
      setWithdrawalTimezone(tz);
      const _date = new Date(Number(seasonEndTimestamp) * 1000);
      const _dateString = _date.toLocaleString("en-US", {
        timeZone: tz,
        hour12: false,
      });
      setWithdrawalDate(_dateString);

      const lostCount = res.data[2].result!;
      setMissedCount(Number(lostCount));
      const isFailed = res.data[3].result!;
      setIsFailed(isFailed);
    }
  }, [res, isConnected]);

  return (
    <div className="min-h-screen flex flex-col">
      <Header />
      <div className="flex-grow py-8 px-4 sm:px-8 lg:px-16">
        <div>
          <p className="text-xl font-bold text-gray-900 mb-6">Your Challenge</p>
          {isConnected ? (
            <div className="p-4 sm:p-6 lg:p-10 rounded-lg border-gray-300 border flex flex-col lg:flex-row justify-between">
              <div className="flex-grow mb-6 lg:mb-0">
                <div className="flex flex-col sm:flex-row justify-between">
                  <div className="w-full sm:w-1/3 mb-4 sm:mb-0">
                    <div className="mx-2 px-5 py-3 rounded-lg bg-gray-200 text-center">
                      <h3 className="font-semibold py-2">Success</h3>
                      <p className="text-lg">{successCount}</p>
                    </div>
                  </div>
                  <div className="w-full sm:w-1/3 mb-4 sm:mb-0">
                    <div className="mx-2 px-2 py-3 rounded-lg bg-gray-200 text-center">
                      <h3 className="font-semibold text-sm" style={{ lineHeight: "20px" }}>
                        Consecutive
                        <br />
                        Successes
                      </h3>
                      <p className="text-lg">{consecutiveSuccessCount}</p>
                    </div>
                  </div>
                  <div className="w-full sm:w-1/3">
                    <div className="mx-2 px-5 py-3 rounded-lg bg-gray-200 text-center">
                      <h3 className="font-semibold py-2">Missed</h3>
                      <p className="text-lg">{missedCount}</p>
                    </div>
                  </div>
                </div>
                <div className="mx-2 mt-6 px-5 py-3 rounded-lg bg-gray-200 text-center">
                  <h3 className="font-semibold">Remaining</h3>
                  <p className="text-lg">
                    {challnegeCount - successCount - missedCount}
                  </p>
                </div>
              </div>
              <div className="w-full lg:w-1/2 lg:ml-12">
                <div className="flex justify-between mb-4">
                  <div className="font-semibold">
                    <p className="">Deposited</p>
                    <p className="mt-1">Withdrawal</p>
                  </div>
                  <div className="text-right">
                    <p className="">{depositedAmount} ETH</p>
                    <p className="mt-1">
                      <span>{withdrawalDate}</span> (<span>{withdrawalTimezone}</span>)
                    </p>
                  </div>
                </div>
                <div className="text-center mt-8 lg:mt-16">
                  {isFailed ? (
                    <div className="font-semibold text-lg text-red-500">
                      Your challenge is missed
                    </div>
                  ) : (
                    <WithdrawButton
                      depositedAmount={depositedAmount}
                      endTimestamp={endTimestamp}
                    />
                  )}
                </div>
              </div>
            </div>
          ) : (
            <ConnectWallet />
          )}
        </div>
      </div>
      <Footer />
    </div>
  );
};

export default Dashboard;
