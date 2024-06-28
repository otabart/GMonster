import React from "react";
import { Button } from "@/components/ui/button";
import LoadingIndicator from "../components/LoadingIndicator";
import { toast } from "sonner";
import { useWriteContract } from "wagmi";
import { GmonsterAbi } from "../constants/GmonsterAbi";
import { GmonsterAddress } from "../constants/GmonsterAddress";

interface WithdrawButtonProps {
  depositedAmount: string;
  endTimestamp: number;
}

const WithdrawButton = ({
  depositedAmount,
  endTimestamp,
}: WithdrawButtonProps) => {
  const { isPending, writeContract } = useWriteContract();

  const withdraw = async () => {
    writeContract(
      {
        address: GmonsterAddress as `0x${string}`,
        abi: GmonsterAbi,
        functionName: "withdraw",
      },
      {
        onSuccess() {
          toast("Withdraw success!", {
            action: {
              label: "Share on X",
              onClick: () => {
                const shareText = encodeURIComponent(
                  `I'm winner of challenge to get up early for 21 days. 🫡 \nhttps://gmonster.vercel.app//`
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
    <>
      {Number(depositedAmount) > 0 && Date.now() > endTimestamp * 1000 ? (
        <Button
          className="bg-blue-500 hover:bg-blue-600 text-white text-lg py-3 px-6 rounded-full transition duration-300 ease-in-out transform hover:scale-105"
          onClick={withdraw}
        >
          {isPending ? <LoadingIndicator /> : "Withdraw"}
        </Button>
      ) : (
        <Button
          className="bg-gray-500 text-white text-lg py-3 px-6 rounded-full"
          disabled={true}
        >
          Withdraw
        </Button>
      )}
    </>
  );
};

export default WithdrawButton;
