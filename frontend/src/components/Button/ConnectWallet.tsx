import { ConnectKitButton } from "connectkit";
import { Button } from "@/components/ui/button"
import styled from "styled-components";


export const ConnectWallet = ({ buttonText = "Connect Wallet" }) => {
  return (
    <ConnectKitButton.Custom>
      {({ isConnected, show, truncatedAddress, ensName }) => {
        return (
          <Button className="w-full bg-blue-500 hover:bg-blue-600 text-white text-lg py-3 px-6 rounded-full transition duration-300 ease-in-out transform hover:scale-105" onClick={show}>
            {isConnected ? ensName ?? truncatedAddress : buttonText}
          </Button>
        );
      }}
    </ConnectKitButton.Custom>
  );
};
