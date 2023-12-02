"use client";
import React from "react";
import {
  EthereumClient,
  w3mConnectors,
  w3mProvider,
} from "@web3modal/ethereum";
import { Web3Button, Web3Modal } from "@web3modal/react";
import { configureChains, createConfig, WagmiConfig } from "wagmi";
import { avalancheFuji, sepolia, filecoin } from "wagmi/chains";
import Navbar from "./navbar";
import { HeliaProvider } from "./HeliaContext";

const projectId = process.env.walletConnectProjectId!;
const chains = [avalancheFuji, sepolia, filecoin];
const ethereumClient = new EthereumClient(WagmiConfig, chains);

const { publicClient } = configureChains(chains, [w3mProvider({ projectId })]);

const config = createConfig({
  autoConnect: true,
  connectors: w3mConnectors({ projectId, chains }),
  publicClient,
});

export default function WrappedApp({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <>
      <HeliaProvider>
        <Navbar />
        <WagmiConfig config={config}>{children}</WagmiConfig>
        <div className="absolute top-10 right-10">
          <Web3Button />
        </div>
        <Web3Modal projectId={projectId} ethereumClient={ethereumClient} />
      </HeliaProvider>
    </>
  );
}
