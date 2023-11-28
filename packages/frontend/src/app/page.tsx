"use client";
import { useRouter } from 'next/navigation';
import { useAccount } from 'wagmi'

export default function Home() {

  const router = useRouter();

  const { address, isConnecting, isDisconnected } = useAccount()


  return (
    <main className="flex h-screen flex-col items-center justify-around p-24">
      <div className="absolute top-10 right-10"></div>
      <h1 className="mb-4 pt-20 items-center justify-center text-4xl font-extrabold tracking-tight leading-none text-gray-900 md:text-5xl lg:text-6xl dark:text-white">
        Welcome to Tesseract!
      </h1>
      <h2 className="text-secondary-foreground leading-tight tracking-tighter">
      This platform aims to revolutionize how personal medical data is handled and analyzed, 
      providing a secure and efficient method for delivering personalized medical insights. 
      The combination of Avalanche's blockchain technology and Cartesi's decentralized computing could offer a robust and scalable solution. 
      However, careful consideration must be given to regulatory compliance, data security, and user adoption strategies.
      </h2>
      <div>{address}</div>
    </main>
  );
}
