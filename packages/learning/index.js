const connectButton = document.getElementById("connectButton");
connectButton.onclick = connect;

async function connect() {
    if (typeof window.ethereum !== undefined) {
        await window.ethereum.request({ method: "eth_requestAccounts" })
    }
}