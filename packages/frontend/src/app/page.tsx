"use client";
import { useRouter } from 'next/navigation';
import { useAccount } from 'wagmi';
import { useState } from 'react';

export default function Home() {

  const router = useRouter();

  const { address, isConnecting, isDisconnected } = useAccount()

  const [data, setData] = useState('');

  async function upload() {
    try {
      const response = await fetch('/api/upload', {
        method: 'POST',
        body: JSON.stringify(data),
      })
      const json = await response.json();
      console.log('json: ', json);
    } catch(err) {
      console.log({ err })
    }
  }

  return (
    <main className="flex h-screen flex-col items-center justify-around p-24">
      <div className="absolute top-10 right-10"></div>
      <h1 className="mb-4 pt-20 items-center justify-center text-4xl font-extrabold tracking-tight leading-none text-gray-900 md:text-5xl lg:text-6xl dark:text-white">
        Welcome to Tesseract!
      </h1>
      <h2 className="text-secondary-foreground leading-tight tracking-tighter">
      This platform aims to revolutionize how personal medical data is handled and analyzed, 
      providing a secure and efficient method for delivering personalized medical insights.
      </h2>
      <div>{address}</div>

      <div>
        <input
            placeholder="Create post"
            onChange={e => setData(e.target.value)}
        />
        <button
          onClick={upload}
          className='text-black bg-white mt-2 px-12'
        >
          Upload Text
        </button>


      </div>
    </main>
  );
}
