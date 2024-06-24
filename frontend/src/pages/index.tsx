import type { NextPage } from "next";

import { Toaster } from "@/components/ui/toaster";
import { Toaster as ToasterSonner } from "@/components/ui/sonner";

const Home: NextPage = () => {  

  return (
    <div className="flex flex-col">
      <div className="flex flex-grow justify-center mt-8">
        <>TODO: Wright something</>
      </div>
      <Toaster />
      <ToasterSonner position="bottom-right" />
    </div>
  );
};

export default Home;
