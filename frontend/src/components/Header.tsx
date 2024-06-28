import React from "react";
import Image from "next/image";
import { useAccount } from "wagmi";

const truncatedText = (val: string, num: number): string => {
  return val.length > 8 ? `${val.slice(0, num)}...` : val;
};

const Header = () => {
  const { address } = useAccount();

  return (
    <footer className="bg-blue-600 text-white py-2">
      <div className="container mx-auto px-4 flex justify-between items-center">
        <div className="">
          <a href="/">
            <Image
              src="/GMonster-logo.png"
              alt="GMaster Logo"
              width={240}
              height={10}
              className="max-w-full h-auto"
            />
          </a>
        </div>
        <div className="flex justify-between items-center">
          {address && (
            <>
              <div className="mr-3">
                <Image src="/wallet_icon.png" alt="" width={18} height={18} />
              </div>
              <div>{truncatedText(address, 12)}</div>
            </>
          )}
        </div>
      </div>
    </footer>
  );
};

export default Header;
