import ClientComponent from "@/components/ClientComponent"
import Link from "next/link"

export default function ServerComponent() {
  // ターミナルに表示
  console.log('Server');

  return (
    <div>
      Server
      <ClientComponent />
      <Link href="/about">About</Link>
    </div>
  );
}
