const { Connection, Keypair, PublicKey } = require("@solana/web3.js");
const {
  postVaaSolana,
  createWrappedOnSolana,
} = require("@certusone/wormhole-sdk/lib/solana");

// Solana Testnet RPC 예시
const RPC_URL = "https://api.devnet.solana.com";
// 실제 Wormhole 프로그램 ID(테스트넷용)
// 공식 문서/디스코드에서 최신 주소를 확인하십시오.
const CORE_BRIDGE_ID = new PublicKey("3XJ2rsjfwFFQBFJuTo1kEyheSn6BRLw7owJ6JvTDq9ha");
const TOKEN_BRIDGE_ID = new PublicKey("8UnFdKnKvw4u78mAbw6bULz4yLeBe1iPQzUxnQxgvNvH");


async function main() {
  // 1) RPC 커넥션 생성
  const connection = new Connection(RPC_URL, "confirmed");

  // 2) 지갑 준비 (Keypair 예시)
  //    secrets/my-solana.json 등에서 읽어올 수 있음
  //    이 예시에서는 아무 값(32바이트)로 대체
  const secretKeyBytes = Uint8Array.from(
    JSON.parse(fs.readFileSync("secrets/my-wallet.json", "utf8"))
  );
  const payer = Keypair.fromSecretKey(secretKeyBytes);

  // 3) VAA 준비
  // VAA가 'hex' 또는 'base64'일 수 있음.
  // 'hex' 예시 (문자열 -> buffer)
  const vaaHex = "AQAAAAABAG3K2wGDv7Q7LgJzs5FrL1arGpRvjRZ2dFR2RLD44eiMbb2BEV6O4jbGeyzL1Hdf/AyiFnOxazR9JUKaJXHUuZYAZ/FVnAAAAAAnEgAAAAAAAAAAAAAAANtUkiZfYDiDHon0lWcP+Qmt6UvZAAAAAAAAEhQBAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD0JAAAAAAAAAAAAAAAAAe3mZXl95Oge8AMIUEuUOyuCY5/knEjbtJbPxdJbrQPVeIvxR/438JggoVtP8tjTOJDc+6AGJAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="
  const vaaBuffer = Buffer.from(vaaHex, "hex");

  // (A) Core Bridge에 VAA 등록
  await postVaaSolana(
    connection,
    async (transaction) => {
      // 트랜잭션에 서명
      transaction.partialSign(payer);
      return transaction;
    },
    CORE_BRIDGE_ID,
    payer.publicKey,
    vaaBuffer
  );
  console.log("VAA posted to Solana Core Bridge.");

  // (B) AttestMeta인 경우 -> createWrappedOnSolana로 래핑 토큰 생성
  // Transfer VAA라면 redeemOnSolana, completeTransferWrappedOnSolana 등 사용
  await createWrappedOnSolana(
    connection,
    async (transaction) => {
      transaction.partialSign(payer);
      return transaction;
    },
    CORE_BRIDGE_ID,
    TOKEN_BRIDGE_ID,
    payer.publicKey,
    vaaBuffer
  );
  console.log("Wrapped token minted on Solana.");
}

main()
  .then(() => {
    console.log("Done!");
  })
  .catch((err) => {
    console.error("Error:", err);
  });
