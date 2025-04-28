// Make sure to include ethers.js in your HTML file:
// <script src="https://cdn.jsdelivr.net/npm/ethers/dist/ethers.min.js"></script>

const contractAddress = " 0x91AeD384ff3528bc52a8667E955Ea2094212886f"; // Replace with your deployed contract address
const contractABI = [/* Paste ABI here */];

let provider;
let signer;
let contract;

window.addEventListener('load', async () => {
    if (typeof window.ethereum !== 'undefined') {
        provider = new ethers.providers.Web3Provider(window.ethereum);
        await provider.send("eth_requestAccounts", []);
        signer = provider.getSigner();
        contract = new ethers.Contract(contractAddress, contractABI, signer);
        console.log("Connected to Ethereum via MetaMask");
        loadAssets();
    } else {
        alert("Please install MetaMask!");
    }
});

async function loadAssets() {
    const assetsContainer = document.getElementById('assets');
    assetsContainer.innerHTML = "";

    try {
        const totalAssets = await contract.assetCount();
        for (let i = 0; i < totalAssets; i++) {
            const asset = await contract.getAsset(i);
            const isRented = await contract.isAssetRented(i);

            assetsContainer.innerHTML += `
                <div class="asset">
                    <h3>${asset[0]}</h3>
                    <p>Rent per day: ${ethers.utils.formatEther(asset[1])} ETH</p>
                    <p>Renter: ${asset[2]}</p>
                    <p>Rented Until: ${new Date(asset[3] * 1000).toLocaleString()}</p>
                    <p>Status: ${isRented ? "Rented" : "Available"}</p>
                    ${!isRented ? `<button onclick="rentAsset(${i})">Rent</button>` : ""}
                </div>
            `;
        }
    } catch (error) {
        console.error("Error loading assets:", error);
    }
}

async function rentAsset(assetId) {
    const days = prompt("Enter number of days to rent:");
    if (!days || isNaN(days)) return;

    try {
        const asset = await contract.getAsset(assetId);
        const rentPerDay = asset[1];
        const totalCost = ethers.BigNumber.from(rentPerDay).mul(days);

        const tx = await contract.rentAsset(assetId, days, { value: totalCost });
        await tx.wait();
        alert("Asset rented successfully!");
        loadAssets();
    } catch (err) {
        console.error("Renting failed:", err);
        alert("Renting failed. See console for details.");
    }
}





