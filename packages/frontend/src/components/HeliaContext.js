import { createHelia } from 'helia'
import { useContext, useState, useEffect, createContext } from 'react'
import { createLibp2p } from "libp2p-bootstrap"
import React from 'react';

const HeliaContext = createContext(null);

export const useHelia = () => useContext(HeliaContext);

export const HeliaProvider = ({ children }) => {
  const [id, setId] = useState(null)
  const [helia, setHelia] = useState(null)
  const [isOnline, setIsOnline] = useState(false)

  useEffect(() => {
    const initHelia = async () => {
      if (helia) return

      // const heliaNode = await createHelia()

      const heliaNode = await createHelia()

      const nodeId = heliaNode.libp2p.peerId.toString()
      const nodeIsOnline = heliaNode.libp2p.isStarted()

      setHelia(heliaNode)
      setId(nodeId)
      setIsOnline(nodeIsOnline)
    }

    if (!helia) {
      initHelia();
    }
  }, [helia])

  

  const value = { helia, id, isOnline}

  return <HeliaContext.Provider value={value}>{children}</HeliaContext.Provider>

    // <div>
    //   <h4 data-test="id">ID: {id.toString()}</h4>
    //   <h4 data-test="status">Status: {isOnline ? 'Online' : 'Offline'}</h4>
    // </div>
}

// export default IpfsComponent