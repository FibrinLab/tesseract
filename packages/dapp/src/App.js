import './App.css';

import { useState, useEffect } from 'react';

function App() {

  const [web3, setWeb3] = useState(null);
  const [account, setAccount] = useState(null);
  const [contract, setContract] = useState(null);

  useEffect(() => {
    async function init() {

    }

    init();

  }, []);


  return (
    <div className="App">
      <h1>Data Manager</h1>
    </div>
  );
}

export default App;
