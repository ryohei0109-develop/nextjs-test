'use client'
import { useRouter } from "next/navigation"
import Link from "next/link"

export default function ClientComponent() {
  const router = useRouter();

  return (
    <div>
      Client<br />
      <Link href="/about">About1</Link><br />
      <button onClick={() => (router.push('/about'))}>About2</button>
    </div>
  );
}
